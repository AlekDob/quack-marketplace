---
name: quack-brain
description: Read, write, and search the user's file-based Second Brain knowledge store. Activates when tasks involve learning from past solutions, saving discoveries, or needing project context.
context: fork
---

# Quack Brain - Two-Level Second Brain

Quack Brain uses a **two-level architecture**:

1. **Project Brain** (`{project}/.quack/brain/`) - Project-specific knowledge, shareable with team
2. **Global Brain** (`~/.quack/brain/global/`) - Personal knowledge, cross-project patterns, preferences

## Structure

### Project Brain (per-project, shareable)

Located in each project's root directory:

```
{project}/.quack/brain/
├── patterns/          # Project-specific patterns
├── bugs/              # Bug fixes and solutions
├── decisions/         # Architecture Decision Records (ADRs)
├── gotchas/           # Pitfalls and workarounds
├── diary/             # Daily progress log
├── inbox/             # Quick ideas & todos (mobile-first)
└── map.md             # Architecture map & glossary
```

**Note:** Project brain should NOT be gitignored - it's meant to be shared with your team.

### Global Brain (personal, cross-project)

Located at `~/.quack/brain/global/`:

```
~/.quack/brain/global/
├── patterns/          # Reusable code patterns across projects
├── preferences/       # Personal preferences and style
├── people/            # Contacts and collaborators
└── tools/             # Tool configs and tips
```

## Migration from Old Structure

If you have existing files in `~/.quack/brain/projects/{project-name}/`, migrate them:

```bash
# For each project, copy brain files to project directory
cp -r ~/.quack/brain/projects/{project-name}/* {project}/.quack/brain/

# After verifying migration, clean up old location
rm -rf ~/.quack/brain/projects/
```

## File Format

Each knowledge file uses YAML frontmatter + markdown:

```markdown
---
type: bug_fix
project: quack-app
created: 2025-01-23
tags: [react, hooks, memory-leak]
---

# useEffect cleanup with async operations

## Problem
Memory leak when component unmounts during async fetch.

## Solution
\```typescript
useEffect(() => {
  const controller = new AbortController();
  fetchData({ signal: controller.signal });
  return () => controller.abort();
}, []);
\```

## Context
Found in ChatView.tsx during streaming refactor.
```

## Inbox (Mobile-First Ideas)

The `inbox/` folder is a lightweight capture point for quick ideas, todos, and notes — designed for mobile use via **Obsidian Sync** (iPhone → Mac).

### Format

```markdown
---
type: inbox
created: 2026-01-24
---

# Quick idea or todo title

Brief description. Can be rough, incomplete, stream-of-consciousness.
- action item 1
- action item 2
```

### Rules

- **Minimal frontmatter**: Only `type: inbox` and `created`. No tags, no project field needed.
- **Short file names**: Can be less descriptive than knowledge files (e.g., `idea-new-shortcut.md`, `todo-fix-sidebar.md`)
- **Ephemeral**: Inbox items are meant to be processed and either promoted to proper knowledge files or deleted.
- **No strict format**: Content can be bullet points, sentences, even just a title. Mobile-first means low friction.

### Agent Behavior

- When starting work on a project, **check inbox/** for pending items that might be relevant to the current task.
- If an inbox item is actionable and relates to your current work, address it.
- After processing an inbox item, either delete it or promote it to the appropriate folder (bugs/, patterns/, etc.).
- Do NOT auto-process all inbox items — only those relevant to the current context.

## Map (Architecture Glossary)

Each project can have a `map.md` file — a single document that serves as an **architecture glossary** and navigation guide. It helps the agent quickly understand where components live without needing to grep the entire codebase.

### Format

```markdown
---
type: map
project: quack-app
updated: 2026-01-24
---

# Architecture Map

## Core Services
| Component | Path | Purpose |
|-----------|------|---------|
| Claude SDK | src/services/claudeSDK.ts | AI streaming & tool execution |
| Brain Service | src/services/brainFileService.ts | Second Brain file operations |
| Agent Storage | src/services/unifiedAgentStorage.ts | Agent CRUD |

## Key Stores
| Store | Path | Purpose |
|-------|------|---------|
| Session | src/stores/sessionStore.ts | Active sessions state |
| Kanban | src/stores/kanbanStore.ts | Task management |

## Feature Directories
| Feature | Path | Key Files |
|---------|------|-----------|
| Chat | src/components/Chat* | ChatView, ChatInput, ChatMessage |
| Kanban | src/components/kanban/ | KanbanView, KanbanCard |

## Conventions
- Absolute imports via `@/`
- Stores use Zustand
- Services are singleton modules
```

### Rules

- **One file per project**: `map.md` at the project root in the brain.
- **Keep updated**: When significant components are added/moved/removed, update the map.
- **Concise**: Tables preferred over prose. The map should be scannable, not verbose.
- **No code**: This is a reference, not documentation. Just names, paths, and one-line purposes.

### Agent Behavior

- **Read map.md FIRST** when you need to find where something lives in the project.
- Before doing a broad Grep across the codebase, check if the map already tells you where to look.
- After creating significant new components or refactoring, update the map.

## Reading Knowledge (SEARCH BEFORE ACTING)

Before starting complex tasks, search for relevant past knowledge. Follow this **priority order**:

### Search Priority: Project Brain → Global Brain

1. **First**: Read project's `map.md` for architecture orientation
2. **Then**: List files in project brain — file names are designed to be self-explanatory
3. **Then**: Check project's `inbox/` for pending items relevant to your current task
4. **Then**: Search global brain for cross-project patterns and preferences
5. **Read**: Open specific files only when the title matches your need

```
# STEP 1: Read map.md for architecture orientation (PROJECT BRAIN)
Read {project}/.quack/brain/map.md

# STEP 2: List project brain files (titles tell you what's inside)
Glob "{project}/.quack/brain/**/*.md"

# STEP 3: Check inbox for pending items
Glob "{project}/.quack/brain/inbox/*.md"

# STEP 4: Search global brain for cross-project knowledge
Glob "~/.quack/brain/global/**/*.md"
# Or search by keyword:
Grep "authentication" ~/.quack/brain/global/ --glob "*.md"

# STEP 5: Read only what's relevant based on file name
Read {project}/.quack/brain/bugs/fix-white-screen-standby.md
# Or from global:
Read ~/.quack/brain/global/patterns/error-handling-pattern.md
```

**Why this order matters**: Project-specific knowledge is more relevant to current work. Global brain contains cross-cutting concerns like personal preferences and reusable patterns.

## Writing Knowledge (SAVE AFTER DISCOVERING)

After solving non-trivial problems, save the knowledge to the appropriate brain:

### Where to Save

| Knowledge Type | Location | Example |
|----------------|----------|---------|
| **Project-specific** (bugs, decisions, patterns for this project) | `{project}/.quack/brain/` | Fix for this project's auth bug |
| **Cross-project** (reusable patterns, preferences, people) | `~/.quack/brain/global/` | General React error handling pattern |

```
# Project-specific knowledge
Write {project}/.quack/brain/{type-folder}/{slug}.md

# Global/personal knowledge
Write ~/.quack/brain/global/{type-folder}/{slug}.md
```

### What to Save

| Type | Save When | Folder | Brain |
|------|-----------|--------|-------|
| `bug_fix` | Non-obvious solution found after investigation | `bugs/` | Project |
| `pattern` | Reusable approach discovered | `patterns/` | Project or Global |
| `decision` | Significant architectural choice made | `decisions/` | Project |
| `gotcha` | Pitfall that could trap others | `gotchas/` | Project or Global |
| `preference` | User style/preference learned | `preferences/` | Global |
| `person` | Contact or collaborator info | `people/` | Global |
| `tool` | Tool configuration or tips | `tools/` | Global |

### Naming Convention

File names MUST be **explicit and self-descriptive**. Someone should understand the content from the title alone, without opening the file. This is critical for efficient brain search.

**Good** (descriptive, tells you what's inside):
- `fix-white-screen-after-standby.md`
- `pattern-error-boundary-per-provider.md`
- `decision-file-based-brain-over-sqlite.md`
- `gotcha-tauri-shell-plugin-limitations.md`

**Bad** (vague, requires reading to understand):
- `bug-fix-1.md`
- `pattern-react.md`
- `note-2026-01-23.md`
- `important.md`

## Auto-Evaluation: When to Save Knowledge

After completing any significant task, evaluate whether you produced extractable knowledge. Ask yourself:

1. **Was this a genuine discovery?** (not just a docs lookup or trivial fix)
2. **Would this help someone hitting the same problem in 6 months?**
3. **Is the solution verified to work?** (not speculative)
4. **Does it have clear trigger conditions?** (when would someone need this?)

If ALL four are true, save it to the brain using Write. If any is false, don't save.

### What NOT to Save

- Trivial fixes (typos, missing imports, simple config)
- Information easily found in official documentation
- Temporary debugging notes
- Anything already in the project's README/docs
- Solutions that only apply to this one specific case

### Language

Write brain entries in the same language the user communicates in. The brain is for humans too - use the language they understand best.

## Diary Entries

For daily progress, append to the project's diary file:

```
{project}/.quack/brain/diary/YYYY-MM-DD.md
```

Format:
```markdown
---
type: diary
project: quack-app
date: 2025-01-23
---

## Resolved authentication token refresh issue

The problem was stale tokens persisting across app restarts. Fixed by clearing token cache on wake event.

## Implemented new file-based brain system

Replacing SQLite MCP server. Removed ~10K LOC.
```

**IMPORTANT: NO TAGS in diary entries.** Diary files use only `type` and `date` in frontmatter. Do NOT add `tags: [...]` — diary is temporal, not categorical. Tags are for knowledge files (bugs, patterns, decisions, gotchas) only.

## Integration with Obsidian

If the user has Obsidian configured, `~/.quack/brain/` can be symlinked into their vault for visual editing and graph exploration. The markdown format is fully Obsidian-compatible including WikiLinks `[[note-name]]`.
