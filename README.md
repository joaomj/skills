# OpenCode Agent Guidelines

A Vercel-style knowledge base for AI coding agents, optimized for software engineering and machine learning tasks.

## Philosophy

This repository follows the [Vercel research finding](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) that **passive context outperforms active skill invocation**. Instead of hoping agents remember to load skills, we embed a compressed index that is always available, then retrieve specific instructions on demand.

## How It Works

### The Index: AGENTS.md

The root `AGENTS.md` file is a compressed, pipe-delimited index that:
- Loads into context on every agent session (~2.7KB)
- Contains critical principles and workflow rules
- Points to detailed instructions in `agents/`
- Includes the directive: **"Prefer retrieval-led reasoning over pre-training-led reasoning"**

### The Knowledge Base: agents/

Detailed instructions organized by domain, retrieved only when needed:

```
agents/
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

### agents/python/
Type hints, Pydantic patterns, error handling, and Ruff rules for modern Python development.

### agents/docker/
Dockerfile security, runtime flags, compose templates, and network isolation strategies.

### agents/ml/
CRISP-DM methodology, data splitting strategies, leakage prevention, evaluation metrics, feature importance, and MLflow tracking.

### agents/workflow/
Investigation workflows, task management patterns, documentation guidelines, and PR templates.

### agents/tools/
Instructions for external APIs and tools (e.g., Context7 for library documentation).

## Usage

### For Agent Users

The agent automatically loads `AGENTS.md` at the start of every session. Based on your request, it will:
1. Identify the relevant domain (python, docker, ml, workflow, tools)
2. Read specific instruction files from `agents/`
3. Apply the guidelines to generate code

### For Developers

To use the pre-commit hooks and linting configs in your projects:

```bash
# Copy config files to your project
cp agents/.pre-commit-config.yaml ./
cp agents/pyproject.toml ./
cp agents/check_file_length.py ./

# Install pre-commit
pip install pre-commit
pre-commit install
```

## Key Principles

1. **Investigate First** - Never edit without approval. Analyze, plan, then ask permission.
2. **Tradeoffs Required** - Every suggestion must include pros, cons, and alternatives.
3. **Enforcement via Pre-commit** - Critical rules (secrets, file length, formatting) are enforced, not just suggested.
4. **Retrieval-Led Reasoning** - Always read relevant docs before generating code, don't rely on training data.

## Why This Works (metrics from Vercel test)

| Approach | Pass Rate | Why |
|----------|-----------|-----|
| No guidelines | 53% | Agent uses outdated training |
| Skill invocation | 53-79% | Agent forgets to invoke skills |
| **AGENTS.md index** | **100%** | **Always loaded, no decision point** |

The key insight: **removing the decision to "look something up"** eliminates the failure mode where agents don't use available knowledge.

## License

MIT License - See [LICENSE](LICENSE) file.
