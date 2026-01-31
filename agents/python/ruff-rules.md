# Ruff Rules Reference

## Key Rules

| Code | Name | What It Checks |
|------|------|----------------|
| E, W | pycodestyle | PEP 8 style errors |
| F | Pyflakes | Undefined variables, unused imports |
| I | isort | Import sorting |
| B | flake8-bugbear | Common bugs and anti-patterns |
| C4 | flake8-comprehensions | List/dict comprehension improvements |
| UP | pyupgrade | Modern Python syntax |
| ARG | unused-arguments | Unused function arguments |
| SIM | flake8-simplify | Code simplification opportunities |
| PTH | flake8-use-pathlib | Use pathlib over os.path |
| ERA | eradicate | Commented-out code |
| PL | Pylint subset | Code quality checks |
| RUF | Ruff-specific | Ruff-specific rules |
| S | bandit | Security vulnerabilities |
| NPY | NumPy | NumPy-specific best practices |

## Complexity Limits

| Rule | Limit | What It Means |
|------|-------|---------------|
| `max-complexity` | 15 | Cyclomatic complexity per function |
| `max-args` | 7 | Number of function arguments |
| `max-statements` | 50 | Lines/statements per function |
| `line-length` | 100 | Characters per line |

## Common Issues

```python
# B006: Mutable default argument (BUG)
def bad(items=[]):  # ❌ Mutable default
    items.append(1)

def good(items=None):  # ✅ Safe
    if items is None:
        items = []
    items.append(1)

# UP007: Use modern Union syntax (PYTHON UPGRADE)
def old(x: Union[int, str]) -> None:  # ❌ Old style
    pass

def new(x: int | str) -> None:  # ✅ Modern
    pass

# PTH: Use pathlib (PATHLIB)
import os
os.path.join("a", "b")  # ❌ os.path

from pathlib import Path
Path("a") / "b"  # ✅ pathlib

# S: Bandit security (SECURITY)
password = "secret123"  # ❌ Hardcoded secret
cmd = f"ls {user_input}"  # ❌ Command injection risk
```

## Fixing Issues

```bash
# Check only
ruff check .

# Auto-fix safe issues
ruff check . --fix

# Check specific rules
ruff check . --select E,W,F,B,S
```
