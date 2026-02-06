---
name: swiftui-best-practices
description: Use this skill when building SwiftUI views, managing state with @Observable or @State, composing view hierarchies, adding animations, handling navigation with NavigationStack, or reviewing SwiftUI code for modern API usage and deprecated pattern replacement.
---

# SwiftUI Best Practices

Expert guidance for building SwiftUI applications with modern patterns.

## State Management

### @Observable (iOS 17+, Preferred)
```swift
@Observable
class UserViewModel {
    var name: String = ""
    var email: String = ""
    var isLoading: Bool = false

    func loadUser() async {
        isLoading = true
        defer { isLoading = false }
        // fetch user...
    }
}

struct UserView: View {
    @State private var viewModel = UserViewModel()

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.name)
            TextField("Email", text: $viewModel.email)
        }
        .task { await viewModel.loadUser() }
    }
}
```

### When to Use What

| Property Wrapper | Use Case |
|------------------|----------|
| `@State` | Simple value types owned by the view |
| `@Binding` | Two-way connection to parent's state |
| `@Observable` class | Complex state with multiple properties |
| `@Environment` | Dependency injection (settings, services) |
| `@AppStorage` | UserDefaults-backed persistence |

### Migration from ObservableObject
- Replace `@Published var` with plain `var` in `@Observable` classes
- Remove `@ObservedObject` / `@StateObject` — use `@State` for owned instances
- Remove `objectWillChange.send()` — automatic with `@Observable`
- Keep `@EnvironmentObject` only for legacy code; prefer `@Environment` with custom keys

## View Composition

### Keep Views Small
```swift
// Good: decomposed views
struct OrderListView: View {
    let orders: [Order]

    var body: some View {
        List(orders) { order in
            OrderRow(order: order)
        }
    }
}

struct OrderRow: View {
    let order: Order

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(order.title).font(.headline)
                Text(order.date.formatted()).font(.caption)
            }
            Spacer()
            StatusBadge(status: order.status)
        }
    }
}
```

### View Property Ordering Convention
```swift
struct MyView: View {
    // 1. Environment values
    @Environment(\.dismiss) private var dismiss

    // 2. State and bindings
    @State private var searchText = ""
    @Binding var isPresented: Bool

    // 3. Let properties (injected)
    let title: String
    let items: [Item]

    // 4. Body
    var body: some View { ... }

    // 5. Computed properties
    private var filteredItems: [Item] { ... }

    // 6. Private methods
    private func handleSubmit() { ... }
}
```

## Navigation

### NavigationStack (iOS 16+)
```swift
struct AppNavigation: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product)
                }
                .navigationDestination(for: Category.self) { category in
                    CategoryView(category: category)
                }
        }
    }
}
```

### TabView
```swift
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(1)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(2)
        }
    }
}
```

## Lists and Performance

### Lazy Loading
```swift
struct FeedView: View {
    let items: [FeedItem]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    FeedCard(item: item)
                }
            }
            .padding()
        }
    }
}
```

### Identifiable and Equatable
- Always conform list items to `Identifiable`
- Conform to `Equatable` for expensive rows to avoid unnecessary redraws
- Use `id:` parameter only when `Identifiable` conformance isn't practical

## Animations

```swift
// Implicit animation
Text("Hello")
    .scaleEffect(isExpanded ? 1.2 : 1.0)
    .animation(.spring(duration: 0.3), value: isExpanded)

// Explicit animation
Button("Toggle") {
    withAnimation(.easeInOut(duration: 0.25)) {
        isExpanded.toggle()
    }
}

// Matched geometry for transitions
@Namespace private var animation

// In source view
Image(item.image)
    .matchedGeometryEffect(id: item.id, in: animation)

// In destination view
Image(item.image)
    .matchedGeometryEffect(id: item.id, in: animation)
```

## Modifiers Best Practices

- Apply modifiers from most specific to most general (inside-out)
- Use `ViewModifier` protocol for reusable modifier combinations
- Prefer `.task {}` over `.onAppear` for async work (automatic cancellation)
- Use `.onChange(of:)` sparingly — often a sign of imperative thinking

## SF Symbols

```swift
// Standard usage
Image(systemName: "heart.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.red)

// Variable value (iOS 16+)
Image(systemName: "wifi", variableValue: signalStrength)

// Symbol effect (iOS 17+)
Image(systemName: "bell")
    .symbolEffect(.bounce, value: notificationCount)
```

## Accessibility

- Always add `.accessibilityLabel()` for image-only buttons
- Use semantic font styles (`.headline`, `.body`, `.caption`) for Dynamic Type
- Test with VoiceOver — `Cmd + F5` in Simulator
- Support Dark Mode via semantic colors (`Color.primary`, `Color.secondary`)
- Respect `@Environment(\.dynamicTypeSize)` for layout adjustments
