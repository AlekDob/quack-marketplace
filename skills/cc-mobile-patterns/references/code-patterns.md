# Code Patterns for C&C Mobile Apps

## State Management Patterns

### SwiftUI Property Wrappers

**@State** - View-local UI state:
```swift
struct ProductCard: View {
    @State private var isExpanded = false
    @State private var quantity = 1

    var body: some View {
        VStack {
            // UI that changes based on state
        }
    }
}
```

**@StateObject** - View-owned observable objects:
```swift
struct ProductSearchView: View {
    @StateObject private var viewModel: ProductSearchViewModel

    init(supabaseClient: SupabaseClient) {
        _viewModel = StateObject(
            wrappedValue: ProductSearchViewModel(supabaseClient: supabaseClient)
        )
    }
}
```

**@ObservedObject** - Injected observable objects:
```swift
struct CartView: View {
    @ObservedObject var cartManager: CartManager // Passed from parent
}
```

**@EnvironmentObject** - App-wide shared state:
```swift
struct ContentView: View {
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
}
```

**@FocusState** - Keyboard focus management:
```swift
struct SearchView: View {
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        TextField("Search", text: $searchText)
            .focused($isSearchFocused)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isSearchFocused = false
                    }
                }
            }
    }
}
```

### Combine for Reactive Programming

**Debounced Search Pattern:**
```swift
@MainActor
class ProductSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
        setupSearchDebouncing()
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

    private func performSearch(text: String) async {
        guard text.count >= 2 else {
            products = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            products = try await fetchProducts(query: text)
        } catch {
            print("Search failed: \(error)")
        }
    }

    private func fetchProducts(query: String) async throws -> [Product] {
        // Supabase API call
        return []
    }
}
```

**Key Features:**
- 500ms debounce delay (optimal for search)
- Minimum 2 characters before search
- `removeDuplicates()` prevents redundant API calls
- `[weak self]` prevents retain cycles
- Loading state management
- Error handling

**Property Observation Pattern:**
```swift
@MainActor
class FilterManager: ObservableObject {
    @Published var currentFilter = StoreFilter() {
        didSet {
            saveFilter()
            notifyFilterChange()
        }
    }

    @Published var appliedFilterCount: Int = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe filter changes
        $currentFilter
            .map { filter in
                filter.activeCount
            }
            .assign(to: &$appliedFilterCount)
    }

    private func saveFilter() {
        // Persist to UserDefaults
    }

    private func notifyFilterChange() {
        NotificationCenter.default.post(name: .filterDidChange, object: currentFilter)
    }
}
```

## Navigation Patterns

### NavigationStack (iOS 16+)

**State-Driven Navigation:**
```swift
struct AppCoordinator: View {
    @EnvironmentObject var authManager: SupabaseAuthManager

    var body: some View {
        Group {
            switch authManager.authenticationState {
            case .checking:
                SplashView()
            case .unauthenticated:
                AuthenticationView()
            case .authenticating:
                LoadingView()
            case .biometricRequired:
                BiometricUnlockView()
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.authenticationState)
    }
}
```

**Programmatic Navigation:**
```swift
struct ProductListView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(products) { product in
                NavigationLink(value: product) {
                    ProductRow(product: product)
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
        }
    }

    func navigateToProduct(_ product: Product) {
        navigationPath.append(product)
    }
}
```

### Sheet Presentation

**Modern Sheet with Detents:**
```swift
struct ProductListView: View {
    @State private var selectedProduct: Product?
    @State private var showingFilters = false

    var body: some View {
        ScrollView {
            // Content
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .sheet(isPresented: $showingFilters) {
            FilterSheet()
                .presentationDetents([.height(400), .large])
                .presentationDragIndicator(.hidden)
        }
    }
}
```

**Full-Screen Cover:**
```swift
.fullScreenCover(isPresented: $showingOnboarding) {
    OnboardingView()
        .interactiveDismissDisabled() // Prevent swipe to dismiss
}
```

## Async/Await Patterns

### Basic Async Function

```swift
func fetchProducts() async throws -> [Product] {
    let response = try await supabaseClient
        .from("products")
        .select()
        .execute()

    return try JSONDecoder().decode([Product].self, from: response.data)
}
```

### Task Management in Views

```swift
struct ProductListView: View {
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        List(products) { product in
            ProductRow(product: product)
        }
        .task {
            await loadProducts()
        }
        .refreshable {
            await loadProducts()
        }
    }

    private func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            products = try await fetchProducts()
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
}
```

### Parallel Async Operations

```swift
func loadDashboardData() async {
    async let products = fetchProducts()
    async let stores = fetchStores()
    async let members = fetchMembers()

    do {
        let (productsResult, storesResult, membersResult) = try await (products, stores, members)
        // Update UI with all results
    } catch {
        // Handle error
    }
}
```

### Task Cancellation

```swift
struct SearchView: View {
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        TextField("Search", text: $searchText)
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    guard !Task.isCancelled else { return }
                    await performSearch(newValue)
                }
            }
    }
}
```

## Error Handling Patterns

### Result Type

```swift
enum DataLoadingError: LocalizedError {
    case networkError(String)
    case decodingError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError:
            return "Failed to process data"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}

func fetchProducts() async -> Result<[Product], DataLoadingError> {
    do {
        let products = try await performFetch()
        return .success(products)
    } catch {
        if let urlError = error as? URLError {
            return .failure(.networkError(urlError.localizedDescription))
        }
        return .failure(.decodingError)
    }
}
```

### Toast Notifications

```swift
struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast = toast {
                    ToastView(toast: toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    self.toast = nil
                                }
                            }
                        }
                }
            }
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

// Usage
struct ContentView: View {
    @State private var currentToast: Toast?

    var body: some View {
        VStack {
            // Content
        }
        .toast($currentToast)
    }

    func showSuccess() {
        currentToast = Toast(message: "Success!", type: .success)
    }
}
```

## Memory Management

### Weak References in Closures

```swift
// ❌ BAD: Creates retain cycle
class ViewModel: ObservableObject {
    func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateData() // Strong reference
        }
    }
}

// ✅ GOOD: Prevents retain cycle
class ViewModel: ObservableObject {
    func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateData() // Weak reference
        }
    }
}
```

### Cancellable Storage

```swift
@MainActor
class ViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default
            .publisher(for: .dataDidChange)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }

    deinit {
        // Cancellables are automatically cancelled when set is deallocated
    }
}
```

## Performance Optimization

### Lazy Loading

```swift
struct ProductListView: View {
    let products: [Product]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(products) { product in
                    ProductCard(product: product)
                }
            }
        }
    }
}
```

### Image Caching

```swift
struct CachedAsyncImage: View {
    let url: URL?
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .task {
                        await loadImage()
                    }
            }
        }
    }

    private func loadImage() async {
        guard let url = url else { return }

        // Check cache first
        if let cached = ImageCache.shared.get(url: url) {
            image = cached
            return
        }

        // Load from network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                ImageCache.shared.set(url: url, image: loadedImage)
                image = loadedImage
            }
        } catch {
            print("Image load failed: \(error)")
        }
    }
}

actor ImageCache {
    static let shared = ImageCache()
    private var cache: [URL: UIImage] = [:]

    func get(url: URL) -> UIImage? {
        cache[url]
    }

    func set(url: URL, image: UIImage) {
        cache[url] = image
    }
}
```

### Computed Properties for Derived State

```swift
struct Product: Identifiable {
    let id: String
    let name: String
    let price: Double
    let availability: Int

    // ✅ Computed property instead of stored
    var displayPrice: String {
        CurrencyFormatter.shared.format(price)
    }

    var isAvailable: Bool {
        availability > 0
    }

    var availabilityColor: Color {
        switch availability {
        case 0: return .red
        case 1...5: return .orange
        default: return .green
        }
    }
}
```

## Code Organization Patterns

### MARK Comments

```swift
class ProductSearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var products: [Product] = []

    // MARK: - Private Properties
    private let supabaseClient: SupabaseClient
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
        setupSearchDebouncing()
    }

    // MARK: - Public Methods
    func refresh() async {
        // Implementation
    }

    // MARK: - Private Methods
    private func setupSearchDebouncing() {
        // Implementation
    }

    // MARK: - API Methods
    private func fetchProducts() async throws -> [Product] {
        // Implementation
    }
}
```

### View Extensions

```swift
// Extract complex subviews
extension ProductListView {
    var searchBar: some View {
        TextField("Search", text: $searchText)
            .padding()
            .background(.ultraThinMaterial)
    }

    var filterButton: some View {
        Button {
            showingFilters = true
        } label: {
            Image(systemName: "slider.horizontal.3")
                .foregroundStyle(hasFilters ? .orange : .blue)
        }
    }
}
```

## Testing Patterns

### Dependency Injection for Testing

```swift
// Protocol for testability
protocol ProductServiceProtocol {
    func fetchProducts() async throws -> [Product]
}

// Real implementation
class ProductService: ProductServiceProtocol {
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    func fetchProducts() async throws -> [Product] {
        // Real API call
    }
}

// Mock for testing
class MockProductService: ProductServiceProtocol {
    var productsToReturn: [Product] = []
    var shouldThrowError = false

    func fetchProducts() async throws -> [Product] {
        if shouldThrowError {
            throw NSError(domain: "Test", code: -1)
        }
        return productsToReturn
    }
}

// ViewModel uses protocol
class ProductViewModel: ObservableObject {
    private let service: ProductServiceProtocol

    init(service: ProductServiceProtocol) {
        self.service = service
    }
}
```

## Best Practices Summary

### DO:
✅ Use `@MainActor` for ViewModels and Managers
✅ Implement debouncing for search (500ms)
✅ Use `[weak self]` in closures
✅ Handle errors gracefully with user-friendly messages
✅ Cancel tasks when views disappear
✅ Use lazy loading for lists
✅ Cache expensive computations
✅ Extract complex views into subviews
✅ Use MARK comments for organization

### DON'T:
❌ Forget to store cancellables
❌ Use force unwrapping (`!`)
❌ Block the main thread with heavy operations
❌ Create retain cycles with strong self references
❌ Ignore task cancellation
❌ Mix business logic in views
❌ Skip error handling
❌ Use `DispatchQueue.main.async` when `@MainActor` is available
