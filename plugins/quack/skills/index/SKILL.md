---
name: index
description: Build or refresh documentation/INDEX.md, a PageIndex-style map of the repo (folder, file, symbols with line ranges) so agents open only the code they need. Use when the user runs /quack:index or asks for a code map.
---

Run:

```bash
node "${CLAUDE_PLUGIN_ROOT}/scripts/index.mjs"
```

It maps the files git tracks (or the folder, outside git) into `documentation/INDEX.md`. Repos with more than 250 files get one sub-index per folder in `documentation/index/`, so nobody loads the whole map. Output is deterministic and only changed pages are rewritten. Once the map exists, Quack refreshes it at the start of every session.

Then tell the user, in two lines: how many files are mapped, and that from now on agents read the map before opening files. Suggest committing `documentation/INDEX.md` (and `documentation/index/`) so the whole team shares it.
