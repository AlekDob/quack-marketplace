---
name: rust-tauri-commands
description: Use this skill when writing Rust commands for Tauri, serializing data with serde for JavaScript interop, handling errors with custom types, creating async commands for I/O operations, or accessing Tauri State and AppHandle. Also use when debugging command invocation failures or designing the Rust-to-frontend data contract.
---

# Rust Tauri Commands

Expert guidance for writing Rust commands in Tauri applications.

## Command Patterns

### Basic Command
```rust
#[tauri::command]
fn get_app_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}
```

### With Parameters
```rust
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct CreateProjectArgs {
    name: String,
    path: String,
    template: Option<String>,
}

#[derive(Serialize)]
struct Project {
    id: String,
    name: String,
    path: String,
    created_at: String,
}

#[tauri::command]
fn create_project(args: CreateProjectArgs) -> Result<Project, String> {
    let id = uuid::Uuid::new_v4().to_string();
    // Create project directory, initialize config...
    Ok(Project {
        id,
        name: args.name,
        path: args.path,
        created_at: chrono::Utc::now().to_rfc3339(),
    })
}
```

### Async Commands
```rust
#[tauri::command]
async fn fetch_remote_config(url: String) -> Result<serde_json::Value, String> {
    let response = reqwest::get(&url)
        .await
        .map_err(|e| format!("Request failed: {}", e))?;

    let json = response
        .json::<serde_json::Value>()
        .await
        .map_err(|e| format!("Parse failed: {}", e))?;

    Ok(json)
}
```

### With App Handle
```rust
use tauri::{AppHandle, Manager};

#[tauri::command]
async fn get_app_data_dir(app: AppHandle) -> Result<String, String> {
    let path = app
        .path()
        .app_data_dir()
        .map_err(|e| e.to_string())?;

    Ok(path.to_string_lossy().to_string())
}
```

### With State
```rust
use std::sync::Mutex;

struct DatabasePool {
    connections: Mutex<Vec<Connection>>,
}

#[tauri::command]
fn query_database(
    pool: tauri::State<DatabasePool>,
    query: String,
) -> Result<Vec<Row>, String> {
    let connections = pool.connections.lock().map_err(|e| e.to_string())?;
    // Execute query...
    Ok(results)
}
```

## Error Handling

### Custom Error Types
```rust
use serde::Serialize;

#[derive(Debug, Serialize)]
enum AppError {
    FileNotFound(String),
    PermissionDenied(String),
    ParseError(String),
    Internal(String),
}

impl std::fmt::Display for AppError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AppError::FileNotFound(path) => write!(f, "File not found: {}", path),
            AppError::PermissionDenied(msg) => write!(f, "Permission denied: {}", msg),
            AppError::ParseError(msg) => write!(f, "Parse error: {}", msg),
            AppError::Internal(msg) => write!(f, "Internal error: {}", msg),
        }
    }
}

// Implement From for common error types
impl From<std::io::Error> for AppError {
    fn from(err: std::io::Error) -> Self {
        match err.kind() {
            std::io::ErrorKind::NotFound => AppError::FileNotFound(err.to_string()),
            std::io::ErrorKind::PermissionDenied => AppError::PermissionDenied(err.to_string()),
            _ => AppError::Internal(err.to_string()),
        }
    }
}

impl From<serde_json::Error> for AppError {
    fn from(err: serde_json::Error) -> Self {
        AppError::ParseError(err.to_string())
    }
}

#[tauri::command]
fn read_config(path: String) -> Result<Config, AppError> {
    let content = std::fs::read_to_string(&path)?; // Uses From<io::Error>
    let config: Config = serde_json::from_str(&content)?; // Uses From<serde_json::Error>
    Ok(config)
}
```

## Serde Patterns

### Rename Fields for JS Convention
```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct UserPreferences {
    theme_mode: String,        // -> themeMode in JS
    font_size: u32,            // -> fontSize in JS
    auto_save: bool,           // -> autoSave in JS
    sidebar_width: Option<u32>, // -> sidebarWidth in JS
}
```

### Enum Serialization
```rust
#[derive(Serialize, Deserialize)]
#[serde(tag = "type", content = "data")]
enum Message {
    Text(String),
    File { path: String, size: u64 },
    System { code: u32, message: String },
}
// JS: { type: "Text", data: "hello" }
// JS: { type: "File", data: { path: "/tmp/f.txt", size: 1024 } }
```

### Default Values
```rust
#[derive(Serialize, Deserialize)]
struct AppConfig {
    #[serde(default = "default_theme")]
    theme: String,
    #[serde(default)]
    debug: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    custom_css: Option<String>,
}

fn default_theme() -> String {
    "dark".to_string()
}
```

## File System Operations

```rust
use std::path::PathBuf;
use tauri::Manager;

#[tauri::command]
async fn list_directory(app: AppHandle, path: String) -> Result<Vec<FileEntry>, String> {
    let dir = PathBuf::from(&path);
    if !dir.exists() {
        return Err(format!("Directory not found: {}", path));
    }

    let mut entries = Vec::new();
    let read_dir = std::fs::read_dir(&dir).map_err(|e| e.to_string())?;

    for entry in read_dir.flatten() {
        let metadata = entry.metadata().map_err(|e| e.to_string())?;
        entries.push(FileEntry {
            name: entry.file_name().to_string_lossy().to_string(),
            path: entry.path().to_string_lossy().to_string(),
            is_dir: metadata.is_dir(),
            size: metadata.len(),
        });
    }

    entries.sort_by(|a, b| {
        b.is_dir.cmp(&a.is_dir).then(a.name.to_lowercase().cmp(&b.name.to_lowercase()))
    });

    Ok(entries)
}
```

## Best Practices

- Always use `#[serde(rename_all = "camelCase")]` for JS interop
- Return `Result<T, String>` or custom serializable error types
- Use `async` for I/O-bound operations (file, network, process)
- Keep commands small — delegate to helper functions
- Use `tauri::State<T>` for shared state, wrap mutable data in `Mutex`
- Validate inputs at the command boundary before processing
- Log errors with context before returning them to the frontend
- Use `#[cfg(test)]` modules to test command logic independently
