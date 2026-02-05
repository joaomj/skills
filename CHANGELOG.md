# Changelog

All notable changes to the OpenCode Agent Guidelines.

## [2.2.0] - 2025-02-04

### Added

- **Multi-Machine Support** - AGENTS.md now loads via GitHub URL
  - Update global opencode.json with `instructions` field
  - Lazy-loading from `https://raw.githubusercontent.com/joaomj/skills/main/`
  - Added `opencode.example.json` as setup template
  - Enables consistent agent behavior across 4+ machines

- **External File Loading** (AGENTS.md)
  - WebFetch-based lazy loading for instruction files
  - `@instructions/python/type-hints.md` syntax
  - 5-second timeout per remote fetch
  - Reduces initial context load

- **One-Command Pre-Commit Setup** (`setup-hooks.sh`)
  - Automatic installation of quality checks in any project
  - Downloads pre-commit config and custom hooks
  - Config updates to use local file-length script

### Changed

- **AGENTS.md** - Replaced local path references with GitHub URLs
- **AGENTS.md** - Replaced "Enforcement|pre-commit" with "Quality Checks|pre-commit-hooks"
- **AGENTS.md** - Updated "stop-when" to remove "security addressed" (now handled by pre-commit hooks)
- **README.md** - Updated documentation for GitHub-based setup
- **README.md** - Added "Multi-Machine Setup" section
- **README.md** - Replaced "Usage" section with pre-commit hooks setup
- **README.md** - Updated "Key Principles" #3 to reflect pre-commit quality checks
- **CHANGELOG.md** - Added v2.2.0 entry documenting all changes

## [2.1.0] - 2024-02-04

### Added

- **Structured Logging Policy** (`instructions/python/logging.md`)
  - JSON structured logging format requirement
  - Trace IDs for distributed systems / Run IDs for batch-ML systems
  - Context propagation patterns
  - Explicit ban on logging secrets (P1 security requirement)

- **Testing Policy** (`instructions/python/testing.md`)
  - Test behavior, not implementation philosophy
  - Strict anti-mock-abuse rules (only external I/O)
  - 70/20/10 test pyramid ratios
  - Clear guidance on when NOT to test

- **Code Review Guidelines** (`instructions/workflow/code-review.md`)
  - P1/P2/P3 priority classification system
  - Per-file review format
  - `CODE_REVIEW.md` document generation at project root
  - Only reports issues (clean files ignored)
  - Suggests fixes, never implements

- **Custom Code Review Command** (`commands/codereview.md`)
  - `/codereview` slash command for OpenCode TUI
  - Supports default (origin/main...HEAD) and custom scopes
  - Generates priority-based review documents

- **Development Philosophy** (AGENTS.md)
  - `|incremental|` - Build in testable increments
  - `|checkpoint-driven|` - Define testable success criteria
  - `|verify-first|` - Prove increment works before building on it

- **Architecture Tradeoff Documentation** (`instructions/workflow/documentation.md`)
  - Mandatory "Why This Architecture" sections
  - Alternatives considered table format
  - Explicit tradeoffs documentation
  - Revisit conditions

### Changed

- **AGENTS.md Updates**
  - Added `|env-files|` principle: NEVER read .env files, only .env.example
  - Added Development Philosophy section
  - Updated workflow indices to include logging.md, testing.md, code-review.md
  - Workflow step 5 now explicitly ends with "update docs/tech-context.md when done"
  - Workflow step 3 emphasizes "testable checkpoints between phases"

- **Workflow Planning** (`instructions/workflow/planning.md`)
  - Added explicit warning: NEVER read .env files
  - Redefined checkpoints as "testable functionality gates"
  - Added checkpoint table with phase-specific test criteria
  - Step 5 After Changes now explicitly updates docs/tech-context.md

- **Task Management** (`instructions/workflow/task-management.md`)
  - Added "Implementation Plan Checkpoints" section
  - Each major step must have clear test criteria before proceeding

- **Documentation Guidelines** (`instructions/workflow/documentation.md`)
  - Added required Architecture Tradeoff Documentation section
  - Mandates explaining "why this architecture" in all tech-context.md and Start Here sections

## [2.0.0] - Previous Release

- Initial structured guidelines with AGENTS.md index
- Python, Docker, ML, Workflow instruction categories
- Pre-commit enforcement (gitleaks, ruff, hadolint, file length)
- Vercel-style retrieval-led reasoning approach

---

## Format

This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

Versioning: MAJOR.MINOR.PATCH
- MAJOR: Breaking changes to workflow or core principles
- MINOR: New instructions, features, or significant enhancements
- PATCH: Bug fixes, clarifications, minor updates
