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
- [ ] Documentation: Updated if architecture changed, pruned if obsolete

### Skip If

- File has no meaningful changes (whitespace only)
- File is generated (lock files, auto-generated code)
- Documentation-only changes that improve clarity and remove obsolete content

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

## Dual Subagent Review Workflow

### Overview

Two independent subagents perform full code reviews in parallel to maximize issue coverage. This redundancy ensures different perspectives catch different issues.

### Why Two Subagents?

| Approach | Issue Coverage | Time | Confidence |
|----------|----------------|------|------------|
| Single reviewer | 60-70% | Fast | Low |
| Two independent reviewers | 85-95% | Medium | High |
| Sequential (reviewer 2 sees reviewer 1 output) | 75-80% | Medium | Medium |

Independent reviews provide the best coverage because subagents won't bias each other.

## Subagent Invocation Protocol

### Step 1: Determine Review Scope

```bash
# Get review scope from user or use default
git diff origin/main...HEAD
```

### Step 2: Launch Two Independent Subagents

Both subagents receive identical instructions but operate independently:

```python
# Subagent 1: Full review - Security, bugs, critical issues
subagent_1 = Task(
    subagent_type="general",
    prompt=f"""
Perform a comprehensive code review of changes from {source} to {target}.

Review all changed files for:
1. P1 Issues: Security bugs, data loss, logic errors, broken contracts, secret exposure
2. P2 Issues: Performance issues, missing error handling, poor maintainability
3. P3 Issues: Style inconsistencies, minor optimizations

For each issue found:
- Provide file path and line number
- Explain why it's an issue
- Categorize as P1/P2/P3
- Suggest a fix (code example)

Return a structured list of all issues found.
"""
)

# Subagent 2: Full review - Architecture, performance, maintainability
subagent_2 = Task(
    subagent_type="general",
    prompt=f"""
Perform a comprehensive code review of changes from {source} to {target}.

Review all changed files for:
1. P1 Issues: Security bugs, data loss, logic errors, broken contracts, secret exposure
2. P2 Issues: Performance issues, missing error handling, poor maintainability
3. P3 Issues: Style inconsistencies, minor optimizations

For each issue found:
- Provide file path and line number
- Explain why it's an issue
- Categorize as P1/P2/P3
- Suggest a fix (code example)

Return a structured list of all issues found.
"""
)
```

### Step 3: Wait for Both Subagents to Complete

```python
# Run both subagents in parallel
results = asyncio.gather(subagent_1, subagent_2)
issues_1 = results[0]  # Issues from subagent 1
issues_2 = results[1]  # Issues from subagent 2
```

### Key Protocol Rules

1. **Identical scope**: Both subagents review the exact same diff
2. **Independent execution**: Subagents cannot see each other's findings
3. **Parallel execution**: Run both simultaneously for efficiency
4. **Full review**: Both subagents review all aspects (no focus split)
5. **Structured output**: Both return issues in consistent format

### Example Subagent Prompts

#### Default Review (origin/main...HEAD)

```
Review the git diff between origin/main and current HEAD.

For each file with changes:
1. Read the diff to understand what changed
2. Check for security issues, bugs, performance problems, style issues
3. Prioritize: P1 (critical), P2 (important), P3 (nice to have)

Return all findings as a structured list.
```

#### Specific Branch Review (feature-x to develop)

```
Review changes from branch "feature-x" to branch "develop".

Use this git command: git diff feature-x...develop

For each changed file, identify issues and categorize by severity.
```

#### PR Review (PR #123)

```
Review pull request #123.

First, fetch PR information:
- Use gh pr view 123 to get branch names
- Use gh pr diff 123 to get the diff

Then review all changes for bugs, security issues, and code quality.
```

## Finding Merge Protocol

### Step 1: Parse Subagent Outputs

Both subagents return structured issue lists:

```python
# Example output format from subagent
issues_1 = [
    {
        "file": "src/payments/processor.py",
        "line": 45,
        "severity": "P1",
        "issue": "SQL injection risk",
        "description": "User input interpolated into query",
        "fix": "Use parameterized queries: cursor.execute(query, (user_id,))"
    },
    # ... more issues
]

issues_2 = [
    # Same format, potentially overlapping
]
```

### Step 2: Deduplicate Issues

Merge identical or near-identical findings:

```python
def deduplicate_issues(issues_list: List[List[Issue]]) -> List[Issue]:
    merged = []
    seen = set()
    
    for issues in issues_list:
        for issue in issues:
            # Create signature for deduplication
            signature = (issue["file"], issue["line"], issue["severity"], issue["issue"][:50])
            
            if signature not in seen:
                merged.append(issue)
                seen.add(signature)
    
    return merged
```

### Step 3: Prioritize by Severity

Sort merged issues by priority:

```python
SEVERITY_ORDER = {"P1": 0, "P2": 1, "P3": 2}

def prioritize_issues(issues: List[Issue]) -> List[Issue]:
    return sorted(issues, key=lambda x: (SEVERITY_ORDER[x["severity"]], x["file"], x["line"]))
```

### Step 4: Group by File

Organize issues for the review document:

```python
from collections import defaultdict

def group_by_file(issues: List[Issue]) -> Dict[str, List[Issue]]:
    grouped = defaultdict(list)
    for issue in issues:
        grouped[issue["file"]].append(issue)
    return grouped
```

### Step 5: Generate Summary

Calculate totals:

```python
def generate_summary(issues: List[Issue]) -> Dict[str, int]:
    summary = {"P1": 0, "P2": 0, "P3": 0}
    for issue in issues:
        summary[issue["severity"]] += 1
    return summary
```

### Merge Algorithm

```python
# Complete merge process
all_issues = issues_1 + issues_2  # Combine both subagent findings

# Deduplicate identical findings
deduped_issues = deduplicate_issues([all_issues])

# Prioritize by severity
prioritized_issues = prioritize_issues(deduped_issues)

# Group by file for review document
file_groups = group_by_file(prioritized_issues)

# Generate summary
summary = generate_summary(prioritized_issues)

# Result: Ready for CODE_REVIEW.md generation
```

## Iterative Review Loop

### Overview

After presenting issues to the user, allow fixes and re-review until convergence.

### Loop Structure

```
┌─────────────────────────────────────────────────────────┐
│  1. Launch 2 subagents for initial review                │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  2. Merge findings from both subagents                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  3. Present issues to user (CODE_REVIEW.md)           │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  4. User fixes issues                                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  5. Launch 2 subagents again to review fixes            │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
         ┌───────┴───────┐
         │ Any issues?   │
         └───────┬───────┘
           Yes │     │ No
              ▼     ▼
  ┌────────────────┐  ┌──────────────────┐
  │ Continue loop  │  │ Create final     │
  │ (max 3 times)  │  │ CODE_REVIEW.md   │
  └────────────────┘  └──────────────────┘
```

### Iteration Protocol

#### Iteration 1: Initial Review

```python
# Launch subagents
issues_1 = subagent_1.review(scope=review_scope)
issues_2 = subagent_2.review(scope=review_scope)

# Merge and present
merged_issues = merge_and_deduplicate([issues_1, issues_2])
create_code_review(merged_issues, iteration=1)
```

#### User Fixes Issues

User fixes P1 and P2 issues based on review.

#### Iteration 2: Verify Fixes

```python
# Launch subagents again (same scope, new code)
issues_1_v2 = subagent_1.review(scope=review_scope)
issues_2_v2 = subagent_2.review(scope=review_scope)

# Merge and compare to previous iteration
merged_issues_v2 = merge_and_deduplicate([issues_1_v2, issues_2_v2])

# Check if issues were actually fixed
fixed_issues = compare_iterations(merged_issues, merged_issues_v2)
new_issues = find_new_issues(merged_issues_v2)

create_code_review(merged_issues_v2, iteration=2)
```

#### Iteration 3+: Continue Until Convergence

Repeat until no P1/P2 issues remain or max iterations reached.

### Tracking Iteration State

```python
class ReviewIteration:
    def __init__(self, iteration_number: int, issues: List[Issue]):
        self.number = iteration_number
        self.issues = issues
        self.p1_count = sum(1 for i in issues if i["severity"] == "P1")
        self.p2_count = sum(1 for i in issues if i["severity"] == "P2")
        self.p3_count = sum(1 for i in issues if i["severity"] == "P3")
    
    def has_critical_issues(self) -> bool:
        return self.p1_count > 0 or self.p2_count > 0
    
    def progress(self, previous: "ReviewIteration") -> Dict[str, int]:
        return {
            "P1_fixed": previous.p1_count - self.p1_count,
            "P2_fixed": previous.p2_count - self.p2_count,
            "P3_fixed": previous.p3_count - self.p3_count,
        }
```

## Termination Criteria

### Stop When

1. **Zero Critical Issues**: No P1 or P2 issues remain (P3 issues acceptable)
2. **Max Iterations Reached**: 3 iterations completed (prevents infinite loop)
3. **Diminishing Returns**: Issues stopped being fixed between iterations

### Termination Logic

```python
def should_terminate(iterations: List[ReviewIteration]) -> Tuple[bool, str]:
    latest = iterations[-1]
    
    # Check 1: No critical issues
    if not latest.has_critical_issues():
        return (True, "Converged: No P1 or P2 issues remain")
    
    # Check 2: Max iterations
    if len(iterations) >= 3:
        return (True, "Terminated: Reached maximum 3 iterations")
    
    # Check 3: Diminishing returns (no progress from last iteration)
    if len(iterations) >= 2:
        prev = iterations[-2]
        latest = iterations[-1]
        progress = latest.progress(prev)
        
        if all(v == 0 for v in progress.values()):
            return (True, "Terminated: No progress in last iteration")
    
    # Continue loop
    return (False, "Continue: Critical issues remain")
```

### Termination Examples

#### Example 1: Successful Convergence

```
Iteration 1: 3 P1, 5 P2, 2 P3
→ User fixes all P1 and 3 P2

Iteration 2: 0 P1, 2 P2, 4 P3
→ User fixes remaining 2 P2

Iteration 3: 0 P1, 0 P2, 3 P3
→ TERMINATED: No critical issues remain
```

#### Example 2: Max Iterations

```
Iteration 1: 2 P1, 4 P2, 1 P3
→ User fixes P1 issues, 2 P2

Iteration 2: 0 P1, 2 P2, 2 P3
→ User fixes 1 P2

Iteration 3: 0 P1, 1 P2, 2 P3
→ TERMINATED: Reached maximum 3 iterations (1 P2 remains)
```

#### Example 3: Diminishing Returns

```
Iteration 1: 1 P1, 3 P2, 5 P3
→ User fixes P1

Iteration 2: 0 P1, 3 P2, 5 P3
→ User reports P2 issues are false positives

Iteration 3: 0 P1, 3 P2, 5 P3
→ TERMINATED: No progress in last iteration
```

## Updated Workflow Steps

### Complete Dual Subagent Workflow

1. **Determine Review Scope**
   - Get review scope from user or use default (origin/main...HEAD)
   - Run git commands to gather diff information

2. **Launch 2 Independent Subagents**
   - Subagent 1: Full review of all changes
   - Subagent 2: Full review of all changes (independent, parallel)
   - Both receive identical scope instructions

3. **Wait for Subagent Completion**
   - Both subagents complete their reviews
   - Receive structured issue lists from each

4. **Merge Findings**
   - Deduplicate identical issues
   - Prioritize by severity (P1 > P2 > P3)
   - Group by file for review document

5. **Generate Review Document**
   - Create CODE_REVIEW.md with merged findings
   - Include summary of P1/P2/P3 counts
   - Present to user with action items

6. **Wait for User Fixes**
   - User reviews and fixes issues
   - Commit fixes to branch

7. **Re-Launch Subagents** (if iteration < 3)
   - Launch 2 subagents again with same scope
   - Review the new code after fixes

8. **Check Termination Criteria**
   - If 0 P1/P2 issues: Create final CODE_REVIEW.md and stop
   - If iteration >= 3: Create final CODE_REVIEW.md and stop
   - If no progress: Create final CODE_REVIEW.md and stop
   - Otherwise: Go to step 5 (present new iteration)

9. **Final Report**
   - Create final CODE_REVIEW.md with all remaining issues
   - Include iteration history showing progress
   - Report to user: "Final review with X P1, Y P2, Z P3 issues after 3 iterations"

### Pseudocode Implementation

```python
def dual_subagent_review(review_scope: ReviewScope):
    iterations = []
    
    for iteration_num in range(1, 4):  # Max 3 iterations
        # Step 1: Launch 2 subagents
        issues_1 = subagent_1.review(scope=review_scope)
        issues_2 = subagent_2.review(scope=review_scope)
        
        # Step 2: Merge findings
        merged_issues = merge_and_deduplicate([issues_1, issues_2])
        prioritized_issues = prioritize_issues(merged_issues)
        
        # Step 3: Record iteration
        iteration = ReviewIteration(iteration_num, prioritized_issues)
        iterations.append(iteration)
        
        # Step 4: Generate review document
        create_code_review(iteration, iterations)
        
        # Step 5: Check termination
        should_stop, reason = should_terminate(iterations)
        
        if should_stop:
            print(f"{reason} (after {iteration_num} iterations)")
            break
        
        # Step 6: Wait for user fixes
        print(f"Iteration {iteration_num}: {iteration.p1_count} P1, {iteration.p2_count} P2")
        print("Please fix the issues above, then continue.")
        input("Press Enter when fixes are ready...")
        
        # Note: In actual agent workflow, this would be:
        # - Present issues to user
        # - Wait for user to implement fixes
        # - Continue to next iteration
    
    # Final summary
    final = iterations[-1]
    print(f"Final review: {final.p1_count} P1, {final.p2_count} P2, {final.p3_count} P3")
    return iterations
```

## Example Subagent Prompts

### Prompt Template: Full Review

```
You are a code reviewer performing a comprehensive review of code changes.

Review Scope: {review_scope_description}

Git Command to Run: {git_command}

For each file with changes:
1. Read the diff to understand what changed
2. Read the full file context if needed
3. Check against these criteria:

Priority P1 (Critical - MUST FIX):
- Security bugs: SQL injection, XSS, secret exposure, auth bypass
- Data loss: Unintended deletions, data corruption
- Logic errors: Broken business logic, incorrect algorithms
- Broken contracts: API changes that break clients, schema changes

Priority P2 (Important - SHOULD FIX):
- Performance issues: N+1 queries, inefficient algorithms, memory leaks
- Missing error handling: Uncaught exceptions, silent failures
- Poor maintainability: Hard to understand, complex code
- Architectural violations: Inconsistent patterns, wrong abstractions

Priority P3 (Nice to Have - COULD FIX):
- Style inconsistencies: Naming, formatting, minor code style
- Minor optimizations: Small performance wins
- Missing comments: Could use documentation

For each issue found:
- File path and line number
- Severity (P1/P2/P3)
- Brief description of the issue
- Why it's a problem (1-2 sentences)
- Suggested fix (code example if applicable)

Return all findings as a structured list. Do not make suggestions that violate existing codebase patterns.
```

### Example 1: Default Review

```
You are a code reviewer.

Review the git diff between origin/main and current HEAD.

Run this command: git diff origin/main...HEAD

For each changed file, identify issues and categorize as P1 (critical), P2 (important), or P3 (nice to have).

Focus on:
- Security vulnerabilities
- Logic errors
- Performance problems
- Code quality issues

Return all findings in a structured format with file path, line number, severity, description, and suggested fix.
```

### Example 2: Branch-to-Branch Review

```
You are a code reviewer.

Review changes from branch "feature-authentication" to branch "develop".

Run this command: git diff feature-authentication...develop

Review all changed files for bugs, security issues, and code quality.

Categorize each issue as:
- P1: Critical bugs, security issues, data loss risks
- P2: Performance issues, missing error handling
- P3: Style inconsistencies, minor optimizations

Return findings with specific file paths and line numbers.
```

### Example 3: PR Review

```
You are a code reviewer.

Review pull request #42.

First, fetch PR information:
- Run: gh pr view 42 --json title,headRefName,baseRefName
- Run: gh pr diff 42

Review all changes from the PR's head branch to its base branch.

Identify and categorize issues as P1, P2, or P3.

Return a structured list of all findings with file paths, line numbers, and suggested fixes.
```

## Example User Interactions

**Default review:**
```
User: "review my changes"
→ Launch 2 subagents to review origin/main...HEAD
→ Merge findings from both subagents
→ Present CODE_REVIEW.md
→ After fixes, re-launch subagents to verify
→ Repeat until convergence or 3 iterations
```

**Specific branch:**
```
User: "review from feature-x to develop"
→ Launch 2 subagents to review feature-x...develop
→ Merge findings from both subagents
→ Present CODE_REVIEW.md
→ Iterative review loop until convergence
```

**Specific commits:**
```
User: "review commit abc123 against def456"
→ Launch 2 subagents to review abc123..def456
→ Merge findings from both subagents
→ Present CODE_REVIEW.md
→ Iterative review loop until convergence
```

**PR review:**
```
User: "review PR #123"
→ Launch 2 subagents to review PR #123
→ Merge findings from both subagents
→ Present CODE_REVIEW.md
→ Iterative review loop until convergence
```
