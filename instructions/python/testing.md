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

## Testing Concurrency & Race Conditions

### Why It Matters

Concurrency bugs are notoriously difficult to reproduce but critical to catch. Tests that run once and pass won't catch race conditions.

### Testing Strategies

#### 1. Threaded Tests with pytest

```python
import threading
import pytest

def test_counter_thread_safety():
    counter = ThreadSafeCounter()
    threads = []
    increments = 1000

    def increment():
        for _ in range(increments):
            counter.increment()

    # Create multiple threads
    for _ in range(10):
        thread = threading.Thread(target=increment)
        threads.append(thread)
        thread.start()

    # Wait for all threads to complete
    for thread in threads:
        thread.join()

    # Verify no race condition: 10 threads * 1000 increments
    assert counter.value == 10000
```

#### 2. Async Tests with pytest-asyncio

```python
import pytest
from asyncio import gather

@pytest.mark.asyncio
async def test_async_resource_race_condition():
    manager = AsyncResourceManager(max_concurrent=3)
    tasks = [manager.acquire("resource-1") for _ in range(5)]
    
    # Should only acquire 3, 2 should fail or wait
    results = await gather(*tasks, return_exceptions=True)
    
    successful = sum(1 for r in results if not isinstance(r, Exception))
    assert successful == 3
```

#### 3. Timing Tests with freeze_time

```python
from freezegun import freeze_time

def test_cache_expiration_race():
    cache = Cache(ttl_seconds=5)
    
    with freeze_time("2024-01-01 12:00:00"):
        cache.set("key", "value")
        assert cache.get("key") == "value"
    
    with freeze_time("2024-01-01 12:00:06"):
        assert cache.get("key") is None
```

#### 4. Deterministic Race Conditions with pytest-xdist

```python
# Run this test 100 times in parallel to catch race conditions
@pytest.mark.parametrize("iteration", range(100))
def test_concurrent_updates(iteration):
    shared = SharedState()
    
    def update():
        shared.increment()
    
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(update) for _ in range(100)]
        for future in futures:
            future.result()
    
    # Verify final state is consistent
    assert shared.value == 100
```

### Common Race Condition Patterns

| Pattern | How to Test |
|---------|-------------|
| **Shared state without locks** | Multiple threads modify same variable, verify final state |
| **Cache invalidation** | Write after read expired cache, verify data consistency |
| **Resource pooling** | Acquire more than pool size, verify proper queuing/rejection |
| **Async callbacks** | Complete async operations in random order, verify no state corruption |
| **Database transactions** | Concurrent updates to same row, verify isolation level |

### Anti-Pattern: Non-Deterministic Tests

```python
# Bad: Sleep-based timing - fragile and unreliable
def test_race_condition():
    obj = SomeClass()
    Thread(target=obj.update).start()
    time.sleep(0.1)  # Hope it's enough time ❌
    assert obj.ready

# Good: Use events to synchronize
def test_race_condition():
    obj = SomeClass()
    thread = Thread(target=obj.update)
    thread.start()
    thread.join(timeout=5.0)  # Wait with timeout ✅
    assert obj.ready
```

## Integration vs Unit Test Decision Framework

### Decision Matrix

| Scenario | Write Integration Test | Write Mocked Unit Test | Rationale |
|----------|----------------------|------------------------|-----------|
| Business logic with no I/O | ❌ | ✅ | Pure functions, fast, deterministic |
| Database queries | ✅ | ❌ | Real SQL, catches schema issues, query optimization |
| External API (payment gateway) | ✅ | ❌ | Use test sandbox, don't mock third-party |
| File system operations | ✅ | ❌ | Use tmp_path, catches permission issues |
| Email sending | ✅ | ❌ | Use test mail server, validates templates |
| Cache layer | ✅ | ❌ | Test cache hit/miss, serialization |
| Message queue | ✅ | ❌ | Use test broker, validates message format |
| Algorithm (sorting, compression) | ❌ | ✅ | Pure logic, property-based testing |
| Data validation rules | ✅ | ❌ | Test with real Pydantic models |
| Authentication middleware | ✅ | ❌ | Test with real tokens, headers |
| Error handling paths | ✅ | ❌ | Real error scenarios, not mocked |

### When Integration Tests Are Better

```python
# Good Integration Test: Real database, real validation
@pytest.mark.integration
def test_user_creation_with_real_db():
    response = client.post("/users", json={
        "email": "test@example.com",
        "password": "secure123"
    })
    
    assert response.status_code == 201
    
    # Verify in actual database
    user = db.users.find_one({"email": "test@example.com"})
    assert user["password_hash"] is not None
    assert bcrypt.check("secure123", user["password_hash"])

# Bad Mocked Unit Test: Fake database, fake validation
@patch("app.db.users.insert_one")
@patch("bcrypt.hashpw")
def test_user_creation_with_mocks(mock_hash, mock_insert):
    mock_hash.return_value = "hashed"
    mock_insert.return_value.inserted_id = "123"
    
    # This test never catches real DB errors ❌
    result = create_user("test@example.com", "secure123")
    assert result == "123"
```

### Integration Test Setup

```python
@pytest.fixture(scope="function")
async def test_db():
    # Use test database, not mock
    async with AsyncClient(app=app) as client:
        async with test_db_connection() as db:
            # Clear before test
            await db.users.delete_many({})
            yield db
            # Clean up after test
            await db.users.delete_many({})

@pytest.mark.integration
async def test_full_user_flow(test_db, client):
    # Test real flow: API → Service → DB → Cache
    response = await client.post("/register", json={
        "email": "user@example.com",
        "password": "Password123!"
    })
    
    assert response.status_code == 201
    
    # Verify in database
    user = await test_db.users.find_one({"email": "user@example.com"})
    assert user is not None
```

### Rules of Thumb

1. **If it touches the network, write an integration test**
2. **If it has a schema, test with real data**
3. **If it involves serialization, test round-trip**
4. **If it uses third-party services, use their test environments**
5. **Mock only when absolutely necessary (costly, rate-limited, unavailable)**

## Before/After Test Examples

### Example 1: Testing a Payment Service

#### Before: Useless Test (Always Passes)

```python
# ❌ This test verifies mocks work, not the actual code
@patch("stripe.Charge.create")
@patch("app.db.payments.insert_one")
def test_process_payment_success(mock_db, mock_stripe):
    mock_stripe.return_value.id = "ch_123"
    mock_db.return_value.inserted_id = "pay_456"
    
    service = PaymentService()
    result = service.process_payment(
        amount=100,
        currency="usd",
        token="tok_visa"
    )
    
    # Testing that our mocks work, not the logic
    assert mock_stripe.called
    assert mock_db.called
    assert result == "pay_456"
```

#### After: Useful Test (Finds Real Issues)

```python
# ✅ This test catches actual bugs
def test_process_payment_declines_insufficient_funds():
    # Use Stripe test card that declines
    service = PaymentService()
    
    with pytest.raises(PaymentDeclinedError) as exc_info:
        service.process_payment(
            amount=2000,  # Stripe test card limit
            currency="usd",
            token="tok_visa"  # Real Stripe test token
        )
    
    assert exc_info.value.code == "card_declined"
    assert exc_info.value.type == "insufficient_funds"

def test_process_payment_idempotency():
    service = PaymentService()
    
    # Process same payment twice
    result1 = service.process_payment(100, "usd", "tok_visa", idempotency_key="key1")
    result2 = service.process_payment(100, "usd", "tok_visa", idempotency_key="key1")
    
    # Should return same charge, not create two
    assert result1.charge_id == result2.charge_id
    assert result1.charge_id.startswith("ch_")
```

### Example 2: Testing a Data Pipeline

#### Before: Mock Heavy (Always Passes)

```python
# ❌ Tests mocks, not the pipeline
@patch("pandas.read_csv")
@patch("pandas.DataFrame.to_sql")
def test_data_pipeline_success(mock_to_sql, mock_read):
    mock_read.return_value = pd.DataFrame({"col": [1, 2, 3]})
    
    pipeline = DataPipeline()
    pipeline.run("input.csv", "output_table")
    
    # Only verifies mock was called
    assert mock_read.called
    assert mock_to_sql.called
```

#### After: Integration Test (Catches Issues)

```python
# ✅ Tests real data flow
def test_data_pipeline_handles_duplicates():
    pipeline = DataPipeline()
    
    # Create test CSV with duplicates
    test_data = pd.DataFrame({
        "id": [1, 2, 1, 3, 2],
        "value": ["a", "b", "a", "c", "b"]
    })
    test_data.to_csv("test_input.csv", index=False)
    
    pipeline.run("test_input.csv", "test_output", deduplicate=True)
    
    # Verify duplicates removed
    result = pd.read_sql("SELECT * FROM test_output", con=test_db)
    assert len(result) == 3  # Only unique IDs
    assert sorted(result["id"].tolist()) == [1, 2, 3]
    
    os.remove("test_input.csv")
```

### Example 3: Testing Concurrency

#### Before: No Concurrency Test (Misses Race Conditions)

```python
# ❌ Single-threaded test, never catches race conditions
def test_counter_increment():
    counter = Counter()
    counter.increment()
    counter.increment()
    assert counter.value == 2
```

#### After: Concurrency Test (Catches Race Conditions)

```python
# ✅ Multi-threaded test catches race conditions
def test_counter_thread_safety():
    counter = Counter()
    threads = []
    
    def increment_100_times():
        for _ in range(100):
            counter.increment()
    
    # Create 10 threads
    for _ in range(10):
        thread = threading.Thread(target=increment_100_times)
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()
    
    # Should be 1000, will fail if not thread-safe
    assert counter.value == 1000
```

## Property-Based Testing

### What Is Property-Based Testing?

Traditional tests verify specific examples. Property-based testing generates thousands of random inputs to verify invariants hold true.

### Using Hypothesis

```python
from hypothesis import given, strategies as st

# Traditional test: specific case
def test_add_positive():
    assert add(2, 3) == 5

# Property-based test: thousands of random cases
@given(a=st.integers(), b=st.integers())
def test_add_commutative(a, b):
    # Property: a + b == b + a for all integers
    assert add(a, b) == add(b, a)

@given(a=st.integers(), b=st.integers(), c=st.integers())
def test_add_associative(a, b, c):
    # Property: (a + b) + c == a + (b + c)
    assert add(add(a, b), c) == add(a, add(b, c))
```

### Real-World Examples

#### 1. List Sorting

```python
@given(lst=st.lists(st.integers()))
def test_sort_preserves_elements(lst):
    sorted_lst = sorted(lst)
    
    # Property 1: Same elements
    assert Counter(sorted_lst) == Counter(lst)
    
    # Property 2: Sorted in non-decreasing order
    for i in range(len(sorted_lst) - 1):
        assert sorted_lst[i] <= sorted_lst[i + 1]

@given(lst=st.lists(st.integers()), n=st.integers(min_value=0))
def test_sort_n_times(lst, n):
    # Property: Sorting n times == sorting once
    once = sorted(lst)
    many_times = lst
    for _ in range(n):
        many_times = sorted(many_times)
    assert once == many_times
```

#### 2. Data Serialization

```python
@given(user_data=st.builds(dict, 
    email=st.emails(),
    age=st.integers(min_value=0, max_value=120),
    name=st.text(min_size=1, max_size=50)
))
def test_json_roundtrip(user_data):
    # Property: Serialize → Deserialize = original
    serialized = json.dumps(user_data)
    deserialized = json.loads(serialized)
    assert deserialized == user_data

@given(obj=st.from_type(User))
def test_pydantic_roundtrip(obj):
    # Property: Pydantic roundtrip preserves data
    serialized = obj.model_dump()
    deserialized = User(**serialized)
    assert deserialized == obj
```

#### 3. Cache Invariants

```python
@given(
    keys=st.lists(st.text(), min_size=0, max_size=100, unique=True),
    values=st.integers()
)
def test_cache_lru_eviction(keys, values):
    cache = LRUCache(capacity=10)
    
    # Insert items
    for i, key in enumerate(keys[:20]):
        cache.put(key, values)
    
    # Property: After adding more than capacity, oldest items evicted
    assert len(cache) <= 10
    
    # Property: Most recent items still accessible
    if len(keys) > 10:
        oldest_key = keys[0]
        with pytest.raises(KeyError):
            _ = cache.get(oldest_key)
        
        newest_key = keys[-1]
        assert cache.get(newest_key) == values
```

#### 4. Concurrency Invariants

```python
@given(
    initial=st.integers(min_value=0),
    increments=st.lists(st.integers(min_value=1), min_size=10, max_size=100)
)
def test_thread_safe_counter_invariant(initial, increments):
    counter = ThreadSafeCounter(initial)
    
    def add_value(value):
        for _ in range(value):
            counter.increment()
    
    threads = [threading.Thread(target=add_value, args=(val,)) 
               for val in increments]
    
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    
    # Property: Final value = initial + sum of all increments
    expected = initial + sum(increments)
    assert counter.value == expected
```

### When to Use Property-Based Testing

| Scenario | Use Property-Based Testing |
|----------|---------------------------|
| Pure functions with clear invariants | ✅ Perfect fit |
| Data transformations | ✅ Round-trip invariants |
| Algorithms (sorting, searching) | ✅ Mathematical properties |
| I/O operations | ❌ Need to mock I/O |
| UI interactions | ❌ Hard to generate inputs |
| Database queries | ❌ Schema constraints limit inputs |
| API contracts | ✅ Response format invariants |

### Hypothesis Strategies

```python
from hypothesis import strategies as st

# Common strategies
st.integers()           # Random integers
st.text()               # Random strings
st.emails()            # Valid email addresses
st.lists(st.integers()) # Lists of integers
st.dictionaries(st.text(), st.integers())  # Dict with str keys, int values
st.builds(User)         # Build User objects with valid fields
st.tuples(st.integers(), st.text())       # Tuples

# Custom strategies
def valid_phone_number():
    return st.from_regex(r'\+?\d{10,15}')

def user_dict():
    return st.fixed_dictionaries({
        'name': st.text(min_size=1, max_size=50),
        'age': st.integers(min_value=0, max_value=120),
        'email': st.emails()
    })
```

## Test Data Management

### The Problem

Hardcoded test data becomes brittle, doesn't cover edge cases, and creates maintenance burden.

### Strategies

#### 1. Test Factories

```python
class UserFactory:
    @staticmethod
    def create(**overrides):
        defaults = {
            "id": str(uuid.uuid4()),
            "email": f"user-{uuid.uuid4()}@example.com",
            "name": "Test User",
            "tier": "standard",
            "verified": False,
            "created_at": datetime.now()
        }
        return User(**{**defaults, **overrides})

# Usage: Create specific test data easily
def test_premium_user_discount():
    premium_user = UserFactory.create(tier="premium", purchase_count=10)
    discount = calculate_discount(premium_user, amount=100)
    assert discount == 20  # 20% for premium
```

#### 2. Property-Based Factories

```python
@given(
    user=st.builds(User,
        email=st.emails(),
        age=st.integers(min_value=0, max_value=120),
        tier=st.sampled_from(["standard", "premium", "gold"])
    )
)
def test_user_validation(user):
    # Test validation with generated users
    is_valid = validate_user(user)
    assert is_valid == (0 <= user.age <= 120 and user.tier in USER_TIERS)
```

#### 3. Edge Case Data Sets

```python
# Test with realistic problematic data
EDGE_CASE_USERS = [
    UserFactory.create(email=""),  # Empty email
    UserFactory.create(age=-5),    # Invalid age
    UserFactory.create(tier="invalid"),  # Wrong tier
    UserFactory.create(name="a"*1000),   # Too long
    UserFactory.create(email="not-an-email"),
]

@pytest.mark.parametrize("user", EDGE_CASE_USERS)
def test_user_validation_rejects_invalid(user):
    with pytest.raises(ValidationError):
        validate_user(user)
```

#### 4. Data Builders with Chaining

```python
class OrderBuilder:
    def __init__(self):
        self._items = []
        self._discount = 0
        self._shipping = 0
    
    def with_item(self, product_id: str, price: float, quantity: int = 1):
        self._items.append({"product_id": product_id, "price": price, "quantity": quantity})
        return self
    
    def with_discount(self, discount: float):
        self._discount = discount
        return self
    
    def with_free_shipping(self):
        self._shipping = 0
        return self
    
    def build(self) -> Order:
        return Order(
            items=self._items,
            discount=self._discount,
            shipping=self._shipping
        )

# Usage: Build complex test scenarios
def test_order_with_multiple_items():
    order = (OrderBuilder()
        .with_item("prod-1", 10.0, 2)
        .with_item("prod-2", 20.0, 1)
        .with_discount(5.0)
        .build())
    
    total = calculate_total(order)
    assert total == (10.0*2 + 20.0*1) - 5.0
```

#### 5. Realistic Data Generation

```python
import random
import string

def generate_realistic_users(count: int) -> List[User]:
    users = []
    for _ in range(count):
        users.append(UserFactory.create(
            email=f"{''.join(random.choices(string.ascii_lowercase, k=8))}@example.com",
            name=f"User {random.randint(1000, 9999)}",
            age=random.randint(18, 80),
            tier=random.choice(["standard", "premium", "gold"])
        ))
    return users

def test_search_pagination():
    users = generate_realistic_users(100)
    repository.save_all(users)
    
    page1 = repository.search(page=1, page_size=10)
    page2 = repository.search(page=2, page_size=10)
    
    assert len(page1) == 10
    assert len(page2) == 10
    assert page1[0].id != page2[0].id  # Different pages
```

#### 6. Test Fixtures with Variants

```python
@pytest.fixture
def standard_user():
    return UserFactory.create(tier="standard")

@pytest.fixture
def premium_user():
    return UserFactory.create(tier="premium")

@pytest.fixture
def gold_user():
    return UserFactory.create(tier="gold")

@pytest.fixture
def users_with_different_tiers(standard_user, premium_user, gold_user):
    return [standard_user, premium_user, gold_user]

def test_tier_discounts(users_with_different_tiers):
    discounts = [calculate_discount(u, 100) for u in users_with_different_tiers]
    assert discounts == [0, 10, 20]  # standard=0%, premium=10%, gold=20%
```

### Data Anti-Patterns

| Anti-Pattern | Why It's Bad | Solution |
|--------------|--------------|----------|
| Hardcoded values | Brittle, limited coverage | Use factories or generators |
| Single happy path | Misses edge cases | Test with edge case sets |
| Test data in production risk | Accidental data leaks | Use clearly fake data (example.com) |
| Random data without reproducibility | Flaky tests | Use seeded random or property-based |
| Test data coupled to schema | Breaks when schema changes | Use factories with defaults |

## Test Metrics

Target these metrics:

| Metric | Target | Why |
|--------|--------|-----|
| Line coverage | > 80% | Catches untested critical paths |
| Branch coverage | > 70% | Catches untested error paths |
| Test duration | < 30s total | Fast feedback loop |
| Test count | Quality > Quantity | 50 good tests > 200 bad tests |
| Flaky test rate | 0% | Flaky tests undermine confidence |
| Test effectiveness | > 30% fail rate during development | Tests that catch bugs, not just pass |

### Measuring Test Effectiveness

Track how often tests catch bugs:

1. **Bug Detection Rate**: Count bugs caught by tests during development vs. production
2. **Test Failure Rate**: Percentage of test runs that fail (should be higher during active development)
3. **Time to Fix**: Average time to fix issues caught by tests vs. production issues

### Anti-Metric to Avoid

| Anti-Metric | Why It's Bad |
|--------------|--------------|
| 100% coverage goal | Leads to testing trivial code, mocking abuse |
| Number of tests | Doesn't measure quality, 100 bad tests < 10 good tests |
| Test pass rate | 100% pass rate might mean tests don't challenge the code |

## Enhanced Checklist

- [ ] Testing behavior, not implementation
- [ ] No mocks of internal code (only external I/O)
- [ ] Following 70/20/10 pyramid
- [ ] AAA pattern in every test
- [ ] Test names read like sentences
- [ ] Using fixtures for setup
- [ ] Error cases tested
- [ ] Not testing framework/library code
- [ ] Not testing trivial getters/setters
- [ ] **Concurrency tested** where applicable (threading, async, race conditions)
- [ ] **Integration tests** used for I/O operations (DB, API, file system)
- [ ] **Property-based tests** used for pure functions and invariants
- [ ] **Realistic test data** (factories, generators, edge cases)
- [ ] **No test always passes** - each test can fail with code changes
- [ ] **No heavy mocking** - prefer real dependencies in integration tests
