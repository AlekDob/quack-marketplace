---
name: angular-routing
description: Angular Router patterns for navigation, guards, resolvers, and lazy loading.
---

# Angular Routing

Complete routing patterns for Angular applications using functional guards, resolvers, and lazy loading with standalone components. Covers route configuration, nested child routes, programmatic navigation, withComponentInputBinding for cleaner param access, and withViewTransitions for animated page changes. Ideal for building scalable navigation architectures with proper authentication and data pre-fetching.

## Route Configuration

### Basic Routes with Standalone
```typescript
// app.routes.ts
export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'about', component: AboutComponent },
  { path: 'users/:id', component: UserDetailComponent },
  { path: '**', component: NotFoundComponent }
];

// main.ts
bootstrapApplication(AppComponent, {
  providers: [provideRouter(routes)]
});
```

### Lazy Loading
```typescript
export const routes: Routes = [
  {
    path: 'admin',
    loadComponent: () => import('./admin/admin.component')
      .then(m => m.AdminComponent)
  },
  {
    path: 'dashboard',
    loadChildren: () => import('./dashboard/routes')
      .then(m => m.DASHBOARD_ROUTES)
  }
];
```

## Route Guards

### Functional Guards
```typescript
// auth.guard.ts
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  return router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url }
  });
};

// Usage in routes
{
  path: 'dashboard',
  component: DashboardComponent,
  canActivate: [authGuard]
}
```

### Can Deactivate Guard
```typescript
export interface CanDeactivateComponent {
  canDeactivate: () => boolean | Observable<boolean>;
}

export const unsavedChangesGuard: CanDeactivateFn<CanDeactivateComponent> =
  (component) => {
    if (component.canDeactivate()) {
      return true;
    }
    return confirm('You have unsaved changes. Leave anyway?');
  };
```

## Route Resolvers

### Functional Resolver
```typescript
export const userResolver: ResolveFn<User> = (route) => {
  const userService = inject(UserService);
  const userId = route.paramMap.get('id')!;

  return userService.getUser(userId).pipe(
    catchError(() => {
      inject(Router).navigate(['/users']);
      return EMPTY;
    })
  );
};

// Route config
{
  path: 'users/:id',
  component: UserDetailComponent,
  resolve: { user: userResolver }
}

// Component access
export class UserDetailComponent {
  private route = inject(ActivatedRoute);
  user = toSignal(this.route.data.pipe(map(d => d['user'])));
}
```

## Router Features

### withComponentInputBinding
```typescript
// Enable in providers
provideRouter(routes, withComponentInputBinding())

// Component automatically receives route params as inputs
@Component({...})
export class UserDetailComponent {
  // Automatically bound from :id route param
  id = input.required<string>();
}
```

### withViewTransitions
```typescript
provideRouter(routes, withViewTransitions())
```

## Navigation

### Programmatic Navigation
```typescript
@Component({...})
export class NavComponent {
  private router = inject(Router);

  goToUser(id: string) {
    this.router.navigate(['/users', id], {
      queryParams: { tab: 'profile' },
      fragment: 'section1'
    });
  }

  goBack() {
    this.location.back();
  }
}
```

### RouterLink Directive
```html
<a routerLink="/home">Home</a>
<a [routerLink]="['/users', user.id]">{{ user.name }}</a>
<a routerLink="/search" [queryParams]="{ q: searchTerm }">Search</a>

<!-- Active link styling -->
<a routerLink="/dashboard"
   routerLinkActive="active"
   [routerLinkActiveOptions]="{ exact: true }">
  Dashboard
</a>
```

## Nested Routes

### Child Routes
```typescript
export const routes: Routes = [
  {
    path: 'admin',
    component: AdminLayoutComponent,
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: AdminDashboardComponent },
      { path: 'users', component: AdminUsersComponent },
      { path: 'settings', component: AdminSettingsComponent }
    ]
  }
];
```

### Layout Component
```typescript
@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [RouterOutlet, RouterLink],
  template: `
    <nav>
      <a routerLink="dashboard">Dashboard</a>
      <a routerLink="users">Users</a>
    </nav>
    <main>
      <router-outlet />
    </main>
  `
})
export class AdminLayoutComponent {}
```

## Best Practices

- Use functional guards and resolvers
- Enable `withComponentInputBinding()` for cleaner param access
- Lazy load feature modules for better performance
- Use `routerLinkActive` for navigation state
- Handle errors in resolvers to prevent broken states
