# Docker Network Isolation

## Principle

Segment containers by trust level. Frontend should NOT reach database directly.

## Three-Tier Architecture

```yaml
services:
  frontend:
    image: nginx:alpine
    networks:
      - frontend-net

  backend:
    image: myapp:latest
    networks:
      - frontend-net
      - backend-net

  database:
    image: postgres:15-alpine
    networks:
      - backend-net

networks:
  frontend-net:
  backend-net:
```

## Network Flow

```
Internet → frontend (frontend-net) → backend (frontend+backend-net) → database (backend-net)
```

If frontend is compromised, attacker cannot reach database directly.

## Complete Isolation

```yaml
services:
  isolated-app:
    image: myapp
    networks:
      - isolated-net

networks:
  isolated-net:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.enable_icc: "false"  # No inter-container communication
```

## Disable Inter-Container Communication

```bash
# Create network with ICC disabled
docker network create \
  --driver bridge \
  -o com.docker.network.bridge.enable_icc=false \
  isolated-net

# Containers on this network can only reach external hosts
```

## Port Exposure Best Practices

```yaml
services:
  # GOOD: Expose only what needed
  frontend:
    ports:
      - "80:80"
      - "443:443"
    networks:
      - frontend-net

  # GOOD: Internal services, no public ports
  backend:
    # No ports exposed - only reachable via networks
    networks:
      - frontend-net
      - backend-net

  # GOOD: Database completely internal
  db:
    networks:
      - backend-net
```

## External Networks

```yaml
services:
  app:
    networks:
      - traefik-public  # Shared reverse proxy network
      - internal-net

networks:
  traefik-public:
    external: true
  internal-net:
    internal: true  # No external access
```

## DNS and Discovery

```yaml
services:
  web:
    networks:
      - mynet
    # Accessible as: http://web/ from other containers on mynet

  worker:
    networks:
      - mynet
    # Can reach web via: http://web:3000/
```
