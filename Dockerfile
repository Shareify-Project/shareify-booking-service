# Stage 1: Build
FROM python:3.10-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Final Run
FROM python:3.10-slim
WORKDIR /app

# Create non-root user with FIXED UID 1000
RUN groupadd -g 1000 shareify && useradd -u 1000 -g 1000 -m -s /bin/bash shareify
RUN mkdir -p /app/data && chown -R shareify:shareify /app

# Copy dependencies from builder
COPY --from=builder /root/.local /home/shareify/.local
COPY . .

ENV PATH=/home/shareify/.local/bin:$PATH
USER shareify

EXPOSE 80
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
