FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install deps
COPY services/upgraderr/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY services/upgraderr/app.py app.py
COPY services/upgraderr/templates/ templates/
COPY services/upgraderr/static/ static/

# Copy shared quality scoring library
COPY scripts/lib/__init__.py lib/__init__.py
COPY scripts/lib/quality_scoring.py lib/quality_scoring.py

RUN useradd -m -u 1000 upgraderruser && \
    mkdir -p /data && \
    chown -R upgraderruser:upgraderruser /data

USER upgraderruser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--threads", "4", "--timeout", "120", "app:app"]
