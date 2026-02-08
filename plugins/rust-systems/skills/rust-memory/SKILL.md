---
name: rust-memory
description: Rust ownership, borrowing, and memory management patterns for safe systems programming.
---

# Rust Memory Management

Deep guide to Rust's ownership system, borrowing rules, and lifetime annotations for writing memory-safe code without a garbage collector. Covers ownership transfer and cloning, immutable and mutable references, lifetime elision and explicit annotations, smart pointers (Box, Rc, Arc, RefCell), interior mutability, and Cow for efficient copy-on-write semantics. The key to understanding Rust's core differentiator and writing zero-cost safe abstractions.

## Ownership Rules

```rust
fn main() {
    // Rule 1: Each value has exactly one owner
    let s1 = String::from("hello");

    // Rule 2: Ownership can be transferred (moved)
    let s2 = s1;  // s1 is no longer valid

    // Rule 3: When owner goes out of scope, value is dropped
    {
        let s3 = String::from("world");
    } // s3 is dropped here

    // Clone for deep copy
    let s4 = s2.clone();
    println!("{} {}", s2, s4);  // Both valid
}
```

## Borrowing

### Immutable References
```rust
fn main() {
    let s = String::from("hello");

    // Multiple immutable borrows allowed
    let r1 = &s;
    let r2 = &s;
    println!("{} {}", r1, r2);

    // Function borrowing
    let len = calculate_length(&s);
    println!("Length of '{}' is {}", s, len);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}
```

### Mutable References
```rust
fn main() {
    let mut s = String::from("hello");

    // Only ONE mutable reference at a time
    let r1 = &mut s;
    r1.push_str(", world");
    // let r2 = &mut s;  // ERROR: cannot borrow twice

    println!("{}", r1);

    // Mutable borrow ends, can borrow again
    let r2 = &mut s;
    r2.push_str("!");
}
```

### Borrowing Rules
```rust
fn main() {
    let mut s = String::from("hello");

    // Can't have mutable and immutable refs simultaneously
    let r1 = &s;
    let r2 = &s;
    println!("{} {}", r1, r2);
    // r1 and r2 no longer used after this point

    // Now we can have a mutable reference
    let r3 = &mut s;
    r3.push_str(" world");
}
```

## Lifetimes

### Basic Lifetimes
```rust
// Explicit lifetime annotation
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

fn main() {
    let s1 = String::from("long string");
    let s2 = String::from("short");

    let result = longest(&s1, &s2);
    println!("Longest: {}", result);
}
```

### Struct Lifetimes
```rust
struct Excerpt<'a> {
    part: &'a str,
}

impl<'a> Excerpt<'a> {
    fn level(&self) -> i32 {
        3
    }

    fn announce_and_return_part(&self, announcement: &str) -> &str {
        println!("Attention: {}", announcement);
        self.part
    }
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().unwrap();
    let excerpt = Excerpt { part: first_sentence };
}
```

### Static Lifetime
```rust
// Lives for entire program duration
let s: &'static str = "I live forever!";

// Often used with constants
static HELLO: &str = "Hello, World!";
```

## Smart Pointers

### Box<T>
```rust
// Heap allocation
fn main() {
    let b = Box::new(5);
    println!("b = {}", b);

    // Useful for recursive types
    enum List {
        Cons(i32, Box<List>),
        Nil,
    }

    use List::{Cons, Nil};
    let list = Cons(1, Box::new(Cons(2, Box::new(Nil))));
}
```

### Rc<T> (Reference Counting)
```rust
use std::rc::Rc;

fn main() {
    let a = Rc::new(String::from("shared data"));

    // Clone increases reference count
    let b = Rc::clone(&a);
    let c = Rc::clone(&a);

    println!("Reference count: {}", Rc::strong_count(&a));
}
```

### Arc<T> (Atomic Reference Counting)
```rust
use std::sync::Arc;
use std::thread;

fn main() {
    let data = Arc::new(vec![1, 2, 3]);

    let mut handles = vec![];

    for i in 0..3 {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            println!("Thread {}: {:?}", i, data);
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

### RefCell<T> (Interior Mutability)
```rust
use std::cell::RefCell;

fn main() {
    let data = RefCell::new(5);

    // Borrow mutably at runtime
    *data.borrow_mut() += 1;

    // Borrow immutably
    println!("Value: {}", data.borrow());
}
```

## Common Patterns

### Cow (Clone on Write)
```rust
use std::borrow::Cow;

fn process_name(name: &str) -> Cow<str> {
    if name.contains(' ') {
        // Need to allocate
        Cow::Owned(name.replace(' ', "_"))
    } else {
        // No allocation needed
        Cow::Borrowed(name)
    }
}
```

### Option and Memory
```rust
// Option<Box<T>> has same size as Box<T> due to null pointer optimization
let some_box: Option<Box<i32>> = Some(Box::new(42));
let no_box: Option<Box<i32>> = None;
```

## Best Practices

- Prefer borrowing over ownership transfer when possible
- Use `&str` instead of `String` in function parameters
- Use `Arc<Mutex<T>>` for shared mutable state across threads
- Avoid `Rc<RefCell<T>>` unless necessary (prefer compile-time checks)
- Let the compiler guide you with lifetime errors
