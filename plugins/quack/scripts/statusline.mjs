#!/usr/bin/env node
// Quack status line: model · context in use · session cost, plus a reminder when the chat gets heavy.
// Claude Code pipes the session as JSON on stdin and shows what we print. Zero tokens: it never reaches the model.
const HEAVY_PERCENT = 60
const HEAVY_TOKENS = 150_000

let raw = ''
for await (const chunk of process.stdin) raw += chunk
let session = {}
try { session = JSON.parse(raw) } catch { /* show defaults */ }

const ctx = session.context_window ?? {}
const percent = Math.round(ctx.used_percentage ?? 0)
const used = ctx.total_input_tokens ?? 0
const cost = session.cost?.total_cost_usd
const parts = [session.model?.display_name ?? 'Claude', `ctx ${percent}% (${Math.round(used / 1000)}k)`]
if (typeof cost === 'number') parts.push(`$${cost.toFixed(2)}`)
if (percent >= HEAVY_PERCENT || used >= HEAVY_TOKENS) parts.push('heavy chat: /compact or /clear')
console.log(parts.join(' · '))
