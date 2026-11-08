#!/usr/bin/env node
// Quack checkup: measures what Claude Code loads into every message for this project
// (memory files, skill descriptions, MCP servers) and the settings that control compaction.
// Read-only: it prints a report; the checkup skill decides with the user what to change.
// shortcut: plugin skills and CLAUDE.md files in parent folders are not counted; /context shows everything.
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'
import { INDEX_PATH, projectRoot } from './index.mjs'

const HOME = path.join(os.homedir(), '.claude')
const root = projectRoot(process.argv[2] || process.cwd())
const BIG_MEMORY_LINES = 200

const tokens = (text) => Math.round(text.length / 4)
const kTok = (n) => `~${(n / 1000).toFixed(1)}k tokens`
const readJson = (file) => { try { return JSON.parse(fs.readFileSync(file, 'utf8')) } catch { return {} } }
const listDir = (dir) => { try { return fs.readdirSync(dir) } catch { return [] } }
const mdIn = (dir) => listDir(dir).filter((f) => f.endsWith('.md')).map((f) => path.join(dir, f))
const short = (file) => file.replace(os.homedir(), '~')

function memoryReport() {
  const candidates = [path.join(HOME, 'CLAUDE.md'), ...mdIn(path.join(HOME, 'rules')), path.join(root, 'CLAUDE.md'),
    path.join(root, 'CLAUDE.local.md'), path.join(root, '.claude', 'CLAUDE.md'), ...mdIn(path.join(root, '.claude', 'rules'))]
  const files = candidates.filter((f) => fs.existsSync(f)).map((f) => ({ f, text: fs.readFileSync(f, 'utf8') }))
  const total = files.reduce((sum, { text }) => sum + tokens(text), 0)
  const rows = files.map(({ f, text }) => {
    const lines = text.split('\n').length
    return `  ${short(f)}: ${lines} lines, ${kTok(tokens(text))}${lines > BIG_MEMORY_LINES ? '  <- over 200 lines' : ''}`
  })
  return [`Memory files (loaded in every message): ${files.length}, ${kTok(total)}`, ...rows]
}

function skillsReport() {
  const dirs = [path.join(HOME, 'skills'), path.join(root, '.claude', 'skills')]
  const skills = dirs.flatMap((d) => listDir(d).map((s) => path.join(d, s, 'SKILL.md'))).filter((f) => fs.existsSync(f))
  const descTokens = skills.reduce((sum, f) => sum + tokens(fs.readFileSync(f, 'utf8').match(/^description:(.*)$/m)?.[1] ?? ''), 0)
  return [`Skills (user + project): ${skills.length}; their descriptions cost ${kTok(descTokens)} per message, bodies load only when used`]
}

function mcpReport() {
  const user = readJson(path.join(os.homedir(), '.claude.json'))
  const names = [...Object.keys(user.mcpServers ?? {}), ...Object.keys(user.projects?.[root]?.mcpServers ?? {}),
    ...Object.keys(readJson(path.join(root, '.mcp.json')).mcpServers ?? {})]
  return [`MCP servers (user + local + project): ${names.length}${names.length ? `: ${names.join(', ')}` : ''}`]
}

function settingsReport() {
  const s = readJson(path.join(HOME, 'settings.json'))
  const env = s.env ?? {}
  return [`Settings (~/.claude/settings.json): status line ${s.statusLine ? 'set' : 'none'} · model ${s.model ?? 'default'} · ` +
    `autoCompactWindow ${s.autoCompactWindow ?? env.CLAUDE_CODE_AUTO_COMPACT_WINDOW ?? 'default'} · ` +
    `MCP tool search ${env.ENABLE_TOOL_SEARCH === 'false' ? 'OFF (all MCP tools load every message)' : 'on'}`]
}

const indexReport = () => [`Code map: ${INDEX_PATH} ${fs.existsSync(path.join(root, INDEX_PATH)) ? 'present' : 'missing'}`]

console.log([`Quack checkup for ${short(root)}`, '', ...memoryReport(), ...skillsReport(), ...mcpReport(), ...settingsReport(), ...indexReport()].join('\n'))
