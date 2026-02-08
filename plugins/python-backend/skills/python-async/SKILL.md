---
name: python-async
description: Python async/await patterns for concurrent programming with asyncio.
---

# Python Async Patterns

In-depth async/await patterns for concurrent Python programming targeting Python 3.11 and above. Covers asyncio fundamentals, TaskGroups for structured concurrency, async context managers and iterators, synchronization primitives (locks, semaphores, events), timeouts, aiohttp for concurrent HTTP requests, and connection pooling. Essential for writing high-throughput I/O-bound applications without the complexity of threads.

## Fundamentals

### Basic Async/Await
```python
import asyncio

async def fetch_data(url: str) -> dict:
    """Async function that simulates fetching data."""
    await asyncio.sleep(1)  # Simulate I/O
    return {"url": url, "data": "..."}

async def main():
    # Await single coroutine
    result = await fetch_data("https://api.example.com")
    print(result)

asyncio.run(main())
```

### Concurrent Execution
```python
async def main():
    # Run multiple coroutines concurrently
    results = await asyncio.gather(
        fetch_data("https://api1.example.com"),
        fetch_data("https://api2.example.com"),
        fetch_data("https://api3.example.com"),
    )
    return results

# With error handling
async def main_safe():
    results = await asyncio.gather(
        fetch_data("url1"),
        fetch_data("url2"),
        return_exceptions=True  # Don't fail fast
    )
    for result in results:
        if isinstance(result, Exception):
            print(f"Error: {result}")
        else:
            print(f"Success: {result}")
```

## TaskGroups (Python 3.11+)

```python
async def process_items(items: list[str]) -> list[dict]:
    results = []

    async with asyncio.TaskGroup() as tg:
        tasks = [
            tg.create_task(process_item(item))
            for item in items
        ]

    return [task.result() for task in tasks]

# With structured concurrency
async def download_all(urls: list[str]) -> list[bytes]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(download(url)) for url in urls]
    # All tasks complete or all are cancelled if one fails
    return [t.result() for t in tasks]
```

## Async Context Managers

```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def database_connection():
    conn = await create_connection()
    try:
        yield conn
    finally:
        await conn.close()

# Usage
async with database_connection() as conn:
    result = await conn.execute("SELECT * FROM users")
```

## Async Iterators

```python
async def fetch_pages(url: str):
    """Async generator for paginated API."""
    page = 1
    while True:
        data = await fetch_page(url, page)
        if not data["items"]:
            break
        for item in data["items"]:
            yield item
        page += 1

# Usage
async for item in fetch_pages("https://api.example.com/items"):
    process(item)
```

## Synchronization

### Locks
```python
lock = asyncio.Lock()

async def thread_safe_operation():
    async with lock:
        # Only one coroutine executes this at a time
        await modify_shared_resource()
```

### Semaphores
```python
# Limit concurrent operations
semaphore = asyncio.Semaphore(10)

async def limited_fetch(url: str):
    async with semaphore:
        return await fetch(url)

# Process many URLs with max 10 concurrent
async def main():
    urls = [f"https://api.example.com/{i}" for i in range(100)]
    results = await asyncio.gather(*[limited_fetch(url) for url in urls])
```

### Events
```python
event = asyncio.Event()

async def waiter():
    print("Waiting for event...")
    await event.wait()
    print("Event received!")

async def setter():
    await asyncio.sleep(2)
    event.set()

async def main():
    await asyncio.gather(waiter(), setter())
```

## Timeouts

```python
async def fetch_with_timeout(url: str, timeout: float = 5.0):
    try:
        async with asyncio.timeout(timeout):
            return await fetch(url)
    except asyncio.TimeoutError:
        return None

# Or use wait_for (older API)
result = await asyncio.wait_for(fetch(url), timeout=5.0)
```

## HTTP with aiohttp

```python
import aiohttp

async def fetch_json(url: str) -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            response.raise_for_status()
            return await response.json()

# Connection pooling
async def main():
    async with aiohttp.ClientSession() as session:
        # Reuse session for multiple requests
        tasks = [fetch_with_session(session, url) for url in urls]
        return await asyncio.gather(*tasks)
```

## Best Practices

- Use `asyncio.run()` as the main entry point
- Prefer `TaskGroup` over `gather` for structured concurrency
- Use `async with` for resource management
- Limit concurrency with semaphores for external APIs
- Handle timeouts explicitly
- Don't mix sync and async code (use `run_in_executor` if needed)
- Profile async code with `asyncio.get_event_loop().slow_callback_duration`
