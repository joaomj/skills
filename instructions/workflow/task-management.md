# Task Management with TodoWrite

## When to Use TodoWrite

Use the TodoWrite tool when:
- Task has 3+ non-trivial steps
- Task spans multiple files
- Task has dependencies (do A before B)
- Need to track progress over time

## Example Task Breakdown

**Bad:** Single vague todo
```markdown
- [ ] Implement new feature
```

**Good:** Atomic, testable units
```markdown
- [ ] Create data model for X
- [ ] Write unit tests for model validation
- [ ] Implement service layer for CRUD operations
- [ ] Add API endpoint with input validation
- [ ] Write integration tests for endpoint
- [ ] Update documentation
```

## TodoWrite Usage

```python
# Initialize at start of task
todos = [
    {"id": "1", "content": "Analyze existing code", "status": "in_progress", "priority": "high"},
    {"id": "2", "content": "Design new component", "status": "pending", "priority": "high"},
    {"id": "3", "content": "Write tests", "status": "pending", "priority": "high"},
]

# Mark complete immediately after finishing
todos[0]["status"] = "completed"

# Mark current
todos[1]["status"] = "in_progress"
```

## Atomic Units

Break tasks into smallest independently testable pieces:

| Task | Bad (Too Big) | Good (Atomic) |
|------|---------------|---------------|
| Add auth | "Implement authentication" | 1. Create User model<br>2. Add password hashing<br>3. Create login endpoint<br>4. Add JWT generation<br>5. Add middleware<br>6. Write tests |
| Refactor | "Clean up code" | 1. Extract function A<br>2. Move class to new file<br>3. Rename variable X<br>4. Update imports |
| Bug fix | "Fix the bug" | 1. Reproduce bug with test<br>2. Identify root cause<br>3. Implement fix<br>4. Verify test passes<br>5. Check for similar issues |

## Implementation Plan Checkpoints

Every major step must have a clear testable exit criteria:

```markdown
## Action Plan

### Phase 1: Data Layer
- [ ] Create User model with Pydantic
- [ ] Add database migration

**Checkpoint 1:** Unit tests pass, model validates correctly with sample data

### Phase 2: Business Logic  
- [ ] Implement authentication service
- [ ] Add password hashing

**Checkpoint 2:** Service layer tests pass, hashing works with test vectors

### Phase 3: API Layer
- [ ] Create login/register endpoints
- [ ] Add JWT token generation

**Checkpoint 3:** Integration tests pass, endpoints return 200/401 correctly
```

**Format:** Checkpoint = Testable success criteria that proves the increment works.

## Dependency Management

Order todos so each can be tested in isolation:

```markdown
1. [ ] Data layer (can test with mock data)
2. [ ] Business logic (can test with fake repository)
3. [ ] API layer (can test with test client)
4. [ ] Frontend (can test with mock API)
```

## When to Stop

A task is complete when:
- [ ] All tests pass
- [ ] Feature works as specified
- [ ] Code is documented
- [ ] Security concerns addressed
- [ ] No linting/type errors
- [ ] User confirms satisfaction

**Don't perfect working code** unless there's a specific issue.

## Task Status States

| State | Meaning | When to Use |
|-------|---------|-------------|
| pending | Not started | Future tasks |
| in_progress | Currently working | One at a time |
| completed | Done | Immediately after finishing |
| cancelled | No longer needed | Requirements changed |

**Rule:** Only ONE task in_progress at a time.

## Progress Reporting

Update user at key milestones:

```
"Completed: Data model and validation (3/6)
Current: Implementing API endpoint
Next: Integration tests"
```

This gives user visibility without overwhelming them.
