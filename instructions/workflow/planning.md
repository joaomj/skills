# Investigation and Planning Workflow

## Step 1: Workspace Analysis

Before any action, scan the project:

```
1. Check docs/tech-context.md - understand architecture
2. Read pyproject.toml - dependencies, config
3. Identify entry points - main.py, app.py, index.js, etc.
4. Scan directory structure - understand organization
5. Look for existing tests - test patterns, coverage
6. Check for .env.example - required environment variables (NEVER read .env files)
```

## Step 2: User Interview

Ask questions until the specification is 100% clear:

- What is the goal?
- What does success look like?
- Are there constraints (time, resources, compatibility)?
- What is the priority (must-have vs nice-to-have)?
- Are there examples of similar features?

**Rule:** Continue asking until no ambiguity remains.

## Step 3: Action Plan

Create a step-by-step todo list:

```markdown
## Action Plan

### Phase 1: Foundation
- [ ] Analyze current implementation
- [ ] Design new component structure
- [ ] Write tests first (TDD)

### Phase 2: Implementation  
- [ ] Implement core logic
- [ ] Add error handling
- [ ] Write integration tests

### Phase 3: Validation
- [ ] Run full test suite
- [ ] Check linting and types
- [ ] Manual testing

### Checkpoints Between Phases

**Definition:** Testable functionality gates that must pass before proceeding.

| Phase | Checkpoint | Test Criteria |
|-------|------------|---------------|
| After Phase 1 | Foundation Complete | Unit tests pass for new data model, Pydantic validation works with sample data |
| After Phase 2 | Implementation Verified | Integration tests pass, API endpoints return correct status codes |
| After Phase 3 | Validation Passed | Full test suite green, linting clean, manual testing confirms feature works |

**Rule:** Never proceed to next phase until current checkpoint passes.
```

## Step 4: Approval Gate

**CRITICAL:** Wait for explicit "yes" or "go ahead" from user.

Phrases that indicate approval:
- "Yes, proceed"
- "Go ahead"
- "Implement it"
- "Make the changes"
- "LGTM" (looks good to me)

**Never proceed on:**
- "Looks good" (not explicit)
- "I think that works"
- "Let's see"
- Silence after plan presentation

## Step 5: Execution

### Before Each Change
1. Explain what you're about to do
2. Explain why (reference guidelines)
3. Ask if user wants to see diff first (optional)

### During Changes
1. Make atomic commits (one logical change at a time)
2. Mark todos as complete immediately after
3. Run tests frequently
4. Stop on first error - don't batch fixes

### After Changes
1. Report what was changed
2. Report test results
3. **Update docs/tech-context.md** if architecture changed:
   - Add new content for new features/decisions
   - Update existing content if it changed
   - Remove obsolete content about old architecture
4. **Review and prune documentation** if:
   - Architecture or data flows changed significantly
   - Removed/deprecated features or components
   - Documentation mentions outdated patterns or APIs
5. Summarize tradeoffs made

## Investigation Tools

```bash
# Find entry points
grep -r "if __name__" --include="*.py" .
grep -r "app.listen\|app.run\|fastapi\|flask" --include="*.py" .

# Check dependencies
cat pyproject.toml | grep -A 20 "\[project.dependencies\]"
cat package.json | jq '.dependencies'

# Find tests
find . -name "*test*.py" -o -name "test_*" -o -name "*_test.py"
find . -name "pytest.ini" -o -name "setup.cfg" -o -name "pyproject.toml" | xargs grep -l "pytest"

# Check config
ls -la .env* 2>/dev/null || echo "No env files"
cat .env.example 2>/dev/null || echo "No env example"
```

## Common Mistakes

| Mistake | Why Wrong | Correct |
|---------|-----------|---------|
| Start coding immediately | No context, wrong assumptions | Investigate first |
| Assume user's intent | Ambiguity leads to wrong solution | Clarify with questions |
| Skip planning | Miss edge cases, poor structure | Write plan, get approval |
| Batch changes | Hard to debug, rollback | Atomic changes |
| No tests | Regressions, low confidence | Test as you go |
