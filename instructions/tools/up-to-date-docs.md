# Context7 API Usage

## Purpose

Retrieve real-time documentation for software libraries, frameworks, and APIs via the Context7 API.

## When to Use

Activate when interaction involves:
- **Setup and Configuration**: Environment initialization questions ("How do I configure Next.js middleware?")
- **Code Generation**: Specific implementation requests ("Write a Prisma query for nested relations")
- **API Reference**: Method/property questions ("What are the Supabase auth methods?")
- **Framework Specifics**: Modern ecosystems (React, Vue, Svelte, Express, Tailwind, etc.)

## Two-Step Process

### Step 1: Find Library ID

```bash
# Search for library
curl -s "https://context7.com/api/v2/libs/search?libraryName=LIBRARY_NAME&query=TOPIC" | jq '.results[0]'
```

**Parameters:**
- `libraryName`: Core library name ("react", "fastapi")
- `query`: User's full question for relevance ranking

**Selection Criteria:**
- Exact name matches preferred
- Higher benchmark scores better
- Version-specific if user mentioned version (e.g., React 19)

**Key Response Fields:**
| Field | Description |
|-------|-------------|
| `id` | Unique identifier for context fetching (e.g., `/vercel/next.js`) |
| `title` | Human-readable name |
| `totalSnippets` | Volume of available documentation |

### Step 2: Fetch Documentation

```bash
# Retrieve relevant context
curl -s "https://context7.com/api/v2/context?libraryId=LIBRARY_ID&query=TOPIC&type=txt"
```

**Parameters:**
- `libraryId`: ID from Step 1
- `query`: Specific technical topic ("useState", "app router")
- `type`: `txt` for readability, `json` for structured data

## Examples

### React Hooks

```bash
# 1. Find library ID
curl -s "https://context7.com/api/v2/libs/search?libraryName=react&query=hooks" | jq '.results[0].id'
# Returns: "/websites/react_dev_reference"

# 2. Fetch documentation
curl -s "https://context7.com/api/v2/context?libraryId=/websites/react_dev_reference&query=useState&type=txt"
```

### Next.js Routing

```bash
# 1. Find library ID
curl -s "https://context7.com/api/v2/libs/search?libraryName=nextjs&query=routing" | jq '.results[0].id'
# Returns: "/vercel/next.js"

# 2. Fetch documentation
curl -s "https://context7.com/api/v2/context?libraryId=/vercel/next.js&query=app+router&type=txt"
```

## Best Practices

1. **Precision**: Pass user's full question as query parameter
2. **Version Control**: Select version-specific library ID if user mentioned version
3. **Authority**: Prefer official packages over community forks
4. **Readability**: Use `type=txt` for text-based responses
5. **Encoding**: URL-encode spaces (`+` or `%20`)
