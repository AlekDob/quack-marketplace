---
name: angular-signals
description: Angular Signals for reactive state management - the modern alternative to RxJS for component state.
---

# Angular Signals

Deep dive into Angular Signals, the modern reactive primitive that replaces BehaviorSubject for component state management. Covers writable signals, computed signals, effects, signal-based inputs and outputs, two-way binding with model(), the signal store pattern for services, and RxJS interoperability with toSignal/toObservable. The foundation for Angular's new reactivity model and fine-grained change detection.

## Core Concepts

### Creating Signals
```typescript
import { signal, computed, effect } from '@angular/core';

// Writable signal
const count = signal(0);

// Reading value
console.log(count()); // 0

// Setting value
count.set(5);

// Updating based on previous
count.update(prev => prev + 1);
```

### Computed Signals
```typescript
const firstName = signal('John');
const lastName = signal('Doe');

// Automatically tracks dependencies
const fullName = computed(() => `${firstName()} ${lastName()}`);

console.log(fullName()); // "John Doe"
```

### Effects for Side Effects
```typescript
// Runs when any tracked signal changes
effect(() => {
  console.log(`Count changed to: ${count()}`);
});
```

## Component Integration

### Signal-Based Components
```typescript
@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <div>
      <p>Count: {{ count() }}</p>
      <button (click)="increment()">+</button>
      <button (click)="decrement()">-</button>
    </div>
  `
})
export class CounterComponent {
  count = signal(0);

  increment() {
    this.count.update(c => c + 1);
  }

  decrement() {
    this.count.update(c => c - 1);
  }
}
```

### Input Signals
```typescript
@Component({
  selector: 'app-user-card',
  standalone: true,
  template: `<h2>{{ name() }}</h2>`
})
export class UserCardComponent {
  // Required input
  name = input.required<string>();

  // Optional input with default
  role = input<string>('guest');

  // Aliased input
  userId = input<number>(0, { alias: 'id' });
}
```

### Output with Signals
```typescript
@Component({
  selector: 'app-form',
  standalone: true,
  template: `
    <button (click)="handleSubmit()">Submit</button>
  `
})
export class FormComponent {
  // Output emitter
  submitted = output<FormData>();

  private formData = signal<FormData>({ name: '' });

  handleSubmit() {
    this.submitted.emit(this.formData());
  }
}
```

### Model for Two-Way Binding
```typescript
@Component({
  selector: 'app-toggle',
  standalone: true,
  template: `
    <input type="checkbox" [checked]="checked()" (change)="toggle()">
  `
})
export class ToggleComponent {
  checked = model(false);

  toggle() {
    this.checked.update(v => !v);
  }
}

// Usage: <app-toggle [(checked)]="isEnabled" />
```

## Advanced Patterns

### Signal Store Pattern
```typescript
@Injectable({ providedIn: 'root' })
export class TodoStore {
  private _todos = signal<Todo[]>([]);

  // Public readonly access
  todos = this._todos.asReadonly();

  // Computed selectors
  completedCount = computed(() =>
    this._todos().filter(t => t.completed).length
  );

  addTodo(text: string) {
    this._todos.update(todos => [...todos, { id: Date.now(), text, completed: false }]);
  }

  toggleTodo(id: number) {
    this._todos.update(todos =>
      todos.map(t => t.id === id ? { ...t, completed: !t.completed } : t)
    );
  }
}
```

### RxJS Interoperability
```typescript
import { toSignal, toObservable } from '@angular/core/rxjs-interop';

// Observable to Signal
const data = toSignal(this.http.get<Data>('/api/data'), {
  initialValue: null
});

// Signal to Observable
const count$ = toObservable(this.count);
```

## Best Practices

- Prefer signals over `BehaviorSubject` for component state
- Use `computed()` for derived state
- Keep signals immutable - use `update()` for mutations
- Use `input.required()` for mandatory component inputs
- Expose readonly signals from services with `asReadonly()`
