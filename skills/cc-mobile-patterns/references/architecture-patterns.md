# Architecture Patterns for C&C Mobile Apps

## Domain-Driven Organization

All C&C mobile apps follow **domain-driven architecture**, NOT technical type organization.

### Standard Structure

```
Features/
├── [DomainName]/          # e.g., Products, Cart, Team, Stores
│   ├── Views/             # SwiftUI views for this domain
│   ├── Models/            # Data models specific to this domain
│   ├── ViewModels/        # Business logic and state
│   ├── Services/          # API calls and data fetching
│   ├── Managers/          # Domain-specific coordination
│   ├── Utilities/         # Domain-specific helpers
│   └── Storage/           # Domain-specific persistence
```

### Why Domain-Driven?

**Benefits:**
- All related code lives together
- Reduces cognitive load
- Faster navigation and changes
- Fewer merge conflicts
- AI agents can work 10x faster

**When implementing "add product filter":**
- ✅ Open `/Features/Products/` folder → everything is there
- ❌ Search through 100+ views, models, services scattered everywhere

### Anti-Pattern to Avoid

```
❌ NEVER DO THIS:
/Views/      # All views mixed together
/Models/     # All models mixed together
/Services/   # All services mixed together
/ViewModels/ # All view models mixed together
```

## The 4 Laws (Universal)

### 1. The 20-Line Function Rule

**Rule:** Functions should be maximum 20 lines.

**Exceptions:**
- SwiftUI view body (layout code)
- Complex switch statements with many cases
- Initialization with many parameters

**Why:** Forces single responsibility and readability.

**Example:**
```swift
// ❌ BAD: 45-line function doing too much
func processOrder() {
    // Validate customer
    // Check inventory
    // Calculate prices
    // Apply discounts
    // Create invoice
    // Send email
    // Update database
}

// ✅ GOOD: Split into smaller functions
func processOrder() {
    validateCustomer()
    checkInventory()
    let total = calculateTotal()
    applyDiscounts(to: total)
    createInvoice()
    sendConfirmation()
    updateDatabase()
}
```

### 2. The 300-Line File Rule

**Rule:** Files should be maximum 300 lines.

**Exceptions:**
- Complex ViewModels with multiple related features
- Generated code files

**When to split:**
- Extract complex views into subviews
- Move validation logic to dedicated validators
- Split large managers by responsibility
- Create view extensions for helper methods

**Example:**
```swift
// ❌ BAD: 600-line ProductSearchViewModel
ProductSearchViewModel.swift (600 lines)

// ✅ GOOD: Split by responsibility
ProductSearchViewModel.swift (250 lines)     # Core search logic
ProductFilterExtension.swift (150 lines)     # Filter functionality
ProductSortingExtension.swift (100 lines)    # Sorting logic
```

### 3. The Domain Rule

**Rule:** Group by feature/domain, not by technical type.

**Implementation:**
```
✅ CORRECT:
Features/
├── Authentication/
│   ├── Views/
│   │   ├── LoginView.swift
│   │   └── BiometricSetupView.swift
│   ├── Models/
│   │   ├── User.swift
│   │   └── AuthenticationState.swift
│   ├── Managers/
│   │   ├── SupabaseAuthManager.swift
│   │   └── BiometricAuthManager.swift
│   └── Storage/
│       └── SecureTokenManager.swift
```

### 4. The Self-Documenting Names Rule

**Rule:** Names should clearly indicate purpose without comments.

**Conventions:**

**Functions:** `verbNoun` pattern
```swift
func fetchProducts()
func clearSearch()
func toggleFilter()
func validateEmail()
```

**Types:** `PascalCase`
```swift
class ProductSearchViewModel
struct UserProfile
enum AuthenticationState
protocol Authenticatable
```

**Constants:** `UPPER_SNAKE_CASE`
```swift
static let DEFAULT_WAREHOUSE = "IT01"
static let MAX_CART_ITEMS = 99
static let API_TIMEOUT: TimeInterval = 30
```

**Boolean Properties:** Start with `is`, `has`, `should`
```swift
var isLoading: Bool
var hasSearched: Bool
var shouldRefresh: Bool
```

## MVVM Architecture Pattern

### ViewModel Pattern

```swift
@MainActor
class ProductSearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

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
}
```

**Key Characteristics:**
- `@MainActor` ensures all updates on main thread
- `@Published` properties for SwiftUI reactivity
- Dependency injection via initializer
- Clear section markers with `// MARK:`
- Public methods for view interaction
- Private methods for internal logic

### View Pattern

```swift
struct ProductSearchView: View {
    @StateObject private var viewModel: ProductSearchViewModel
    @EnvironmentObject var authManager: SupabaseAuthManager

    init(supabaseClient: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: ProductSearchViewModel(supabaseClient: supabaseClient))
    }

    var body: some View {
        NavigationStack {
            VStack {
                searchBar
                productList
            }
            .navigationTitle("Products")
        }
    }

    // MARK: - Subviews
    private var searchBar: some View {
        // Implementation
    }

    private var productList: some View {
        // Implementation
    }
}
```

**Key Characteristics:**
- `@StateObject` for view-owned ViewModels
- `@EnvironmentObject` for app-wide state
- Extract complex views into computed properties
- Dependency injection through initializer

## Manager Pattern (Singleton)

### Standard Implementation

```swift
@MainActor
class ThemeManager: ObservableObject {
    // MARK: - Singleton
    static let shared = ThemeManager()

    // MARK: - Published Properties
    @Published var currentTheme: AppTheme {
        didSet {
            saveThemePreference()
            updateColorScheme()
        }
    }

    @Published var colorScheme: ColorScheme?

    // MARK: - Private Properties
    private let userDefaultsKey = "app_theme_preference"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        // Load from UserDefaults
        self.currentTheme = loadThemePreference() ?? .system
        updateColorScheme()
    }

    // MARK: - Public Methods
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }

    // MARK: - Private Methods
    private func saveThemePreference() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: userDefaultsKey)
    }

    private func updateColorScheme() {
        colorScheme = currentTheme.colorScheme
    }

    private func loadThemePreference() -> AppTheme? {
        guard let rawValue = UserDefaults.standard.string(forKey: userDefaultsKey) else {
            return nil
        }
        return AppTheme(rawValue: rawValue)
    }
}
```

**When to Use Manager Pattern:**
- App-wide state (theme, localization, auth)
- Singleton services (Supabase client wrapper)
- Persistent configuration

**Key Characteristics:**
- Singleton with `static let shared`
- `@MainActor` for thread safety
- `ObservableObject` for SwiftUI reactivity
- Private initializer prevents multiple instances
- `didSet` observers for automatic side effects
- UserDefaults or Keychain persistence

## File Organization Best Practices

### Directory Structure Template

```
MyApp/
├── Features/                     # Domain-driven features
│   ├── Authentication/
│   ├── Products/
│   ├── Cart/
│   └── Profile/
│
├── Shared/                       # Actually shared across features
│   ├── Components/               # Reusable UI components
│   │   ├── GlassCard.swift
│   │   ├── GlassButton.swift
│   │   └── LoadingIndicator.swift
│   ├── Networking/               # API client, request builder
│   │   ├── SupabaseClient.swift
│   │   └── APIError.swift
│   ├── Extensions/               # Swift extensions
│   │   ├── String+Localization.swift
│   │   ├── View+Keyboard.swift
│   │   └── Color+Brand.swift
│   ├── Utilities/                # Generic helpers
│   │   ├── DateFormatter.swift
│   │   ├── CurrencyFormatter.swift
│   │   └── Validator.swift
│   └── Theme/                    # Design system
│       ├── Colors.swift
│       ├── Typography.swift
│       └── Spacing.swift
│
├── Assets.xcassets/              # Images and colors
├── Localization/                 # i18n files
│   ├── en.lproj/
│   ├── it.lproj/
│   └── fr.lproj/
├── MyAppApp.swift               # App entry point
└── ContentView.swift             # Main authenticated view
```

### Naming Conventions

**Files:**
- Managers: `ThemeManager.swift`
- ViewModels: `ProductSearchViewModel.swift`
- Views: `ProductSearchView.swift`
- Models: `Product.swift`
- Services: `ProductAvailabilityService.swift`
- Extensions: `String+Localization.swift`

**Avoid:**
- Generic names like `Utils.swift`, `Helpers.swift`
- Abbreviations like `ProdSrchVM.swift`
- Technical suffixes on models like `ProductModel.swift` (just `Product.swift`)
