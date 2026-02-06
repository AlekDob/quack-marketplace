---
name: tauri-v2-patterns
description: Use this skill when building Tauri 2 desktop applications, defining Tauri commands, setting up the event system between Rust and frontend, configuring permissions and capabilities, integrating Tauri plugins (fs, dialog, shell), or managing app state with Mutex. Also use when debugging IPC issues or structuring a Tauri project.
---

# Tauri v2 Patterns

Expert guidance for building desktop applications with Tauri 2.

## Architecture Overview

Tauri apps have two processes:
- **Core (Rust)**: Backend logic, file system, OS integration, security
- **Webview (JS/TS)**: Frontend UI rendered in a native webview

Communication flows through Tauri's **IPC bridge** using `invoke` (frontend to backend) and `emit/listen` (events in both directions).

```
┌─────────────┐    invoke()     ┌──────────────┐
│  React UI   │ ──────────────> │  Rust Core   │
│  (Webview)  │ <────────────── │  (Commands)  │
└─────────────┘    Response     └──────────────┘
       ↑↓                            ↑↓
    Events                        Events
   (listen)                      (emit)
```

## Tauri Commands

### Defining Commands
```rust
use tauri::command;

#[command]
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

#[command]
async fn read_file(path: String) -> Result<String, String> {
    std::fs::read_to_string(&path).map_err(|e| e.to_string())
}

// Register in builder
fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet, read_file])
        .run(tauri::generate_context!())
        .expect("error running app");
}
```

### Calling from Frontend
```typescript
import { invoke } from '@tauri-apps/api/core'

// Simple call
const greeting = await invoke<string>('greet', { name: 'World' })

// With error handling
try {
  const content = await invoke<string>('read_file', { path: '/tmp/test.txt' })
} catch (error) {
  console.error('Command failed:', error)
}
```

## Event System

### Rust to Frontend
```rust
use tauri::Emitter;

#[command]
async fn start_process(app: tauri::AppHandle) -> Result<(), String> {
    // Emit progress events
    for i in 0..100 {
        app.emit("process-progress", i).map_err(|e| e.to_string())?;
        tokio::time::sleep(tokio::time::Duration::from_millis(50)).await;
    }
    app.emit("process-complete", ()).map_err(|e| e.to_string())?;
    Ok(())
}
```

### Frontend Listening
```typescript
import { listen } from '@tauri-apps/api/event'

const unlisten = await listen<number>('process-progress', (event) => {
  setProgress(event.payload)
})

// Cleanup
unlisten()
```

## Permission System (Tauri v2)

### Capability Files
```json
// src-tauri/capabilities/default.json
{
  "identifier": "default",
  "description": "Default app permissions",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "fs:default",
    "shell:allow-open",
    "dialog:default",
    "clipboard-manager:default"
  ]
}
```

### Custom Permissions
```toml
# src-tauri/permissions/custom.toml
[[permission]]
identifier = "allow-read-config"
description = "Allow reading config files"

[[permission.scope.allow]]
path = "$APPCONFIG/**"
```

## Plugin System

### Using Official Plugins
```rust
// Cargo.toml
[dependencies]
tauri-plugin-fs = "2"
tauri-plugin-dialog = "2"
tauri-plugin-shell = "2"

// main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_shell::init())
        .run(tauri::generate_context!())
        .expect("error running app");
}
```

### Frontend Plugin Usage
```typescript
import { readTextFile, writeTextFile } from '@tauri-apps/plugin-fs'
import { open, save } from '@tauri-apps/plugin-dialog'

// File dialog + read
const path = await open({ filters: [{ name: 'Text', extensions: ['txt'] }] })
if (path) {
  const content = await readTextFile(path)
}
```

## State Management

### Managed State in Rust
```rust
use std::sync::Mutex;
use tauri::Manager;

struct AppState {
    counter: Mutex<i32>,
    config: Mutex<AppConfig>,
}

#[command]
fn increment(state: tauri::State<AppState>) -> i32 {
    let mut counter = state.counter.lock().unwrap();
    *counter += 1;
    *counter
}

fn main() {
    tauri::Builder::default()
        .manage(AppState {
            counter: Mutex::new(0),
            config: Mutex::new(AppConfig::default()),
        })
        .invoke_handler(tauri::generate_handler![increment])
        .run(tauri::generate_context!())
        .expect("error running app");
}
```

## Window Management

```rust
use tauri::Manager;

#[command]
async fn open_settings(app: tauri::AppHandle) -> Result<(), String> {
    let _window = tauri::WebviewWindowBuilder::new(
        &app,
        "settings",
        tauri::WebviewUrl::App("settings.html".into()),
    )
    .title("Settings")
    .inner_size(600.0, 400.0)
    .build()
    .map_err(|e| e.to_string())?;
    Ok(())
}
```

## Best Practices

- Keep Rust commands focused and small — one responsibility per command
- Use `Result<T, String>` for error handling in commands
- Serialize complex data with serde — `#[derive(Serialize, Deserialize)]`
- Use `tauri::State` for shared app state, not global variables
- Emit events for long-running operations instead of blocking invoke calls
- Scope file system access to specific directories via permissions
- Use `async` commands for I/O operations to avoid blocking the main thread
- Test Rust commands independently from the frontend
