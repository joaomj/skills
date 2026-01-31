# Pydantic V2 Patterns

## Requirements

Use Pydantic V2 for ALL:
- Data structures
- API schemas
- Configuration
- Validation

NEVER use raw dicts for complex data.

## Basic Model

```python
from pydantic import BaseModel, Field, ConfigDict

class User(BaseModel):
    model_config = ConfigDict(strict=True)
    
    id: int
    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    age: int = Field(..., ge=0, le=150)
```

## Field Types

| Type | Use For | Validation |
|------|---------|------------|
| `EmailStr` | Email addresses | Valid email format |
| `HttpUrl` | URLs | Valid URL format |
| `constr()` | Constrained strings | Length, regex patterns |
| `conint()` | Constrained integers | Min/max bounds |
| `condecimal()` | Money values | Precision constraints |

## Nested Models

```python
class Address(BaseModel):
    street: str
    city: str
    zip: str

class User(BaseModel):
    name: str
    addresses: List[Address]  # Nested validation
```

## Error Handling

```python
try:
    user = User(**data)
except ValidationError as e:
    # e.errors() gives detailed breakdown
    for error in e.errors():
        print(f"{error['loc']}: {error['msg']}")
```

## Environment Config

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    api_key: SecretStr  # Masked in logs
    debug: bool = False
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8"
    )

settings = Settings()  # Auto-loads from .env
```

## Performance Tips

1. Use `model_validator` for cross-field validation
2. Use `field_validator` for field-specific logic
3. Cache model instances with `@lru_cache` for configs
