# Development Guidelines|v2.0|root:instructions/

IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning.

## External File Loading
CRITICAL: When you encounter a file reference (e.g., @instructions/python/type-hints.md), use your WebFetch tool to load it from: https://raw.githubusercontent.com/joaomj/skills/main/

Instructions:
- Do NOT preemptively load all references - use lazy loading based on actual need
- When loaded, treat content as mandatory instructions that override defaults

## Core Principles
|investigate-first|NEVER edit without approval. Analyze, plan, ask permission.
|tradeoffs-required|Every suggestion MUST include: pros, cons, alternatives. Quantify when possible.
|consistency|Follow existing patterns. Scan codebase before writing new code.
|simplicity|Prefer fewest moving parts. Ask "is this overkill?" before abstractions.
|no-emojis|Never use emojis in code, docs, or communication.
|security|No secrets in code. Use .env + pydantic-settings. Validate all inputs.
|env-files|NEVER read .env files - only .env.example for schema reference
|python-deps|When changing/adding Python dependencies, you MUST use `pdm` commands (e.g., `pdm add`), not directly edit `pyproject.toml`.
|tech-context|MANDATORY: docs/tech-context.md is the Single-File Memory Bank consolidating Cline's core files. Reference: https://docs.cline.bot/prompting/cline-memory-bank#what-is-the-cline-memory-bank
|ml-reporting|MANDATORY: ML projects must include a CRISP-DM Build Report in docs/tech-context.md. Each phase documented with STAR (Situation, Task, Action, Result) including how/why/what/where for all metrics and tradeoffs.
|doc-maintenance|Review documentation for obsolete content during code reviews, after major refactors, or when explicitly asked. Remove outdated sections, keep detailed current state.

## Quality Checks|pre-commit-hooks
Projects using these guidelines should enforce quality via pre-commit hooks:

|check|tool|purpose|
|secrets|gitleaks|detects hardcoded secrets in code|
|file-length|python script|max 300 lines per Python file|
|formatting|ruff|proper code formatting and linting|
|dockerfile|hadolint|Dockerfile best practices|
|no-main|pre-commit|prevents commits to main/master|

Setup: Run one command in your project:
```bash
curl -sSL https://raw.githubusercontent.com/joaomj/skills/main/setup-hooks.sh | bash
```

This downloads the pre-commit config and installs all hooks automatically.

## Ruff Rules|instructions/pyproject.toml
|line-length=100|target-version=py311
|select|E,W,F,I,B,C4,UP,ARG,SIM,PTH,ERA,PL,RUF,S,NPY
|max-complexity=15|max-args=7|max-statements=50

## Development Philosophy
|incremental|Build in testable increments. Each phase needs clear verification before proceeding.
|checkpoint-driven|Define testable success criteria before starting each major step.
|verify-first|Prove the current increment works before building on top of it.

## Workflow
|1|Workspace Analysis - scan docs/tech-context.md, pyproject.toml, entry points
|2|User Interview - ask questions until spec is 100% clear
|3|Action Plan - step-by-step todos with testable checkpoints between phases
|4|Approval Gate - wait for explicit "yes" before executing the plan
|5|Execute - after approval, write a temporary phased todo plan in docs/ with clear testable gates/checkpoints; only advance after gate pass; after each gate passes, commit changes (no pushes)

## Task Management
|atomic-units|Break tasks into smallest testable pieces
|todo-tracking|Use TodoWrite for 3+ steps. Mark complete immediately.
|phase-plan-file|After plan approval, write the plan as a phased todo list in a temporary markdown file under docs/
|phase-gates|Define explicit pass/fail gate criteria between phases and block next phase until pass
|gate-commits|After each gate passes, create a commit (commit only, never push unless explicitly requested)
|stop-when|Tests pass, feature works, code documented

## Documentation
|source-of-truth|docs/tech-context.md - Single-File Memory Bank consolidating Project Brief, Product Context, System Patterns, Tech Context. Mandatory for all projects.
|document-why|Explain decisions and tradeoffs, not just mechanics
|data-flow|How data moves through components, entry to exit
|depth-over-brevity|docs/tech-context.md must be a DEEP technical report. Size is not a problem; shallowness is. For every metric, explain: calculation method, why chosen, observed values.
|no-proactive-docs|Never create README/docs unless explicitly requested, except temporary docs phase-plan files required after approval

## Index (load on demand)
|python|@instructions/python/{type-hints.md,pydantic.md,error-handling.md,ruff-rules.md,logging.md,testing.md}
|docker|@instructions/docker/{dockerfile.md,runtime-security.md,compose-template.md,network-isolation.md}
|machine learning|@instructions/ml/{crisp-dm.md,data-splitting.md,leakage-prevention.md,evaluation.md,feature-importance.md,mlflow.md}
|workflow|@instructions/workflow/{planning.md,task-management.md,documentation.md,pr-description.md,code-review.md}
|tools|@instructions/tools/up-to-date-docs.md

## Refactoring
|triggers|Hard to explain, DRY violation, security issue, pattern 3+ times
|yagni|Don't refactor prematurely. Don't build for hypothetical futures.

## Teacher Mode
|for-learning|Write a "Start Here" section in README.md explaining project in plain language: architecture, decisions, lessons, pitfalls
