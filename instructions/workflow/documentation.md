# Documentation Guidelines

## Core Principle

Document the **"why"**, not just the "what" or "how".

## Source of Truth

- `docs/tech-context.md` - Master architecture document
- Must be updated whenever architecture or data flows change

## What to Document

### 1. Data Flow

How data moves through components:

```markdown
## Data Flow: User Registration

1. Frontend POST /api/users
2. API validates with Pydantic schema
3. Service layer checks email uniqueness
4. Repository layer writes to PostgreSQL
5. Event published to Redis queue
6. Email service consumes event, sends welcome email
```

### 2. Architecture Rationale

Why you chose specific approaches:

```markdown
## Why PostgreSQL over MongoDB

- ACID transactions required for financial data
- Complex joins needed for reporting
- Team expertise in SQL
- Existing ORM (SQLAlchemy) integration

Tradeoff: Less flexible schema, but data integrity is critical.
```

### 3. Architecture Tradeoff Documentation (Required)

Every `docs/tech-context.md` and README "Start Here" section MUST explain:

```markdown
## Architecture Decisions

### Why This Architecture?

We chose [specific architecture] because:
1. [Primary reason - e.g., "ACID requirements for financial data"]
2. [Secondary reason - e.g., "Team has 5 years experience with this stack"]
3. [Third reason - e.g., "Existing infrastructure compatibility"]

### Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| MongoDB | Flexible schema, easy scaling | No ACID, complex reporting queries | Financial data requires transactions |
| Microservices | Independent scaling | Operational complexity, latency | Team size too small (3 devs) |
| Serverless | No infra management | Cold starts, vendor lock-in | Predictable traffic doesn't need it |

### Tradeoffs Made

- **Consistency over Availability**: We accept occasional downtime for data integrity
- **Simplicity over Performance**: Single-node DB now, can shard later if needed
- **Familiarity over Innovation**: Used Django instead of FastAPI due to team expertise

### When to Revisit

Reconsider this architecture when:
- [ ] Transaction volume exceeds 10k/sec
- [ ] Team grows to 10+ developers
- [ ] Multi-region deployment required
```

**Rule:** No architecture choice is obvious. Document why you chose what you chose.

### 4. Module Purpose

Clear explanation of what and why:

```python
"""
Payment Processor

Handles all payment operations including:
- Card validation (via Stripe)
- Transaction recording
- Refund processing
- Webhook handling

Why separate service:
- PCI compliance requires isolation
- Retry logic for failed payments
- Idempotency for webhook safety
"""
```

## What NOT to Document

| Don't Document | Why |
|----------------|-----|
| Obvious mechanics | Code should be self-documenting |
| Outdated TODOs | Use actual TODOs or issues |
| Implementation details | These change frequently |
| Internal refactoring notes | Use commit messages |

## No Proactive Docs

**Rule:** Never create documentation files unless explicitly requested.

Wait for user to ask:
- "Can you document this?"
- "Write a README for X"
- "Explain how this works"

Then create targeted documentation for that specific need.

## Code Comments

### Good Comments
```python
# Tradeoff: Using recursion here to handle nested structures
# Complexity O(n) where n = total nodes, not tree depth

def process_tree(node):
    ...
```

### Bad Comments
```python
# This function processes a node  # ❌ Obvious

def process_node(node):
    # Iterate through items  # ❌ Code says this
    for item in items:
        ...
```

### When Code Needs Comments

If you need >3 lines of comments to explain, refactor instead:

```python
# Bad: Needs explanation
# Calculate discount based on:
# - Customer tier (0-5)
# - Time since last purchase
# - Product category (A-F)
# - Seasonal multiplier (1.0-1.5)
def calc_discount(cust):
    base = cust.tier * 0.1
    time = 1.0 if cust.last_purchase < 30 else 0.8
    cat = {'A': 1.0, 'B': 0.9, ...}[cust.category]
    season = get_season_mult()
    return base * time * cat * season

# Better: Extract to named functions
def calc_discount(cust):
    return (
        tier_discount(cust.tier) *
        loyalty_bonus(cust.last_purchase) *
        category_rate(cust.category) *
        seasonal_adjustment()
    )
```

## Documentation Checklist

- [ ] Data flows explained
- [ ] Architectural decisions justified
- [ ] Module purposes clear
- [ ] tech-context.md updated if architecture changed
- [ ] No obvious comments
- [ ] Complex code refactored, not commented
- [ ] README only if user explicitly requested
