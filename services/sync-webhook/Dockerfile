FROM python:3.11-slim

# Install rsync
RUN apt-get update && \
    apt-get install -y --no-install-recommends rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py .
COPY gunicorn.conf.py .
COPY templates/ templates/
COPY static/ static/

# Create non-root user and required directories
RUN useradd -m -u 1000 syncuser && \
    mkdir -p /data /logs && \
    chown -R syncuser:syncuser /data /logs

USER syncuser

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Run with gunicorn. Config in gunicorn.conf.py — same bind/workers/threads/timeout
# as before, plus worker_exit/on_exit hooks that kill in-progress rsync process
# groups on shutdown (prevents orphaned D-state rsyncs from wedging container
# teardown) and a bounded graceful_timeout.
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:app"]
