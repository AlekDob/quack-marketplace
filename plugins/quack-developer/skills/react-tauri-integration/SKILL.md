---
name: react-tauri-integration
description: React + Tauri integration patterns for IPC communication, hooks, and desktop-native UI.
---

# React + Tauri Integration

Expert guidance for building React frontends that integrate seamlessly with Tauri's Rust backend.

## IPC Communication Hooks

### Generic Invoke Hook
```tsx
import { useState, useCallback } from 'react'
import { invoke } from '@tauri-apps/api/core'

function useInvoke<T>(command: string) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const execute = useCallback(async (args?: Record<string, unknown>) => {
    setLoading(true)
    setError(null)
    try {
      const result = await invoke<T>(command, args)
      setData(result)
      return result
    } catch (err) {
      const message = typeof err === 'string' ? err : String(err)
      setError(message)
      throw err
    } finally {
      setLoading(false)
    }
  }, [command])

  return { data, loading, error, execute }
}

// Usage
function ProjectList() {
  const { data: projects, loading, execute } = useInvoke<Project[]>('list_projects')

  useEffect(() => { execute() }, [execute])

  if (loading) return <Skeleton />
  return <ul>{projects?.map(p => <li key={p.id}>{p.name}</li>)}</ul>
}
```

### Event Listener Hook
```tsx
import { useEffect } from 'react'
import { listen } from '@tauri-apps/api/event'

function useEvent<T>(eventName: string, handler: (payload: T) => void) {
  useEffect(() => {
    let unlisten: (() => void) | undefined

    listen<T>(eventName, (event) => {
      handler(event.payload)
    }).then((fn) => {
      unlisten = fn
    })

    return () => {
      unlisten?.()
    }
  }, [eventName, handler])
}

// Usage
function ProgressBar() {
  const [progress, setProgress] = useState(0)
  useEvent<number>('process-progress', setProgress)
  return <div style={{ width: `${progress}%` }} className="progress-bar" />
}
```

## Desktop-Native Patterns

### Window Dragging (Title Bar)
```tsx
function TitleBar() {
  return (
    <div
      data-tauri-drag-region
      className="flex items-center h-8 bg-gray-900 select-none"
    >
      <span className="ml-3 text-sm font-medium text-gray-300">My App</span>
      <div className="ml-auto flex">
        <WindowControls />
      </div>
    </div>
  )
}
```

### Window Controls
```tsx
import { getCurrentWindow } from '@tauri-apps/api/window'

function WindowControls() {
  const appWindow = getCurrentWindow()

  return (
    <div className="flex">
      <button
        onClick={() => appWindow.minimize()}
        className="window-control"
      >
        —
      </button>
      <button
        onClick={() => appWindow.toggleMaximize()}
        className="window-control"
      >
        □
      </button>
      <button
        onClick={() => appWindow.close()}
        className="window-control close"
      >
        ×
      </button>
    </div>
  )
}
```

### File Drag & Drop
```tsx
import { listen } from '@tauri-apps/api/event'

function FileDropZone({ onFiles }: { onFiles: (paths: string[]) => void }) {
  const [isDragging, setIsDragging] = useState(false)

  useEffect(() => {
    const unlistenDrop = listen<{ paths: string[] }>('tauri://drag-drop', (event) => {
      setIsDragging(false)
      onFiles(event.payload.paths)
    })
    const unlistenEnter = listen('tauri://drag-enter', () => setIsDragging(true))
    const unlistenLeave = listen('tauri://drag-leave', () => setIsDragging(false))

    return () => {
      unlistenDrop.then(fn => fn())
      unlistenEnter.then(fn => fn())
      unlistenLeave.then(fn => fn())
    }
  }, [onFiles])

  return (
    <div className={`drop-zone ${isDragging ? 'active' : ''}`}>
      Drop files here
    </div>
  )
}
```

## State Synchronization

### Rust State to React
```tsx
// Pattern: Load state from Rust on mount, update via commands

interface AppPreferences {
  theme: string
  fontSize: number
  autoSave: boolean
}

function usePreferences() {
  const [prefs, setPrefs] = useState<AppPreferences | null>(null)

  useEffect(() => {
    invoke<AppPreferences>('get_preferences').then(setPrefs)
  }, [])

  const updatePref = useCallback(async <K extends keyof AppPreferences>(
    key: K,
    value: AppPreferences[K]
  ) => {
    // Optimistic update
    setPrefs(prev => prev ? { ...prev, [key]: value } : null)
    try {
      await invoke('set_preference', { key, value })
    } catch {
      // Rollback on error
      const fresh = await invoke<AppPreferences>('get_preferences')
      setPrefs(fresh)
    }
  }, [])

  return { prefs, updatePref }
}
```

### Bidirectional Event Sync
```tsx
// For real-time features: terminals, file watchers, process output

function useTerminalOutput(terminalId: string) {
  const [lines, setLines] = useState<string[]>([])

  // Listen for output from Rust
  useEvent<string>(`terminal-output-${terminalId}`, (line) => {
    setLines(prev => [...prev, line])
  })

  // Send input to Rust
  const sendInput = useCallback((input: string) => {
    invoke('terminal_write', { id: terminalId, data: input })
  }, [terminalId])

  return { lines, sendInput }
}
```

## Context Menu Integration

```tsx
import { invoke } from '@tauri-apps/api/core'

function FileExplorer() {
  const handleContextMenu = useCallback(async (e: React.MouseEvent, file: FileEntry) => {
    e.preventDefault()

    // Show native context menu via Rust command
    const action = await invoke<string>('show_context_menu', {
      items: [
        { label: 'Open', action: 'open' },
        { label: 'Rename', action: 'rename' },
        { separator: true },
        { label: 'Delete', action: 'delete', danger: true },
      ],
    })

    switch (action) {
      case 'open': handleOpen(file); break
      case 'rename': handleRename(file); break
      case 'delete': handleDelete(file); break
    }
  }, [])

  return (
    <div onContextMenu={(e) => handleContextMenu(e, selectedFile)}>
      {/* File list */}
    </div>
  )
}
```

## Performance Considerations

- Minimize IPC calls — batch related data in single commands
- Use events for streaming data (terminal output, file watching, progress)
- Cache Rust state in React — don't invoke for every render
- Use `requestAnimationFrame` for high-frequency UI updates from events
- Debounce user input before sending to Rust (search, resize, typing)
- Prefer Rust for CPU-intensive work (parsing, diffing, file scanning)
- Keep React responsible for UI rendering and user interaction only

## Anti-Patterns to Avoid

- Polling Rust with `setInterval` — use events instead
- Storing large data in React state that belongs in Rust
- Making synchronous IPC calls in render paths
- Forgetting to unlisten from events (memory leaks)
- Passing file paths without sanitizing — let Rust handle path resolution
- Using `window.__TAURI__` directly — use the official `@tauri-apps/api`
