# Stage 1: Build
FROM python:3.12-slim AS builder
WORKDIR /app

# Install dependencies and build wheels
COPY app/requirements.txt .
RUN pip install --upgrade pip && pip wheel --wheel-dir /wheels -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-slim
WORKDIR /app

# Copy wheels and install
COPY --from=builder /wheels /wheels
RUN pip install --no-index --find-links=/wheels -r requirements.txt

# Copy the application code
COPY app/ .

# Expose port 8080 for FastAPI
EXPOSE 8080

# Run the app
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
