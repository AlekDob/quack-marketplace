---
name: code
description: "Expert coding workflow that writes clean, DRY code with smart search-friendly comments, then automatically reviews it. Use this skill whenever the user invokes /code, asks you to implement a feature, write code, fix a bug, refactor, or build something — especially for tasks that benefit from disciplined coding practices and quality review. Use it proactively for any non-trivial coding task."
user_invocable: true
---

# /code — Write + Review

A two-phase coding workflow: first write production-quality code, then automatically review it for quality, security, and DRY compliance.

## When to Use

This skill activates when the user types `/code` followed by their task. It's designed for any coding task in any language — features, bug fixes, refactors, migrations, new files, or cross-file changes.

## Workflow

### Phase 1: Code

Read the coder agent instructions from `agents/coder.md` (relative to this skill's directory), then implement the user's task following those instructions precisely.

**Key principles from the coder agent:**
- Read CLAUDE.md and existing code before writing anything
- Follow APATR-D: Analyze > Plan > Act > Test > Review > Document
- DRY — no duplication, extract shared logic
- Smart comments for grep-friendly navigation (section headers, WHY: comments, purpose comments on exports)
- Functions max 20 lines, files max 300 lines
- Self-documenting names: `verbNoun`, `PascalCase`, `UPPER_SNAKE`
- Run type-check/lint after writing code

After implementing, run available checks:
- TypeScript: `npx tsc --noEmit`
- Rust: `cargo check`
- Python: `mypy` or `pyright` if configured
- Go: `go vet`
- Or whatever the project uses

### Phase 2: Review

After Phase 1 is complete and code compiles/passes checks, read the reviewer agent instructions from `agents/code-reviewer.md` (relative to this skill's directory), then spawn a `code-reviewer` subagent to review all changes made.

Use the Agent tool with `subagent_type: "code-reviewer"` and provide it with:
- The full content of `agents/code-reviewer.md` as its operating instructions
- A summary of what was changed and why
- The list of modified files
- Any specific areas of concern

The reviewer checks for:
- Code quality and consistency with project patterns
- Security vulnerabilities (OWASP top 10)
- DRY violations and smart commenting compliance
- Naming conventions (`verbNoun`, `PascalCase`, `UPPER_SNAKE`)
- Missing error handling at system boundaries
- Performance concerns (memory leaks, N+1 queries, unbounded loops)

### Phase 3: Fix (if needed)

If the reviewer finds critical issues, fix them immediately following the same coder agent principles. Then report the final result to the user, including:
- What was implemented
- What the reviewer found
- What was fixed (if anything)

## Important

- Always explain what you plan to do before doing it
- If the task is ambiguous, ask clarifying questions first
- Match the project's existing patterns and conventions
- Don't over-engineer — minimum viable change for the current task
