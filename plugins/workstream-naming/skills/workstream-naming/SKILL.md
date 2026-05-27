---
name: workstream-naming
description: Use this skill when creating new workstreams, renaming existing ones, or improving workstream titles for clarity and human-friendliness. Also use when coaching teams on workstream naming conventions and ensuring titles convey intent to non-technical stakeholders.
---

# Workstream Naming Framework

Human-friendly workstream names are the difference between "WS01" and "Claude SDK 0.2.138 → 0.3.150 upgrade with AskUserQuestion fix". This skill provides a framework for naming workstreams that **stakeholders understand immediately**.

## Core Principles

### 1. Lead with Business or User Value, Not Implementation

**Bad:** "Add git commands to CLI"
**Good:** "Git branch workflow visibility — surface uncommitted changes in sidebar"

**Bad:** "Refactor token tracking"
**Good:** "Stamina bar accuracy — fix prompt caching token counting for session limits"

### 2. Include the "Why" for Complex Projects

When the workstream title alone doesn't explain the motivation, append a brief reason in em-dashes.

**Good:** "Remote terminal API endpoints — eliminate SSH gateway friction for cloud agents"
**Good:** "MCP HTTP pool — reduce per-session stdio fanout overhead on Windows"

### 3. Use Active Language, Not Passive

**Bad:** "Support for Anthropic-compatible providers"
**Good:** "Multi-provider LLM support — Claude + z.ai + MiniMax in unified UI"

### 4. Avoid Jargon Unless Stakeholders Own It

**Bad:** "DDD refactor across domain boundaries"
**Good:** "Domain-driven code organization — group files by feature, not by type"

**Bad:** "Implement MCP token pooling with broadcast streams"
**Good:** "MCP HTTP server pool — shared connection pool per session to reduce stdio fanout"

## Naming Pattern

```
{feature/fix/refactor} {what} — {why/impact} [optional: stakeholder detail]
```

### Examples

| Workstream | Pattern |
|---|---|
| "Claude SDK 0.2.138 → 0.3.150 upgrade" | `{upgrade}` `{what}` — (why is obvious) |
| "ChangesPanel sub-repos section" | `{feature}` `{what}` — (how it works is the what) |
| "Handoff — fork session with summary" | `{feature}` `{what}` — `{impact}` |
| "Remote Terminal Management — API endpoints per terminal" | `{feature}` `{what}` — `{detail}` |
| "MCP HTTP Server Pool — eliminate per-session stdio fanout" | `{feature}` `{what}` — `{why/impact}` |

## Title Length Targets

- **Short form (ideal):** 40–60 characters (fits in sidebar without wrap)
  - "Stamina bar accuracy — fix prompt caching"
  - "Multi-provider LLM support — Claude + z.ai"

- **Long form (acceptable):** 60–100 characters (fits in workstream header)
  - "Remote Terminal Management — API endpoints visible to remote agents"
  - "MCP HTTP Pool — eliminate per-session stdio fanout on Windows build"

- **Too long:** >100 characters (doesn't fit INDEX.md table column)
  - ❌ "Implement a comprehensive multi-provider LLM integration layer supporting Claude, z.ai, MiniMax, and future Anthropic-compatible clones with unified UI and per-provider token calculation"

## Writing Checklist

Before finalizing a workstream title:

- [ ] **Is the "what" clear?** Can a non-technical person guess what the code does?
- [ ] **Is the "why" present (if needed)?** Do stakeholders understand the value?
- [ ] **Is it active voice?** "Add/fix/refactor X", not "X support" or "implementation"?
- [ ] **Does it avoid jargon?** (or explain it inline)
- [ ] **Is it 40–100 characters?** (fits in UI + readable)
- [ ] **Does it pass the "3-month test"?** Would you understand this 3 months from now?

## Common Patterns by Workstream Type

### Feature Launch

```
{Feature Name} — {user benefit} [{optional: integration detail}]
```

Examples:
- "File explorer context switching — jump between projects without tabs"
- "Whiteboard nested components — organize canvas into logical groups"
- "Automation job templates — cron presets + drag-copy for recurring tasks"

### Bug Fix

```
{Component/System} — fix {symptom} [for {context}]
```

Examples:
- "Token tracking — fix prompt caching zero-input fallback"
- "Session scroll memory — restore position after agent reply"
- "Windows path separators — prevent backslash collision in Git commands"

### Upgrade / Migration

```
{Library/System} {old version} → {new version} [+ {major change}]
```

Examples:
- "Claude Agent SDK 0.2.138 → 0.3.150 + Task tools migration"
- "React 18 → React 19 + Server Components migration"

### Refactor / Cleanup

```
{System} — {architectural goal} [{rationale in parens}]
```

Examples:
- "Tab system singleton — centralize state (eliminate race conditions on rapid switch)"
- "Dark theme CSS tokens — unify accent color across 40+ components"
- "Permission modes — split Build/Plan/Debug (respect user trust boundaries)"

### Performance / Optimization

```
{System} — {goal impact} [{measurement unit}]
```

Examples:
- "MCP HTTP pool — reduce per-session stdio fanout (20+ MCP servers)"
- "Token stats panel — unblock project switching (~2–3s blockage)"
- "Whiteboard render optimization — support 100+ feature nodes"

## Anti-Patterns

| ❌ Bad | ✅ Good | Reason |
|---|---|---|
| "WS01" (number only) | Name the workstream | Numbers don't convey intent |
| "Refactor" | "Tab system singleton — centralize session state" | Be specific about what |
| "Add feature X" | Lead with stakeholder value first | Passive, vague |
| "Bug fixes (misc)" | "Token tracking — fix prompt caching" | Group by root cause |
| "TBD" | Name it once scope is clear | Placeholder obscures progress |
| "Research spike" | "Anthropic-compatible provider integration research — evaluate z.ai, MiniMax, Kimi" | Be specific |

## When to Rename

Rename a workstream title if:

1. **Scope shifted significantly** — original name no longer reflects what's being built
   - Original: "Project-ops hooks" → Renamed to: "Project-ops native integration — Quack's spec system"
   
2. **It's unclear to new stakeholders** — jargon-heavy or missing the "why"
   - Original: "DDD refactor" → Renamed to: "Code organization — group files by feature, not by type"
   
3. **The component name changed** — the feature moved to a different part of the app
   - Original: "SearchPanel UX fix" → Renamed to: "Global search — surface Brain as first result"

**Do NOT rename** just to polish — workstreams should have stable titles so backlinks don't break. Only rename if it's a genuine scope or clarity issue.

## Stakeholder Visibility

When sharing workstream status with non-technical stakeholders (designers, product, leadership):

1. Lead with the title (they're reading only this)
2. Add a 1-line impact statement if non-obvious
   ```
   "Stamina bar accuracy — fix prompt caching"
   → "Stamina bar accuracy (fixes false 'out of tokens' warnings for long sessions)"
   ```
3. Avoid:
   - Technical implementation details
   - Internal component names
   - Code-only jargon

## Tools & Automation

Use the **project-ops** skill to:
- Batch-update workstream titles via YAML frontmatter
- Regenerate INDEX.md (auto-groups by focus level)
- Validate title length (>100 chars triggers linting warning)

Example in CLAUDE.md Current Focus:
```markdown
- **WS5** — Remote Terminal Management — API endpoints per terminali visibili
- **WS6** — MCP HTTP Server Pool — eliminate per-session stdio fanout
```

Readable, concise, immediately clear to anyone reading the status.
