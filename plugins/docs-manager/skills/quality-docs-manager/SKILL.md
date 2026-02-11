---
name: quality-docs-manager
description: Use this skill when managing project documentation quality through the Second Brain, creating Architecture Decision Records (ADRs), auditing knowledge gaps, maintaining the architecture map, cross-referencing brain entries, or performing documentation health checks. Also use when the user says "document this", "create an ADR", "update the map", "what's missing in the brain", or "knowledge audit".
---

# Quality Documentation Manager

A structured approach to managing project knowledge through Quack Brain. This skill turns the Second Brain into a well-curated, navigable, and complete knowledge base.

## Brain Path Discovery

**ALWAYS read `~/.quack/brain-path` first** to discover the brain location. If missing, fall back to `~/.quack/brain/`.

## Core Capabilities

### 1. Architecture Decision Records (ADR)

Structured records for significant technical decisions. Saved in `decisions/`.

**Template:**

```markdown
---
type: decision
project: {project-name}
created: {YYYY-MM-DD}
status: accepted
tags: [{relevant-tags}]
---

# ADR: {Decision Title}

## Status
Accepted | Proposed | Deprecated | Superseded by [link]

## Context
What is the issue that we're seeing that is motivating this decision?

## Options Considered

### Option A: {Name}
- Pros: ...
- Cons: ...

### Option B: {Name}
- Pros: ...
- Cons: ...

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or more difficult to do because of this change?

## References
- Related decisions: [[decision-name]]
- Related patterns: [[pattern-name]]
```

**Naming:** `decision-{slug}.md` (e.g., `decision-file-based-brain-over-sqlite.md`)

**When to create:**
- Choosing between technologies or libraries
- Defining data storage strategies
- Changing architectural patterns
- Making trade-offs that affect the whole project

### 2. Knowledge Audit

Systematically check what's documented and what's missing.

**Audit Process:**

1. **Read map.md** to understand the project architecture
2. **List all brain entries** with `Glob "{project}/.quack/brain/**/*.md"`
3. **Compare against codebase** — identify key modules without documentation
4. **Check for staleness** — entries referencing files/patterns that no longer exist
5. **Generate audit report** as a diary entry

**Audit Report Template:**

```markdown
---
type: diary
project: {project-name}
date: {YYYY-MM-DD}
---

# Knowledge Audit - {date}

## Coverage Summary
- Patterns documented: X
- Bug fixes recorded: X
- Decisions logged: X
- Gotchas captured: X

## Gaps Identified
- [ ] {Module/feature} has no pattern documentation
- [ ] {Recent refactor} has no decision record
- [ ] {Known issue} not in gotchas

## Stale Entries
- {entry-name}.md references {old-file} which was removed/moved

## Actions
- Create pattern for {module}
- Update map.md with {new-component}
- Archive {stale-entry}
```

### 3. Map Maintenance

The `map.md` file is the architecture glossary. Keep it current and navigable.

**Maintenance Rules:**
- Update after every significant component addition/removal/rename
- Use tables: Component | Path | Purpose
- Group by domain (Core Services, Stores, Features, etc.)
- Keep concise — one line per component
- Include last-updated date in frontmatter

**When to update map.md:**
- New service or store created
- Major component refactored or moved
- Feature directory restructured
- After completing a knowledge audit

### 4. Cross-Referencing

Link related brain entries using WikiLinks `[[entry-name]]` for Obsidian compatibility.

**Cross-reference patterns:**
- Bug fix → Pattern that prevents it: `See [[pattern-error-boundary-per-provider]]`
- Decision → Gotcha it introduces: `Watch out for [[gotcha-tauri-shell-plugin-limitations]]`
- Pattern → Decision that adopted it: `Adopted in [[decision-file-based-brain-over-sqlite]]`

**When cross-referencing:**
- After creating a new entry, scan existing entries for related content
- After an audit reveals related but unlinked entries
- When a bug fix reveals a pattern worth documenting

### 5. Documentation Health Check

Quick assessment of brain quality. Run periodically or before releases.

**Health Metrics:**

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| map.md updated | < 2 weeks | 2-4 weeks | > 1 month |
| Entries per active feature | >= 1 | 0 for some | 0 for most |
| Stale entries | 0 | 1-3 | > 3 |
| Cross-references | Common | Rare | None |
| Diary frequency | Weekly+ | Monthly | Never |

### 6. Entry Quality Standards

Every brain entry should meet these criteria:

**Required:**
- YAML frontmatter with `type`, `project`, `created`, `tags`
- Self-descriptive file name (no `note-1.md` or `fix.md`)
- Clear problem/context section
- Verified solution (not speculative)

**Recommended:**
- Cross-references to related entries `[[link]]`
- Code examples where relevant
- Trigger conditions (when would someone need this?)

**File Name Convention:**
- Prefix with type: `fix-`, `pattern-`, `decision-`, `gotcha-`
- Use kebab-case
- Be specific: `fix-white-screen-after-standby.md` not `fix-screen-bug.md`

## Workflows

### After Completing a Feature

1. Check if an ADR exists for the key decisions made
2. Create patterns for any reusable approaches discovered
3. Update map.md with new components
4. Add diary entry summarizing the work
5. Cross-reference new entries with existing ones

### After Fixing a Bug

1. Check if the fix is non-trivial (worth documenting)
2. Create bug fix entry with problem, root cause, solution
3. Check if a pattern would prevent this class of bugs
4. Update gotchas if the bug had a surprising root cause
5. Cross-reference with related entries

### Periodic Maintenance (Weekly/Before Release)

1. Run knowledge audit
2. Check map.md accuracy
3. Process inbox items
4. Update stale entries
5. Health check metrics
6. Diary entry with findings

## Integration with Quack Brain

This skill works exclusively with the file-based Quack Brain system:

- **Read**: `Read`, `Grep`, `Glob` for searching and reading
- **Write**: `Write`, `Edit` for creating and updating
- **No MCP**: Direct file operations only
- **No /docs**: Brain is the single source of knowledge truth

## Language

Write entries in the same language the user communicates in. The brain is for humans — use their preferred language.
