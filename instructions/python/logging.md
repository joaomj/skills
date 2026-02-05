# Logging Guidelines

## Core Principle

Use **structured logging** with traceability built-in. Every log entry must be machine-parseable and include context for debugging distributed systems.

## Structured Logging Format

All logs must be JSON with standard fields:

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "INFO",
  "message": "User login successful",
  "trace_id": "abc123-def456",
  "service": "auth-service",
  "function": "login_user",
  "user_id": "user_123",
  "duration_ms": 45
}
```

## Traceability Requirements

### Distributed Systems (Web APIs, Microservices)

Use **trace_id** that propagates across service boundaries:

```python
import uuid
from contextvars import ContextVar

# Context variable for trace ID propagation
trace_id_var: ContextVar[str] = ContextVar('trace_id')

def get_trace_id() -> str:
    """Get current trace ID or generate new one."""
    try:
        return trace_id_var.get()
    except LookupError:
        return str(uuid.uuid4())

def set_trace_id(trace_id: str | None = None) -> str:
    """Set trace ID in context."""
    tid = trace_id or str(uuid.uuid4())
    trace_id_var.set(tid)
    return tid

# FastAPI middleware example
@app.middleware("http")
async def add_trace_id(request: Request, call_next):
    # Extract from incoming request or generate new
    trace_id = request.headers.get("X-Trace-ID") or str(uuid.uuid4())
    set_trace_id(trace_id)
    
    response = await call_next(request)
    response.headers["X-Trace-ID"] = trace_id
    return response
```

### Batch/ML Systems

Use **run_id** for pipeline tracking:

```python
import mlflow
from datetime import datetime

# Generate unique run ID
run_id = f"training_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:8]}"

# Log with run_id context
logger.info(
    "Starting model training",
    extra={
        "run_id": run_id,
        "model_type": "random_forest",
        "dataset_version": "v2.1"
    }
)

# Use with MLflow
mlflow.set_tag("run_id", run_id)
```

## Logging Implementation

### Recommended: structlog

```python
import structlog

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ]
)

logger = structlog.get_logger()

# Usage
logger.info(
    "payment_processed",
    amount=100.00,
    currency="USD",
    trace_id=get_trace_id()
)
```

### Alternative: Standard Library

```python
import json
import logging

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
            "trace_id": getattr(record, "trace_id", None),
            "function": record.funcName,
            "line": record.lineno
        }
        return json.dumps(log_data)

# Setup
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger = logging.getLogger()
logger.addHandler(handler)

# Usage with context
logger.info("Processing request", extra={"trace_id": get_trace_id()})
```

## Security: Never Log Secrets

### Explicitly Forbidden

| Never Log | Example | Risk |
|-----------|---------|------|
| Passwords | `password=secret123` | Credential exposure |
| API Keys | `api_key=sk-abc123` | Unauthorized access |
| Tokens | `token=eyJhbG...` | Session hijacking |
| PII | `ssn=123-45-6789` | Privacy violation |
| Credit Cards | `card=4532...` | Financial fraud |

### Safe Logging Patterns

```python
# Bad - logs password
logger.info(f"User login: {username}, password: {password}")

# Good - logs success, never the secret
logger.info("User login successful", extra={"user_id": user.id})

# Bad - logs full request with API key
logger.info(f"API request: {response.text}")

# Good - logs only what you need
logger.info(
    "API call completed",
    extra={
        "endpoint": "/api/users",
        "status_code": response.status_code,
        "duration_ms": duration
    }
)
```

## Context Propagation

Pass trace context through async boundaries:

```python
import asyncio
from contextvars import copy_context

async def process_with_context(coro, trace_id: str):
    """Run coroutine with trace ID in context."""
    ctx = copy_context()
    ctx.run(set_trace_id, trace_id)
    return await ctx.run(asyncio.create_task, coro)
```

## Log Levels

| Level | Use For | Retention |
|-------|---------|-----------|
| DEBUG | Detailed debugging info | Short-term (7 days) |
| INFO | Normal operations | Medium-term (30 days) |
| WARNING | Recoverable issues | Long-term (90 days) |
| ERROR | Failed operations | Long-term (1 year) |
| CRITICAL | System failures | Permanent |

## Best Practices

1. **One log per operation** - Don't spam logs in loops
2. **Include duration** - Always log timing for I/O operations
3. **Log at boundaries** - Entry/exit of services, API calls, DB operations
4. **Use consistent keys** - Standardize field names across services
5. **Sample high-volume logs** - Use sampling for debug logs in production

## Checklist

- [ ] Structured JSON format used
- [ ] Trace ID or Run ID included
- [ ] No secrets in logs (use log sanitizers)
- [ ] Context propagates across async boundaries
- [ ] Appropriate log levels used
- [ ] Duration/timing included for operations
- [ ] Consistent field naming across codebase
