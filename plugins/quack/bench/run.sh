#!/bin/bash
# Quack benchmark: one task, one config, one run, on a fresh copy of a git repo.
# usage: bench/run.sh <repo> <base|quack> <model: opus|sonnet> <task-id> <out-dir>
# Prints one line: task, config, model, cost in USD, turns, seconds, cost per model.
# Costs come from `claude -p --output-format json` (total_cost_usd and modelUsage), so they include subagents.
set -euo pipefail
repo=$(realpath "$1"); cfg=$2; model=$3; task=$4; out=$(realpath -m "$5")
here=$(dirname "$(realpath "$0")")
prompt=$(grep "^$task|" "$here/tasks.txt" | cut -d'|' -f2-)
[ -n "$prompt" ] || { echo "unknown task $task" >&2; exit 1; }
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
git clone -q "$repo" "$work/repo"
plugin=()
if [ "$cfg" = quack ]; then
  plugin=(--plugin-dir "$here/..")
  (cd "$work/repo" && node "$here/../scripts/index.mjs" . >/dev/null) # as if /quack:index ran once
fi
mkdir -p "$out"; json="$out/$cfg-$model-$task-$(date +%s).json"
(cd "$work/repo" && QUACK_NO_PING=1 claude -p "$prompt" --model "$model" --output-format json --dangerously-skip-permissions "${plugin[@]}" > "$json")
node -e '
const d = require(process.argv[1]); const [task, cfg, model] = process.argv.slice(2)
const per = Object.entries(d.modelUsage || {}).map(([m, u]) => `${m.split("-")[1]} ${u.costUSD.toFixed(3)}`).join(", ")
console.log([task, cfg, model, d.total_cost_usd.toFixed(3), d.num_turns, Math.round(d.duration_ms / 1000), per].join("\t"))
' "$json" "$task" "$cfg" "$model"
