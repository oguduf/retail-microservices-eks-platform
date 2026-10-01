import json
import os

import boto3


dynamodb = boto3.client("dynamodb")
EVENTS_TABLE_NAME = os.environ["EVENTS_TABLE_NAME"]


def handler(event, context):
    event_id = (event.get("pathParameters") or {}).get("eventId")

    if event_id:
        return get_event(event_id)

    return list_events()


def get_event(event_id):
    response = dynamodb.get_item(
        TableName=EVENTS_TABLE_NAME,
        Key={"eventId": {"S": event_id}},
    )

    if "Item" not in response:
        return response_json(404, {"message": "Event not found"})

    return response_json(200, deserialize_item(response["Item"]))


def list_events():
    response = dynamodb.scan(TableName=EVENTS_TABLE_NAME, Limit=50)
    events = [deserialize_item(item) for item in response.get("Items", [])]
    events.sort(key=lambda item: item["timestamp"], reverse=True)

    return response_json(200, {"items": events})


def deserialize_item(item):
    return {key: next(iter(value.values())) for key, value in item.items()}


def response_json(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body),
    }
