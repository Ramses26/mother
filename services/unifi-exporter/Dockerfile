FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends iputils-ping \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 9110
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:9110/health')" || exit 1
CMD ["python", "app.py"]
