# Quack benchmark: with and without

Measured on 2026-11-08 with Claude Code 2.1.318. Every number below is a real run; nothing is estimated.

## Method

- **Project**: a copy of a real Next.js site (the quack.build landing, 280 tracked files). Each run starts from a fresh copy.
- **Configs**: `base` is Claude Code as installed on the test machine. `quack` is the same, plus `--plugin-dir` pointing at this plugin and the code map already built (as if `/quack:index` had run once).
- **Main model**: `--model opus` or `--model sonnet`, default effort. Subagents use their own model.
- **Cost**: `total_cost_usd` and `modelUsage` from `claude -p --output-format json`. They include subagents.
- **Runs**: each task was run twice per config. The install ping was off (`QUACK_NO_PING=1`).
- **The same floor in every run**: the test machine loads a large personal setup (global CLAUDE.md, rules, other plugins), about 40k tokens before the first message, in both configs. A lighter setup has a lower floor, so the same differences weigh more in percent.

The tasks are in [tasks.txt](tasks.txt). To repeat a run:

```bash
plugins/quack/bench/run.sh <any-git-repo> quack opus t4 ./bench-out
```

## Summary

| Task | Without Quack | With Quack |
|---|---|---|
| t1 Explain a flow (Opus) | $0.40 | $0.41 |
| t2 FAQ edit (Opus) | $0.40 | $0.42 |
| t3 Explore a section (Opus) | $0.48 | $0.49 |
| t4 Rate limiter (Opus) | $0.56 | $0.54 |
| t5 Review, fix, diary (Opus) | $0.51 | $0.51 |
| t4 Rate limiter (Sonnet) | $0.25 | $0.25 |
| t4 forced "Pia plans, Kit builds", chat on Opus, Kit on Sonnet (1.1) | | $0.83 |
| t4 forced "Pia plans, Kit builds", chat on Opus, Kit on Opus (1.2) | | $0.92 |
| t4 forced "Pia plans, Kit builds", chat on Sonnet, Kit on Opus (1.2) | | $0.63 |

Every t4 and t6 run finished the job: a shared helper, both routes using it, and a passing `node:test` file.

## What it means

1. **On a single short task, Quack doesn't change the bill.** The differences are -3% to +4%, which is noise. On these tasks Opus worked alone and called no duck. That was the right call: a subagent re-reads what it needs in a fresh context, and on a short job that costs more than it saves.
2. **The main model is the biggest lever.** The same multi-file job cost $0.25 on Sonnet and $0.56 on Opus, with the same result.
3. **The ducks buy quality and a smaller chat, not a cheaper task.** "Pia plans, Kit builds" put Opus on both the thinking and the code, in their own contexts. It cost $0.92 from an Opus chat and $0.63 from a Sonnet chat, against $0.56 for Opus alone. Use them on big or unclear tasks, where a plan and a clean context matter. Don't use them on everyday edits.
4. **What a one-prompt test can't show** is where Quack is built to save: long chats. That covers the /clear and /compact reminders at 100k tokens, the warning when a pause expired the cache, and the code map that stops whole-file reads over a long session. To measure those, compare `/usage` over a week with and without Quack.

## Limits of this test

- Two runs per task, on one project, on one machine.
- Costs depend on Anthropic's prices on the test day.
- Wall time is not reported. With background subagents, `duration_ms` covers only the main loop.

## Every run

| Task | Config | Chat model | Kit model | Cost | Cost per model |
|---|---|---|---|---|---|
| t1 | base | opus | — | $0.405 | opus 0.41 |
| t1 | base | opus | — | $0.404 | opus 0.40 |
| t1 | quack | opus | — | $0.411 | opus 0.41 |
| t1 | quack | opus | — | $0.416 | opus 0.42 |
| t2 | base | opus | — | $0.405 | opus 0.40 |
| t2 | base | opus | — | $0.404 | opus 0.40 |
| t2 | quack | opus | — | $0.423 | opus 0.42 |
| t2 | quack | opus | — | $0.418 | opus 0.42 |
| t3 | base | opus | — | $0.439 | opus 0.44 |
| t3 | base | opus | — | $0.524 | opus 0.52 |
| t3 | quack | opus | — | $0.472 | opus 0.47 |
| t3 | quack | opus | — | $0.515 | opus 0.51 |
| t4 | base | opus | — | $0.497 | opus 0.50 |
| t4 | base | opus | — | $0.614 | opus 0.61 |
| t4 | quack | opus | — | $0.513 | opus 0.51 |
| t4 | quack | opus | — | $0.567 | opus 0.57 |
| t4 | base | sonnet | — | $0.239 | sonnet 0.24 |
| t4 | base | sonnet | — | $0.254 | sonnet 0.25 |
| t4 | quack | sonnet | — | $0.247 | sonnet 0.25 |
| t4 | quack | sonnet | — | $0.257 | sonnet 0.26 |
| t4 | quack | sonnet | — | $0.244 | sonnet 0.24 |
| t4 | quack | sonnet | — | $0.239 | sonnet 0.24 |
| t5 | base | opus | — | $0.509 | opus 0.51 |
| t5 | base | opus | — | $0.511 | opus 0.51 |
| t5 | quack | opus | — | $0.502 | opus 0.50 |
| t5 | quack | opus | — | $0.519 | opus 0.52 |
| t6 | quack | opus | opus | $0.923 | opus 0.92 |
| t6 | quack | opus | opus | $0.908 | opus 0.91 |
| t6 | quack | opus | sonnet | $0.865 | opus 0.77, sonnet 0.09 |
| t6 | quack | opus | sonnet | $0.798 | opus 0.71, sonnet 0.09 |
| t6 | quack | sonnet | opus | $0.633 | sonnet 0.26, opus 0.37 |
| t6 | quack | sonnet | opus | $0.618 | sonnet 0.24, opus 0.38 |

Tasks: t1 = Explain a flow, t2 = FAQ edit (2 languages), t3 = Explore a section, t4 = Rate limiter: helper, 2 routes, test, t5 = Review all routes, fix one, diary, t6 = t4, forced "Pia plans, Kit builds".
