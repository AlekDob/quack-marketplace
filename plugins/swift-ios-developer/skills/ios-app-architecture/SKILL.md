---
name: ios-app-architecture
description: Use this skill when structuring an iOS app, choosing between MVVM and MV patterns, organizing files by feature, setting up dependency injection with @Environment, implementing navigation patterns, following Apple Human Interface Guidelines, or planning project structure for scalability and testability.
---

# iOS App Architecture

Expert guidance for structuring iOS applications with modern patterns.

## Project Structure

### Feature-Based Organization
```
MyApp/
├── App/
│   ├── MyApp.swift              # @main entry point
│   └── AppDelegate.swift        # UIKit lifecycle (if needed)
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift
│   │   └── Components/
│   │       ├── FeedCard.swift
│   │       └── StatsWidget.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   ├── ProfileViewModel.swift
│   │   └── EditProfileView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
├── Services/
│   ├── NetworkService.swift
│   ├── AuthService.swift
│   └── StorageService.swift
├── Models/
│   ├── User.swift
│   ├── Order.swift
│   └── Settings.swift
├── Shared/
│   ├── Components/           # Reusable UI components
│   │   ├── LoadingView.swift
│   │   ├── ErrorView.swift
│   │   └── AvatarView.swift
│   ├── Extensions/
│   │   ├── Date+Formatting.swift
│   │   └── View+Modifiers.swift
│   └── Utilities/
│       ├── Logger.swift
│       └── Constants.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Localizable.xcstrings
└── Tests/
    ├── HomeViewModelTests.swift
    └── NetworkServiceTests.swift
```

## Model-View Pattern (Recommended for SwiftUI)

### The Pattern
SwiftUI's declarative nature favors a lightweight **Model-View** approach over traditional MVVM:

```swift
// Model — plain data
struct Product: Identifiable, Codable {
    let id: UUID
    var name: String
    var price: Decimal
    var inStock: Bool
}

// ViewModel — @Observable class managing state
@Observable
@MainActor
class ProductListViewModel {
    var products: [Product] = []
    var isLoading = false
    var error: Error?

    private let service: ProductService

    init(service: ProductService = .shared) {
        self.service = service
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await service.fetchProducts()
        } catch {
            self.error = error
        }
    }

    func deleteProduct(_ product: Product) async {
        do {
            try await service.delete(product.id)
            products.removeAll { $0.id == product.id }
        } catch {
            self.error = error
        }
    }
}

// View — declarative UI driven by observable state
struct ProductListView: View {
    @State private var viewModel = ProductListViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List(viewModel.products) { product in
                    ProductRow(product: product)
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                Task { await viewModel.deleteProduct(product) }
                            }
                        }
                }
            }
        }
        .task { await viewModel.loadProducts() }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        }
    }
}
```

## Dependency Injection

### Environment-Based DI
```swift
// Define the environment key
struct NetworkServiceKey: EnvironmentKey {
    static let defaultValue: NetworkServiceProtocol = NetworkService()
}

extension EnvironmentValues {
    var networkService: NetworkServiceProtocol {
        get { self[NetworkServiceKey.self] }
        set { self[NetworkServiceKey.self] = newValue }
    }
}

// Inject in app root
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.networkService, NetworkService())
        }
    }
}

// Use in views
struct OrderView: View {
    @Environment(\.networkService) private var networkService

    // ...
}

// Override in previews/tests
#Preview {
    OrderView()
        .environment(\.networkService, MockNetworkService())
}
```

### Protocol-Based Services
```swift
protocol AuthServiceProtocol: Sendable {
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    var currentUser: User? { get async }
}

final class AuthService: AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> User {
        // Real implementation
    }

    func signOut() async throws {
        // Real implementation
    }

    var currentUser: User? {
        get async { /* ... */ }
    }
}

final class MockAuthService: AuthServiceProtocol {
    var mockUser: User?

    func signIn(email: String, password: String) async throws -> User {
        guard let user = mockUser else { throw AuthError.invalidCredentials }
        return user
    }

    func signOut() async throws { mockUser = nil }
    var currentUser: User? { get async { mockUser } }
}
```

## Navigation Architecture

### Coordinator Pattern with NavigationStack
```swift
@Observable
@MainActor
class AppRouter {
    var homePath = NavigationPath()
    var searchPath = NavigationPath()

    enum Destination: Hashable {
        case productDetail(Product)
        case userProfile(User)
        case settings
        case orderHistory
    }

    func navigate(to destination: Destination) {
        homePath.append(destination)
    }

    func popToRoot() {
        homePath = NavigationPath()
    }
}

struct HomeTab: View {
    @State private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.homePath) {
            HomeView()
                .navigationDestination(for: AppRouter.Destination.self) { dest in
                    switch dest {
                    case .productDetail(let product):
                        ProductDetailView(product: product)
                    case .userProfile(let user):
                        UserProfileView(user: user)
                    case .settings:
                        SettingsView()
                    case .orderHistory:
                        OrderHistoryView()
                    }
                }
        }
        .environment(router)
    }
}
```

### Sheet and Alert Management
```swift
@Observable
@MainActor
class SheetManager {
    var activeSheet: Sheet?
    var activeAlert: AlertItem?

    enum Sheet: Identifiable {
        case newItem
        case editItem(Item)
        case filter

        var id: String {
            switch self {
            case .newItem: "newItem"
            case .editItem(let item): "edit-\(item.id)"
            case .filter: "filter"
            }
        }
    }
}
```

## Error Handling

```swift
enum AppError: LocalizedError {
    case network(underlying: Error)
    case auth(AuthError)
    case validation(String)
    case notFound

    var errorDescription: String? {
        switch self {
        case .network: "Network connection failed"
        case .auth(let error): error.localizedDescription
        case .validation(let message): message
        case .notFound: "Resource not found"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .network: "Check your internet connection and try again."
        case .auth: "Please sign in again."
        case .validation: nil
        case .notFound: nil
        }
    }
}
```

## Apple Human Interface Guidelines

### Key Principles
- **Clarity**: Use system fonts, semantic colors, and SF Symbols
- **Deference**: Let content shine — minimal chrome, generous whitespace
- **Depth**: Use sheets, popovers, and navigation to show hierarchy

### Design Tokens
```swift
// Use semantic styles, never hardcoded values
Text("Title").font(.title)           // Not .system(size: 28)
Text("Body").font(.body)             // Not .system(size: 17)
Text("Caption").font(.caption)       // Not .system(size: 12)

// Use semantic colors
Color.primary                         // Not .black / .white
Color.secondary                       // Not .gray
Color.accentColor                     // App's tint color

// Use standard spacing
.padding()                            // System default (16pt)
.padding(.horizontal)                 // Standard horizontal
```

### Standard Patterns
- Use `Form` for settings screens
- Use `List` with swipe actions for data collections
- Use `NavigationStack` with toolbar items
- Use `.searchable()` modifier for search
- Use `.refreshable()` for pull-to-refresh
- Show destructive actions in red with confirmation dialogs
- Use `.sheet()` for creation, `.navigationDestination` for drill-down

## Testing Strategy

### What to Test
- **ViewModels**: All business logic, state transitions, error handling
- **Services**: Network layer with mocked responses
- **Models**: Codable conformance, computed properties, validation

### What NOT to Test
- SwiftUI view layout (use previews instead)
- System framework behavior
- Third-party library internals

### Test File Naming
```
{Feature}ViewModelTests.swift
{Service}Tests.swift
{Model}Tests.swift
```
