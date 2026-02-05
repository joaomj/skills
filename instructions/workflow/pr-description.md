# PR Description Template

## Purpose

Create a structured PR description file at project root for copy/paste into GitHub.

## When to Use

When user wants a PR description they can manually paste into GitHub.

## Workflow

1. Determine project root (git top-level or current directory)
2. Check git status and diff between current and target branch
3. Create/overwrite `PR_DESCRIPTION.md` at project root
4. Populate template below with extracted information
5. Report file path to user

## Template

```markdown
# Pull Request

## Summary

**What:**
[Brief description of changes from git diff]

**Why:**
[Problem being solved or feature being added]

**Impact:**
[How this affects users/system/performance]

## Related Work

- Closes #[issue_number]
- Relates to #[issue_number]

## Changes

- **Feature** - [New capability added]
- **Fix** - [Bug fixed]
- **Refactor** - [Code restructuring]
- **Docs** - [Documentation updates]
- **Config** - [Configuration changes]

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Edge cases considered

**How to test:**
[Step-by-step testing instructions]

## Deployment Notes

- **Breaking changes:** [None/List them]
- **Database changes:** [Migrations required?]
- **Config updates needed:** [Environment variables?]
- **Third-party APIs:** [New integrations?]

## Review Focus

[What reviewers should pay special attention to]

## Checklist

- [ ] Code follows style guidelines
- [ ] No secrets or sensitive data committed
- [ ] Documentation updated (if needed)
- [ ] Tests pass (CI/CD)
- [ ] Ready for production deployment

## Notes

[Any additional context for reviewers]
```

## Git Commands for Information

```bash
# Get changed files
git diff --name-status main...HEAD

# Get diff summary
git diff --stat main...HEAD

# Get commit messages
git log main...HEAD --oneline

# Get current branch
git branch --show-current
```

## Do NOT

- Do NOT create the actual PR (use gh CLI or GitHub UI)
- Do NOT change git state beyond writing the file
- Do NOT modify commit history
- Do NOT push branches automatically

## Example Output

After running, user should see:

```
Created PR_DESCRIPTION.md at /path/to/project/PR_DESCRIPTION.md

Next steps:
1. Review the description
2. Copy contents to GitHub PR
3. Or run: gh pr create --body-file PR_DESCRIPTION.md
```
