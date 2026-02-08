---
name: rust-error-handling
description: Rust error handling patterns with Result, Option, and custom error types.
---

# Rust Error Handling

Idiomatic Rust error handling patterns using Result, Option, and the ? operator for clean error propagation. Covers custom error types with enum variants, thiserror for library errors, anyhow for application errors with context, early return patterns, collecting results from iterators, and fallback value chains. Master the Rust approach to making errors explicit, composable, and impossible to ignore.

## Result Basics

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;  // ? propagates error
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

fn main() {
    match read_file("config.txt") {
        Ok(contents) => println!("File contents: {}", contents),
        Err(e) => eprintln!("Error reading file: {}", e),
    }
}
```

## The ? Operator

```rust
// ? propagates errors, converts types if needed
fn get_user_age(id: u32) -> Result<u32, AppError> {
    let user = find_user(id)?;          // Returns early if Err
    let profile = user.get_profile()?;  // Returns early if Err
    Ok(profile.age)
}

// Works in functions returning Option too
fn get_first_word(s: &str) -> Option<&str> {
    let words: Vec<&str> = s.split_whitespace().collect();
    let first = words.get(0)?;  // Returns None if empty
    Some(first)
}
```

## Option Handling

```rust
fn main() {
    let numbers = vec![1, 2, 3];

    // Using match
    match numbers.get(0) {
        Some(n) => println!("First: {}", n),
        None => println!("Empty"),
    }

    // Using if let
    if let Some(n) = numbers.get(0) {
        println!("First: {}", n);
    }

    // Combinators
    let first = numbers.get(0)
        .map(|n| n * 2)
        .unwrap_or(0);

    // Convert Option to Result
    let value = numbers.get(10)
        .ok_or("Index out of bounds")?;
}
```

## Custom Error Types

### Simple Enum Error
```rust
#[derive(Debug)]
enum AppError {
    NotFound,
    PermissionDenied,
    InvalidInput(String),
    IoError(io::Error),
}

impl std::fmt::Display for AppError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AppError::NotFound => write!(f, "Resource not found"),
            AppError::PermissionDenied => write!(f, "Permission denied"),
            AppError::InvalidInput(msg) => write!(f, "Invalid input: {}", msg),
            AppError::IoError(e) => write!(f, "IO error: {}", e),
        }
    }
}

impl std::error::Error for AppError {}

// Enable ? conversion from io::Error
impl From<io::Error> for AppError {
    fn from(error: io::Error) -> Self {
        AppError::IoError(error)
    }
}
```

### Using thiserror
```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum AppError {
    #[error("Resource not found: {0}")]
    NotFound(String),

    #[error("Permission denied for user {user_id}")]
    PermissionDenied { user_id: u32 },

    #[error("Invalid input: {0}")]
    InvalidInput(String),

    #[error(transparent)]
    IoError(#[from] io::Error),

    #[error(transparent)]
    DatabaseError(#[from] sqlx::Error),
}
```

### Using anyhow for Applications
```rust
use anyhow::{Context, Result, bail, anyhow};

fn read_config() -> Result<Config> {
    let path = std::env::var("CONFIG_PATH")
        .context("CONFIG_PATH environment variable not set")?;

    let contents = std::fs::read_to_string(&path)
        .with_context(|| format!("Failed to read config from {}", path))?;

    let config: Config = toml::from_str(&contents)
        .context("Failed to parse config")?;

    if config.port == 0 {
        bail!("Port cannot be 0");
    }

    Ok(config)
}

fn main() -> Result<()> {
    let config = read_config()?;
    run_server(config)?;
    Ok(())
}
```

## Error Handling Patterns

### Early Return
```rust
fn process_data(data: Option<Vec<u8>>) -> Result<String, AppError> {
    let data = match data {
        Some(d) => d,
        None => return Err(AppError::NotFound("No data provided".into())),
    };

    // Or using ok_or
    let data = data.ok_or(AppError::NotFound("No data".into()))?;

    // Continue processing...
    Ok(String::from_utf8(data)?)
}
```

### Collecting Results
```rust
fn parse_numbers(strings: Vec<&str>) -> Result<Vec<i32>, std::num::ParseIntError> {
    strings.iter()
        .map(|s| s.parse::<i32>())
        .collect()  // Collects into Result<Vec<i32>, _>
}

// Keep successes, log errors
fn process_items(items: Vec<Item>) -> Vec<ProcessedItem> {
    items.into_iter()
        .filter_map(|item| {
            match process_item(item) {
                Ok(processed) => Some(processed),
                Err(e) => {
                    eprintln!("Error processing item: {}", e);
                    None
                }
            }
        })
        .collect()
}
```

### Fallback Values
```rust
fn main() {
    // Default value
    let port = env::var("PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse::<u16>()
        .unwrap_or(8080);

    // Chain of fallbacks
    let value = primary_source()
        .or_else(|_| secondary_source())
        .or_else(|_| fallback_source())
        .unwrap_or_default();
}
```

## Best Practices

- Use `thiserror` for library errors, `anyhow` for application errors
- Implement `From` traits for automatic error conversion with `?`
- Add context to errors with `.context()` or `.with_context()`
- Don't use `.unwrap()` in production code
- Use `expect()` only when panic is intentional
- Prefer `?` over explicit `match` for error propagation
