---
name: nuxt-patterns
description: Nuxt 3 patterns for SSR, data fetching, routing, and server-side functionality.
---

# Nuxt 3 Patterns

Expert patterns for building Nuxt 3 applications with SSR and hybrid rendering.

## Directory Structure
```
app/
├── components/     # Auto-imported components
├── composables/    # Auto-imported composables
├── layouts/        # App layouts
├── middleware/     # Route middleware
├── pages/          # File-based routing
├── plugins/        # Vue plugins
├── server/         # Server routes & middleware
└── utils/          # Auto-imported utilities
```

## Data Fetching

### useAsyncData
```typescript
// For server-side data fetching with caching
const { data, pending, error, refresh } = await useAsyncData(
  'users',
  () => $fetch('/api/users'),
  {
    lazy: true,
    transform: (data) => data.users
  }
)
```

### useFetch
```typescript
// Convenience wrapper for API calls
const { data } = await useFetch('/api/posts', {
  query: { limit: 10 },
  pick: ['id', 'title']
})
```

### Server-Only Data
```typescript
// Data that should never reach the client
const secrets = await useAsyncData('secrets', () => {
  if (import.meta.server) {
    return getSecretData()
  }
  return null
})
```

## Routing

### Dynamic Routes
```
pages/
├── users/
│   ├── [id].vue          # /users/:id
│   └── [...slug].vue     # /users/* (catch-all)
└── [[optional]].vue      # Optional param
```

### Route Middleware
```typescript
// middleware/auth.ts
export default defineNuxtRouteMiddleware((to, from) => {
  const user = useUser()
  if (!user.value && to.path !== '/login') {
    return navigateTo('/login')
  }
})

// pages/dashboard.vue
definePageMeta({
  middleware: 'auth'
})
```

## State Management

### useState for SSR-Safe State
```typescript
// Shared state that survives SSR
const counter = useState('counter', () => 0)
```

### Pinia Integration
```typescript
// stores/user.ts
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const isLoggedIn = computed(() => !!user.value)

  async function login(credentials: Credentials) {
    user.value = await $fetch('/api/auth/login', {
      method: 'POST',
      body: credentials
    })
  }

  return { user, isLoggedIn, login }
})
```

## Server Routes

### API Endpoints
```typescript
// server/api/users.get.ts
export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  return await db.users.findMany({ limit: query.limit })
})

// server/api/users.post.ts
export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  return await db.users.create(body)
})
```

### Server Middleware
```typescript
// server/middleware/auth.ts
export default defineEventHandler((event) => {
  const token = getHeader(event, 'authorization')
  event.context.user = verifyToken(token)
})
```

## Rendering Modes

### Route-Level Rendering
```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  routeRules: {
    '/': { prerender: true },
    '/api/**': { cors: true },
    '/admin/**': { ssr: false },
    '/blog/**': { isr: 3600 }
  }
})
```

## Performance

- Use `<NuxtLink>` for client-side navigation with prefetching
- Implement `<ClientOnly>` for browser-only components
- Use `<LazyComponent>` prefix for code splitting
- Configure `experimental.payloadExtraction` for smaller payloads
