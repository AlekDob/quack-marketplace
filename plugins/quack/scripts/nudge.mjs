// UserPromptSubmit hook: tells the user, once per level, when the chat has grown expensive
// (every message re-reads the whole context) or when a long pause let the prompt cache expire.
// Claude Code doesn't let hooks run /compact or /clear, so Quack can only advise.
import { runHook, emit, kTokens, lastUsage, loadState, saveState } from './lib.mjs'

const STEP = Number(process.env.QUACK_COMPACT_AT) || 100_000 // remind again at every multiple
const COLD_MIN_TOKENS = 30_000 // below this a cold cache costs little

runHook(async (input) => {
  const usage = lastUsage(input.transcript_path)
  if (!usage) return
  const state = loadState(input.session_id)
  const notice = coldCacheNotice(usage, state) ?? bigContextNotice(usage, state)
  saveState(input.session_id, state)
  emit('UserPromptSubmit', { notice })
})

function bigContextNotice(usage, state) {
  const level = Math.floor(usage.tokens / STEP)
  const shown = state.level ?? 0
  state.level = level // after /compact the level drops, so the reminder can come back later
  if (level < 1 || level <= shown) return null
  return `Quack: this chat carries ${kTokens(usage.tokens)} tokens and every message re-reads them. New task? /clear. Same task? /compact.`
}

function coldCacheNotice(usage, state) {
  const idle = Date.now() - usage.at
  if (usage.tokens < COLD_MIN_TOKENS || idle < usage.ttlMs || state.coldAt === usage.at) return null
  state.coldAt = usage.at
  return `Quack: after ${Math.round(idle / 60_000)} min away the prompt cache expired, so this message re-reads ${kTokens(usage.tokens)} tokens at full price. After a long break, /clear is often cheaper.`
}
