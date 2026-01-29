---
description: "Use Quack Brain as Second Brain - file-based knowledge storage in ~/.quack/brain/"
---

# Quack Brain - Second Brain

File-based knowledge store using markdown files with YAML frontmatter.

## When to SEARCH Brain

- Before answering questions you're unsure about
- When investigating bugs or issues
- When making architectural decisions
- When user asks about past work or decisions

## Search Priority

1. Read map.md for architecture orientation
2. List project files (titles are self-descriptive)
3. Check inbox/ for pending items
4. Search globally if needed
5. Read specific files matching your need

## When to SAVE to Brain

- Tricky bug fixes
- Patterns that work well
- Architectural decisions and rationale
- Solutions useful in the future
- Configuration gotchas

## Auto-Evaluation

After significant tasks, evaluate:
1. Genuine discovery? (not docs lookup)
2. Would help in 6 months?
3. Solution verified?
4. Clear trigger conditions?

All true -> save. Any false -> don't save.

## Directory Structure

~/.quack/brain/
- global/ (patterns, preferences, people, tools)
- projects/{name}/ (patterns, bugs, decisions, gotchas, diary, inbox, map.md)
