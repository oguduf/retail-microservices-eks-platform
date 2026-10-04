FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --only-binary=:all: -r requirements.txt

COPY app.py .

RUN useradd --create-home --uid 10001 appuser
RUN mkdir -p /run/event-producer && chown appuser:appuser /run/event-producer
USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD ["python", "-c", "import os,sys,time; p='/run/event-producer/health'; sys.exit(0 if os.path.exists(p) and time.time()-os.path.getmtime(p)<120 else 1)"]

CMD ["python", "app.py"]
