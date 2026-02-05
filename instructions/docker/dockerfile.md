# Dockerfile Security

## Non-Root User (CRITICAL)

```dockerfile
FROM python:3.12-alpine
WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy with proper ownership
COPY --chown=appuser:appgroup . .

# Switch to non-root
USER appuser

CMD ["python", "main.py"]
```

Verify: `docker run myapp whoami` must return non-root user.

## Minimal Base Images

| Priority | Image | Size | Use When |
|----------|-------|------|----------|
| 1 | gcr.io/distroless/python3-debian12 | ~20MB | Maximum security, no shell |
| 2 | python:3.12-alpine | ~50MB | General use, small footprint |
| 3 | python:3.12-slim | ~150MB | Alpine compatibility issues |
| Never | python:3.12 / ubuntu | ~900MB | Development only |

## Multi-Stage Builds

```dockerfile
# Build stage
FROM python:3.12-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Runtime stage - smaller
FROM python:3.12-alpine
COPY --from=builder /root/.local /root/.local
COPY . .
CMD ["python", "main.py"]
```

## No Secrets in Images

```dockerfile
# NEVER DO THIS
ENV DATABASE_PASSWORD=secret123
ARG API_KEY
ENV API_KEY=$API_KEY

# CORRECT: Runtime environment
# Pass at runtime: docker run -e DB_PASS=$DB_PASS myapp
# Or use Docker secrets (Swarm mode)

# For build-time secrets (npm, pip)
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc npm ci
```

## COPY vs ADD

```dockerfile
# Use COPY for local files
COPY . /app

# NEVER use ADD - it has unexpected behavior with URLs and tar extraction
```

## Layer Caching

```dockerfile
# Good: Copy requirements first (cacheable)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Then copy code (changes frequently)
COPY . .
```
