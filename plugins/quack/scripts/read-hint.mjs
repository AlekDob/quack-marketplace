// PreToolUse(Read) hook: before Claude reads a big file whole, remind it to read only the part it needs.
// It never blocks the read, it only adds one line of advice next to it.
import fs from 'node:fs'
import path from 'node:path'
import { runHook, emit, kTokens } from './lib.mjs'
import { INDEX_PATH } from './index.mjs'

const MIN_LINES = Number(process.env.QUACK_BIG_FILE_LINES) || 400
const MIN_BYTES = 16_000 // smaller files can't reach MIN_LINES of real code: skip reading them
const MEDIA = /\.(png|jpe?g|gif|webp|bmp|ico|svg|pdf|ipynb)$/i // Read handles these as media, not text

runHook(async ({ tool_input: args = {}, cwd = process.cwd() }) => {
  const file = args.file_path
  if (!file || args.offset || args.limit || MEDIA.test(file) || fs.statSync(file).size < MIN_BYTES) return
  const text = fs.readFileSync(file, 'utf8')
  const lines = text.split('\n').length
  if (lines < MIN_LINES) return
  const where = fs.existsSync(path.join(cwd, INDEX_PATH))
    ? `${INDEX_PATH} lists its symbols with line ranges`
    : 'Grep for the symbol to find its lines'
  emit('PreToolUse', {
    context: `Quack: ${path.basename(file)} has ${lines} lines (~${kTokens(text.length / 4)} tokens). If you need only part of it, ${where}, then Read with offset/limit.`,
  })
})
