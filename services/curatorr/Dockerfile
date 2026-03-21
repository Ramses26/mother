# Stage 1: Build Vue 3 frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /frontend
COPY services/curatorr/frontend/package*.json ./
RUN npm ci
COPY services/curatorr/frontend/ .
RUN npm run build

# Stage 2: Python FastAPI runtime
FROM python:3.11-slim
WORKDIR /app
COPY services/curatorr/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY services/curatorr/app/ ./app/
COPY --from=frontend-builder /frontend/dist ./app/static/
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
