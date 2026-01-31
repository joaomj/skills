# Docker Compose Templates

## Basic Secure Compose

```yaml
version: '3.8'

services:
  app:
    image: myapp:latest
    read_only: true
    tmpfs:
      - /tmp
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
    environment:
      - DATABASE_URL=${DATABASE_URL}  # From .env
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true

volumes:
  postgres_data:
```

## Production-Ready Template

```yaml
version: '3.8'

services:
  frontend:
    image: frontend:latest
    read_only: true
    tmpfs:
      - /tmp
      - /var/cache/nginx
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    security_opt:
      - no-new-privileges:true
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    networks:
      - frontend-net

  backend:
    image: backend:latest
    read_only: true
    tmpfs:
      - /tmp
      - /app/tmp
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
    environment:
      - DB_HOST=db
      - REDIS_HOST=redis
    networks:
      - frontend-net
      - backend-net
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    secrets:
      - db_password
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    networks:
      - backend-net

  redis:
    image: redis:7-alpine
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    networks:
      - backend-net

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  db_data:

networks:
  frontend-net:
  backend-net:
```

## Environment Variables

```yaml
# Use .env file (not committed to git)
env_file:
  - .env.production

# Or individual vars from host
environment:
  - API_KEY=${API_KEY}
  - DEBUG=false
```

## Health Checks

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```
