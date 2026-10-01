import json
import logging
import os
import time
import uuid
from datetime import datetime, timezone

import boto3


logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

QUEUE_URL = os.environ["EVENTS_QUEUE_URL"]
SERVICE_NAME = os.getenv("SERVICE_NAME", "kubernetes-event-producer")
EVENT_SEVERITY = os.getenv("EVENT_SEVERITY", "info")
EVENT_MESSAGE = os.getenv("EVENT_MESSAGE", "Kubernetes event producer heartbeat")
INTERVAL_SECONDS = int(os.getenv("INTERVAL_SECONDS", "60"))

sqs = boto3.client("sqs")


def build_event():
    return {
        "eventId": str(uuid.uuid4()),
        "service": SERVICE_NAME,
        "severity": EVENT_SEVERITY,
        "message": EVENT_MESSAGE,
        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }


def send_event():
    event = build_event()
    sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(event))
    logger.info("Sent event %s with severity %s", event["eventId"], event["severity"])


def main():
    while True:
        try:
            send_event()
        except Exception:
            logger.exception("Unable to send monitoring event")

        time.sleep(INTERVAL_SECONDS)


if __name__ == "__main__":
    main()
