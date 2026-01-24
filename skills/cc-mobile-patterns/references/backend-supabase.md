# Supabase Backend Integration Patterns

## Configuration Management

### Info.plist Configuration

**NEVER hardcode credentials in code.** All sensitive configuration goes in `Info.plist`:

```xml
<!-- Info.plist -->
<key>SUPABASE_URL</key>
<string>https://your-project.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...</string>
```

### Configuration Manager Pattern

```swift
import Foundation

class SupabaseConfig {
    static let url: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            fatalError("SUPABASE_URL not found in Info.plist. Please add it to the configuration.")
        }
        return url
    }()

    static let anonKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY not found in Info.plist. Please add it to the configuration.")
        }
        return key
    }()

    // Optional: Custom URL scheme for OAuth
    static let urlScheme: String = {
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL_SCHEME") as? String else {
            return "io.supabase.yourapp" // Fallback default
        }
        return scheme
    }()
}
```

### Client Initialization

```swift
import Supabase

// Singleton Supabase client
@MainActor
class SupabaseClientManager {
    static let shared = SupabaseClientManager()

    let client: SupabaseClient

    private init() {
        guard let url = URL(string: SupabaseConfig.url) else {
            fatalError("Invalid Supabase URL")
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }
}

// Usage in app
let supabaseClient = SupabaseClientManager.shared.client
```

## Service Layer Pattern

### Standard Service Implementation

```swift
import Supabase

class ProductService {
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    // MARK: - Fetch Operations

    func fetchAllProducts() async throws -> [Product] {
        let response = try await supabaseClient
            .from("products")
            .select()
            .execute()

        return try JSONDecoder().decode([Product].self, from: response.data)
    }

    func fetchProduct(id: String) async throws -> Product {
        let response = try await supabaseClient
            .from("products")
            .select()
            .eq("id", value: id)
            .single()
            .execute()

        return try JSONDecoder().decode(Product.self, from: response.data)
    }

    func searchProducts(query: String) async throws -> [Product] {
        let response = try await supabaseClient
            .from("products")
            .select()
            .ilike("name", value: "%\(query)%")
            .execute()

        return try JSONDecoder().decode([Product].self, from: response.data)
    }

    // MARK: - Insert Operations

    func createProduct(_ product: Product) async throws -> Product {
        let response = try await supabaseClient
            .from("products")
            .insert(product)
            .select()
            .single()
            .execute()

        return try JSONDecoder().decode(Product.self, from: response.data)
    }

    // MARK: - Update Operations

    func updateProduct(id: String, updates: ProductUpdate) async throws -> Product {
        let response = try await supabaseClient
            .from("products")
            .update(updates)
            .eq("id", value: id)
            .select()
            .single()
            .execute()

        return try JSONDecoder().decode(Product.self, from: response.data)
    }

    // MARK: - Delete Operations

    func deleteProduct(id: String) async throws {
        try await supabaseClient
            .from("products")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
```

### Advanced Query Patterns

**Filtering:**
```swift
func fetchProductsByCategory(_ category: String, minPrice: Double) async throws -> [Product] {
    let response = try await supabaseClient
        .from("products")
        .select()
        .eq("category", value: category)
        .gte("price", value: minPrice)
        .order("name")
        .execute()

    return try JSONDecoder().decode([Product].self, from: response.data)
}
```

**Joins (Foreign Key Relationships):**
```swift
func fetchProductsWithCategories() async throws -> [ProductWithCategory] {
    let response = try await supabaseClient
        .from("products")
        .select("*, categories(*)")
        .execute()

    return try JSONDecoder().decode([ProductWithCategory].self, from: response.data)
}
```

**Pagination:**
```swift
func fetchProductsPaginated(page: Int, pageSize: Int = 20) async throws -> [Product] {
    let from = page * pageSize
    let to = from + pageSize - 1

    let response = try await supabaseClient
        .from("products")
        .select()
        .range(from: from, to: to)
        .execute()

    return try JSONDecoder().decode([Product].self, from: response.data)
}
```

**Count:**
```swift
func countProducts() async throws -> Int {
    let response = try await supabaseClient
        .from("products")
        .select("*", head: true, count: .exact)
        .execute()

    return response.count ?? 0
}
```

## Model Patterns

### Basic Model with Codable

```swift
struct Product: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String?
    let price: Double
    let category: String
    let stock: Int
    let createdAt: Date
    let updatedAt: Date

    // Custom CodingKeys for API field mapping
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case category
        case stock
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

### Model with Computed Properties

```swift
struct Product: Codable, Identifiable {
    let id: UUID
    let name: String
    let price: Double
    let stock: Int

    // Computed properties (not stored in database)
    var displayPrice: String {
        CurrencyFormatter.shared.format(price)
    }

    var isAvailable: Bool {
        stock > 0
    }

    var stockStatus: StockStatus {
        switch stock {
        case 0: return .outOfStock
        case 1...5: return .lowStock
        default: return .inStock
        }
    }

    enum StockStatus {
        case outOfStock
        case lowStock
        case inStock

        var color: Color {
            switch self {
            case .outOfStock: return .red
            case .lowStock: return .orange
            case .inStock: return .green
            }
        }
    }
}
```

### Model with Relationships

```swift
struct Product: Codable, Identifiable {
    let id: UUID
    let name: String
    let categoryId: UUID
    let category: Category?  // Joined data

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case categoryId = "category_id"
        case category
    }
}

struct Category: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
}
```

### Update Models

```swift
// Separate model for updates (only updatable fields)
struct ProductUpdate: Codable {
    let name: String?
    let description: String?
    let price: Double?
    let stock: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case price
        case stock
    }
}
```

## Real-Time Subscriptions

### Subscribe to Changes

```swift
@MainActor
class RealtimeProductViewModel: ObservableObject {
    @Published var products: [Product] = []

    private let supabaseClient: SupabaseClient
    private var subscription: Task<Void, Never>?

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    func startListening() {
        subscription = Task {
            let channel = await supabaseClient.channel("products")

            let insertions = await channel.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "products"
            )

            let updates = await channel.postgresChange(
                UpdateAction.self,
                schema: "public",
                table: "products"
            )

            let deletions = await channel.postgresChange(
                DeleteAction.self,
                schema: "public",
                table: "products"
            )

            await channel.subscribe()

            for await insertion in insertions {
                if let product = try? JSONDecoder().decode(Product.self, from: insertion.record) {
                    products.append(product)
                }
            }
        }
    }

    func stopListening() {
        subscription?.cancel()
        subscription = nil
    }

    deinit {
        stopListening()
    }
}
```

## Storage (File Upload)

### Upload File to Supabase Storage

```swift
class StorageService {
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    func uploadImage(_ image: UIImage, bucket: String, path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }

        let file = File(
            name: path,
            data: imageData,
            fileName: path,
            contentType: "image/jpeg"
        )

        let response = try await supabaseClient.storage
            .from(bucket)
            .upload(path: path, file: file, options: FileOptions(upsert: true))

        // Return public URL
        let publicURL = try supabaseClient.storage
            .from(bucket)
            .getPublicURL(path: path)

        return publicURL.absoluteString
    }

    func downloadImage(bucket: String, path: String) async throws -> UIImage {
        let data = try await supabaseClient.storage
            .from(bucket)
            .download(path: path)

        guard let image = UIImage(data: data) else {
            throw StorageError.invalidImage
        }

        return image
    }

    func deleteFile(bucket: String, path: String) async throws {
        try await supabaseClient.storage
            .from(bucket)
            .remove(paths: [path])
    }
}

enum StorageError: LocalizedError {
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        }
    }
}
```

## Error Handling

### Custom Error Types

```swift
enum SupabaseError: LocalizedError {
    case networkError(String)
    case decodingError(DecodingError)
    case notFound
    case unauthorized
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError:
            return "Failed to process data from server"
        case .notFound:
            return "Resource not found"
        case .unauthorized:
            return "You are not authorized to perform this action"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}
```

### Error Handling in Service

```swift
func fetchProducts() async throws -> [Product] {
    do {
        let response = try await supabaseClient
            .from("products")
            .select()
            .execute()

        return try JSONDecoder().decode([Product].self, from: response.data)
    } catch let error as DecodingError {
        throw SupabaseError.decodingError(error)
    } catch let error as URLError {
        throw SupabaseError.networkError(error.localizedDescription)
    } catch {
        throw SupabaseError.serverError(error.localizedDescription)
    }
}
```

## Best Practices

### DO:
✅ Store configuration in Info.plist
✅ Use dependency injection for SupabaseClient
✅ Create dedicated service classes per domain
✅ Use Codable for automatic JSON mapping
✅ Handle all error cases with user-friendly messages
✅ Use proper CodingKeys for snake_case API fields
✅ Implement pagination for large datasets
✅ Cache frequently accessed data
✅ Use transactions for related operations

### DON'T:
❌ Hardcode API keys in source code
❌ Create global mutable state
❌ Mix API logic in ViewModels
❌ Ignore errors or use empty catch blocks
❌ Fetch all data at once without pagination
❌ Store sensitive data in UserDefaults
❌ Use force unwrapping on API responses
❌ Skip input validation before API calls

## Performance Tips

1. **Use `.select()` with specific columns** to reduce data transfer:
   ```swift
   .select("id, name, price") // Only fetch what you need
   ```

2. **Implement pagination** for large datasets:
   ```swift
   .range(from: 0, to: 19) // First 20 items
   ```

3. **Use indexes** on frequently queried columns (database side)

4. **Cache results** locally:
   ```swift
   // Cache in UserDefaults for non-sensitive data
   // Cache in Keychain for sensitive data
   ```

5. **Batch operations** when possible:
   ```swift
   // Insert multiple records at once
   .insert([product1, product2, product3])
   ```

6. **Use RPC for complex queries**:
   ```swift
   try await supabaseClient.rpc("complex_query", params: params).execute()
   ```
