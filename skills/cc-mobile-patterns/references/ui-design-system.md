# UI Design System for C&C Mobile Apps

## Liquid Glass Design Language

Liquid Glass is Apple's modern material design system (iOS 26+) providing frosted-glass aesthetics with soft translucency, depth, and fluidity.

### Material Hierarchy

```swift
// Subtle backgrounds - 10% opacity
.ultraThinMaterial       // Cards, overlays, subtle surfaces

// Standard surfaces - 20% opacity
.thinMaterial            // Primary UI surfaces, panels

// Emphasis elements - 35% opacity
.regularMaterial         // Important sections, selected states

// Navigation and toolbars - 40% opacity
.bar                     // TabBar, NavigationBar, ToolBar

// Strong separation - 50%+ opacity
.thickMaterial           // Modals, sheets, critical UI
.ultraThickMaterial      // Maximum frosting
```

### When to Use Each Material

**ultraThinMaterial:**
- Product cards
- List item backgrounds
- Overlay panels
- Floating search bars

**thinMaterial:**
- Section containers
- Filter panels
- Settings groups
- Info cards

**regularMaterial:**
- Active/selected states
- Important badges
- Highlighted sections
- Modal backgrounds

**bar:**
- TabBar (automatic)
- NavigationBar (automatic)
- Custom toolbars

**thickMaterial:**
- Full-screen sheets
- Important modals
- Alert backgrounds

## Standard Components

### GlassCard

Basic card component with Liquid Glass effect:

```swift
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// Usage
GlassCard {
    VStack {
        Text("Card Title")
        Text("Card Content")
    }
}
```

### GlassButton

Standard button with glass effect:

```swift
struct GlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(backgroundMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(shadowOpacity), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var backgroundMaterial: Material {
        switch style {
        case .primary: return .regularMaterial
        case .secondary: return .thinMaterial
        case .destructive: return .thinMaterial
        }
    }

    private var shadowOpacity: Double {
        switch style {
        case .primary: return 0.15
        case .secondary: return 0.08
        case .destructive: return 0.1
        }
    }
}

// Usage
GlassButton(title: "Add to Cart", icon: "cart.badge.plus", style: .primary) {
    // Action
}
```

### FilterChip

Removable filter chip with glass effect:

```swift
struct FilterChip: View {
    let title: String
    let icon: String?
    let color: Color
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
            }

            Text(title)
                .font(.caption)
                .fontWeight(.medium)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.thinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Usage
FilterChip(title: "Italy", icon: "globe", color: .blue) {
    // Remove filter
}
```

### SearchBar

Compact auto-collapsing search bar:

```swift
struct CompactSearchBar: View {
    @Binding var text: String
    let placeholder: String
    var isLoading: Bool = false
    var collapseDelay: TimeInterval = 2.0

    @State private var isExpanded = false
    @FocusState private var isFocused: Bool
    @State private var collapseWorkItem: DispatchWorkItem?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(isExpanded ? .blue : .secondary)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded = true
                        isFocused = true
                    }
                }

            if isExpanded || !text.isEmpty {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if !text.isEmpty {
                    Button {
                        withAnimation {
                            text = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onChange(of: isFocused) { _, newValue in
            if !newValue && text.isEmpty {
                scheduleCollapse()
            } else {
                cancelCollapse()
            }
        }
    }

    private func scheduleCollapse() {
        collapseWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded = false
            }
        }
        collapseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + collapseDelay, execute: workItem)
    }

    private func cancelCollapse() {
        collapseWorkItem?.cancel()
        collapseWorkItem = nil
    }
}

// Usage
CompactSearchBar(text: $searchText, placeholder: "Search products...", isLoading: isLoading)
```

## Design Tokens

### Spacing System (8pt Grid)

```swift
enum Spacing {
    static let xs: CGFloat = 4      // 0.5x
    static let sm: CGFloat = 8      // 1x - Base unit
    static let md: CGFloat = 16     // 2x
    static let lg: CGFloat = 24     // 3x
    static let xl: CGFloat = 32     // 4x
    static let xxl: CGFloat = 48    // 6x
}

// Usage
.padding(Spacing.md)
.padding(.horizontal, Spacing.lg)
```

### Corner Radius Standards

```swift
enum CornerRadius {
    static let small: CGFloat = 8    // Chips, pills, small buttons
    static let medium: CGFloat = 12  // Standard buttons
    static let large: CGFloat = 16   // Cards, containers
    static let xlarge: CGFloat = 20  // Large panels
    static let xxlarge: CGFloat = 24 // Sheets, modals
}

// Usage
.clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
```

### Shadow Standards

```swift
extension View {
    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    func buttonShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    func modalShadow() -> some View {
        self.shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

// Usage
GlassCard { ... }
    .cardShadow()
```

### Typography Scale

```swift
extension Font {
    // Display
    static let displayLarge = Font.system(size: 57, weight: .bold)
    static let displayMedium = Font.system(size: 45, weight: .bold)
    static let displaySmall = Font.system(size: 36, weight: .bold)

    // Headline
    static let headlineLarge = Font.system(size: 32, weight: .semibold)
    static let headlineMedium = Font.system(size: 28, weight: .semibold)
    static let headlineSmall = Font.system(size: 24, weight: .semibold)

    // Title
    static let titleLarge = Font.system(size: 22, weight: .semibold)
    static let titleMedium = Font.system(size: 16, weight: .semibold)
    static let titleSmall = Font.system(size: 14, weight: .semibold)

    // Body
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let bodySmall = Font.system(size: 12, weight: .regular)

    // Label
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let labelSmall = Font.system(size: 11, weight: .medium)
}

// Usage
Text("Product Name")
    .font(.titleLarge)
```

## Color System

### Semantic Colors

Always use semantic colors that adapt to light/dark mode:

```swift
extension Color {
    // Primary brand colors
    static let brandPrimary = Color(.systemBlue)      // Apple ecosystem
    static let brandSecondary = Color(.systemIndigo)

    // State colors
    static let success = Color(.systemGreen)    // Success, available
    static let warning = Color(.systemOrange)   // Warning, low stock
    static let error = Color(.systemRed)        // Error, out of stock
    static let info = Color(.systemBlue)        // Info, badges

    // UI colors
    static let background = Color(.systemGroupedBackground)
    static let secondaryBackground = Color(.secondarySystemGroupedBackground)
    static let tertiaryBackground = Color(.tertiarySystemGroupedBackground)

    // Text colors
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
}
```

### Color Usage Guidelines

**DO:**
- Use semantic colors (`.systemBlue`, `.label`, etc.)
- Define custom colors in Assets.xcassets with light/dark variants
- Use foregroundStyle for text and icons
- Test in both light and dark mode

**DON'T:**
- Hardcode hex colors in code
- Use `.black` or `.white` directly (use `.primary` or `.label`)
- Forget dark mode variants

## Touch Targets

### Minimum Sizes

All interactive elements must meet minimum touch targets:

```swift
enum TouchTarget {
    static let minimum: CGFloat = 44    // Apple HIG minimum
    static let comfortable: CGFloat = 48 // Recommended for retail
}

// Usage
Button("Action") { }
    .frame(minHeight: TouchTarget.minimum)
```

### Retail-Optimized Components

For on-the-floor usage, use larger targets:

```swift
struct RetailButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.titleMedium)
                .frame(maxWidth: .infinity)
                .frame(height: 56) // Larger than standard
        }
    }
}
```

## Animation Standards

### Standard Animations

```swift
// Default spring (smooth and natural)
.animation(.spring(response: 0.4, dampingFraction: 0.7), value: state)

// Quick response
.animation(.spring(response: 0.3, dampingFraction: 0.8), value: state)

// Slow, fluid
.animation(.spring(response: 0.6, dampingFraction: 0.75), value: state)

// Ease in/out (for simple transitions)
.animation(.easeInOut(duration: 0.3), value: state)
```

### Transition Examples

```swift
// Slide and fade
.transition(.move(edge: .trailing).combined(with: .opacity))

// Scale and fade
.transition(.scale(scale: 0.9).combined(with: .opacity))

// Push from bottom
.transition(.move(edge: .bottom))
```

### Loading States

```swift
// Skeleton loader with shimmer
struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.tertiary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 200 : -200)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
```

## Accessibility

### Required Practices

**Dynamic Type:**
```swift
// Always use semantic font sizes
Text("Title")
    .font(.headline) // Scales automatically

// For custom sizes, use .dynamicTypeSize
Text("Custom")
    .font(.system(size: 16))
    .dynamicTypeSize(.xSmall ... .xxxLarge)
```

**VoiceOver:**
```swift
// Add accessibility labels
Image(systemName: "cart")
    .accessibilityLabel("Shopping cart")

// Add hints for complex interactions
Button("Filter") { }
    .accessibilityHint("Opens filter options")

// Group related elements
HStack {
    Text("Product")
    Text("$99")
}
.accessibilityElement(children: .combine)
```

**Color Contrast:**
- Maintain WCAG AA minimum (4.5:1 for normal text, 3:1 for large text)
- Test with system accessibility settings
- Don't rely on color alone for information

## Responsive Design

### iPad Adaptations

```swift
struct ProductListView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        let columns = horizontalSizeClass == .regular ? 3 : 2

        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns)) {
            // Content
        }
    }
}
```

### Safe Areas

```swift
// Respect safe areas
VStack {
    // Content
}
.padding(.horizontal, Spacing.md)
.safeAreaInset(edge: .bottom) {
    // Fixed bottom element
}
```

## Best Practices Summary

### DO:
✅ Use Liquid Glass materials (`.ultraThinMaterial`, `.thinMaterial`)
✅ Follow 8pt grid for spacing
✅ Use semantic colors
✅ Maintain 44pt minimum touch targets
✅ Add spring animations for natural feel
✅ Support Dynamic Type
✅ Test in light and dark mode
✅ Use SF Symbols for icons

### DON'T:
❌ Hardcode colors or spacing values
❌ Use UIKit unless absolutely necessary
❌ Forget accessibility labels
❌ Ignore iPad layout considerations
❌ Use `Color.black` or `Color.white` directly
❌ Create tiny touch targets (< 44pt)
