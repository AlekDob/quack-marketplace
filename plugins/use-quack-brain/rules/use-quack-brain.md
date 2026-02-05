---
description: "Use Quack Brain as Second Brain - two-level knowledge storage"
---

# Quack Brain - Two-Level Second Brain

File-based knowledge store using markdown files with YAML frontmatter.

## Architecture

Two levels of knowledge storage:

1. **Project Brain** (`{project}/.quack/brain/`) - Project-specific, shareable with team
2. **Global Brain** (`~/.quack/brain/global/`) - Personal, cross-project patterns

## When to SEARCH Brain

- Before answering questions you're unsure about
- When investigating bugs or issues
- When making architectural decisions
- When user asks about past work or decisions

## Search Priority: Project → Global

1. Read project's `map.md` for architecture orientation
2. List project brain files (titles are self-descriptive)
3. Check project's `inbox/` for pending items
4. Search global brain for cross-project patterns
5. Read specific files matching your need

## When to SAVE to Brain

**Project Brain** (`{project}/.quack/brain/`):
- Bug fixes specific to this project
- Architecture decisions for this project
- Project-specific patterns and gotchas

**Global Brain** (`~/.quack/brain/global/`):
- Reusable patterns across projects
- Personal preferences and style
- People and contacts
- Tool configurations

## Auto-Evaluation

After significant tasks, evaluate:
1. Genuine discovery? (not docs lookup)
2. Would help in 6 months?
3. Solution verified?
4. Clear trigger conditions?

All true -> save. Any false -> don't save.

## Directory Structure

```
{project}/.quack/brain/        # Project-specific (shareable)
├── patterns/
├── bugs/
├── decisions/
├── gotchas/
├── diary/
├── inbox/
└── map.md

~/.quack/brain/global/         # Personal (cross-project)
├── patterns/
├── preferences/
├── people/
└── tools/
```
