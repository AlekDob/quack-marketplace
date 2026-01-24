import Foundation
import Supabase

/// Template for creating a new Service (Backend Integration)
///
/// Usage:
/// 1. Rename the file and class to match your domain (e.g., `ProductService`, `CustomerService`)
/// 2. Replace `YourDomain` with your actual domain name throughout the file
/// 3. Replace `your_table` with your actual Supabase table name
/// 4. Add your API methods
/// 5. Remove this comment block
///
/// Example:
/// ```
/// class ProductService {
///     private let supabaseClient: SupabaseClient
///
///     init(supabaseClient: SupabaseClient) {
///         self.supabaseClient = supabaseClient
///     }
///
///     func fetchProducts() async throws -> [Product] {
///         let response = try await supabaseClient
///             .from("products")
///             .select()
///             .execute()
///
///         return try JSONDecoder().decode([Product].self, from: response.data)
///     }
/// }
/// ```

class YourDomainService {
    // MARK: - Properties
    private let supabaseClient: SupabaseClient

    // MARK: - Initialization
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    // MARK: - Fetch Operations

    /// Fetch all items
    func fetchAll() async throws -> [YourModel] {
        let response = try await supabaseClient
            .from("your_table")
            .select()
            .order("created_at", ascending: false)
            .execute()

        return try JSONDecoder().decode([YourModel].self, from: response.data)
    }

    /// Fetch single item by ID
    func fetch(id: UUID) async throws -> YourModel {
        let response = try await supabaseClient
            .from("your_table")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()

        return try JSONDecoder().decode(YourModel.self, from: response.data)
    }

    /// Search items by query
    func search(query: String) async throws -> [YourModel] {
        let response = try await supabaseClient
            .from("your_table")
            .select()
            .ilike("name", value: "%\(query)%")
            .execute()

        return try JSONDecoder().decode([YourModel].self, from: response.data)
    }

    /// Fetch with filters
    func fetchFiltered(
        category: String? = nil,
        status: String? = nil,
        minPrice: Double? = nil
    ) async throws -> [YourModel] {
        var query = supabaseClient
            .from("your_table")
            .select()

        if let category = category {
            query = query.eq("category", value: category)
        }

        if let status = status {
            query = query.eq("status", value: status)
        }

        if let minPrice = minPrice {
            query = query.gte("price", value: minPrice)
        }

        let response = try await query.execute()
        return try JSONDecoder().decode([YourModel].self, from: response.data)
    }

    // MARK: - Pagination

    /// Fetch with pagination
    func fetchPaginated(page: Int, pageSize: Int = 20) async throws -> PaginatedResponse<YourModel> {
        let from = page * pageSize
        let to = from + pageSize - 1

        let response = try await supabaseClient
            .from("your_table")
            .select("*", head: false, count: .exact)
            .range(from: from, to: to)
            .execute()

        let items = try JSONDecoder().decode([YourModel].self, from: response.data)
        let totalCount = response.count ?? 0

        return PaginatedResponse(
            items: items,
            page: page,
            pageSize: pageSize,
            totalCount: totalCount
        )
    }

    // MARK: - Insert Operations

    /// Create new item
    func create(_ item: YourModel) async throws -> YourModel {
        let response = try await supabaseClient
            .from("your_table")
            .insert(item)
            .select()
            .single()
            .execute()

        return try JSONDecoder().decode(YourModel.self, from: response.data)
    }

    /// Create multiple items
    func createBatch(_ items: [YourModel]) async throws -> [YourModel] {
        let response = try await supabaseClient
            .from("your_table")
            .insert(items)
            .select()
            .execute()

        return try JSONDecoder().decode([YourModel].self, from: response.data)
    }

    // MARK: - Update Operations

    /// Update existing item
    func update(id: UUID, updates: YourModelUpdate) async throws -> YourModel {
        let response = try await supabaseClient
            .from("your_table")
            .update(updates)
            .eq("id", value: id.uuidString)
            .select()
            .single()
            .execute()

        return try JSONDecoder().decode(YourModel.self, from: response.data)
    }

    /// Update multiple items
    func updateBatch(ids: [UUID], updates: YourModelUpdate) async throws -> [YourModel] {
        let response = try await supabaseClient
            .from("your_table")
            .update(updates)
            .in("id", values: ids.map { $0.uuidString })
            .select()
            .execute()

        return try JSONDecoder().decode([YourModel].self, from: response.data)
    }

    // MARK: - Delete Operations

    /// Delete single item
    func delete(id: UUID) async throws {
        try await supabaseClient
            .from("your_table")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    /// Delete multiple items
    func deleteBatch(ids: [UUID]) async throws {
        try await supabaseClient
            .from("your_table")
            .delete()
            .in("id", values: ids.map { $0.uuidString })
            .execute()
    }

    // MARK: - Relationships

    /// Fetch with related data (join)
    func fetchWithRelations() async throws -> [YourModelWithRelations] {
        let response = try await supabaseClient
            .from("your_table")
            .select("*, related_table(*)")
            .execute()

        return try JSONDecoder().decode([YourModelWithRelations].self, from: response.data)
    }

    // MARK: - Aggregations

    /// Count items
    func count() async throws -> Int {
        let response = try await supabaseClient
            .from("your_table")
            .select("*", head: true, count: .exact)
            .execute()

        return response.count ?? 0
    }

    /// Count with filter
    func count(where condition: String, value: String) async throws -> Int {
        let response = try await supabaseClient
            .from("your_table")
            .select("*", head: true, count: .exact)
            .eq(condition, value: value)
            .execute()

        return response.count ?? 0
    }

    // MARK: - RPC (Stored Procedures)

    /// Call stored procedure
    func callRPC<T: Codable>(function: String, params: [String: Any]) async throws -> T {
        let response = try await supabaseClient
            .rpc(function, params: params)
            .execute()

        return try JSONDecoder().decode(T.self, from: response.data)
    }
}

// MARK: - Supporting Types

struct YourModel: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String?
    let category: String
    let status: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct YourModelUpdate: Codable {
    let name: String?
    let description: String?
    let category: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case category
        case status
    }
}

struct YourModelWithRelations: Codable, Identifiable {
    let id: UUID
    let name: String
    let relatedTable: RelatedModel?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case relatedTable = "related_table"
    }
}

struct RelatedModel: Codable, Identifiable {
    let id: UUID
    let name: String
}

struct PaginatedResponse<T: Codable> {
    let items: [T]
    let page: Int
    let pageSize: Int
    let totalCount: Int

    var totalPages: Int {
        (totalCount + pageSize - 1) / pageSize
    }

    var hasNextPage: Bool {
        page < totalPages - 1
    }

    var hasPreviousPage: Bool {
        page > 0
    }
}

// MARK: - Error Handling

enum ServiceError: LocalizedError {
    case networkError(String)
    case decodingError
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
