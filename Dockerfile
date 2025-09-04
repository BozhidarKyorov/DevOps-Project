# Stage 1: Builder
FROM python:3.12-slim AS builder
WORKDIR /app

# Copy dependencies and build wheels
COPY app/requirements.txt .
RUN pip install --upgrade pip && pip wheel --wheel-dir /wheels -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-slim
WORKDIR /app

# Copy wheels from builder stage
COPY --from=builder /wheels /wheels

# Copy requirements.txt
COPY app/requirements.txt .

# Install dependencies from wheels
RUN pip install --no-index --find-links=/wheels -r requirements.txt db-requirements.txt

# Copy application code
COPY app/ .

# Expose port
EXPOSE 8080

# Command to run the app
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
