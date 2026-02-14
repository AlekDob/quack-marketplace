---
name: brain-migrate
description: Migrate existing documentation into the Quack Brain v2 format (documentation/ + guide/). Use this skill when a project has documentation scattered across .quack/brain/, .claude/docs/, or loose markdown files that need to be consolidated.
context: fork
---

# Brain Migrate

Convert any project's existing documentation into the Quack Brain v2 structure. Supports `.md` and `.mmd` (Mermaid diagram) files.

## Target Structure

```
{project}/
├── documentation/
│   ├── guide/{feature}/     # Human guides (narrative, Italian)
│   ├── decisions/           # Architectural decisions
│   ├── bugs/                # Bug fixes
│   ├── patterns/            # Reusable patterns
│   ├── gotchas/             # Known issues
│   ├── diary/               # Development logs
│   ├── inbox/               # Unsorted items
│   └── map.md               # Architecture index
├── CLAUDE.md                # Must reference documentation/
```

## Migration Workflow

### Step 1: SCAN — Find all documentation sources

Check these locations in order:

| Location | What to expect |
|----------|---------------|
| `{project}/documentation/` | Already migrated (skip if exists and populated) |
| `{project}/.quack/brain/` | Old project brain (pre-v2) |
| `{project}/.claude/docs/` | Claude-specific docs |
| `~/.quack/brain/projects/{project-name}/` | Global brain mirror |
| `{project}/*.md` (root) | Loose markdown files |
| `{project}/docs/` | Generic docs folder |

Report what was found with file counts per location.

### Step 2: CLASSIFY — Categorize each file

For each file found, determine:

1. **Type**: `decision` / `bug_fix` / `pattern` / `gotcha` / `diary` / `guide` / `skip`
2. **Audience**: `ai` (has YAML frontmatter, technical) / `human` (narrative, tutorial-style)
3. **Scope**: `project` (specific to this project) / `global` (cross-project knowledge)
4. **Action**: `move` / `copy` / `merge` / `skip` / `delete`

Classification rules:
- Files with YAML frontmatter (`type:` field) → keep type, move to matching `documentation/{type}/`
- Files in `bugs/` or named `fix-*` / `bug-*` → `bugs/`
- Files in `patterns/` or named `pattern-*` → `patterns/`
- Files in `gotchas/` or named `gotcha-*` → `gotchas/`
- Files in `decisions/` or named `decision-*` → `decisions/`
- Files in `diary/` or date-named → `diary/`
- Narrative docs (no frontmatter, tutorial-style) → `guide/{feature}/`
- Mermaid diagrams (`.mmd` files) → keep in place or move to relevant folder / `guide/{feature}/`
- Research/reference docs (large, external content) → `skip` (not brain content)
- Empty or duplicate files → `delete`
- Files with `project: {other-project}` in frontmatter → `skip` (wrong project)

### Step 3: PLAN — Present migration plan

Before executing, show the user a summary:

```
Migration Plan for {project-name}
==================================

Sources found:
- .quack/brain/: 86 files
- .claude/docs/: 31 files
- Root: 3 files

Actions:
- Move to documentation/patterns/: 15 files
- Move to documentation/bugs/: 12 files
- Move to documentation/gotchas/: 7 files
- Move to documentation/decisions/: 8 files
- Move to documentation/diary/: 20 files
- Convert to documentation/guide/: 5 files
- Move to inbox/ (needs review): 10 files
- Skip (global/wrong scope): 6 files
- Delete (empty/duplicate): 3 files

New guide features detected:
- guide/dashboard/ (from .claude/docs/dashboard/)
- guide/auth/ (from .claude/docs/auth/)
```

Wait for user approval before proceeding.

### Step 4: EXECUTE — Perform the migration

1. Create `documentation/` folder structure if missing
2. Move/copy files according to the plan
3. Fix file naming (kebab-case, descriptive)
4. Add missing YAML frontmatter to AI knowledge files
5. Convert narrative docs to guide format (plain markdown, no frontmatter)
6. Create `map.md` with architecture overview

### Step 5: UPDATE — Update project CLAUDE.md

The CLAUDE.md **must** have a Knowledge Base section after migration. If it doesn't exist, create it. If it exists, update it.

**Required CLAUDE.md structure after migration:**

```markdown
## Knowledge Base

Read `documentation/map.md` for full architecture overview before making changes.

**Critical gotchas** (read before modifying these areas):
- {gotcha-1}: `documentation/gotchas/{filename}.md`
- {gotcha-2}: `documentation/gotchas/{filename}.md`

**Key patterns**: `documentation/patterns/` — search by name before implementing similar features.

**Human Guides** (`documentation/guide/`):
- {feature-1}: `documentation/guide/{feature}/` ({page list})
- {feature-2}: `documentation/guide/{feature}/` ({page list})

**Brain breadcrumbs in code**: When writing code related to a Brain entry (bug fix, pattern, gotcha), add `// Brain: {slug}` above the relevant block.

Full knowledge store: `documentation/` (project) + `~/.quack/brain/` (global). Use the `quack-brain` skill for read/write operations.
```

**What to update specifically:**
1. Add `documentation/map.md` reference if missing
2. List the top 3-5 most critical gotchas with direct file paths
3. List all guide features with their page counts
4. Remove old references to `.claude/docs/` or `.quack/brain/` as documentation sources
5. Keep references to `~/.quack/brain/` only for the global brain
6. Ensure `quack-brain` skill is in the Preferred Skills list (if agent header exists)

**What NOT to touch:**
- Agent header block (`QUACK_AGENT_HEADER_START` ... `END`)
- Group context block (`QUACK_GROUP_CONTEXT_START` ... `END`)
- Any other sections not related to Knowledge Base

After updating, report the changes made to the user.

**Old sources cleanup** — report to user (don't auto-delete):
- `.quack/brain/` → can be deleted after verification
- `.claude/docs/` → can be deleted after verification
- Global `~/.quack/brain/projects/{name}/` → leave (managed separately)

### Step 6: VERIFY — Check the result

- List `documentation/` tree
- Verify `map.md` exists and is populated
- Verify `CLAUDE.md` references `documentation/`
- Count files per category
- Report any orphaned files

## YAML Frontmatter Template

For AI knowledge files missing frontmatter:

```yaml
---
type: pattern
project: {project-name}
created: {date}
last_verified: {date}
tags: [{relevant, tags}]
summary: "One-line human-readable summary in user's language"
---
```

## Guide Conversion Rules

When converting docs to `guide/{feature}/`:
- Strip YAML frontmatter (guides are plain markdown)
- First `# Heading` becomes the page title
- Add navigation links between pages
- Name files: `overview.md` (first), then descriptive kebab-case
- Write in the user's language

**Writing style — CRITICAL:**
- Write for **complete beginners** ("for dummies" level). Assume the reader knows nothing.
- Use a **storytelling, conversational tone** — like explaining to a friend, not writing a manual.
- Start each page with **WHY** before **HOW**. Context first, details second.
- Use **concrete examples** from the project, not abstract descriptions.
- Use **analogies and metaphors** for technical concepts.
- **Short paragraphs** (2-3 sentences max). No walls of text.
- Tables/lists for reference, but always preceded by narrative explanation.
- Avoid jargon — explain technical terms in parentheses the first time.
- Each page must be **self-contained** but linked to related pages.
- **Create at least one `.mmd` architecture diagram per guide feature.** A visual flow diagram (e.g. `architecture-flow.mmd`) makes complex features instantly understandable. The Brain UI renders it as an interactive visual. If the source project has architecture diagrams in any format, convert them to Mermaid.

## Important

- **Never delete without asking.** Always show the plan first.
- **Preserve git history.** Use `git mv` when possible.
- **Don't move global knowledge.** Only project-specific content goes to `documentation/`.
- **inbox/ is the safety net.** Files that don't fit anywhere go to `inbox/` for manual review.
- **summary field.** Add a `summary:` to every AI knowledge entry during migration.
