// Shared helpers for Quack's hooks.
// A hook must never break or slow down a session: every error ends silently (QUACK_DEBUG=1 prints it).
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'

/** Read the hook's JSON from stdin and run the body; errors never reach Claude Code. */
export async function runHook(body) {
  try {
    let raw = ''
    for await (const chunk of process.stdin) raw += chunk
    await body(raw ? JSON.parse(raw) : {})
  } catch (err) {
    if (process.env.QUACK_DEBUG) console.error(err)
  }
}

/** Answer Claude Code: `context` is added for Claude, `notice` is shown to the user. */
export function emit(event, { context, notice } = {}) {
  if (!context && !notice) return
  const out = notice ? { systemMessage: notice } : {}
  if (context) out.hookSpecificOutput = { hookEventName: event, additionalContext: context }
  process.stdout.write(JSON.stringify(out))
}

export const kTokens = (tokens) => `${Math.round(tokens / 1000)}k`

// shortcut: one small JSON file per session, never pruned; add cleanup if the folder ever grows large.
export const DATA_DIR = () => process.env.CLAUDE_PLUGIN_DATA || path.join(os.tmpdir(), 'quack')
const stateFile = (sessionId) => path.join(DATA_DIR(), 'sessions', `${String(sessionId).replace(/[^\w-]/g, '')}.json`)

/** Per-session memory, so each reminder is shown once instead of on every message. */
export function loadState(sessionId) {
  try { return JSON.parse(fs.readFileSync(stateFile(sessionId), 'utf8')) } catch { return {} }
}

export function saveState(sessionId, state) {
  fs.mkdirSync(path.dirname(stateFile(sessionId)), { recursive: true })
  fs.writeFileSync(stateFile(sessionId), JSON.stringify(state))
}

const TAIL_BYTES = 1_000_000

function readTail(file) {
  const fd = fs.openSync(file, 'r')
  try {
    const size = fs.fstatSync(fd).size
    const buf = Buffer.alloc(Math.min(size, TAIL_BYTES))
    fs.readSync(fd, buf, 0, buf.length, size - buf.length)
    return buf.toString('utf8')
  } finally { fs.closeSync(fd) }
}

const parseLine = (line) => { try { return JSON.parse(line) } catch { return null } }

/**
 * Last main-chat API call in the transcript: tokens every message re-reads, when it happened, cache lifetime.
 * The transcript format is not a public interface: if it changes, this returns null and Quack stays quiet.
 */
export function lastUsage(transcriptPath) {
  if (!transcriptPath) return null
  const tail = readTail(transcriptPath)
  for (const line of tail.split('\n').reverse()) {
    const entry = parseLine(line)
    const usage = entry?.type === 'assistant' && !entry.isSidechain && entry.message?.usage
    if (usage) return { tokens: contextTokens(usage), at: Date.parse(entry.timestamp), ttlMs: cacheTtlMs(tail) }
  }
  return null
}

const contextTokens = (u) => (u.input_tokens ?? 0) + (u.cache_read_input_tokens ?? 0) + (u.cache_creation_input_tokens ?? 0)

/** Subscriptions write the cache for 1 hour, the API for 5 minutes: the transcript says which one is in use. */
function cacheTtlMs(tail) {
  const minutes = Number(process.env.QUACK_CACHE_TTL_MIN) || (/"ephemeral_1h_input_tokens":[1-9]/.test(tail) ? 60 : 5)
  return minutes * 60_000
}
