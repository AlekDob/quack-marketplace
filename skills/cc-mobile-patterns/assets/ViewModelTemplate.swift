import Foundation
import Combine
import Supabase

/// Template for creating a new ViewModel (MVVM pattern)
///
/// Usage:
/// 1. Rename the file and class to match your feature (e.g., `ProductSearchViewModel`, `CartViewModel`)
/// 2. Replace `YourFeature` with your actual feature name throughout the file
/// 3. Add your published properties and business logic
/// 4. Inject dependencies through the initializer
/// 5. Remove this comment block
///
/// Example:
/// ```
/// @MainActor
/// class ProductSearchViewModel: ObservableObject {
///     @Published var searchText: String = ""
///     @Published var products: [Product] = []
///     @Published var isLoading: Bool = false
///
///     private let supabaseClient: SupabaseClient
///     private var cancellables = Set<AnyCancellable>()
///
///     init(supabaseClient: SupabaseClient) {
///         self.supabaseClient = supabaseClient
///         setupSearchDebouncing()
///     }
/// }
/// ```

@MainActor
class YourFeatureViewModel: ObservableObject {
    // MARK: - Published Properties (Observable by View)
    @Published var items: [YourModel] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedItem: YourModel?

    // MARK: - Computed Properties
    var filteredItems: [YourModel] {
        guard !searchText.isEmpty else { return items }
        return items.filter { item in
            // Implement your filter logic
            true
        }
    }

    var hasItems: Bool {
        !items.isEmpty
    }

    // MARK: - Private Properties
    private let supabaseClient: SupabaseClient
    private let service: YourFeatureService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
        self.service = YourFeatureService(supabaseClient: supabaseClient)

        setupObservers()
    }

    // For testing with dependency injection
    init(service: YourFeatureService) {
        self.supabaseClient = service.supabaseClient
        self.service = service

        setupObservers()
    }

    // MARK: - Setup
    private func setupObservers() {
        // Example: Debounced search
        setupSearchDebouncing()

        // Example: React to other changes
        $selectedItem
            .sink { [weak self] item in
                self?.handleItemSelection(item)
            }
            .store(in: &cancellables)
    }

    private func setupSearchDebouncing() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                Task {
                    await self?.performSearch(text: searchText)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// Load initial data
    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            items = try await service.fetchItems()
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
    }

    /// Refresh data
    func refresh() async {
        await loadData()
    }

    /// Create new item
    func createItem(_ item: YourModel) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let created = try await service.createItem(item)
            items.append(created)
        } catch {
            errorMessage = "Failed to create item: \(error.localizedDescription)"
        }
    }

    /// Update existing item
    func updateItem(_ item: YourModel) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let updated = try await service.updateItem(item)
            if let index = items.firstIndex(where: { $0.id == updated.id }) {
                items[index] = updated
            }
        } catch {
            errorMessage = "Failed to update item: \(error.localizedDescription)"
        }
    }

    /// Delete item
    func deleteItem(_ item: YourModel) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await service.deleteItem(item.id)
            items.removeAll { $0.id == item.id }
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
    }

    /// Select item
    func selectItem(_ item: YourModel) {
        selectedItem = item
    }

    /// Clear selection
    func clearSelection() {
        selectedItem = nil
    }

    /// Clear error
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    private func performSearch(text: String) async {
        guard text.count >= 2 else {
            // Reset to all items if search is too short
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            items = try await service.searchItems(query: text)
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
    }

    private func handleItemSelection(_ item: YourModel?) {
        // React to item selection if needed
    }
}

// MARK: - Supporting Service
class YourFeatureService {
    let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    func fetchItems() async throws -> [YourModel] {
        let response = try await supabaseClient
            .from("your_table")
            .select()
            .execute()

        return try JSONDecoder().decode([YourModel].self, from: response.data)
    }

    func searchItems(query: String) async throws -> [YourModel] {
        let response = try await supabaseClient
            .from("your_table")
            .select()
            .ilike("name", value: "%\(query)%")
            .execute()

        return try JSONDecoder().decode([YourModel].self, from: response.data)
    }

    func createItem(_ item: YourModel) async throws -> YourModel {
        let response = try await supabaseClient
            .from("your_table")
            .insert(item)
            .select()
            .single()
            .execute()

        return try JSONDecoder().decode(YourModel.self, from: response.data)
    }

    func updateItem(_ item: YourModel) async throws -> YourModel {
        let response = try await supabaseClient
            .from("your_table")
            .update(item)
            .eq("id", value: item.id.uuidString)
            .select()
            .single()
            .execute()

        return try JSONDecoder().decode(YourModel.self, from: response.data)
    }

    func deleteItem(_ id: UUID) async throws {
        try await supabaseClient
            .from("your_table")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}

// MARK: - Supporting Model
struct YourModel: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
    }
}
