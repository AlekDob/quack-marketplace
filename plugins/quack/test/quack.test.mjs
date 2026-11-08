// Run: node --test plugins/quack/test/*.test.mjs
// Hooks are tested as Claude Code runs them: a child process with JSON on stdin.
import { test } from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'
import { spawnSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'
import { buildIndex } from '../scripts/index.mjs'
import { lastUsage } from '../scripts/lib.mjs'

const SCRIPTS = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'scripts')
const tmp = () => fs.mkdtempSync(path.join(os.tmpdir(), 'quack-test-'))
const DATA = tmp() // per-session state of the hooks under test

function write(root, rel, text) {
  fs.mkdirSync(path.dirname(path.join(root, rel)), { recursive: true })
  fs.writeFileSync(path.join(root, rel), text)
}

function runScript(name, input) {
  const res = spawnSync('node', [path.join(SCRIPTS, name)], { input: JSON.stringify(input), encoding: 'utf8', env: { ...process.env, CLAUDE_PLUGIN_DATA: DATA, QUACK_NO_PING: '1' } })
  assert.equal(res.status, 0, res.stderr)
  return res.stdout ? JSON.parse(res.stdout) : null
}

function transcript(tokens, minutesAgo, oneHourCache = true) {
  const file = path.join(tmp(), 't.jsonl')
  const usage = { input_tokens: 2, cache_read_input_tokens: tokens - 1002, cache_creation_input_tokens: 1000, cache_creation: { ephemeral_1h_input_tokens: oneHourCache ? 1000 : 0 } }
  const at = new Date(Date.now() - minutesAgo * 60_000).toISOString()
  const main = { type: 'assistant', isSidechain: false, timestamp: at, message: { usage } }
  const sub = { ...main, isSidechain: true, message: { usage: { input_tokens: 5 } } } // a subagent call: ignored
  fs.writeFileSync(file, [JSON.stringify({ type: 'user' }), JSON.stringify(main), JSON.stringify(sub)].join('\n'))
  return file
}

test('index maps symbols and doc sections with line ranges, and is stable', () => {
  const root = tmp()
  write(root, 'src/app.ts', '// Entry point of the app\nexport function hello() {\n  return 1\n}\n\nconst hidden = 2\nexport class Greeter {}\n')
  write(root, 'docs/guide.md', '# Guide\n\n## Setup\nrun it\n```bash\n# not a heading\n```\n## Use\nok\n')
  write(root, 'node_modules/x/index.js', 'export function skipped() {}\n')
  assert.deepEqual(buildIndex(root), { files: 2, changed: 1 })
  const index = fs.readFileSync(path.join(root, 'documentation/INDEX.md'), 'utf8')
  assert.match(index, /`app\.ts` \(8\) — Entry point of the app\n {2}hello L2-4 · Greeter L7/)
  assert.match(index, /`guide\.md` \(10\) — Guide\n {2}Setup L3-7 · Use L8-9/)
  assert.doesNotMatch(index, /hidden|skipped|not a heading/)
  assert.equal(buildIndex(root).changed, 0)
})

test('big repos get one sub-index per folder, and old sub-indexes are removed', () => {
  const root = tmp()
  for (let i = 0; i < 260; i++) write(root, `src/f${i}.js`, `export const v${i} = ${i}\n`)
  write(root, 'lib/a.js', 'export function a() {}\n')
  buildIndex(root)
  assert.match(fs.readFileSync(path.join(root, 'documentation/INDEX.md'), 'utf8'), /\[src\]\(index\/src\.md\): 260 files/)
  assert.ok(fs.existsSync(path.join(root, 'documentation/index/lib.md')))
  for (let i = 0; i < 260; i++) fs.unlinkSync(path.join(root, `src/f${i}.js`))
  buildIndex(root)
  assert.ok(!fs.existsSync(path.join(root, 'documentation/index')) || fs.readdirSync(path.join(root, 'documentation/index')).length === 0)
})

test('lastUsage reads the main chat, not subagents, and detects the 1h cache', () => {
  assert.deepEqual({ ...lastUsage(transcript(150_000, 2)), at: 0 }, { tokens: 150_000, at: 0, ttlMs: 3_600_000 })
  assert.equal(lastUsage(transcript(150_000, 2, false)).ttlMs, 300_000)
})

test('nudge warns once per level of context', () => {
  const input = { session_id: 'nudge-1', transcript_path: transcript(150_000, 1) }
  assert.match(runScript('nudge.mjs', input).systemMessage, /150k tokens.*\/clear.*\/compact/)
  assert.equal(runScript('nudge.mjs', input), null)
  assert.equal(runScript('nudge.mjs', { session_id: 'nudge-2', transcript_path: transcript(40_000, 1) }), null)
})

test('nudge warns when a long pause expired the cache', () => {
  const out = runScript('nudge.mjs', { session_id: 'cold-1', transcript_path: transcript(50_000, 90) })
  assert.match(out.systemMessage, /90 min away.*50k tokens at full price/)
})

test('read hint fires only for big files read whole', () => {
  const root = tmp()
  write(root, 'big.ts', 'const line = "some code to make the file long enough"\n'.repeat(500))
  const file = path.join(root, 'big.ts')
  assert.match(runScript('read-hint.mjs', { cwd: root, tool_input: { file_path: file } }).hookSpecificOutput.additionalContext, /501 lines/)
  assert.equal(runScript('read-hint.mjs', { cwd: root, tool_input: { file_path: file, offset: 10, limit: 20 } }), null)
  assert.equal(runScript('read-hint.mjs', { cwd: root, tool_input: { file_path: path.join(root, 'missing.ts') } }), null)
})

test('session start gives the rules and the last diary lines, then refreshes the index', () => {
  const root = tmp()
  write(root, 'documentation/diary/2026-11-08.md', '---\ntype: diary\n---\n- [10:00] Built the login page, tests left to do\n')
  write(root, 'src/a.js', 'export function a() {}\n')
  write(root, 'documentation/INDEX.md', 'old')
  const context = runScript('session-start.mjs', { cwd: root, source: 'startup' }).hookSpecificOutput.additionalContext
  assert.match(context, /Quack token rules[\s\S]*Code map[\s\S]*tests left to do/)
  assert.match(fs.readFileSync(path.join(root, 'documentation/INDEX.md'), 'utf8'), /a L1/)
  const resumed = runScript('session-start.mjs', { cwd: root, source: 'resume', prompt_cache_likely_expired: true, context_tokens: 80_000, estimated_cache_write_usd: 0.5 })
  assert.doesNotMatch(resumed.hookSpecificOutput.additionalContext, /tests left to do/)
  assert.match(resumed.systemMessage, /80k tokens and a cold cache \(about \$0\.50\)/)
})

test('status line shows context and the heavy-chat hint', () => {
  const res = spawnSync('node', [path.join(SCRIPTS, 'statusline.mjs')], {
    input: JSON.stringify({ model: { display_name: 'Opus' }, context_window: { used_percentage: 72.4, total_input_tokens: 144_000 }, cost: { total_cost_usd: 1.234 } }), encoding: 'utf8' })
  assert.equal(res.stdout.trim(), 'Opus · ctx 72% (144k) · $1.23 · heavy chat: /compact or /clear')
})

test('install ping: once per version, anonymous, and off with QUACK_NO_PING', async () => {
  const http = await import('node:http')
  const got = []
  const server = http.createServer((req, res) => { let b = ''; req.on('data', (c) => { b += c }); req.on('end', () => { got.push(JSON.parse(b)); res.end('{}') }) })
  await new Promise((r) => server.listen(0, r))
  process.env.QUACK_PING_URL = `http://127.0.0.1:${server.address().port}`
  delete process.env.QUACK_NO_PING
  const { pingInstall } = await import('../scripts/ping.mjs')
  const dir = tmp()
  await pingInstall(dir)
  await pingInstall(dir) // same version: no second ping
  process.env.QUACK_NO_PING = '1'
  await pingInstall(tmp())
  server.close()
  assert.equal(got.length, 1)
  assert.deepEqual(Object.keys(got[0]).sort(), ['event', 'id', 'version'])
  assert.equal(got[0].event, 'installed')
})
