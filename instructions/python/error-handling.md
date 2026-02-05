# Error Handling Patterns

## Philosophy

- **Exceptions for unrecoverable errors** (I/O failure, network down)
- **Return values for logic flow** (user not found, validation failed)

## Exceptions: When to Raise

| Scenario | Example |
|----------|---------|
| I/O failure | `FileNotFoundError`, `ConnectionError` |
| System errors | `PermissionError`, `OSError` |
| Programming errors | `ValueError`, `TypeError` |
| External service down | Custom exception class |

```python
def read_config(path: str) -> dict:
    """Read config file. Raise on I/O error."""
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError as e:
        logger.error(f"Config file not found: {path}")
        raise ConfigError(f"Missing config: {path}") from e
```

## Return Values: When to Return None/Union

| Scenario | Return Type |
|----------|-------------|
| User not found | `Optional[User]` |
| Validation failed | `Union[Result, ValidationError]` |
| Multiple outcomes | `Union[Success, NotFound, Error]` |
| Partial success | `Tuple[List[Success], List[Failure]]` |

```python
def find_user(user_id: str) -> Optional[User]:
    """Find user or return None. Not an error."""
    user = db.query(User).filter_by(id=user_id).first()
    return user  # Returns None if not found

# Caller handles both cases
user = find_user("123")
if user is None:
    print("User not found")
else:
    process_user(user)
```

## Custom Exceptions

```python
class BusinessError(Exception):
    """Base for business logic errors."""
    pass

class ValidationError(BusinessError):
    """Input validation failed."""
    def __init__(self, field: str, message: str):
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")
```

## Pattern: Result Type (Optional)

```python
from typing import Generic, TypeVar

T = TypeVar("T")
E = TypeVar("E")

class Result(Generic[T, E]):
    """Rust-style result type."""
    def __init__(self, value: Optional[T], error: Optional[E]):
        self._value = value
        self._error = error
    
    @property
    def is_ok(self) -> bool:
        return self._error is None
    
    def unwrap(self) -> T:
        if self._error:
            raise self._error
        return self._value

# Usage
def parse_int(s: str) -> Result[int, ValueError]:
    try:
        return Result(int(s), None)
    except ValueError as e:
        return Result(None, e)
```
