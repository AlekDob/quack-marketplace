#!/usr/bin/env node
// Quack index: a PageIndex-style map of the repo for AI agents (folder → file → symbols with line ranges),
// written to documentation/INDEX.md. Agents read the map first, then open only the lines they need.
// Zero dependencies and deterministic: the same code always gives the same file, so it is safe to commit.
// shortcut: symbols come from line regexes, not a parser, so nested or unusual declarations are missed;
//           switch to tree-sitter or ctags if users need exact coverage.
import fs from 'node:fs'
import path from 'node:path'
import { execFileSync } from 'node:child_process'
import { pathToFileURL } from 'node:url'

export const INDEX_PATH = 'documentation/INDEX.md'
const SUB_DIR = 'documentation/index'
const MARK = '<!-- quack-index'
const SPLIT_AT = 250 // more files than this: one sub-index per folder, so nobody loads the whole map
const MAX_BYTES = 256_000 // bigger files are usually generated: listed without symbols
const MAX_SYMBOLS = 30
const SOURCE = /\.(m?[jt]sx?|cjs|py|go|rs|swift|kts?|java|rb|php|vue|svelte|cs|c|h|cc|cpp|hpp|scala|exs?|sh|mdx?)$/i
const SKIP = /(^|\/)(\.[^/]+|node_modules|vendor|dist|build|out|coverage|\.next|\.nuxt|documentation\/index|documentation\/diary)\/|\.min\.|^documentation\/INDEX\.md$/
const DECL = /^(export\s+(?:default\s+)?)?(?:(?:pub(?:\([^)]*\))?|public|private|internal|open|final|abstract|sealed|data|static|async)\s+)*(function\*?|class|interface|type|enum|struct|trait|impl|protocol|extension|object|def|fn|func|fun|const|let|var|module)\s+(?:\([^)]*\)\s*)?([A-Za-z_$][\w$]*)/
const HEADING = /^#{1,3}\s+(.+?)\s*#*$/
const SECTION = /^#{2,3}\s+(.+?)\s*#*$/ // h1 is the title, already used as the purpose
const COMMENT = /^\s*(?:\/\/+|#+|\/\*+|\*|"""|'''|--)\s*(.*)$/
const NOT_PURPOSE = /^(!|eslint|@ts-|prettier|copyright|spdx|include|define|pragma|use (client|server|strict))/i

function git(cwd, args) {
  try {
    return execFileSync('git', args, { cwd, encoding: 'utf8', maxBuffer: 64 << 20, stdio: ['ignore', 'pipe', 'ignore'] })
  } catch { return null }
}

/** Repo root when inside git, otherwise the folder itself. */
export function projectRoot(cwd) {
  return git(cwd, ['rev-parse', '--show-toplevel'])?.trim() || cwd
}

export const isGitRepo = (cwd) => git(cwd, ['rev-parse', '--is-inside-work-tree']) !== null

function listFiles(root) {
  const out = git(root, ['ls-files', '-z', '-co', '--exclude-standard'])
  const all = out !== null ? out.split('\0') : walk(root, '')
  return all.filter((f) => f && SOURCE.test(f) && !SKIP.test(f)).sort()
}

/** Outside git: walk the folder, skipping hidden and dependency folders. */
function walk(root, rel) {
  return fs.readdirSync(path.join(root, rel), { withFileTypes: true }).flatMap((d) => {
    const child = rel ? `${rel}/${d.name}` : d.name
    if (d.name.startsWith('.') || SKIP.test(`${child}/`)) return []
    return d.isDirectory() ? walk(root, child) : [child]
  })
}

const clean = (s) => (s ?? '').replace(/("""|'''|\*\/)\s*$/, '').replace(/^["']|["']$/g, '').replace(/\s+/g, ' ').trim().slice(0, 110)

/** One line on what the file is for: a doc's description or first heading, a code file's first comment. */
function purpose(lines, isDoc) {
  if (isDoc) {
    const desc = lines.slice(0, 20).find((l) => /^description:\s*\S/.test(l))
    return clean(desc ? desc.replace(/^description:\s*/, '') : lines.find((l) => HEADING.test(l))?.match(HEADING)[1])
  }
  for (const line of lines.slice(0, 15)) {
    const text = clean(line.match(COMMENT)?.[1])
    if (text && !NOT_PURPOSE.test(text)) return text
  }
  return ''
}

function declaration(line) {
  const m = line.match(DECL)
  // Private constants are noise in the map, but they still end the previous symbol's range
  return m && { name: m[3], hidden: !m[1] && /^(const|let|var)$/.test(m[2]) }
}

/** Top-level symbols (code) or headings (docs), each with its range up to the next one. */
function symbols(lines, isDoc) {
  const starts = []
  let fenced = false
  lines.forEach((line, i) => {
    if (isDoc && /^(```|~~~)/.test(line)) fenced = !fenced
    const found = fenced ? null : isDoc ? { name: line.match(SECTION)?.[1] } : declaration(line)
    if (found?.name) starts.push({ ...found, line: i + 1 })
  })
  return starts
    .map((s, i) => ({ ...s, end: lastFilled(lines, (starts[i + 1]?.line ?? lines.length + 1) - 1) }))
    .filter((s) => !s.hidden)
}

/** Range end = last non-empty line before the next symbol. */
function lastFilled(lines, end) {
  while (end > 1 && !lines[end - 1].trim()) end--
  return end
}

function formatSymbols(syms) {
  const shown = syms.slice(0, MAX_SYMBOLS).map((s) => `${s.name} L${s.line}${s.end > s.line ? `-${s.end}` : ''}`)
  const more = syms.length - shown.length
  return shown.join(' · ') + (more > 0 ? ` · +${more} more` : '')
}

function fileEntry(root, rel) {
  let text
  try { text = fs.readFileSync(path.join(root, rel), 'utf8') } catch { return null } // deleted or unreadable
  const lines = text.split('\n')
  const isDoc = /\.mdx?$/i.test(rel)
  const big = text.length > MAX_BYTES
  const what = big ? 'large file, probably generated' : purpose(lines, isDoc)
  const syms = big ? [] : symbols(lines, isDoc)
  const head = `- \`${path.posix.basename(rel)}\` (${lines.length})${what ? ` — ${what}` : ''}`
  return { rel, text: syms.length ? `${head}\n  ${formatSymbols(syms)}` : head }
}

function groupBy(list, keyOf) {
  const groups = new Map()
  for (const item of list) groups.set(keyOf(item), [...(groups.get(keyOf(item)) ?? []), item])
  return groups
}

const dirKey = (rel, depth) => {
  const dir = path.posix.dirname(rel)
  return dir === '.' ? '(root)' : dir.split('/').slice(0, depth).join('/')
}

function renderTree(entries) {
  const byDir = groupBy(entries, (e) => dirKey(e.rel, Infinity))
  return [...byDir].map(([dir, list]) => `## ${dir === '(root)' ? dir : `${dir}/`}\n${list.map((e) => e.text).join('\n')}`).join('\n\n')
}

/** Split folders until each sub-index holds at most SPLIT_AT files (PageIndex: open only the branch you need). */
function splitGroups(entries, depth = 1) {
  return [...groupBy(entries, (e) => dirKey(e.rel, depth))].flatMap(([key, list]) => {
    const deeper = list.length > SPLIT_AT && list.some((e) => dirKey(e.rel, depth + 1) !== key)
    return deeper ? splitGroups(list, depth + 1) : [[key, list]]
  })
}

const page = (title, body) => `${MARK} v1: generated by Quack, do not edit by hand. Refresh: /quack:index -->
# ${title}

Map of this repo for AI agents: folder → \`file\` (lines) — purpose → symbols with line ranges.
Find what you need here, then Read only that range (offset = start line, limit = range length).
Ranges come from the last refresh: if a symbol moved, Grep for it.

${body}
`

/** Pages to write, keyed by path: one INDEX.md, or INDEX.md plus one sub-index per folder in big repos. */
function render(entries) {
  if (entries.length <= SPLIT_AT) return { [INDEX_PATH]: page('Code index', renderTree(entries)) }
  const pages = {}
  const rows = splitGroups(entries).map(([key, list]) => {
    const file = `${key === '(root)' ? '_root' : key.replace(/\//g, '--')}.md`
    pages[`${SUB_DIR}/${file}`] = page(`Code index: ${key}`, renderTree(list))
    return `- [${key}](index/${file}): ${list.length} file${list.length === 1 ? "" : "s"}`
  })
  pages[INDEX_PATH] = page('Code index', `Large repo: open only the sub-index of the folder you need.\n\n${rows.join('\n')}`)
  return pages
}

function writeIfChanged(file, content) {
  try { if (fs.readFileSync(file, 'utf8') === content) return 0 } catch { /* new file */ }
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, content)
  return 1
}

/** Removes sub-indexes Quack wrote earlier that no longer exist; files without Quack's mark are never touched. */
function removeStale(root, pages) {
  const dir = path.join(root, SUB_DIR)
  if (!fs.existsSync(dir)) return 0
  const stale = fs.readdirSync(dir).filter((f) => f.endsWith(".md") && !pages[`${SUB_DIR}/${f}`] && fs.readFileSync(path.join(dir, f), 'utf8').startsWith(MARK))
  stale.forEach((f) => fs.unlinkSync(path.join(dir, f)))
  return stale.length
}

/** Builds the map; writes only the pages whose content changed. */
export function buildIndex(root) {
  const entries = listFiles(root).map((rel) => fileEntry(root, rel)).filter(Boolean)
  const pages = render(entries)
  let changed = removeStale(root, pages)
  for (const [rel, content] of Object.entries(pages)) changed += writeIfChanged(path.join(root, rel), content)
  return { files: entries.length, changed }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const { files, changed } = buildIndex(projectRoot(process.argv[2] || process.cwd()))
  console.log(`Quack index: ${files} files mapped in ${INDEX_PATH}${changed ? ` (${changed} page(s) updated)` : ', already up to date'}.`)
}
