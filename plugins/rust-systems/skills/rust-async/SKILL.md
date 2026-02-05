---
name: rust-async
description: Rust async/await patterns with Tokio for concurrent and parallel programming.
---

# Rust Async Patterns

Asynchronous programming in Rust with Tokio runtime.

## Basics

### Async Functions
```rust
use tokio;

async fn fetch_data(url: &str) -> Result<String, reqwest::Error> {
    let response = reqwest::get(url).await?;
    let body = response.text().await?;
    Ok(body)
}

#[tokio::main]
async fn main() {
    let result = fetch_data("https://api.example.com").await;
    match result {
        Ok(data) => println!("Got: {}", data),
        Err(e) => eprintln!("Error: {}", e),
    }
}
```

### Spawning Tasks
```rust
use tokio::task;

async fn main() {
    // Spawn concurrent tasks
    let handle1 = task::spawn(async {
        fetch_data("https://api1.example.com").await
    });

    let handle2 = task::spawn(async {
        fetch_data("https://api2.example.com").await
    });

    // Wait for both
    let (result1, result2) = tokio::join!(handle1, handle2);
    println!("Results: {:?}, {:?}", result1, result2);
}
```

## Concurrent Execution

### join! Macro
```rust
use tokio;

async fn main() {
    // Run concurrently, wait for all
    let (a, b, c) = tokio::join!(
        fetch_user(1),
        fetch_posts(1),
        fetch_comments(1),
    );
}
```

### select! Macro
```rust
use tokio::select;
use tokio::time::{sleep, Duration};

async fn race_requests() -> String {
    select! {
        result = fetch_from_server_a() => {
            format!("Server A responded: {}", result)
        }
        result = fetch_from_server_b() => {
            format!("Server B responded: {}", result)
        }
        _ = sleep(Duration::from_secs(5)) => {
            "Timeout".to_string()
        }
    }
}
```

### FuturesUnordered
```rust
use futures::stream::{FuturesUnordered, StreamExt};

async fn fetch_all(urls: Vec<String>) -> Vec<String> {
    let mut futures = FuturesUnordered::new();

    for url in urls {
        futures.push(fetch_data(&url));
    }

    let mut results = Vec::new();
    while let Some(result) = futures.next().await {
        if let Ok(data) = result {
            results.push(data);
        }
    }
    results
}
```

## Channels

### mpsc (Multiple Producer, Single Consumer)
```rust
use tokio::sync::mpsc;

async fn main() {
    let (tx, mut rx) = mpsc::channel::<String>(32);

    // Producer
    let tx_clone = tx.clone();
    tokio::spawn(async move {
        tx_clone.send("Hello".to_string()).await.unwrap();
    });

    // Consumer
    while let Some(message) = rx.recv().await {
        println!("Got: {}", message);
    }
}
```

### oneshot (Single Value)
```rust
use tokio::sync::oneshot;

async fn request_with_response() {
    let (tx, rx) = oneshot::channel();

    tokio::spawn(async move {
        let result = expensive_computation().await;
        let _ = tx.send(result);
    });

    match rx.await {
        Ok(value) => println!("Got: {}", value),
        Err(_) => println!("Sender dropped"),
    }
}
```

### broadcast (Multiple Consumers)
```rust
use tokio::sync::broadcast;

async fn pub_sub() {
    let (tx, _) = broadcast::channel::<String>(16);

    let mut rx1 = tx.subscribe();
    let mut rx2 = tx.subscribe();

    tokio::spawn(async move {
        while let Ok(msg) = rx1.recv().await {
            println!("Subscriber 1: {}", msg);
        }
    });

    tokio::spawn(async move {
        while let Ok(msg) = rx2.recv().await {
            println!("Subscriber 2: {}", msg);
        }
    });

    tx.send("Hello everyone!".to_string()).unwrap();
}
```

## Synchronization

### Mutex
```rust
use tokio::sync::Mutex;
use std::sync::Arc;

async fn shared_counter() {
    let counter = Arc::new(Mutex::new(0));

    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        handles.push(tokio::spawn(async move {
            let mut num = counter.lock().await;
            *num += 1;
        }));
    }

    for handle in handles {
        handle.await.unwrap();
    }

    println!("Counter: {}", *counter.lock().await);
}
```

### RwLock
```rust
use tokio::sync::RwLock;
use std::sync::Arc;

async fn read_heavy_workload() {
    let data = Arc::new(RwLock::new(vec![1, 2, 3]));

    // Multiple concurrent readers
    let read_handle = {
        let data = Arc::clone(&data);
        tokio::spawn(async move {
            let guard = data.read().await;
            println!("Data: {:?}", *guard);
        })
    };

    // Exclusive writer
    let write_handle = {
        let data = Arc::clone(&data);
        tokio::spawn(async move {
            let mut guard = data.write().await;
            guard.push(4);
        })
    };

    let _ = tokio::join!(read_handle, write_handle);
}
```

## Timeouts

```rust
use tokio::time::{timeout, Duration};

async fn with_timeout() {
    match timeout(Duration::from_secs(5), slow_operation()).await {
        Ok(result) => println!("Got result: {:?}", result),
        Err(_) => println!("Operation timed out"),
    }
}
```

## Best Practices

- Use `#[tokio::main]` for the entry point
- Prefer `tokio::spawn` for CPU-bound tasks in separate threads
- Use channels for communication between tasks
- Avoid holding locks across await points
- Use `Arc<Mutex<T>>` for shared mutable state
- Handle cancellation properly with `select!`
