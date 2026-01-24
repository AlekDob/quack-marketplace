import Foundation
import Combine

/// Template for creating a new Manager (Singleton pattern)
///
/// Usage:
/// 1. Rename the file and class to match your domain (e.g., `CartManager`, `NotificationManager`)
/// 2. Replace `YourDomain` with your actual domain name throughout the file
/// 3. Add your published properties
/// 4. Implement your business logic
/// 5. Remove this comment block
///
/// Example:
/// ```
/// @MainActor
/// class CartManager: ObservableObject {
///     static let shared = CartManager()
///
///     @Published var items: [CartItem] = []
///     @Published var total: Double = 0.0
///
///     private init() {
///         loadCart()
///     }
///
///     func addItem(_ item: Product) {
///         // Implementation
///     }
/// }
/// ```

@MainActor
class YourDomainManager: ObservableObject {
    // MARK: - Singleton
    static let shared = YourDomainManager()

    // MARK: - Published Properties
    @Published var yourProperty: YourType = defaultValue {
        didSet {
            // Automatically triggered when property changes
            saveToUserDefaults()
            notifyObservers()
        }
    }

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let userDefaultsKey = "YourDomainManagerKey"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        // Load persisted data
        loadFromUserDefaults()

        // Setup observers if needed
        setupObservers()
    }

    // MARK: - Public Methods

    /// Public method description
    /// - Parameter param: Parameter description
    func publicMethod(param: YourType) {
        // Implementation
    }

    /// Async method example
    func fetchData() async throws -> YourType {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Perform async operation
            let data = try await performAsyncOperation()
            return data
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Example: Observe another published property
        $yourProperty
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.handlePropertyChange(newValue)
            }
            .store(in: &cancellables)
    }

    private func handlePropertyChange(_ newValue: YourType) {
        // React to property changes
    }

    private func saveToUserDefaults() {
        // Example: Save Codable type
        if let encoded = try? JSONEncoder().encode(yourProperty) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadFromUserDefaults() {
        // Example: Load Codable type
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode(YourType.self, from: data) else {
            return
        }
        yourProperty = decoded
    }

    private func notifyObservers() {
        NotificationCenter.default.post(
            name: .yourDomainDidChange,
            object: yourProperty
        )
    }

    private func performAsyncOperation() async throws -> YourType {
        // Implement your async logic
        fatalError("Implement your async operation")
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let yourDomainDidChange = Notification.Name("YourDomainDidChangeNotification")
}

// MARK: - Supporting Types
// Define any supporting types here if needed
