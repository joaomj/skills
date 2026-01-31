# Development Guidelines|v2.0|root:agents/

IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning.
Read files from agents/ before generating code.

## Core Principles
|investigate-first|NEVER edit without approval. Analyze, plan, ask permission.
|tradeoffs-required|Every suggestion MUST include: pros, cons, alternatives. Quantify when possible.
|consistency|Follow existing patterns. Scan codebase before writing new code.
|simplicity|Prefer fewest moving parts. Ask "is this overkill?" before abstractions.
|no-emojis|Never use emojis in code, docs, or communication.
|security|No secrets in code. Use .env + pydantic-settings. Validate all inputs.

## Enforcement|pre-commit
|secrets|gitleaks - blocks commits with hardcoded secrets
|file-length|max 300 lines per Python file
|formatting|ruff format + ruff check --fix
|dockerfile|hadolint - enforces non-root, minimal base, no ADD
|config|agents/.pre-commit-config.yaml

## Ruff Rules|agents/pyproject.toml
|line-length=100|target-version=py311
|select|E,W,F,I,B,C4,UP,ARG,SIM,PTH,ERA,PL,RUF,S,NPY
|max-complexity=15|max-args=7|max-statements=50

## Workflow
|1|Workspace Analysis - scan docs/tech-context.md, pyproject.toml, entry points
|2|User Interview - ask questions until spec is 100% clear
|3|Action Plan - step-by-step todos with testable checkpoints
|4|Approval Gate - wait for explicit "yes" before executing the plan
|5|Execute - explain changes before applying, mark todos complete

## Task Management
|atomic-units|Break tasks into smallest testable pieces
|todo-tracking|Use TodoWrite for 3+ steps. Mark complete immediately.
|stop-when|Tests pass, feature works, code documented, security addressed

## Documentation
|source-of-truth|docs/tech-context.md - update when architecture changes
|document-why|Explain decisions and tradeoffs, not just mechanics
|data-flow|How data moves through components, entry to exit
|no-proactive-docs|Never create README/docs unless explicitly requested

## Index|root:agents/
|python:{type-hints.md,pydantic.md,error-handling.md,ruff-rules.md}
|docker:{dockerfile.md,runtime-security.md,compose-template.md,network-isolation.md}
|ml:{crisp-dm.md,data-splitting.md,leakage-prevention.md,evaluation.md,feature-importance.md,mlflow.md}
|workflow:{planning.md,task-management.md,documentation.md,pr-description.md}
|tools:{context7.md}

## Refactoring
|triggers|Hard to explain, DRY violation, security issue, pattern 3+ times
|yagni|Don't refactor prematurely. Don't build for hypothetical futures.

## Teacher Mode
|for-learning|Write a "Start Here" section in README.md explaining project in plain language: architecture, decisions, lessons, pitfalls
