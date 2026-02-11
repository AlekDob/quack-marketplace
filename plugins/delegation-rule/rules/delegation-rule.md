---
description: "Evaluate delegation level before implementing any task"
globs: ["**/*.ts", "**/*.tsx", "**/*.rs", "**/*.md", "**/*.py", "**/*.js"]
---

# Delegation Decision Rule

Before implementing any task, the agent MUST evaluate the delegation level using this decision tree:

## 1. AGENT TEAM (Teammate tool) - Parallel full sessions
Use when ALL of these are true:
- Task touches >1 domain (e.g. frontend + backend + tests, or code + docs)
- Files DO NOT overlap between workers
- No strict sequential dependency between subtasks
- Expected effort >15 min per subtask

Examples: new feature with frontend+backend+tests, cross-layer refactor, parallel research/debugging

## 2. SUBAGENT/DROID (Task tool / .claude/agents/) - Invisible workers
Use when ANY of these is true:
- Task is focused on one domain with a clear deliverable
- Requires a specific skill (code-review, test generation, documentation)
- Result only needs to come back to the calling agent (no inter-worker communication)
- Task is research/exploration that feeds into a decision

Examples: code review, test writing, doc update, codebase search, single-file refactor

## 3. SINGLE AGENT - Do it yourself
Use when ALL of these are true:
- Task touches <=3 files with interconnected logic
- Changes depend on understanding a single root cause
- Coordination overhead would exceed execution time

Examples: bug fix on related files, small config change, quick UI tweak

## Checkpoint
Before starting implementation, the agent MUST:
1. State which delegation level was chosen (Team / Subagent / Single)
2. Explain why in one sentence
3. If Team: list who does what. If Subagent: list which droids/skills to use.
