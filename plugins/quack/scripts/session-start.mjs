// SessionStart hook: gives Claude Quack's short token rules, keeps documentation/INDEX.md fresh,
// and on a fresh chat hands over the last diary lines, so /clear doesn't mean starting from zero.
import fs from 'node:fs'
import path from 'node:path'
import { runHook, emit, kTokens } from './lib.mjs'
import { buildIndex, isGitRepo, projectRoot, INDEX_PATH } from './index.mjs'
import { pingInstall } from './ping.mjs'

const RULES = `Quack token rules (Quack by Alek Dobrohotov & Studio Futuro):
- Be brief. No preamble, no recap of what you just did, no restating the question. Short answers unless asked for depth.
- Read less. Check documentation/ first (INDEX.md, gotchas, decisions). Prefer Grep and Read with offset/limit over whole files; don't re-read a file already in context unless it changed.
- Route work by size. Subagents work in their own context and return only a summary, but each call has a startup cost: skip them for short tasks.
  - Small or short task: do it yourself.
  - This chat runs on Sonnet or Haiku and the task is big or unclear: quack:planner (Pia, Opus) plans, quack:coder (Kit, Opus) builds. You coordinate and check.
  - This chat runs on Opus: plan yourself. Hand only long implementation jobs to quack:coder (Kit), so this chat stays small.
  - Wide code search: quack:scout (Marco, Haiku). Web research: quack:researcher (Iris, Sonnet). Diary and docs: quack:scribe (Dante, Haiku).
- One chat, one task. When the user moves to an unrelated task, suggest /clear; at a natural pause in a long task, suggest /compact. Before either, offer to have Dante (quack:scribe) note where the work stopped.
- After non-trivial work, have quack:scribe record what was learned, so the next chat starts from the docs instead of a long history.`

const DIARY_LINES = 10
const DIARY_CHARS = 1500

runHook(async (input) => {
  const root = projectRoot(input.cwd || process.cwd())
  const fresh = input.source !== 'resume' && input.source !== 'compact' // a resumed or compacted chat has its history
  const parts = [RULES, indexNote(root), fresh ? diaryTail(root) : null]
  emit('SessionStart', { context: parts.filter(Boolean).join('\n\n'), notice: resumeNotice(input) })
  await pingInstall()
})

function indexNote(root) {
  if (fs.existsSync(path.join(root, INDEX_PATH))) {
    buildIndex(root) // rewrites only what changed since the last session
    return `Code map: ${INDEX_PATH} (folder → file → symbols with line ranges). Read it before exploring the code.`
  }
  return isGitRepo(root) ? `No ${INDEX_PATH} yet. When the user starts exploring this code, suggest running /quack:index once.` : null
}

/** Last lines of the newest diary file: where the previous chat stopped. */
function diaryTail(root) {
  const dir = path.join(root, 'documentation', 'diary')
  const latest = fs.existsSync(dir) ? fs.readdirSync(dir).filter((f) => f.endsWith('.md')).sort().pop() : null
  if (!latest) return null
  const body = fs.readFileSync(path.join(dir, latest), 'utf8').replace(/^---\n[\s\S]*?\n---\n/, '')
  const lines = body.split('\n').filter((l) => l.trim()).slice(-DIARY_LINES).join('\n').slice(-DIARY_CHARS)
  return `Where work stopped (documentation/diary/${latest}):\n${lines}`
}

function resumeNotice(input) {
  if (input.source !== 'resume' || !input.prompt_cache_likely_expired || !(input.context_tokens > 30_000)) return null
  const cost = input.estimated_cache_write_usd ? ` (about $${input.estimated_cache_write_usd.toFixed(2)})` : ''
  return `Quack: this chat resumes with ${kTokens(input.context_tokens)} tokens and a cold cache${cost}. For a new task, /clear is cheaper.`
}
