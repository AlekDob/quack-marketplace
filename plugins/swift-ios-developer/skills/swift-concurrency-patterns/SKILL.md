---
name: swift-concurrency-patterns
description: Use this skill when writing async/await code in Swift, working with actors and @MainActor, handling task cancellation, using AsyncSequence or AsyncStream, fixing Sendable conformance warnings, migrating to Swift 6 concurrency, or writing concurrent tests with XCTest and Swift Testing framework.
---

# Swift Concurrency Patterns

Expert guidance for structured concurrency in Swift 6.

## async/await Fundamentals

### Basic Async Functions
```swift
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw APIError.invalidResponse
    }

    return try JSONDecoder().decode(User.self, from: data)
}
```

### Parallel Execution
```swift
// Concurrent fetch with async let
func loadDashboard() async throws -> Dashboard {
    async let user = fetchUser(id: currentUserId)
    async let orders = fetchOrders()
    async let notifications = fetchNotifications()

    return try await Dashboard(
        user: user,
        orders: orders,
        notifications: notifications
    )
}
```

### Task Groups
```swift
func fetchAllImages(urls: [URL]) async throws -> [UIImage] {
    try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
        for (index, url) in urls.enumerated() {
            group.addTask {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    throw ImageError.invalidData
                }
                return (index, image)
            }
        }

        var results = [(Int, UIImage)]()
        for try await result in group {
            results.append(result)
        }
        return results.sorted(by: { $0.0 < $1.0 }).map(\.1)
    }
}
```

## Actors

### Custom Actors
```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? {
        cache[url]
    }

    func store(_ image: UIImage, for url: URL) {
        cache[url] = image
    }

    func clear() {
        cache.removeAll()
    }
}

// Usage — all calls are automatically serialized
let cache = ImageCache()
await cache.store(image, for: url)
let cached = await cache.image(for: url)
```

### @MainActor
```swift
@Observable
@MainActor
class SettingsViewModel {
    var theme: Theme = .system
    var notifications: Bool = true

    func save() async throws {
        // This runs on main actor — safe to update UI state
        let settings = Settings(theme: theme, notifications: notifications)
        try await settingsService.save(settings)
    }
}

// For isolated functions
@MainActor
func updateUI(with result: SearchResult) {
    self.results = result.items
    self.isLoading = false
}

// For nonisolated functions called from main actor
nonisolated func processData(_ data: Data) -> ProcessedResult {
    // Heavy computation off main actor
    return ProcessedResult(data: data)
}
```

## Task Cancellation

```swift
struct SearchView: View {
    @State private var searchTask: Task<Void, Never>?
    @State private var query = ""

    var body: some View {
        TextField("Search", text: $query)
            .onChange(of: query) { _, newValue in
                // Cancel previous search
                searchTask?.cancel()

                searchTask = Task {
                    // Debounce
                    try? await Task.sleep(for: .milliseconds(300))
                    guard !Task.isCancelled else { return }

                    await performSearch(newValue)
                }
            }
    }
}

// Cooperative cancellation in async functions
func fetchItems() async throws -> [Item] {
    var items: [Item] = []
    for page in 1...totalPages {
        try Task.checkCancellation() // Throws if cancelled
        let pageItems = try await fetchPage(page)
        items.append(contentsOf: pageItems)
    }
    return items
}
```

## AsyncSequence and AsyncStream

### AsyncStream for Bridging
```swift
// Bridge delegate/callback APIs to async
func locationUpdates() -> AsyncStream<CLLocation> {
    AsyncStream { continuation in
        let delegate = LocationDelegate { location in
            continuation.yield(location)
        }

        continuation.onTermination = { _ in
            delegate.stop()
        }

        delegate.start()
    }
}

// Usage
for await location in locationUpdates() {
    updateMap(with: location)
}
```

### AsyncThrowingStream
```swift
func downloadProgress(url: URL) -> AsyncThrowingStream<Double, Error> {
    AsyncThrowingStream { continuation in
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error { continuation.finish(throwing: error) }
            else { continuation.finish() }
        }

        let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            continuation.yield(progress.fractionCompleted)
        }

        continuation.onTermination = { _ in
            observation.invalidate()
            task.cancel()
        }

        task.resume()
    }
}
```

## Sendable Conformance

```swift
// Value types are implicitly Sendable
struct UserProfile: Sendable {
    let id: UUID
    let name: String
    let email: String
}

// For classes, mark as @unchecked Sendable only when you guarantee thread safety
final class ThreadSafeCache: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Any] = [:]

    func get(_ key: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }
}

// Prefer actors over @unchecked Sendable when possible
```

## Testing

### XCTest with async
```swift
class UserServiceTests: XCTestCase {
    func testFetchUser() async throws {
        let service = UserService(client: MockClient())
        let user = try await service.fetchUser(id: "123")

        XCTAssertEqual(user.name, "John")
        XCTAssertEqual(user.email, "john@test.com")
    }

    func testFetchUserCancellation() async {
        let task = Task {
            try await service.fetchUser(id: "123")
        }
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation error")
        } catch is CancellationError {
            // Expected
        }
    }
}
```

### Swift Testing Framework (iOS 18+)
```swift
import Testing

@Suite("User Service")
struct UserServiceTests {
    let service = UserService(client: MockClient())

    @Test("Fetches user by ID")
    func fetchUser() async throws {
        let user = try await service.fetchUser(id: "123")
        #expect(user.name == "John")
        #expect(user.email == "john@test.com")
    }

    @Test("Throws for invalid ID", arguments: ["", "   ", "invalid-uuid"])
    func invalidId(id: String) async {
        await #expect(throws: ValidationError.self) {
            try await service.fetchUser(id: id)
        }
    }
}
```

## Best Practices

- Use `async let` for independent parallel operations
- Use `TaskGroup` when the number of concurrent tasks is dynamic
- Always check `Task.isCancelled` or call `Task.checkCancellation()` in loops
- Prefer actors over locks for shared mutable state
- Mark ViewModels as `@MainActor` to guarantee UI safety
- Use `nonisolated` for pure computation functions in `@MainActor` classes
- Never block the main actor with synchronous waits
- Prefer `Sendable` value types over `@unchecked Sendable` classes
