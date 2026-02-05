# Code Review Guidelines

## Purpose

Perform systematic code review of changes, identifying issues by priority level. Produce a temporary review document at project root for human review.

## Invocation

Trigger via natural language requests (OpenCode has built-in `/review` command):

**Default review:**
- "review my changes"
- "code review"
- "review this PR"

**Specific scope:**
- "review changes from feature-branch to main"
- "review commit abc123 against def456"
- "review PR #42"

## Philosophy

**Only report problems.** Files without issues are not mentioned. The review suggests improvements but never implements changes.

## Priority Levels

| Level | Category | Examples | Action Required |
|-------|----------|----------|-----------------|
| **P1** | Critical | Security bugs, data loss, logic errors, broken contracts, secret exposure | MUST fix before merge |
| **P2** | Important | Performance issues, missing error handling, poor maintainability, architectural violations | SHOULD fix, requires justification if skipped |
| **P3** | Nice to have | Style inconsistencies, minor optimizations, missing comments, naming suggestions | COULD fix, reviewer discretion |

## Default vs Custom Review Scope

### Default Behavior

Review changes between current local branch and remote main/master:

```bash
git diff origin/main...HEAD
```

### Custom Scope (User Override)

Accept explicit source and target from user:
- "review changes from feature-branch to main"
- "review commit abc123 against def456"
- "review PR #42"

## Review Document Format

Create `CODE_REVIEW.md` at project root with this structure:

```markdown
# Code Review

**Source:** feature-branch (abc1234)  
**Target:** main (def5678)  
**Files Changed:** 15  
**Total Changes:** +420 / -180 lines  
**Generated:** 2024-01-15 10:30 UTC

---

## Summary

| Priority | Count |
|----------|-------|
| P1 (Critical) | 2 |
| P2 (Important) | 5 |
| P3 (Nice) | 3 |

---

## File: src/payments/processor.py

### P1: SQL Injection Risk (Line 45)

**Issue:** User input directly interpolated into SQL query
```python
query = f"SELECT * FROM payments WHERE user_id = {user_id}"  # ❌
```

**Suggested Fix:** Use parameterized queries
```python
query = "SELECT * FROM payments WHERE user_id = %s"
cursor.execute(query, (user_id,))  # ✅
```

---

### P2: Missing Error Handling (Line 78)

**Issue:** Stripe API call without try/catch
```python
charge = stripe.Charge.create(amount=amount, currency="usd")
```

**Suggested Fix:** Wrap in try/except with proper error handling
```python
try:
    charge = stripe.Charge.create(amount=amount, currency="usd")
except stripe.error.CardError as e:
    logger.warning("Payment declined", extra={"error": str(e)})
    raise PaymentDeclinedError(str(e))
```

---

## File: src/utils/helpers.py

### P3: Function Too Long (Lines 12-67)

**Issue:** `process_data()` is 55 lines (exceeds 50 line limit per ruff-rules.md)

**Suggested Fix:** Extract helper functions
```python
def process_data(data):
    validated = _validate_data(data)
    transformed = _transform_data(validated)
    return _persist_data(transformed)
```

---

## Clean Files (No Issues)

✅ src/models/user.py  
✅ src/api/routes.py  
✅ tests/test_payment.py

*(Clean files are not detailed in review)*

---

## Action Items

### Must Fix (P1)
1. [ ] Fix SQL injection in src/payments/processor.py:45
2. [ ] Remove hardcoded API key in src/config/settings.py:12

### Should Fix (P2)
1. [ ] Add error handling for Stripe API calls
2. [ ] Refactor long function in helpers.py
3. [ ] Add type hints to user service

### Could Fix (P3)
1. [ ] Rename ambiguous variable in auth.py
2. [ ] Add docstring to process_data()
3. [ ] Consider caching for frequent query
```

## Review Process

### Step 1: Get Diff Information

```bash
# Default: compare to main/master
git diff --stat origin/main...HEAD
git diff --name-only origin/main...HEAD

# Get commit info for header
git log --oneline -1 HEAD
git log --oneline -1 origin/main

# Count changes
git diff --numstat origin/main...HEAD | awk '{added+=$1; removed+=$2} END {print "+"added" / -"removed}'
```

### Step 2: Analyze Each Changed File

For each file with changes:
1. Read the diff (added/removed lines)
2. Read the full file context if needed
3. Check against guidelines:
   - Security (AGENTS.md security rules)
   - Performance (complexity, N+1 queries)
   - Error handling (try/catch coverage)
   - Style (ruff-rules.md, type-hints.md)
   - Architecture (consistency with existing patterns)
   - Testing (testing.md guidelines)

### Step 3: Categorize Issues

Assign priority based on severity:
- P1: Could cause production incident, security breach, data loss
- P2: Technical debt, maintenance burden, edge case not handled
- P3: Polish, consistency, minor improvements

### Step 4: Suggest Fixes

For each issue:
1. Show the problematic code
2. Explain why it's an issue
3. Provide corrected code example
4. Reference relevant guideline (e.g., "per ruff-rules.md line-length=100")

**Never implement the fix** - only document the suggestion.

## What to Review

### Always Check

- [ ] Security: No secrets, no injection risks, proper auth
- [ ] Error handling: Try/catch where needed, proper error propagation
- [ ] Type safety: Type hints, Pydantic validation
- [ ] Performance: N+1 queries, unnecessary loops, large data loading
- [ ] Testing: New code has tests, tests follow testing.md
- [ ] Style: Ruff compliance, naming conventions
- [ ] Architecture: Consistent with existing patterns

### Skip If

- File has no meaningful changes (whitespace only)
- File is generated (lock files, auto-generated code)
- File is documentation (README updates without code)

## Review Constraints

### Do NOT

- Change any code files
- Commit the CODE_REVIEW.md file
- Make suggestions that violate existing patterns
- Suggest refactoring unrelated to the changes
- Comment on files with no issues

### DO

- Be specific (file:line references)
- Provide concrete fix examples
- Cite relevant guidelines
- Prioritize issues (P1 > P2 > P3)
- Acknowledge good patterns when seen

## Git Commands Reference

```bash
# Get current branch
git branch --show-current

# Compare current branch to main
git diff origin/main...HEAD

# Compare specific commits
git diff abc123..def456

# Compare branches
git diff feature-branch...main

# Get file list with status
git diff --name-status origin/main...HEAD

# Get statistics
git diff --stat origin/main...HEAD
```

## Workflow

1. Determine review scope (default or user-specified)
2. Run git commands to get change information
3. For each changed file with issues:
   - Identify problems by priority
   - Write suggested fixes
4. Create CODE_REVIEW.md at project root
5. Report to user: "Created CODE_REVIEW.md at {path} with X P1, Y P2, Z P3 issues"
6. Do NOT commit the review file

## Example User Interactions

**Default review:**
```
User: "review my changes"
→ Review origin/main...HEAD
```

**Specific branch:**
```
User: "review from feature-x to develop"
→ Review feature-x...develop
```

**Specific commits:**
```
User: "review commit abc123 against def456"
→ Review abc123..def456
```

**PR review:**
```
User: "review PR #123"
→ Fetch PR, review PR branch against base
```
