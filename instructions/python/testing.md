# Testing Guidelines

## Core Philosophy

**Test behavior, not implementation.** Tests should verify what the code does, not how it does it.

## What to Test

### Always Test

- Business logic and domain rules
- API contracts and data validation
- Integration points (external services)
- Error handling paths
- Critical user workflows

### Never Test

| Don't Test | Why | Example |
|------------|-----|---------|
| Framework code | Tested by framework | FastAPI route decorators, Django ORM |
| Language features | Tested by Python | `len()`, `dict.get()`, list slicing |
| Trivial getters/setters | Adds no value | `@property def name(self): return self._name` |
| Private methods | Tests public interface | `_validate_internal()` - test via public `validate()` |
| Third-party libraries | Tested by maintainers | `requests.get()`, `pandas.read_csv()` |

## Test Pyramid

Maintain the 70/20/10 ratio:

```
    /\
   /  \     E2E Tests (10%) - Critical user journeys
  /____\    
 /      \   Integration Tests (20%) - Service interactions
/________\  
___________ Unit Tests (70%) - Business logic
```

### Unit Tests (70%)

- Single function/class in isolation
- Fast (< 10ms each)
- No I/O (DB, HTTP, filesystem)
- Test edge cases and boundary conditions

```python
def test_calculate_discount():
    # Arrange
    customer = Customer(tier="gold", purchase_count=10)
    
    # Act
    discount = calculate_discount(customer, amount=100)
    
    # Assert - behavior, not implementation
    assert discount == 15  # 15% off for gold tier
```

### Integration Tests (20%)

- Test component interactions
- Use test databases/containers
- Verify data flows correctly
- One external service per test

```python
async def test_user_registration_flow():
    # Test the full flow through API -> Service -> DB
    response = await client.post("/api/users", json={
        "email": "test@example.com",
        "password": "secure123"
    })
    
    assert response.status_code == 201
    
    # Verify in database
    user = await db.users.find_one({"email": "test@example.com"})
    assert user is not None
    assert user["email_verified"] is False
```

### E2E Tests (10%)

- Critical user journeys only
- Full system through UI/API
- Selenium/Playwright for frontend
- Expensive, run in CI/CD pipeline

## Mock Usage: Strict Rules

### When to Mock (Limited Cases)

1. **External HTTP APIs** - Don't hit real services
2. **Database writes** in unit tests - Use fakes, not mocks
3. **File system** - Use tmp_path fixture
4. **Time** - freeze_time for deterministic tests

```python
# Good: Mock external API
@patch("requests.get")
def test_weather_service(mock_get):
    mock_get.return_value.json.return_value = {"temp": 72}
    service = WeatherService()
    assert service.get_temp("NYC") == 72
```

### When NOT to Mock (Mock Abuse)

```python
# Bad: Mocking internal logic
@patch("mymodule.calculate_discount")
def test_apply_discount(mock_calc):  # ❌ Testing mock, not code
    mock_calc.return_value = 10
    result = apply_discount(customer, 100)
    assert result == 90

# Good: Test the real logic
def test_apply_discount():
    customer = Customer(tier="gold")
    result = apply_discount(customer, 100)
    assert result == 85  # Tests real calculation
```

**Rule:** If you're mocking your own code, you're testing the mock, not the code.

## Test Structure: AAA Pattern

Every test follows Arrange-Act-Assert:

```python
def test_process_payment():
    # Arrange - setup state
    payment = Payment(amount=100, currency="USD")
    processor = PaymentProcessor()
    
    # Act - execute the behavior
    result = processor.process(payment)
    
    # Assert - verify outcomes
    assert result.status == PaymentStatus.COMPLETED
    assert result.transaction_id is not None
```

## Test Naming

Tests should read like sentences:

```python
# Bad
def test1():
    ...

def test_payment():
    ...

# Good
def test_payment_processor_declines_insufficient_funds():
    ...

def test_payment_processor_returns_transaction_id_on_success():
    ...
```

## Fixtures over Setup/Teardown

Use pytest fixtures for reusable setup:

```python
@pytest.fixture
def test_customer():
    return Customer(
        id="cust_123",
        email="test@example.com",
        tier="gold"
    )

@pytest.fixture
def mock_payment_gateway():
    return Mock(spec=PaymentGateway)

def test_process_with_valid_customer(test_customer, mock_payment_gateway):
    processor = PaymentProcessor(mock_payment_gateway)
    result = processor.process(test_customer, amount=100)
    assert result.success is True
```

## Testing Error Handling

Test both happy path and error cases:

```python
def test_withdraw_insufficient_funds():
    account = Account(balance=50)
    
    with pytest.raises(InsufficientFundsError) as exc_info:
        account.withdraw(100)
    
    assert exc_info.value.requested == 100
    assert exc_info.value.available == 50
    assert account.balance == 50  # No change
```

## Test Data Builders

Use factory pattern for test data:

```python
class CustomerBuilder:
    def __init__(self):
        self._data = {
            "email": "test@example.com",
            "tier": "standard"
        }
    
    def with_tier(self, tier: str) -> "CustomerBuilder":
        self._data["tier"] = tier
        return self
    
    def build(self) -> Customer:
        return Customer(**self._data)

# Usage
customer = CustomerBuilder().with_tier("gold").build()
```

## When NOT to Write a Test

Before writing any test, ask:

1. **Is this logic trivial?** (simple assignments, data class)
   - → Don't test

2. **Is this tested elsewhere?** (covered by integration test)
   - → Don't duplicate

3. **Is this framework/library code?**
   - → Don't test

4. **Would this test fail if implementation changes?**
   - → Refactor to test behavior, not implementation

5. **Is this test just checking mocks?**
   - → Delete or rewrite to test real logic

## Test Metrics

Target these metrics:

| Metric | Target | Why |
|--------|--------|-----|
| Line coverage | > 80% | Catches untested critical paths |
| Branch coverage | > 70% | Catches untested error paths |
| Test duration | < 30s total | Fast feedback loop |
| Test count | Quality > Quantity | 50 good tests > 200 bad tests |

## Checklist

- [ ] Testing behavior, not implementation
- [ ] No mocks of internal code (only external I/O)
- [ ] Following 70/20/10 pyramid
- [ ] AAA pattern in every test
- [ ] Test names read like sentences
- [ ] Using fixtures for setup
- [ ] Error cases tested
- [ ] Not testing framework/library code
- [ ] Not testing trivial getters/setters
