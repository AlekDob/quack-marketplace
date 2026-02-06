---
name: react-best-practices
description: Use this skill when building React components, managing state with hooks, optimizing rendering performance, writing custom hooks, or structuring React 19 applications with TypeScript and Tailwind CSS. Also use when reviewing React code for best practices, fixing re-render issues, or designing component APIs.
---

# React Best Practices

Expert guidance for building React 19 applications with TypeScript.

## Core Principles

### Component Design
- Prefer functional components with TypeScript interfaces for props
- Use composition over inheritance — build complex UIs from small, focused components
- Keep components under 150 lines; extract sub-components when complexity grows
- Co-locate related files: component, styles, tests, types in the same directory

```tsx
interface UserCardProps {
  user: User
  onSelect: (id: string) => void
  variant?: 'compact' | 'detailed'
}

function UserCard({ user, onSelect, variant = 'compact' }: UserCardProps) {
  return (
    <article className="user-card" data-variant={variant}>
      <h3>{user.name}</h3>
      {variant === 'detailed' && <p>{user.bio}</p>}
      <button onClick={() => onSelect(user.id)}>Select</button>
    </article>
  )
}
```

### Hooks Patterns
- Custom hooks should start with `use` and encapsulate reusable logic
- Keep hooks focused — one concern per hook
- Use `useCallback` only when passing callbacks to memoized children
- Use `useMemo` only for expensive computations, not as a default

```tsx
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])

  return debounced
}
```

### State Management
- Start with `useState` for local state
- Use `useReducer` for complex state with multiple sub-values
- Lift state up only when needed — avoid premature state hoisting
- Use context for truly global state (theme, auth, locale)
- Consider external stores (Zustand, Jotai) for complex cross-component state

```tsx
// useReducer for complex state
type Action =
  | { type: 'add'; item: Item }
  | { type: 'remove'; id: string }
  | { type: 'toggle'; id: string }

function cartReducer(state: CartState, action: Action): CartState {
  switch (action.type) {
    case 'add':
      return { ...state, items: [...state.items, action.item] }
    case 'remove':
      return { ...state, items: state.items.filter(i => i.id !== action.id) }
    case 'toggle':
      return {
        ...state,
        items: state.items.map(i =>
          i.id === action.id ? { ...i, selected: !i.selected } : i
        ),
      }
  }
}
```

## Performance Optimization

### Rendering
- Use `React.memo()` only for components that re-render often with same props
- Avoid creating objects/arrays inline in JSX — extract to constants or useMemo
- Use `key` prop correctly — stable, unique identifiers, never array index for dynamic lists
- Split heavy components with `React.lazy()` and `<Suspense>`

### Data Fetching
- Use Suspense-compatible data fetching (useSuspenseQuery, React.use())
- Implement optimistic updates for better perceived performance
- Cache responses and deduplicate requests
- Show skeleton UIs during loading, not spinners

### Bundle Size
- Dynamic imports for route-level code splitting
- Tree-shake by using named exports
- Analyze bundle with `@next/bundle-analyzer` or `rollup-plugin-visualizer`
- Lazy load heavy libraries (charts, editors, maps)

## TypeScript Integration

### Strict Patterns
- Enable `strict: true` in tsconfig — no exceptions
- Never use `any` — use `unknown` and narrow with type guards
- Define explicit return types for complex functions
- Use discriminated unions for component variants

```tsx
// Discriminated union for polymorphic components
type ButtonProps =
  | { variant: 'link'; href: string; onClick?: never }
  | { variant: 'button'; onClick: () => void; href?: never }
  | { variant: 'submit'; onClick?: never; href?: never }

function Button(props: ButtonProps) {
  switch (props.variant) {
    case 'link':
      return <a href={props.href}>Link</a>
    case 'button':
      return <button onClick={props.onClick}>Click</button>
    case 'submit':
      return <button type="submit">Submit</button>
  }
}
```

### Event Handling
```tsx
// Typed event handlers
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  setValue(e.target.value)
}

const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault()
  // submit logic
}
```

## Tailwind CSS Patterns

### Organization
- Use Tailwind utility classes directly in JSX
- Extract repeated patterns into components, not CSS classes
- Use `cn()` utility (clsx + tailwind-merge) for conditional classes
- Define design tokens via `tailwind.config.ts` — colors, spacing, fonts

```tsx
import { cn } from '@/lib/utils'

function Badge({ variant, children }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full px-2 py-1 text-xs font-medium',
        variant === 'success' && 'bg-green-100 text-green-800',
        variant === 'error' && 'bg-red-100 text-red-800',
        variant === 'warning' && 'bg-yellow-100 text-yellow-800'
      )}
    >
      {children}
    </span>
  )
}
```

## Error Handling

- Use Error Boundaries for graceful failure recovery
- Provide meaningful fallback UIs, not blank screens
- Log errors to monitoring service in production
- Handle async errors in useEffect cleanup

```tsx
function ErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
  return (
    <div role="alert">
      <p>Something went wrong</p>
      <pre>{error.message}</pre>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  )
}
```

## Accessibility

- Use semantic HTML elements (button, nav, main, article)
- Add aria-labels for icon-only buttons
- Ensure keyboard navigation works (focus management, tab order)
- Test with screen readers and axe-core
- Maintain color contrast ratios (WCAG AA minimum)
