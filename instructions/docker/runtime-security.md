# Docker Runtime Security

## Required Flags

```bash
docker run \
  --read-only \
  --tmpfs /tmp \
  --cap-drop=ALL \
  --security-opt=no-new-privileges:true \
  --memory=512m \
  --memory-swap=512m \
  --cpus=1 \
  myapp
```

## Flag Explanations

| Flag | Purpose |
|------|---------|
| `--read-only` | Immutable filesystem (prevents malware drops) |
| `--tmpfs /tmp` | Writable temp directory (in-memory, ephemeral) |
| `--cap-drop=ALL` | Remove all Linux capabilities |
| `--security-opt=no-new-privileges:true` | Prevent privilege escalation |
| `--memory` | Prevent memory exhaustion (DoS protection) |
| `--cpus` | Prevent CPU hogging (mining protection) |

## Docker Compose Template

```yaml
services:
  app:
    image: myapp:latest
    read_only: true
    tmpfs:
      - /tmp
      - /app/cache
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if needed
    security_opt:
      - no-new-privileges:true
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
    user: "1000:1000"  # Non-root UID:GID
```

## NEVER Use

```bash
# NEVER - disables all container isolation
docker run --privileged myapp

# NEVER - gives full root access
docker run --user root myapp

# NEVER - removes security profiles
docker run --security-opt seccomp=unconfined myapp
```

## Privileged Operations

If your app NEEDS capabilities, add only what's required:

```bash
# Common capabilities to add back
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp  # Bind to ports <1024
docker run --cap-drop=ALL --cap-add=CHOWN myapp  # Change file ownership
```

## Read-Only with Writable Paths

Most apps need some writable areas:

```bash
# Multiple tmpfs mounts for different purposes
docker run \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,size=100m \
  --tmpfs /app/cache:noexec,nosuid,size=50m \
  --tmpfs /app/logs:noexec,nosuid,size=10m \
  myapp
```

## Resource Limit Formulas

```
memory: 2x expected peak usage
memory-swap: equal to memory (prevents swap)
cpus: 1.0 per container (scale horizontally)
```
