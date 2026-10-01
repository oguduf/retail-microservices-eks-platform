import json
import logging
import os
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError


logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.client("dynamodb")
s3 = boto3.client("s3")
sns = boto3.client("sns")

EVENTS_TABLE_NAME = os.environ["EVENTS_TABLE_NAME"]
EVENT_ARCHIVE_BUCKET = os.environ["EVENT_ARCHIVE_BUCKET"]
CRITICAL_EVENTS_TOPIC_ARN = os.environ["CRITICAL_EVENTS_TOPIC_ARN"]

REQUIRED_FIELDS = {"eventId", "service", "severity", "message", "timestamp"}


def handler(event, context):
    failures = []

    for record in event["Records"]:
        try:
            process_record(record)
        except Exception:
            logger.exception("Unable to process message %s", record["messageId"])
            failures.append({"itemIdentifier": record["messageId"]})

    return {"batchItemFailures": failures}


def process_record(record):
    monitoring_event = json.loads(record["body"])
    missing_fields = REQUIRED_FIELDS.difference(monitoring_event)

    if missing_fields:
        raise ValueError(f"Missing required event fields: {sorted(missing_fields)}")

    event_id = monitoring_event["eventId"]
    archive_event(monitoring_event)

    if not save_event(monitoring_event):
        logger.info("Event %s was already processed", event_id)
        return

    if monitoring_event["severity"].lower() == "critical":
        publish_critical_event(monitoring_event)

    logger.info("Processed monitoring event %s", event_id)


def archive_event(monitoring_event):
    event_time = datetime.fromisoformat(monitoring_event["timestamp"].replace("Z", "+00:00"))
    object_key = f"events/{event_time:%Y/%m/%d}/{monitoring_event['eventId']}.json"

    s3.put_object(
        Bucket=EVENT_ARCHIVE_BUCKET,
        Key=object_key,
        Body=json.dumps(monitoring_event).encode("utf-8"),
        ContentType="application/json",
        ServerSideEncryption="AES256",
    )


def save_event(monitoring_event):
    try:
        dynamodb.put_item(
            TableName=EVENTS_TABLE_NAME,
            Item={
                "eventId": {"S": monitoring_event["eventId"]},
                "service": {"S": monitoring_event["service"]},
                "severity": {"S": monitoring_event["severity"]},
                "message": {"S": monitoring_event["message"]},
                "timestamp": {"S": monitoring_event["timestamp"]},
                "processedAt": {"S": datetime.now(timezone.utc).isoformat()},
            },
            ConditionExpression="attribute_not_exists(eventId)",
        )
        return True
    except ClientError as error:
        if error.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return False
        raise


def publish_critical_event(monitoring_event):
    sns.publish(
        TopicArn=CRITICAL_EVENTS_TOPIC_ARN,
        Subject=f"Critical monitoring event: {monitoring_event['service']}",
        Message=json.dumps(monitoring_event, indent=2),
    )
