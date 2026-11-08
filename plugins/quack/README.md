# Quack

Spend fewer tokens in Claude Code without changing how you work. Free and open source, by **Alek Dobrohotov & [Studio Futuro](https://www.studiofuturo.ai)**.

## Install

In Claude Code:

```
/plugin marketplace add AlekDob/quack-marketplace
/plugin install quack@quack-marketplace
```

Restart Claude Code. Then, once per project:

- `/quack:index` builds the code map.
- `/quack:checkup` finds what your setup loads into every message, and fixes it with your consent.

## Why chats get expensive

Every message sends the whole conversation again. A chat at 150k tokens pays to read 150k tokens on every message, even for "ok, thanks". The prompt cache makes that re-reading cheaper, but it expires after 5 minutes on the API and 1 hour on subscriptions. Then everything is paid at full price again.

Most of the waste comes from four habits:

- one endless chat for every task;
- reading whole files to find one function;
- running exploration and web research on the main, most expensive model;
- loading many memory files, skills and MCP servers into every message.

## What Quack does

| Piece | How | What it does |
|---|---|---|
| Session rules | SessionStart hook | About 250 tokens of rules: short answers, read ranges instead of whole files, hand work to cheap subagents, one chat per task. |
| Chat-size reminders | UserPromptSubmit hook | Shown once per 100k tokens: "New task? /clear. Same task? /compact." After a pause that expired the cache, it says how much the next message re-reads at full price. |
| Big-file hint | PreToolUse hook on Read | Before Claude reads a file of 400+ lines whole, it points to the code map or Grep, then a line range. |
| Code map | `/quack:index` | A PageIndex-style `documentation/INDEX.md`: folder → file (lines) — purpose → symbols with line ranges. Big repos get one sub-index per folder. It refreshes itself at every session start. |
| Memory between chats | `quack:scribe` + session hook | Diary, gotchas and decisions live in `documentation/`. A new chat gets the last diary lines, so /clear doesn't mean starting over. |
| The duck team | Five subagents, see below | Planning, coding, code search, web research and docs each run on the cheapest model that does the job well, in their own context. Only the summary comes back to the main chat. |
| Setup audit | `/quack:checkup` | Measures memory files, skill descriptions, MCP servers and settings. Offers a status line with context use and cost, and a compact limit for 1M-context models. |

Everything runs locally with Node, with no dependencies. The only network call is the install ping below.

## The duck team

Quack is the rubber duck next to Claude: it says little, at the right time. It also brings a team. Each duck is a subagent with its own model and effort, so the expensive model thinks briefly and the cheaper ones do the long work.

| | Duck | Subagent | Model, effort | Job |
|---|---|---|---|---|
| <img src="assets/team/pia.webp" width="56" alt="Pia"> | **Pia**, planner | `quack:planner` | Opus, high | Reads the code and writes a short plan: files, steps, how to check. Never edits. |
| <img src="assets/team/kit.webp" width="56" alt="Kit"> | **Kit**, coder | `quack:coder` | Opus, medium | Builds the plan or a long job in his own context, runs the tests, returns only what changed. |
| <img src="assets/team/marco.webp" width="56" alt="Marco"> | **Marco**, scout | `quack:scout` | Haiku, low | Finds where things are. Paths and line ranges, never file dumps. |
| <img src="assets/team/iris.webp" width="56" alt="Iris"> | **Iris**, researcher | `quack:researcher` | Sonnet, medium | Web research with sources. |
| <img src="assets/team/dante.webp" width="56" alt="Dante"> | **Dante**, scribe | `quack:scribe` | Haiku, low | Diary, gotchas, decisions: the memory the next chat starts from. |

**Who gets the work.** The session rules route each task:

- a small or short task: the main chat does it (a subagent has a startup cost);
- the chat runs on Sonnet and the task is big or unclear: Pia plans, Kit builds, both on Opus, and the cheaper chat coordinates;
- the chat runs on Opus: it plans itself, and hands only long implementation jobs to Kit, so the chat stays small;
- searches, research and notes: Marco, Iris and Dante.

**What we measured.** See [bench/RESULTS.md](bench/RESULTS.md): every run, the tasks, the method and how to repeat it.

Claude Code doesn't let a plugin change the main chat's model or effort. Routing works by choosing the duck, and each duck has its own. You can always ask for one by name: "have Pia plan this".

## What no plugin can do

Claude Code doesn't let plugins run /clear or /compact, or switch the main chat's model or effort. Quack tells you when it's time, and you type the command. The switching that can be automatic happens through the subagents, which have their own model and effort.

Habits worth keeping:

- /clear between unrelated tasks; /compact at a natural pause in a long one.
- /model sonnet (or opusplan) for routine work; /effort low for small edits.
- Don't switch model mid-task without a reason: it can reset the prompt cache.
- /context and /usage show where the tokens go.

## Settings

Optional environment variables:

| Variable | Default | Meaning |
|---|---|---|
| `QUACK_COMPACT_AT` | `100000` | Chat-size reminder every this many tokens |
| `QUACK_BIG_FILE_LINES` | `400` | Files this long get the big-file hint |
| `QUACK_CACHE_TTL_MIN` | auto | Cache lifetime in minutes: 60 when the transcript shows 1-hour cache writes, otherwise 5 |
| `QUACK_DEBUG` | off | `1` prints hook errors |
| `QUACK_NO_PING` | off | `1` turns off the install ping (`DO_NOT_TRACK=1` works too) |

## Install ping

The first session after you install or update Quack sends one request to quack.build with three fields: `installed` or `updated`, Quack's version, and a random id made on your machine. Nothing else: no paths, code, prompts, names or account data. It tells us how many people use Quack. Set `QUACK_NO_PING=1` to turn it off. The code is in `scripts/ping.mjs`.

## What Quack itself costs

About 750 tokens per session: roughly 400 for the short descriptions of 2 skills and 5 subagents (`claude plugin details quack` shows them) and roughly 330 for the session rules. A single whole-file read it prevents usually saves more than that.

## Pairs well with

[RTK](https://github.com/rtk-ai/rtk) compresses the output of shell commands before Claude reads it. It works alongside Quack.

## Credits

The code map follows the idea of [PageIndex](https://github.com/VectifyAI/PageIndex) (a tree to reason over, then read only the chosen branch). The brevity rule is inspired by [caveman](https://github.com/JuliusBrussee/caveman), but a plain "be brief" rule gets most of the gain. The numbers on caching come from the [Claude Code cost docs](https://code.claude.com/docs/en/costs).

## Development

```bash
node --test plugins/quack/test/*.test.mjs
claude --plugin-dir plugins/quack
```

MIT License.
