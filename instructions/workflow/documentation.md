# Documentation Guidelines

## Core Principle

Document the **"why"**, not just the "what" or "how".

For all metrics, decisions, and tradeoffs, always document **HOW**, **WHY**, **WHAT**, and **WHERE**.

## Source of Truth

- `docs/tech-context.md` - Single-File Memory Bank consolidating Cline's core files
- Must be updated whenever architecture or data flows change
- Reference: https://docs.cline.bot/prompting/cline-memory-bank#what-is-the-cline-memory-bank

## docs/tech-context.md - Single-File Memory Bank

### Mandatory for All Projects

`docs/tech-context.md` consolidates Cline Memory Bank's core files into a single deep technical report. This file is the source of truth for project context.

### Required Sections

Every `docs/tech-context.md` MUST include these sections (equivalent to Cline Memory Bank core files):

#### 1. Project Brief
- Foundation document defining core requirements and goals
- High-level overview of what is being built
- Business problem and solution scope

#### 2. Product Context
- Why this project exists
- Problems it solves
- How it should work
- User experience goals
- Constraints (latency, interpretability, resources)

#### 3. System Patterns
- System architecture
- Key technical decisions
- Design patterns in use
- Component relationships
- Critical implementation paths
- Data flow: How data moves through components, entry to exit

#### 4. Tech Context
- Technologies used
- Development setup
- Technical constraints
- Dependencies
- Tool usage patterns

### Depth Requirement

`docs/tech-context.md` MUST be a DEEP technical report. Size is not a problem; shallowness is.

When documenting metrics, ALWAYS explain:
- **HOW**: Calculation method and implementation details
- **WHY**: Rationale for choosing this metric
- **WHAT**: Observed values and ranges
- **WHERE**: In which component/section this metric is relevant

Example:
```markdown
### Performance Metric: API Response Time

**HOW**: Measured using Prometheus middleware at the FastAPI router level, recording time from request receipt to response transmission. P50, P95, and P99 calculated over 1-minute rolling windows.

**WHY**: Chosen because user experience degrades perceptibly after 200ms and SLA requires 95% of requests under 500ms. Directly impacts customer retention (observed correlation: 15% drop in DAU when P95 > 600ms).

**WHAT**: Current values (production, last 30 days): P50 = 87ms, P95 = 234ms, P99 = 412ms. Baseline before optimization (Oct 2024): P50 = 145ms, P95 = 580ms, P99 = 1.2s.

**WHERE**: Measured at the API gateway edge, after authentication but before application logic. Also monitored per-endpoint in the `api_performance` dashboard.
```

### ML Projects Only: Build Report (CRISP-DM)

ML projects MUST include a section titled `## How the Project Was Built (CRISP-DM)` detailing the entire development process through all 6 CRISP-DM phases.

Each phase MUST be documented using the **STAR** methodology:
- **Situation**: Context and initial state
- **Task**: Specific objective and success criteria
- **Action**: Steps taken, decisions made, why chosen
- **Result**: Outcomes, metrics, tradeoffs

Within each phase, document the **HOW, WHY, WHAT, WHERE** for all metrics and decisions.

#### Required Phase Structure

```markdown
## How the Project Was Built (CRISP-DM)

### Phase 1: Business Understanding

**Situation**
[Describe the business problem, current state, stakeholders involved]

**Task**
[Define what success looks like in business terms, target metrics]

**Action**
[Questions asked, constraints identified, success criteria defined]

**Result**
[Baseline performance, target metric improvement, business impact estimate]

- **Metric Definition**: [HOW calculated, WHY chosen, WHAT values observed, WHERE measured]
- **Constraints Documented**: [Latency, interpretability, resource limits]

### Phase 2: Data Understanding

**Situation**
[Data sources available, initial data state]

**Task**
[Understand data quality, identify patterns, assess leakage risks]

**Action**
[EDA performed, profiling completed, lineage documented]

**Result**
[Key statistics, data quality report, leakage assessment]

- **Data Quality Metrics**:
  - **Completeness**: [HOW: % non-null per column; WHY: missing data impacts model performance; WHAT: observed values; WHERE: in which datasets]
  - **Class Balance**: [HOW: class distribution calculation; WHY: imbalance causes bias; WHAT: observed ratios; WHERE: training set]
- **Leakage Risks Identified**: [List with severity and mitigation]

### Phase 3: Data Preparation

**Situation**
[Raw data state, preprocessing requirements identified]

**Task**
[Create clean, reproducible training data]

**Action**
[Pipeline design, transformations applied, versioning implemented]

**Result**
[Final dataset characteristics, reproducibility achieved]

- **Preprocessing Pipeline**:
  - **Feature X**: [HOW imputed/transformed; WHY this method; WHAT resulting distribution; WHERE in pipeline]
  - **Train/Test Split**: [HOW stratified split performed; WHY stratification needed; WHAT resulting sizes; WHERE in code]
- **Dataset Versioning**: [Hash/DVC tracking, lineage documented]

### Phase 4: Modeling

**Situation**
[Baseline established, model space defined]

**Task**
[Develop models meeting business requirements]

**Action**
[Models tried, hyperparameter search, experiment logging]

**Result**
[Best model selected, performance documented]

- **Model Selection**:
  - **Baseline (Logistic Regression)**:
    - **Accuracy**: [HOW: (TP+TN)/(TP+TN+FP+FN); WHY: simple interpretability baseline; WHAT: 0.82; WHERE: validation set]
    - **Tradeoff**: Low complexity but limited capacity
  - **Selected Model (XGBoost)**:
    - **Accuracy**: [HOW: calculation method; WHY: best performance; WHAT: 0.89; WHERE: validation set]
    - **Feature Importance**: [HOW: SHAP values; WHY: interpretability requirement; WHAT: top features with values; WHERE: SHAP summary plot]
- **Hyperparameters**: [Search space, best values, rationale]

### Phase 5: Evaluation

**Situation**
[Model trained, performance measured]

**Task**
[Validate against business criteria, assess real-world impact]

**Action**
[Cross-validation, business impact analysis, sensitivity analysis]

**Result**
[Confidence intervals, business value estimate, deployment readiness]

- **Evaluation Metrics**:
  - **Precision**: [HOW: TP/(TP+FP); WHY: false positives costly in this domain; WHAT: 0.91 +/- 0.03; WHERE: 5-fold CV]
  - **Recall**: [HOW: TP/(TP+FN); WHY: false negatives have high business risk; WHAT: 0.76 +/- 0.05; WHERE: 5-fold CV]
  - **Business Impact**: [Estimated revenue lift, cost savings, risk reduction]
- **Confidence Intervals**: [95% CI, method used, implications]

### Phase 6: Deployment

**Situation**
[Model validated, production readiness assessed]

**Task**
[Deploy model with monitoring and retraining strategy]

**Action**
[Infrastructure setup, monitoring implementation, retraining triggers defined]

**Result**
[Model in production, metrics tracked, retraining automated]

- **Inference Performance**:
  - **Latency**: [HOW: end-to-end measurement; WHY: SLA requirement < 200ms; WHAT: 145ms P95; WHERE: production cluster]
  - **Throughput**: [HOW: requests/second; WHY: expected peak load 10k/s; WHAT: 15k/s capacity; WHERE: load tests]
- **Monitoring Plan**:
  - **Data Drift Detection**: [HOW: KL divergence on feature distributions; WHY: performance degrades with drift; WHAT: alert threshold 0.1; WHERE: Prometheus alerts]
  - **Performance Monitoring**: [HOW: tracking metrics in production; WHY: catch degradation early; WHAT: current precision/recall; WHERE: MLflow dashboard]
- **Retraining Strategy**:
  - **Trigger**: [Performance drops below X OR data drift exceeds Y]
  - **Frequency**: [Retrain every N weeks OR on trigger]
  - **Rollback**: [How to revert if new model underperforms]
```

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
- [ ] tech-context.md includes all 4 required sections (Project Brief, Product Context, System Patterns, Tech Context)
- [ ] For ML projects: Build Report section with all 6 CRISP-DM phases
- [ ] For ML projects: Each CRISP-DM phase uses STAR methodology
- [ ] For ML projects: All metrics include HOW, WHY, WHAT, WHERE documentation
- [ ] tech-context.md is a deep technical report (not shallow summary)
- [ ] No obvious comments
- [ ] Complex code refactored, not commented
- [ ] README only if user explicitly requested
