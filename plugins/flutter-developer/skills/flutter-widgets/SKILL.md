---
name: flutter-widgets
description: Flutter widget composition patterns, custom widgets, and UI best practices.
---

# Flutter Widgets

Expert patterns for building Flutter UI with widgets.

## Widget Fundamentals

### Stateless vs Stateful
```dart
// Stateless - for UI that doesn't change
class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Hello, $name!'),
      ),
    );
  }
}

// Stateful - for UI with mutable state
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  void _increment() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

## Layout Patterns

### Responsive Layout
```dart
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return _DesktopLayout(child: child);
        } else if (constraints.maxWidth > 600) {
          return _TabletLayout(child: child);
        } else {
          return _MobileLayout(child: child);
        }
      },
    );
  }
}
```

### Flex Layouts
```dart
// Row with spacing
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Icon(Icons.star),
    Expanded(
      child: Text(title, overflow: TextOverflow.ellipsis),
    ),
    Text(rating.toString()),
  ],
)

// Column with flexible children
Column(
  children: [
    const Header(), // Fixed height
    Expanded(
      child: ListView(...), // Takes remaining space
    ),
    const BottomBar(), // Fixed height
  ],
)
```

## Custom Widgets

### Composition Pattern
```dart
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(url: product.imageUrl),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _PriceTag(price: product.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Reusable Components
```dart
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: _getStyle(variant),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
```

## Performance

### const Constructors
```dart
// Use const for widgets that never change
const MyWidget(); // Cached, reused
MyWidget(); // New instance every build

// Const children
Column(
  children: const [
    Text('Static text'),
    Icon(Icons.star),
  ],
)
```

### Keys for Lists
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    // Use key for proper widget reuse
    return ListTile(
      key: ValueKey(item.id),
      title: Text(item.name),
    );
  },
)
```

### RepaintBoundary
```dart
// Isolate expensive repaints
RepaintBoundary(
  child: ExpensiveAnimatedWidget(),
)
```

## Theming

### Access Theme
```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Container(
    color: colorScheme.surface,
    child: Text(
      'Hello',
      style: textTheme.headlineMedium?.copyWith(
        color: colorScheme.primary,
      ),
    ),
  );
}
```

## Best Practices

- Prefer `const` constructors when possible
- Extract widgets into separate classes for reusability
- Use `LayoutBuilder` for responsive layouts
- Keep `build()` methods focused and simple
- Use meaningful widget keys in lists
- Leverage Theme for consistent styling
