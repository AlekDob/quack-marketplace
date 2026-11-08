---
name: checkup
description: Find token waste in this Claude Code setup (memory files, skills, MCP servers, compaction, status line) and fix it with the user's consent. Use when the user runs /quack:checkup or asks why Claude Code burns so many tokens.
---

1. Run:

   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/checkup.mjs"
   ```

   It prints what loads into every message (memory files, skill descriptions, MCP servers) and the settings that matter.

2. Show the user a short table: item, size, verdict. One line on why it matters: whatever is always loaded is paid again on every message.

3. Offer the fixes that apply, one at a time. Apply only the ones the user accepts. Before editing a settings file, read it and keep everything else unchanged.
   - **Memory files over ~200 lines:** move detail into `documentation/` or a skill, keep only the rules every task needs.
   - **No status line:** copy `${CLAUDE_PLUGIN_ROOT}/scripts/statusline.mjs` to `~/.claude/quack-statusline.mjs`, then set `"statusLine": { "type": "command", "command": "node ~/.claude/quack-statusline.mjs" }` in `~/.claude/settings.json`. It shows model, context in use and cost, and says when it is time to /compact.
   - **1M-context model with no compact limit:** set `"autoCompactWindow": 200000` in `~/.claude/settings.json`, so the chat compacts around 200k tokens instead of near 1M.
   - **MCP servers the user never uses:** offer `claude mcp remove <name>`.
   - **MCP tool search OFF:** remove `ENABLE_TOOL_SEARCH=false`, so MCP tools load only when needed.
   - **No code map:** offer /quack:index.

4. Close with the habits no plugin can automate, one line each:
   - /clear between unrelated tasks; /compact at a natural pause in a long one.
   - /model sonnet (or opusplan) for routine work; /effort low for small edits.
   - Don't switch model or effort mid-task without a reason: it can reset the prompt cache.
   - /context and /usage show where the tokens go.
