---
name: human-test-plan
description: Generate a human-friendly test and documentation guide after completing a feature implementation. This skill should be used when a significant feature, migration, or refactor is complete and needs manual verification through the application's UI. It produces a combined documentation + step-by-step manual test plan that non-technical users can follow.
---

# Human Test Plan Generator

## Overview

After completing a feature implementation, generate a combined documentation and manual test plan document. The document serves two purposes: explaining how the feature works (for developers and users) and providing step-by-step UI-based tests to verify everything functions correctly.

## When to Use

- After completing a new feature implementation
- After a significant refactor or migration
- After removing/replacing a system with a new one
- When the user asks to verify that something "works in the UI"
- When the user says "create a test plan" or "how do I test this"

## Document Structure

The output document follows this exact structure:

### Part 1: Documentation (How It Works)

Explain the feature in plain language. Include:

1. **Overview paragraph** - What the feature does, in 2-3 sentences
2. **Architecture diagram** - ASCII art showing the key components and their relationships
3. **Key concepts** - How the system works under the hood (for developers)
4. **Directory/file layout** - If relevant, show where things are stored
5. **Configuration** - Any settings or options available
6. **Code map** - Table of key files and their responsibilities

### Part 2: Manual Tests (Step-by-Step UI Verification)

Numbered test sections, each with:

1. **Test title** - Clear name (e.g., "Test 5: Auto-learn Hook Detection")
2. **What to check** - One sentence explaining the purpose
3. **Steps** - Numbered list of exact actions to perform in the UI
4. **Pass criteria** - Checkbox list of observable outcomes

### Part 3: Supplementary Sections

- **Troubleshooting** - Common issues and how to resolve them
- **Cleanup actions** - Any post-testing housekeeping
- **Architecture summary** - Before/after comparison (for migrations)

## Writing Guidelines

### Tone and Language

- Write in English (code and docs language for Quack)
- Be conversational but precise - imagine explaining to a smart colleague
- No jargon without explanation
- Use "you" when addressing the tester

### Test Design Principles

- Each test must be **independently verifiable** - no test depends on another passing
- Tests should be ordered from **simple to complex** (app launch → basic UI → feature behavior → edge cases)
- Include **negative tests** - verify things that should NOT happen (e.g., "No old UI remains")
- Give **exact prompts** when testing AI behavior - don't leave the tester guessing what to type
- Include **console checks** where relevant - tell the tester exactly what log message to look for
- Always include a **"If it doesn't work"** note for non-obvious failures

### Formatting Rules

- Use `### Test N: Title` for each test section
- Use `**What to check**:` for the purpose line
- Use numbered lists for steps
- Use `- [ ]` checkboxes for pass criteria
- Use triple-backtick code blocks for exact text/commands to enter
- Use tables for structured comparisons
- Use ASCII diagrams for architecture (no images)

## Template

```markdown
# [Feature Name] - Test & Documentation Guide

This document serves two purposes:
1. **Documentation**: Explains how [feature] works
2. **Manual Test Plan**: Step-by-step verification in [App Name]

---

## How [Feature] Works

[2-3 paragraph explanation of what the feature does and why it exists]

### Architecture

\```
[ASCII diagram showing components and data flow]
\```

### Key Concepts

[Explain the main concepts - storage, access patterns, automation, etc.]

### Where Things Live

| File | What it does |
|------|-------------|
| `path/to/file.ts` | Brief description |
| ... | ... |

---

## Manual Testing in [App Name]

Open [App Name] and follow each section in order.

---

### Test 1: [Basic Check]

**What to check**: [One sentence purpose]

1. [Step 1]
2. [Step 2]
3. [Step 3]

**Pass criteria**:
- [ ] [Observable outcome 1]
- [ ] [Observable outcome 2]

---

### Test 2: [Feature Behavior]

**What to check**: [One sentence purpose]

1. [Step 1]
2. [Step 2]

**Pass criteria**:
- [ ] [Observable outcome]

**If it doesn't work**: [Debugging hint]

---

[... more tests ...]

---

## Troubleshooting

### [Common issue 1]

- [How to diagnose]
- [How to fix]

### [Common issue 2]

- [How to diagnose]
- [How to fix]

---

## Architecture Summary

### Before (removed)

\```
[Old system description]
\```

### After (current)

\```
[New system description]
\```

### Key Design Decisions

1. **[Decision]**: [Rationale]
2. **[Decision]**: [Rationale]
```

## Output Location

Save the document to the project's testing documentation folder:
- Primary: `docs/03-testing/[feature-name]-test-plan.md`
- If no docs folder exists: `tests/[feature-name]-test-plan.md`
- If no test infrastructure: project root as `TEST-[FEATURE].md`

## Quality Checklist

Before delivering the document, verify:

- [ ] Documentation section is understandable without reading the code
- [ ] Every test has clear pass/fail criteria (checkboxes)
- [ ] Tests cover: happy path, negative cases, edge cases, performance
- [ ] Exact text/commands are provided where the tester needs to type something
- [ ] Console log messages are specified when relevant
- [ ] Troubleshooting covers at least 3 common failure modes
- [ ] Architecture diagram accurately reflects the current implementation
- [ ] File/code references point to actual existing files

## Saving to Brain

After generating a test plan, save a reference to the Quack Brain:

```
~/.quack/brain/projects/{project}/notes/test-plan-{feature}.md
```

With frontmatter:
```yaml
---
type: note
project: {project-name}
created: {today}
tags: [testing, {feature-tag}]
---
```

This ensures future agents know what has been tested and can find the test plan.
