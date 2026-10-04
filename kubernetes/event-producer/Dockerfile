FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN useradd --create-home --uid 10001 appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD ["python", "-c", "import os,sys,time; p='/tmp/event-producer-health'; sys.exit(0 if os.path.exists(p) and time.time()-os.path.getmtime(p)<120 else 1)"]

CMD ["python", "app.py"]
