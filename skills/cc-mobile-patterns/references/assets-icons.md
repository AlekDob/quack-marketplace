# Asset Management & Icons

## SF Symbols Usage

All C&C mobile apps use SF Symbols for icons. They are:
- Free and included with iOS
- Automatically adapt to weight, size, and color
- Support multicolor variants
- Scale perfectly at any size
- Match system font weights

### Icon Mapping Pattern

For product names, use intelligent icon mapping:

```swift
struct IconMappingRule {
    let keywords: [String]
    let icon: String
    let priority: Int  // 1 = highest priority

    func matches(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return keywords.contains { lowercased.contains($0.lowercased()) }
    }
}

class ProductIconMapper {
    static let shared = ProductIconMapper()

    private let rules: [IconMappingRule] = [
        // Apple Products (Priority 3 - Highest)
        IconMappingRule(keywords: ["iphone"], icon: "iphone", priority: 3),
        IconMappingRule(keywords: ["ipad"], icon: "ipad", priority: 3),
        IconMappingRule(keywords: ["mac", "macbook", "imac"], icon: "laptopcomputer", priority: 3),
        IconMappingRule(keywords: ["apple watch", "watch"], icon: "applewatch", priority: 3),
        IconMappingRule(keywords: ["airpods"], icon: "airpodspro", priority: 3),
        IconMappingRule(keywords: ["apple tv"], icon: "appletv", priority: 3),
        IconMappingRule(keywords: ["homepod"], icon: "homepod", priority: 3),

        // Accessories (Priority 2)
        IconMappingRule(keywords: ["case", "cover", "custodia"], icon: "iphone.gen3.radiowaves.left.and.right", priority: 2),
        IconMappingRule(keywords: ["magsafe"], icon: "magsafe.batterypack", priority: 2),
        IconMappingRule(keywords: ["cable", "cavo"], icon: "cable.connector", priority: 2),
        IconMappingRule(keywords: ["charger", "caricabatterie"], icon: "powerplug", priority: 2),
        IconMappingRule(keywords: ["keyboard", "tastiera"], icon: "keyboard", priority: 2),
        IconMappingRule(keywords: ["mouse"], icon: "computermouse", priority: 2),
        IconMappingRule(keywords: ["trackpad"], icon: "touchpad", priority: 2),
        IconMappingRule(keywords: ["pencil"], icon: "applepencil", priority: 2),

        // Software & Services (Priority 2)
        IconMappingRule(keywords: ["applecare"], icon: "shield.checkered", priority: 2),
        IconMappingRule(keywords: ["app store"], icon: "app.badge", priority: 2),

        // Generic Fallbacks (Priority 1 - Lowest)
        IconMappingRule(keywords: ["audio", "speaker", "cuffie"], icon: "hifispeaker", priority: 1),
        IconMappingRule(keywords: ["video"], icon: "video", priority: 1),
        IconMappingRule(keywords: ["photo", "camera"], icon: "camera", priority: 1),
    ]

    func icon(for productName: String, fallback: String = "gift") -> String {
        let sortedRules = rules.sorted { $0.priority > $1.priority }

        for rule in sortedRules {
            if rule.matches(productName) {
                return rule.icon
            }
        }

        return fallback
    }
}

// Usage
let iconName = ProductIconMapper.shared.icon(for: "iPhone 16 Pro Max")
// Returns: "iphone"

Image(systemName: iconName)
    .font(.title)
    .foregroundStyle(.blue)
```

### Common SF Symbols Reference

**Apple Products:**
```swift
"iphone"                    // iPhone
"ipad"                      // iPad
"laptopcomputer"            // Mac
"applewatch"                // Apple Watch
"airpodspro"                // AirPods
"airpodsmax"                // AirPods Max
"homepod"                   // HomePod
"appletv"                   // Apple TV
"airtag"                    // AirTag
```

**Accessories:**
```swift
"iphone.gen3.radiowaves.left.and.right"  // MagSafe/Case
"magsafe.batterypack"                    // MagSafe Battery
"cable.connector"                        // Cable
"powerplug"                              // Charger
"keyboard"                               // Keyboard
"computermouse"                          // Mouse
"applepencil"                            // Apple Pencil
"display"                                // Display/Monitor
```

**UI Actions:**
```swift
"magnifyingglass"           // Search
"line.3.horizontal.decrease" // Filter
"slider.horizontal.3"       // Settings/Filters
"ellipsis.circle"           // More options
"plus.circle.fill"          // Add
"minus.circle.fill"         // Remove
"xmark.circle.fill"         // Clear/Close
"checkmark.circle.fill"     // Success/Selected
"arrow.triangle.2.circlepath" // Refresh
"square.and.arrow.up"       // Share
```

**Navigation:**
```swift
"chevron.left"              // Back
"chevron.right"             // Forward/Next
"chevron.down"              // Expand
"chevron.up"                // Collapse
"chevron.up.chevron.down"   // Sort
"arrow.up.arrow.down"       // Sort alternative
```

**States:**
```swift
"checkmark.seal.fill"       // Verified
"exclamationmark.triangle"  // Warning
"xmark.octagon"             // Error
"info.circle"               // Information
"questionmark.circle"       // Help
"bolt.circle"               // Fast/Quick
"star.fill"                 // Favorite
"heart.fill"                // Like
```

**E-commerce:**
```swift
"cart"                      // Shopping cart
"cart.badge.plus"           // Add to cart
"creditcard"                // Payment
"bag"                       // Shopping bag
"giftcard"                  // Gift card
"tag"                       // Price tag
"barcode"                   // Barcode scan
```

**Communication:**
```swift
"envelope"                  // Email
"phone"                     // Phone
"message"                   // Message
"bell"                      // Notifications
"person.2"                  // Team/Group
"building.2"                // Store/Company
```

**Maps & Location:**
```swift
"map"                       // Map
"mappin"                    // Location pin
"location"                  // Current location
"location.fill"             // Location filled
"arrow.triangle.turn.up.right.circle" // Directions
```

### SF Symbols Configuration

```swift
extension Image {
    func iconStyle(size: CGFloat = 24, weight: Font.Weight = .regular) -> some View {
        self
            .font(.system(size: size, weight: weight))
            .symbolRenderingMode(.hierarchical)
    }

    func multicolorIcon(size: CGFloat = 24) -> some View {
        self
            .font(.system(size: size))
            .symbolRenderingMode(.multicolor)
    }

    func monochromeIcon(color: Color, size: CGFloat = 24) -> some View {
        self
            .font(.system(size: size))
            .foregroundStyle(color)
    }
}

// Usage
Image(systemName: "iphone")
    .iconStyle(size: 32, weight: .semibold)

Image(systemName: "globe.europe.africa")
    .multicolorIcon(size: 40)
```

## Assets.xcassets Organization

```
Assets.xcassets/
├── AppIcon.appiconset/              # App icon (all sizes)
│   ├── Icon-1024.png                # App Store icon
│   └── [Various sizes]              # iOS generates other sizes
│
├── Colors/                          # Color assets (with dark mode variants)
│   ├── BrandPrimary.colorset/
│   │   ├── Contents.json
│   │   └── [Light/Dark variants]
│   ├── BrandSecondary.colorset/
│   ├── Success.colorset/
│   ├── Warning.colorset/
│   └── Error.colorset/
│
├── Images/                          # Image assets
│   ├── Logo.imageset/
│   │   ├── logo@1x.png
│   │   ├── logo@2x.png
│   │   ├── logo@3x.png
│   │   └── Contents.json
│   ├── PlaceholderAvatar.imageset/
│   └── Onboarding/                  # Grouped onboarding images
│       ├── OnboardingStep1.imageset/
│       ├── OnboardingStep2.imageset/
│       └── OnboardingStep3.imageset/
│
└── Symbols/                         # Custom SF Symbols (if any)
    └── CustomIcon.symbolset/
```

### Color Assets Pattern

Define semantic colors in Assets.xcassets with light/dark variants:

**BrandPrimary.colorset/Contents.json:**
```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.447",
          "green" : "0.447",
          "red" : "0.000"
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.800",
          "green" : "0.600",
          "red" : "0.200"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Usage in Code:**
```swift
extension Color {
    static let brandPrimary = Color("BrandPrimary")
    static let brandSecondary = Color("BrandSecondary")
    static let brandSuccess = Color("Success")
    static let brandWarning = Color("Warning")
    static let brandError = Color("Error")
}

// Automatically adapts to light/dark mode
Text("Hello")
    .foregroundStyle(Color.brandPrimary)
```

## Image Loading Patterns

### AsyncImage with Placeholder

```swift
struct ProductImage: View {
    let url: URL?
    let fallbackIcon: String = "photo"

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 100, height: 100)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: fallbackIcon)
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                    .frame(width: 100, height: 100)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 100, height: 100)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

### Cached Image Loading

```swift
actor ImageCache {
    static let shared = ImageCache()

    private var cache: [URL: UIImage] = [:]

    func get(url: URL) -> UIImage? {
        cache[url]
    }

    func set(url: URL, image: UIImage) {
        cache[url] = image
    }

    func clear() {
        cache.removeAll()
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url = url else {
            isLoading = false
            return
        }

        // Check cache first
        if let cached = await ImageCache.shared.get(url: url) {
            image = cached
            isLoading = false
            return
        }

        // Load from network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                await ImageCache.shared.set(url: url, image: loadedImage)
                image = loadedImage
            }
        } catch {
            print("Image load failed: \(error)")
        }

        isLoading = false
    }
}
```

## Avatar Placeholders

### User Avatar with Initials

```swift
struct UserAvatarView: View {
    let user: User
    let size: CGFloat

    var body: some View {
        Group {
            if let photoURL = user.photoURL {
                CachedAsyncImage(url: photoURL)
            } else {
                initialsAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.brandPrimary.opacity(0.2))

            Text(user.initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(Color.brandPrimary)
        }
    }
}

extension User {
    var initials: String {
        let components = (firstName + " " + lastName).components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}
```

## App Icon Guidelines

### Size Requirements

iOS requires multiple icon sizes:
- **1024x1024**: App Store
- **180x180**: iPhone (@3x)
- **120x120**: iPhone (@2x)
- **167x167**: iPad Pro (@2x)
- **152x152**: iPad (@2x)
- **76x76**: iPad (@1x)

### Design Guidelines

**DO:**
✅ Use simple, recognizable design
✅ Fill entire square (no transparency)
✅ Use vector graphics for scalability
✅ Test on both light and dark backgrounds
✅ Avoid text (icon should work at any size)
✅ Use consistent brand colors

**DON'T:**
❌ Use transparency or rounded corners (iOS adds them)
❌ Include photos (reduce readability at small sizes)
❌ Copy other app icons
❌ Use gradients that don't scale well

## Launch Screen

Use Xcode's Launch Screen storyboard:

```swift
// Simple launch screen with logo
VStack {
    Spacer()
    Image("Logo")
        .resizable()
        .scaledToFit()
        .frame(width: 120, height: 120)
    Spacer()
}
.background(Color.background)
```

## Asset Naming Conventions

**Images:**
- Use descriptive names: `onboarding-step-1` not `img1`
- Use lowercase with hyphens: `product-placeholder` not `ProductPlaceholder`
- Group related assets: `onboarding/step-1` not `onboarding-step-1`

**Colors:**
- PascalCase: `BrandPrimary` not `brand-primary`
- Semantic names: `Success` not `Green`

**Icons (Custom SF Symbols):**
- Use lowercase with dots: `custom.icon.name`
- Follow SF Symbols naming conventions

## Image Optimization

### Pre-Processing

Before adding images to Assets.xcassets:

1. **Compress images**: Use ImageOptim or similar
2. **Use appropriate format**:
   - PNG for logos, icons, transparency
   - JPEG for photos
   - PDF for vector graphics (scales to any size)
3. **Remove metadata**: Strip EXIF data
4. **Use @2x and @3x**: Provide retina assets

### Runtime Optimization

```swift
// Lazy loading for scrolling performance
LazyVStack {
    ForEach(products) { product in
        ProductRow(product: product)
    }
}

// Thumbnail generation for large images
extension UIImage {
    func thumbnail(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
```

## Best Practices Summary

### DO:
✅ Use SF Symbols for all icons
✅ Implement intelligent icon mapping for products
✅ Define colors in Assets.xcassets with dark mode variants
✅ Cache images for better performance
✅ Provide fallback placeholders for failed loads
✅ Use semantic color names
✅ Optimize images before adding to project
✅ Test assets in both light and dark mode
✅ Use vector graphics (PDF) when possible

### DON'T:
❌ Embed large images directly in app bundle
❌ Hardcode color values in code
❌ Use custom icons when SF Symbol exists
❌ Forget @2x and @3x variants
❌ Skip image compression
❌ Use generic asset names
❌ Load all images at once
❌ Skip placeholder handling
