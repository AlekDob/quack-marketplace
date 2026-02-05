---
name: flutter-navigation
description: Flutter navigation patterns with GoRouter, Navigator 2.0, and deep linking.
---

# Flutter Navigation

Modern navigation patterns for Flutter applications.

## GoRouter (Recommended)

### Basic Setup
```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/users/:id',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return UserScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

// Main app
MaterialApp.router(
  routerConfig: router,
)
```

### Navigation Methods
```dart
// Push a new route
context.push('/users/123');

// Replace current route
context.pushReplacement('/home');

// Go (replaces entire stack)
context.go('/login');

// Pop
context.pop();

// Named routes with parameters
context.pushNamed(
  'userProfile',
  pathParameters: {'id': '123'},
  queryParameters: {'tab': 'posts'},
);
```

### Nested Navigation
```dart
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/search');
            case 2:
              context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

### Route Guards
```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authService.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login?redirect=${state.matchedLocation}';
    }

    if (isLoggedIn && isLoggingIn) {
      final redirect = state.uri.queryParameters['redirect'];
      return redirect ?? '/';
    }

    return null; // No redirect
  },
  routes: [...],
);
```

## Navigator 1.0 (Imperative)

### Basic Navigation
```dart
// Push
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailScreen(item: item),
  ),
);

// Push and wait for result
final result = await Navigator.push<String>(
  context,
  MaterialPageRoute(
    builder: (context) => SelectionScreen(),
  ),
);

// Pop with result
Navigator.pop(context, 'Selected value');

// Push replacement
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
);

// Push and remove until
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
  (route) => false, // Remove all
);
```

### Named Routes
```dart
// Define in MaterialApp
MaterialApp(
  routes: {
    '/': (context) => HomeScreen(),
    '/settings': (context) => SettingsScreen(),
  },
  onGenerateRoute: (settings) {
    if (settings.name?.startsWith('/user/') ?? false) {
      final userId = settings.name!.split('/').last;
      return MaterialPageRoute(
        builder: (context) => UserScreen(userId: userId),
      );
    }
    return null;
  },
)

// Navigate
Navigator.pushNamed(context, '/settings');
Navigator.pushNamed(context, '/user/123');
```

## Page Transitions

### Custom Transitions
```dart
GoRoute(
  path: '/details',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      child: const DetailsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  },
)
```

### Shared Element Transitions
```dart
// Source
Hero(
  tag: 'product-${product.id}',
  child: Image.network(product.imageUrl),
)

// Destination
Hero(
  tag: 'product-${product.id}',
  child: Image.network(product.imageUrl),
)
```

## Deep Linking

### Configuration
```dart
// GoRouter handles deep links automatically
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductScreen(id: id);
      },
    ),
  ],
);

// iOS: Add URL scheme in Info.plist
// Android: Add intent filter in AndroidManifest.xml
```

## Best Practices

- Use GoRouter for most apps - handles deep links, guards, and nesting
- Prefer declarative over imperative navigation
- Use path parameters for resource IDs
- Use query parameters for filters/options
- Implement proper back button handling
- Test navigation flows
