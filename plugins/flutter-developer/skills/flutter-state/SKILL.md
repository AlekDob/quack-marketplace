---
name: flutter-state
description: Flutter state management patterns with Riverpod, BLoC, and Provider.
---

# Flutter State Management

Modern state management approaches for Flutter applications.

## Riverpod (Recommended)

### Basic Providers
```dart
// Simple state
final counterProvider = StateProvider<int>((ref) => 0);

// Computed state
final doubleCounterProvider = Provider<int>((ref) {
  return ref.watch(counterProvider) * 2;
});

// Async data
final userProvider = FutureProvider<User>((ref) async {
  return await ref.read(apiProvider).fetchUser();
});
```

### StateNotifier Pattern
```dart
// State class
@freezed
class TodoState with _$TodoState {
  const factory TodoState({
    @Default([]) List<Todo> todos,
    @Default(false) bool isLoading,
    String? error,
  }) = _TodoState;
}

// Notifier
class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(this._api) : super(const TodoState());

  final TodoApi _api;

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final todos = await _api.fetchTodos();
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void addTodo(String title) {
    final todo = Todo(id: DateTime.now().toString(), title: title);
    state = state.copyWith(todos: [...state.todos, todo]);
  }
}

// Provider
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(ref.read(apiProvider));
});
```

### Using in Widgets
```dart
class TodoList extends ConsumerWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoProvider);

    if (state.isLoading) {
      return const CircularProgressIndicator();
    }

    if (state.error != null) {
      return Text('Error: ${state.error}');
    }

    return ListView.builder(
      itemCount: state.todos.length,
      itemBuilder: (context, index) {
        final todo = state.todos[index];
        return ListTile(
          title: Text(todo.title),
          onTap: () => ref.read(todoProvider.notifier).toggleTodo(todo.id),
        );
      },
    );
  }
}
```

## BLoC Pattern

### Cubit (Simpler BLoC)
```dart
// State
abstract class CounterState {}

class CounterInitial extends CounterState {}

class CounterValue extends CounterState {
  final int value;
  CounterValue(this.value);
}

// Cubit
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterInitial());

  void increment() {
    final current = state is CounterValue ? (state as CounterValue).value : 0;
    emit(CounterValue(current + 1));
  }
}

// Usage
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) {
    if (state is CounterValue) {
      return Text('Count: ${state.value}');
    }
    return const Text('Count: 0');
  },
)
```

### Full BLoC with Events
```dart
// Events
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  final AuthRepository _authRepo;

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepo.logout();
    emit(AuthInitial());
  }
}
```

## Provider (Simple Approach)

### ChangeNotifier
```dart
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  double get total => _items.fold(0, (sum, item) => sum + item.price);

  void add(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

// Provide
ChangeNotifierProvider(
  create: (_) => CartModel(),
  child: MyApp(),
)

// Consume
Consumer<CartModel>(
  builder: (context, cart, child) {
    return Text('Total: \$${cart.total}');
  },
)
```

## Best Practices

- **Riverpod**: Preferred for new projects - type-safe, testable, flexible
- **BLoC**: Good for complex, event-driven state with clear separation
- **Provider**: Simple cases, smaller apps

### General Guidelines
- Keep state immutable (use copyWith or freezed)
- Separate UI from business logic
- Test state management independently
- Use selectors to minimize rebuilds
- Avoid putting UI state in global state
