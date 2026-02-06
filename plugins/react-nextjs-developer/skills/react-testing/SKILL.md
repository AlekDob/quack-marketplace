---
name: react-testing
description: Use this skill when writing tests for React components, testing hooks with renderHook, testing forms and user interactions, mocking API calls, or setting up Vitest with React Testing Library. Also use when deciding what to test, choosing query selectors, or writing async component tests.
---

# React Testing

Expert guidance for testing React applications with Vitest and React Testing Library.

## Testing Philosophy

- Test behavior, not implementation details
- Write tests from the user's perspective
- Avoid testing internal state or component internals
- Prefer integration tests over unit tests for components
- Unit test utility functions and hooks independently

## Setup

### Vitest Configuration
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    globals: true,
    css: true,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

### Setup File
```typescript
// src/test/setup.ts
import '@testing-library/jest-dom/vitest'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

afterEach(() => {
  cleanup()
})
```

## Component Testing

### Basic Rendering
```tsx
import { render, screen } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import { UserCard } from './UserCard'

describe('UserCard', () => {
  const mockUser = { id: '1', name: 'John', email: 'john@test.com' }

  it('renders user information', () => {
    render(<UserCard user={mockUser} />)

    expect(screen.getByText('John')).toBeInTheDocument()
    expect(screen.getByText('john@test.com')).toBeInTheDocument()
  })

  it('shows detailed view when variant is detailed', () => {
    render(<UserCard user={{ ...mockUser, bio: 'Developer' }} variant="detailed" />)

    expect(screen.getByText('Developer')).toBeInTheDocument()
  })
})
```

### User Interactions
```tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'
import { Counter } from './Counter'

describe('Counter', () => {
  it('increments count on button click', async () => {
    const user = userEvent.setup()
    render(<Counter initialCount={0} />)

    await user.click(screen.getByRole('button', { name: /increment/i }))

    expect(screen.getByText('Count: 1')).toBeInTheDocument()
  })

  it('calls onChange when value changes', async () => {
    const user = userEvent.setup()
    const onChange = vi.fn()
    render(<Counter initialCount={0} onChange={onChange} />)

    await user.click(screen.getByRole('button', { name: /increment/i }))

    expect(onChange).toHaveBeenCalledWith(1)
  })
})
```

### Form Testing
```tsx
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('submits form with valid data', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()
    render(<LoginForm onSubmit={onSubmit} />)

    await user.type(screen.getByLabelText(/email/i), 'john@test.com')
    await user.type(screen.getByLabelText(/password/i), 'password123')
    await user.click(screen.getByRole('button', { name: /sign in/i }))

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'john@test.com',
        password: 'password123',
      })
    })
  })

  it('shows validation error for empty email', async () => {
    const user = userEvent.setup()
    render(<LoginForm onSubmit={vi.fn()} />)

    await user.click(screen.getByRole('button', { name: /sign in/i }))

    expect(screen.getByText(/email is required/i)).toBeInTheDocument()
  })
})
```

## Hook Testing

```tsx
import { renderHook, act } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('initializes with given value', () => {
    const { result } = renderHook(() => useCounter(5))
    expect(result.current.count).toBe(5)
  })

  it('increments counter', () => {
    const { result } = renderHook(() => useCounter(0))

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })
})
```

## Async Testing

```tsx
import { render, screen, waitFor } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import { UserList } from './UserList'

// Mock the API module
vi.mock('@/api/users', () => ({
  fetchUsers: vi.fn(),
}))

import { fetchUsers } from '@/api/users'

describe('UserList', () => {
  it('renders users after loading', async () => {
    vi.mocked(fetchUsers).mockResolvedValue([
      { id: '1', name: 'Alice' },
      { id: '2', name: 'Bob' },
    ])

    render(<UserList />)

    expect(screen.getByText(/loading/i)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument()
      expect(screen.getByText('Bob')).toBeInTheDocument()
    })
  })

  it('shows error message on fetch failure', async () => {
    vi.mocked(fetchUsers).mockRejectedValue(new Error('Network error'))

    render(<UserList />)

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument()
    })
  })
})
```

## Testing Best Practices

### Queries Priority (from best to worst)
1. `getByRole` — accessible to everyone (button, heading, textbox)
2. `getByLabelText` — form fields
3. `getByPlaceholderText` — when no label
4. `getByText` — non-interactive elements
5. `getByTestId` — last resort

### What NOT to Test
- Implementation details (internal state, private methods)
- Third-party library internals
- CSS styling (use visual regression testing instead)
- Exact snapshot matching (brittle, hard to review)

### What TO Test
- User-visible behavior and outcomes
- Edge cases and error states
- Accessibility (roles, labels, keyboard navigation)
- Integration between components
- Critical business logic
