---
name: codebase-map
description: Auto-generated index of TypeScript/JavaScript exports for fast AI navigation. Reduces exploratory tool calls by 60-80% with a single Read of the codebase map.
---

# Codebase Map - Fast Code Navigation

You have access to a **Codebase Map** at `.quack/codebase-map.md` in the project root. This is an auto-generated index of all TypeScript/JavaScript exports in the project, updated automatically via PostToolUse hook.

## How It Works

```
Agent needs to find a function/component
    |
    v
Read ".quack/codebase-map.md" (~200-400 lines)
    |
    v
Find exact file:export in the map
    |
    v
Read that one file directly
```

**Before** (without map): Glob `**/*.ts` -> Grep "functionName" -> Read 3-4 files -> find the right one (4-6 tool calls)

**After** (with map): Read map -> Read target file (2 tool calls)

## When to Use

**ALWAYS read the codebase map BEFORE doing exploratory searches.** This saves multiple Glob/Grep/Read tool calls.

Check if `.quack/codebase-map.md` exists at the start of any code exploration task. If it exists, use it as your first reference.

## Rules

1. **Read map first**: Before any code exploration, check if `.quack/codebase-map.md` exists and read it
2. **Go direct**: Once you find the export you need, read that specific file
3. **Map may not exist**: If the file doesn't exist, fall back to normal Glob/Grep exploration
4. **Map is auto-updated**: A PostToolUse hook keeps it current when files are written
5. **One Read saves many**: Reading the map (~200-400 lines) is cheaper than 5-10 exploratory tool calls

## When to Skip the Map

- You already know the exact file path
- You're looking for content inside a file (not exports)
- The task is about non-code files (config, docs, etc.)

## Map Format

The map contains sections per file with exported symbols:

```
## src/stores/sessionStore.ts
- export fn useSessionStore() -> StoreApi<SessionState>
- export fn shouldArchiveSession(session) -> boolean
- export const sessionWriteLock

## src/services/modelService.ts
- export fn getModels(remoteModels?) -> ModelConfig[]
- export fn getModelId(shortId, remoteModels?) -> string
- export fn getModelOptions(remoteModels?) -> {value, label}[]
- export const FALLBACK_MODELS
```

## Setup

The Codebase Map is managed via Quack Settings:

1. Open **Settings** -> **Codebase Map**
2. Enable **Auto-update on file changes** for your project
3. Click **Generate** to create the initial map
4. The PostToolUse hook will keep it updated automatically

The generator script (`~/.quack/scripts/generate-codebase-map.mjs`) runs:
- **Full scan**: ~120ms for ~500 files
- **Incremental update**: ~2ms per file change

## Performance Impact

| Metric | Without Map | With Map |
|--------|-------------|----------|
| Tool calls to find a function | 4-6 | 2 |
| Context tokens for exploration | ~5000-10000 | ~1000-2000 |
| Time to first code modification | Slower | Faster |
