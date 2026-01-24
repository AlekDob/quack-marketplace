---
name: cc-mobile-patterns
description: This skill provides comprehensive patterns, conventions, and best practices for building iOS/SwiftUI mobile applications in the C&C ecosystem. Use this skill when creating new C&C mobile apps, implementing features following established patterns, or ensuring consistency across mobile projects. Covers domain-driven architecture, Liquid Glass UI design, Supabase integration, authentication, internationalization, and reusable Swift templates.
---

# C&C Mobile App Patterns & Conventions

## Overview

This skill documents all architectural patterns, UI/UX conventions, code standards, and best practices used across C&C mobile applications (C&C Team, Flow POS, and future apps). It provides reusable templates and comprehensive reference documentation to ensure consistency, quality, and rapid development of new mobile projects.

**When to use this skill:**
- Creating a new iOS/SwiftUI mobile application in the C&C ecosystem
- Implementing features following established C&C patterns
- Setting up authentication, internationalization, or backend integration
- Designing UI components with Liquid Glass design system
- Ensuring code consistency across mobile projects
- Onboarding new developers to C&C mobile standards

## Core Principles

### The 4 Laws (Universal Across All Projects)

1. **20-Line Function Rule**: Functions should be maximum 20 lines (exceptions: SwiftUI body, complex switches)
2. **300-Line File Rule**: Files should be maximum 300 lines (split by responsibility when exceeded)
3. **Domain-Driven Organization**: Group by feature/domain, NOT by technical type
4. **Self-Documenting Names**:
   - Functions: `verbNoun` (e.g., `fetchProducts`, `clearSearch`)
   - Types: `PascalCase` (e.g., `ProductSearchViewModel`)
   - Constants: `UPPER_SNAKE_CASE` (e.g., `DEFAULT_WAREHOUSE`)

### Domain-Driven Architecture

**✅ CORRECT Structure:**
```
Features/
├── Products/                 # All product-related code together
│   ├── Views/
│   ├── Models/
│   ├── ViewModels/
│   ├── Services/
│   └── Managers/
├── Cart/                     # All cart-related code together
└── Authentication/           # All auth-related code together
```

**❌ INCORRECT Structure:**
```
Views/          # All views mixed together (anti-pattern)
Models/         # All models mixed together (anti-pattern)
Services/       # All services mixed together (anti-pattern)
```

**Why:** When implementing "add product filter", all related code is in one place (`/Features/Products/`), making changes 10x faster.

## Quick Start: Creating a New Mobile App

### Step 1: Project Structure Setup

Create the following structure:
```
MyApp/
├── Features/                 # Domain-driven features
├── Shared/                   # Actually shared components
│   ├── Components/
│   ├── Networking/
│   ├── Extensions/
│   ├── Utilities/
│   └── Theme/
├── Assets.xcassets/
├── Localization/
│   ├── it.lproj/Localizable.strings
│   ├── fr.lproj/Localizable.strings
│   └── en.lproj/Localizable.strings
├── MyAppApp.swift
└── ContentView.swift
```

### Step 2: Use Templates

This skill provides ready-to-use templates in `assets/`:

1. **ManagerTemplate.swift** - For singleton managers (ThemeManager, LocalizationManager)
2. **ViewModelTemplate.swift** - For MVVM ViewModels with Combine
3. **ServiceTemplate.swift** - For Supabase backend integration
4. **LocalizationSetup.swift** - Complete i18n setup (copy and customize)

**Example: Creating a Product Manager**
```swift
// 1. Copy ManagerTemplate.swift
// 2. Rename to ProductManager.swift
// 3. Replace "YourDomain" with "Product"
// 4. Add product-specific logic
```

### Step 3: Setup Core Systems

Follow these patterns (see references for details):

1. **Authentication**: Use `SupabaseAuthManager` pattern with biometric support
2. **Internationalization**: Use `LocalizationManager` with `LocalizedKeys` enum
3. **Theme**: Use `ThemeManager` with system color support
4. **Backend**: Use service layer pattern with dependency injection

## Reference Documentation

Comprehensive documentation is available in the `references/` directory:

### Architecture & Code Patterns
- **`architecture-patterns.md`**: Domain-driven structure, The 4 Laws, MVVM, Manager pattern, file organization
- **`code-patterns.md`**: State management, navigation, async/await, error handling, memory management, performance optimization

### UI/UX Design
- **`ui-design-system.md`**: Liquid Glass materials, standard components (GlassCard, GlassButton, FilterChip, SearchBar), design tokens (spacing, corner radius, shadows, typography), color system, touch targets, animations, accessibility

### Backend Integration
- **`backend-supabase.md`**: Configuration management, service layer pattern, model patterns, real-time subscriptions, storage/file upload, error handling, performance tips

### Security & Authentication
- **`authentication-security.md`**: Authentication state machine, OAuth flow, biometric authentication, Keychain storage, session management, security best practices

### Internationalization
- **`internationalization-i18n.md`**: Language enum, LocalizationManager, type-safe keys, Supabase sync, date/number formatting, language picker

### Assets & Icons
- **`assets-icons.md`**: SF Symbols usage, icon mapping pattern, Assets.xcassets organization, image loading patterns, avatar placeholders, app icon guidelines

## Common Implementation Patterns

### Pattern 1: Create a New Feature

```swift
// 1. Create domain folder
Features/MyFeature/

// 2. Add Models
Features/MyFeature/Models/MyFeatureModel.swift

// 3. Add Service (backend)
Features/MyFeature/Services/MyFeatureService.swift

// 4. Add ViewModel (business logic)
Features/MyFeature/ViewModels/MyFeatureViewModel.swift

// 5. Add Views
Features/MyFeature/Views/MyFeatureView.swift
Features/MyFeature/Views/MyFeatureDetailView.swift
```

### Pattern 2: Implement Search with Debouncing

```swift
@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [Item] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task { await self?.performSearch(text) }
            }
            .store(in: &cancellables)
    }
}
```

### Pattern 3: Implement Filtering

```swift
// 1. Define filter model
struct MyFilter: Codable, Equatable {
    var categories: Set<String> = []
    var minPrice: Double? = nil

    var isActive: Bool {
        !categories.isEmpty || minPrice != nil
    }
}

// 2. Create FilterManager
@MainActor
class MyFilterManager: ObservableObject {
    static let shared = MyFilterManager()

    @Published var currentFilter = MyFilter() {
        didSet { saveFilter() }
    }

    func applyFilter(to items: [Item]) -> [Item] {
        guard currentFilter.isActive else { return items }
        return items.filter { /* filter logic */ }
    }
}
```

### Pattern 4: Implement Localization

```swift
// 1. Add keys to LocalizedKeys enum
enum LocalizedKeys: String {
    case myFeatureTitle = "myFeature.title"
    case myFeatureSubtitle = "myFeature.subtitle"

    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

// 2. Add to Localizable.strings
// it.lproj/Localizable.strings:
"myFeature.title" = "Il Mio Titolo";

// fr.lproj/Localizable.strings:
"myFeature.title" = "Mon Titre";

// en.lproj/Localizable.strings:
"myFeature.title" = "My Title";

// 3. Use in views
Text(LocalizedKeys.myFeatureTitle.localized)
```

## UI Component Examples

### Liquid Glass Card

```swift
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: ProductIconMapper.shared.icon(for: product.name))
                .font(.largeTitle)
                .foregroundStyle(.blue)

            Text(product.name)
                .font(.headline)

            Text(product.displayPrice)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
```

### Filter Chips

```swift
if filterManager.currentFilter.isActive {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
            ForEach(Array(filterManager.currentFilter.categories), id: \.self) { category in
                FilterChip(
                    title: category,
                    icon: "tag",
                    color: .blue,
                    onRemove: { filterManager.toggleCategory(category) }
                )
            }
        }
    }
}
```

### Compact Search Bar

```swift
CompactSearchBar(
    text: $searchText,
    placeholder: LocalizedKeys.searchPlaceholder.localized,
    isLoading: viewModel.isLoading,
    collapseDelay: 2.0
)
```

## Technology Stack

### Core Framework
- **UI**: SwiftUI (iOS 18.5+)
- **Language**: Swift 5.10+
- **Architecture**: MVVM with Combine
- **Design**: Liquid Glass (iOS 26+ material system)

### Backend & Auth
- **Backend**: Supabase
- **Auth**: OAuth (Google) + Biometric
- **Storage**: Keychain (tokens), UserDefaults (preferences)

### Localization
- **Languages**: Italian 🇮🇹 (primary), French 🇫🇷, English 🇬🇧
- **System**: Type-safe LocalizedKeys enum + .lproj files

## Best Practices Checklist

### Architecture ✅
- [ ] Use domain-driven organization
- [ ] Follow The 4 Laws (20-line functions, 300-line files)
- [ ] Implement MVVM pattern
- [ ] Use dependency injection

### UI/UX ✅
- [ ] Use Liquid Glass materials
- [ ] Follow 8pt grid spacing
- [ ] Maintain 44pt minimum touch targets
- [ ] Support Dynamic Type
- [ ] Test in light and dark mode
- [ ] Add VoiceOver labels

### Code Quality ✅
- [ ] Use @MainActor for ViewModels and Managers
- [ ] Implement debouncing for search (500ms)
- [ ] Use [weak self] in closures
- [ ] Handle errors gracefully
- [ ] Extract complex views into subviews

### Backend ✅
- [ ] Store config in Info.plist
- [ ] Use service layer pattern
- [ ] Implement error handling
- [ ] Cache frequently accessed data

### Security ✅
- [ ] Store tokens in Keychain
- [ ] Use OAuth (no passwords)
- [ ] Implement token refresh
- [ ] Validate email domains (internal apps)
- [ ] Clear sensitive data on logout

### Localization ✅
- [ ] Use type-safe LocalizedKeys enum
- [ ] Translate all user-facing text
- [ ] Format dates and numbers by locale
- [ ] Test all supported languages

## Getting Help

**For specific implementations**, refer to:
- Architecture questions → `references/architecture-patterns.md`
- UI component design → `references/ui-design-system.md`
- Backend integration → `references/backend-supabase.md`
- Authentication flow → `references/authentication-security.md`
- Localization setup → `references/internationalization-i18n.md`
- Icons and assets → `references/assets-icons.md`

**For code templates**, use:
- `assets/ManagerTemplate.swift` - Singleton managers
- `assets/ViewModelTemplate.swift` - MVVM ViewModels
- `assets/ServiceTemplate.swift` - Backend services
- `assets/LocalizationSetup.swift` - Complete i18n setup

## Examples from Existing Apps

This skill is based on patterns extracted from:
- **C&C Team** (`/Users/alekdob/Desktop/Dev/flow-team-mobile/`) - Internal team directory
- **Flow POS** (`/Users/alekdob/Desktop/Dev/flow-pos-mobile/`) - Point of Sale application

Both apps follow these exact patterns and can serve as reference implementations.
