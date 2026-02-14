---
description: "Use Quack Brain for knowledge management"
---

# Quack Brain

Two-level knowledge store. Use the `quack-brain` skill for detailed instructions.

## Access Chain

1. **CLAUDE.md** — always loaded. Contains links to `documentation/map.md` and critical gotchas.
2. **documentation/** — project knowledge. Read files linked from CLAUDE.md first.
3. **~/.quack/brain/** — global cross-project knowledge. Search when project docs don't cover it.

## Rules

1. **SEARCH before acting**: CLAUDE.md references -> project `documentation/` -> global `~/.quack/brain/`
2. **SAVE after discovering**: all 4 must be true — genuine discovery + useful in 6 months + verified + clear trigger
3. **LINK critical entries**: when saving a gotcha or pattern that agents should always see, add a reference in the project's CLAUDE.md Knowledge Base section
4. **BREADCRUMB in code**: when writing code related to a Brain entry (bug fix, pattern, gotcha), add `// Brain: {slug}` above the relevant block. This links code back to its documentation. See `quack-brain` skill for full rules.
