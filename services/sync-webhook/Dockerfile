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

# Run with gunicorn for production
# Using 1 worker to avoid multiple schedulers (rsync runs in background threads anyway)
# Timeout set to 3600 (1 hour) to handle large file syncs
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--threads", "4", "--timeout", "3600", "app:app"]
