# OpenCode Agent Guidelines

A Vercel-style knowledge base for AI coding agents, optimized for software engineering and machine learning tasks.

## Philosophy

This repository follows the [Vercel research finding](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) that **passive context outperforms active skill invocation**. Instead of hoping agents remember to load skills, we embed a compressed index that is always available, then retrieve specific instructions on demand.

## How It Works

### The Index: AGENTS.md (Hosted on GitHub)

The root `AGENTS.md` file is a compressed, pipe-delimited index that:
- Loads into context on every agent session (~2.7KB)
- Contains critical principles and workflow rules
- Uses lazy-loading to fetch detailed instructions from GitHub on demand
- Includes the directive: **"Prefer retrieval-led reasoning over pre-training-led reasoning"**

### The Knowledge Base: instructions/ (Hosted on GitHub)

Detailed instructions organized by domain, retrieved via GitHub raw URLs when needed:

```
instructions/
├── python/           # Python-specific guidelines
├── docker/           # Container security and best practices
├── ml/               # Machine learning methodology
├── workflow/         # Development workflows and processes
├── tools/            # External tool usage (APIs, etc.)
├── .pre-commit-config.yaml  # Pre-commit hooks template
├── pyproject.toml    # Ruff and pyright configuration
└── check_file_length.py     # File length validation script
```

## Agent Workflow State Machine

```
┌─────────────────┐
│   AGENTS.md     │
│  Index Loaded   │
│  (Always On)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Parse Request  │
│  Identify Domain│
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│ Need Python     │────▶│ Read python/    │
│ Guidance?       │     │ type-hints.md   │
└─────────────────┘     └─────────────────┘
         │
         ├─────────────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐  ┌─────────────────┐
│ Need Docker     │  │ Need ML         │
│ Security?       │  │ Guidance?       │
└────────┬────────┘  └────────┬────────┘
         │                    │
         ▼                    ▼
┌─────────────────┐  ┌─────────────────┐
│ Read docker/    │  │ Read ml/        │
│ dockerfile.md   │  │ crisp-dm.md     │
└─────────────────┘  └─────────────────┘
         │                    │
         └──────────┬─────────┘
                    │
                    ▼
         ┌─────────────────┐
         │  Apply Knowledge│
         │  Generate Code  │
         └─────────────────┘
```

## Directory Structure

### instructions/python/
Type hints, Pydantic patterns, error handling, Ruff rules, structured logging, and testing guidelines for modern Python development.

### instructions/docker/
Dockerfile security, runtime flags, compose templates, and network isolation strategies.

### instructions/ml/
CRISP-DM methodology, data splitting strategies, leakage prevention, evaluation metrics, feature importance, and MLflow tracking.

### instructions/workflow/
Investigation workflows, task management with testable checkpoints, documentation guidelines, code review process, and PR templates.

### instructions/tools/
Instructions for external APIs and tools (e.g., Context7 for library documentation).

## Multi-Machine Setup

### Configure OpenCode Globally

On each machine, add to `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "https://raw.githubusercontent.com/joaomj/skills/main/AGENTS.md"
  ]
}
```

See `opencode.example.json` in this repo for a complete template.

### Benefits

- Single source of truth on GitHub
- Updates propagate automatically after pushing changes
- No manual file copying across machines
- Works on any machine with internet access

## Pre-Commit Hooks

Enable automatic quality checks in your project with one command:

```bash
curl -sSL https://raw.githubusercontent.com/joaomj/skills/main/setup-hooks.sh | bash
```

This downloads the pre-commit config and installs hooks that check for:
- **Secrets** - gitleaks detects hardcoded secrets in code
- **File length** - max 300 lines per Python file
- **Formatting** - ruff ensures proper code formatting and linting
- **Dockerfile best practices** - hadolint enforces security rules
- **No main commits** - prevents direct commits to main/master

Hooks run automatically on every `git commit`.

## Key Principles

1. **Investigate First** - Never edit without approval. Analyze, plan, then ask permission.
2. **Tradeoffs Required** - Every suggestion must include pros, cons, and alternatives.
3. **Quality Checks at Task Completion** - Before marking a task done, run tests and document changes. Pre-commit hooks enforce quality rules when committing.
4. **Retrieval-Led Reasoning** - Always read relevant docs before generating code, don't rely on training data.
5. **Incremental Checkpoint-Driven** - Build in testable increments with verified success criteria before proceeding.
6. **No .env Files** - Never read .env files; only .env.example for schema reference.

## Why This Works (metrics from Vercel test)

| Approach | Pass Rate | Why |
|----------|-----------|-----|
| No guidelines | 53% | Agent uses outdated training |
| Skill invocation | 53-79% | Agent forgets to invoke skills |
| **AGENTS.md index** | **100%** | **Always loaded, no decision point** |

The key insight: **removing the decision to "look something up"** eliminates the failure mode where agents don't use available knowledge.

## License

MIT License - See [LICENSE](LICENSE) file.
