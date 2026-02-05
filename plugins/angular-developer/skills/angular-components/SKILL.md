---
name: angular-components
description: Modern Angular component patterns with standalone components, dependency injection, and lifecycle hooks.
---

# Angular Components

Best practices for building modern Angular components.

## Standalone Components

### Basic Standalone Component
```typescript
@Component({
  selector: 'app-greeting',
  standalone: true,
  imports: [CommonModule],
  template: `
    <h1>Hello, {{ name() }}!</h1>
    <p *ngIf="showMessage()">Welcome back!</p>
  `
})
export class GreetingComponent {
  name = input.required<string>();
  showMessage = input(false);
}
```

### Component with Services
```typescript
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule, UserCardComponent],
  providers: [UserService], // Component-level provider
  template: `
    @for (user of users(); track user.id) {
      <app-user-card [user]="user" />
    }
    @empty {
      <p>No users found</p>
    }
  `
})
export class UserListComponent {
  private userService = inject(UserService);
  users = toSignal(this.userService.getUsers(), { initialValue: [] });
}
```

## Control Flow

### Modern Control Flow Syntax
```html
<!-- Conditionals -->
@if (isLoggedIn()) {
  <app-dashboard />
} @else if (isLoading()) {
  <app-spinner />
} @else {
  <app-login />
}

<!-- Loops -->
@for (item of items(); track item.id; let i = $index, first = $first) {
  <div [class.first]="first">{{ i + 1 }}. {{ item.name }}</div>
} @empty {
  <p>No items available</p>
}

<!-- Switch -->
@switch (status()) {
  @case ('pending') { <span class="badge pending">Pending</span> }
  @case ('active') { <span class="badge active">Active</span> }
  @default { <span class="badge">Unknown</span> }
}
```

## Content Projection

### Single Slot
```typescript
@Component({
  selector: 'app-card',
  standalone: true,
  template: `
    <div class="card">
      <ng-content />
    </div>
  `
})
export class CardComponent {}

// Usage
<app-card>
  <h2>Card Title</h2>
  <p>Card content here</p>
</app-card>
```

### Named Slots
```typescript
@Component({
  selector: 'app-panel',
  standalone: true,
  template: `
    <header><ng-content select="[header]" /></header>
    <main><ng-content /></main>
    <footer><ng-content select="[footer]" /></footer>
  `
})
export class PanelComponent {}

// Usage
<app-panel>
  <h2 header>Panel Title</h2>
  <p>Main content</p>
  <button footer>Close</button>
</app-panel>
```

## Lifecycle Hooks

### Common Lifecycle Patterns
```typescript
@Component({
  selector: 'app-data-view',
  standalone: true,
  template: `...`
})
export class DataViewComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();

  ngOnInit() {
    // Initialize subscriptions
    this.dataService.getData()
      .pipe(takeUntil(this.destroy$))
      .subscribe(data => this.processData(data));
  }

  ngOnDestroy() {
    // Cleanup
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

### afterRender and afterNextRender
```typescript
@Component({...})
export class ChartComponent {
  constructor() {
    // Runs after every render
    afterRender(() => {
      this.updateChart();
    });

    // Runs once after first render
    afterNextRender(() => {
      this.initializeLibrary();
    });
  }
}
```

## Dependency Injection

### inject() Function
```typescript
@Component({...})
export class MyComponent {
  // Preferred: inject() function
  private http = inject(HttpClient);
  private router = inject(Router);
  private config = inject(APP_CONFIG);

  // Optional injection
  private logger = inject(LoggerService, { optional: true });
}
```

### Injection Tokens
```typescript
// Define token
export const API_URL = new InjectionToken<string>('API_URL');

// Provide in app config
export const appConfig: ApplicationConfig = {
  providers: [
    { provide: API_URL, useValue: 'https://api.example.com' }
  ]
};

// Inject
private apiUrl = inject(API_URL);
```

## Best Practices

- Always use standalone components for new code
- Prefer `inject()` over constructor injection
- Use new control flow syntax (@if, @for, @switch)
- Track items in @for loops for performance
- Use signals for component state
- Leverage content projection for flexible components
