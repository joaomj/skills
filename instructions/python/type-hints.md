# Python Type Hints

## Requirements

Every function MUST have type hints for:
- All arguments
- Return values

## Basic Syntax

```python
from typing import Optional, Union, List, Dict

def process_data(
    data: List[Dict[str, int]],
    threshold: float = 0.5
) -> Optional[Dict[str, str]]:
    """Process data and return results or None."""
    ...
```

## Common Patterns

| Pattern | Use For | Example |
|---------|---------|---------|
| `Optional[T]` | May return None | `Optional[str]` |
| `Union[A, B]` | Multiple types | `Union[int, str]` |
| `List[T]` | Homogeneous lists | `List[int]` |
| `Dict[K, V]` | Key-value mappings | `Dict[str, int]` |
| `Callable[[A], B]` | Function types | `Callable[[int], str]` |

## Modern Python (3.10+)

Use new syntax instead of typing imports:

```python
# Old (still valid)
from typing import List, Dict, Optional
List[int] → list[int]
Dict[str, int] → dict[str, int]
Optional[str] → str | None
Union[int, str] → int | str
```

## Return Types

| Scenario | Return Type |
|----------|-------------|
| Single item or None | `Optional[T]` or `T \| None` |
| Multiple valid types | `Union[A, B]` or `A \| B` |
| Error handling | `Union[T, ErrorType]` or raise exception |
| Generator | `Iterator[T]` or `Generator[T, None, None]` |

## Class Methods

```python
class UserService:
    def find_user(self, user_id: str) -> Optional[User]:
        """Find user by ID or return None."""
        ...
    
    @classmethod
    def create(cls, name: str) -> "UserService":
        """Factory method."""
        ...
```
