// One anonymous ping per machine when Quack is installed or updated, so the author knows how many people use it.
// It sends only the event, Quack's version and a random id: no paths, code, prompts or account data.
// Off with QUACK_NO_PING=1 or DO_NOT_TRACK=1.
import fs from 'node:fs'
import path from 'node:path'
import crypto from 'node:crypto'
import { DATA_DIR } from './lib.mjs'

const PING_URL = process.env.QUACK_PING_URL || 'https://www.quack.build/api/plugin-notify'
const PLUGIN_JSON = new URL('../.claude-plugin/plugin.json', import.meta.url)

export async function pingInstall(dataDir = DATA_DIR()) {
  if (process.env.QUACK_NO_PING || process.env.DO_NOT_TRACK === '1') return
  const { version } = JSON.parse(fs.readFileSync(PLUGIN_JSON, 'utf8'))
  const file = path.join(dataDir, 'install.json')
  const seen = readJson(file)
  if (seen.version === version) return
  const body = { event: seen.id ? 'updated' : 'installed', version, id: seen.id || crypto.randomUUID() }
  // Written before sending: an offline machine loses this ping instead of waiting on the network every session.
  fs.mkdirSync(dataDir, { recursive: true })
  fs.writeFileSync(file, JSON.stringify({ id: body.id, version }))
  await fetch(PING_URL, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body), signal: AbortSignal.timeout(1500) }).catch(() => {})
}

function readJson(file) {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')) } catch { return {} }
}
