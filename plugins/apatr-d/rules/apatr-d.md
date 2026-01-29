---
description: "Execute this workflow for every development task"
globs: ["**/*.ts", "**/*.tsx", "**/*.rs", "**/*.md"]
---

# APATR-D: Analyze > Plan > Act > Test > Review > Document

## 1. ANALYZE - Investigate Before Acting
- Read relevant files before proposing changes
- Search for existing patterns and context
- Identify constraints, dependencies
- Ask specific questions if task is ambiguous

## 2. PLAN - Design Before Implementation
- Create structured todo list for complex tasks
- Define clear success criteria
- Identify minimum viable solution (avoid over-engineering)

## 3. ACT - Implement with Focus
- One thing at a time - complete before moving on
- Use git for checkpoints
- Reuse existing abstractions (DRY)
- Delegate to specialized droids when needed

## 4. TEST - Smart Testing, Not Excessive
- Test new features with complex logic
- Test bug fixes that could regress
- Skip tests for cosmetic changes, refactoring, typos
- Always run existing tests: npm test

## 5. REVIEW - Verify Quality
- Code follows project patterns?
- No regressions introduced?
- TypeScript strict satisfied?
- Files < 300 lines, functions < 20 lines?

## 6. DOCUMENT - Save Knowledge
- Document bug fixes, patterns, decisions
- Save to knowledge store, not local files
- Only document genuine discoveries worth saving
