---
name: pinia-store
description: Pinia state management patterns for Vue 3 applications with TypeScript.
---

# Pinia State Management

Complete guide to Pinia, Vue 3's official state management library with full TypeScript support. Covers setup and options syntax for store definition, computed getters, async actions, store-to-store composition, storeToRefs for reactive destructuring, persistence with localStorage, and unit testing with createPinia. The modern replacement for Vuex that integrates seamlessly with Vue's Composition API and devtools.

## Store Definition

### Setup Syntax (Recommended)
```typescript
// stores/cart.ts
export const useCartStore = defineStore('cart', () => {
  // State
  const items = ref<CartItem[]>([])
  const loading = ref(false)

  // Getters (computed)
  const totalItems = computed(() =>
    items.value.reduce((sum, item) => sum + item.quantity, 0)
  )

  const totalPrice = computed(() =>
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  )

  // Actions
  async function addItem(product: Product) {
    const existing = items.value.find(i => i.id === product.id)
    if (existing) {
      existing.quantity++
    } else {
      items.value.push({ ...product, quantity: 1 })
    }
  }

  function removeItem(id: string) {
    const index = items.value.findIndex(i => i.id === id)
    if (index > -1) items.value.splice(index, 1)
  }

  async function checkout() {
    loading.value = true
    try {
      await api.checkout(items.value)
      items.value = []
    } finally {
      loading.value = false
    }
  }

  return {
    items,
    loading,
    totalItems,
    totalPrice,
    addItem,
    removeItem,
    checkout
  }
})
```

### Options Syntax
```typescript
export const useCounterStore = defineStore('counter', {
  state: () => ({
    count: 0
  }),
  getters: {
    doubleCount: (state) => state.count * 2
  },
  actions: {
    increment() {
      this.count++
    }
  }
})
```

## Store Composition

### Using Stores in Components
```vue
<script setup lang="ts">
import { storeToRefs } from 'pinia'

const cartStore = useCartStore()

// Destructure reactive state
const { items, totalPrice } = storeToRefs(cartStore)

// Actions don't need storeToRefs
const { addItem, removeItem } = cartStore
</script>
```

### Store-to-Store Communication
```typescript
// stores/checkout.ts
export const useCheckoutStore = defineStore('checkout', () => {
  const cartStore = useCartStore()
  const userStore = useUserStore()

  async function processOrder() {
    if (!userStore.isLoggedIn) {
      throw new Error('Must be logged in')
    }

    const order = await api.createOrder({
      items: cartStore.items,
      userId: userStore.user.id
    })

    cartStore.$reset()
    return order
  }

  return { processOrder }
})
```

## Persistence

### With pinia-plugin-persistedstate
```typescript
// stores/user.ts
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)

  return { user, token }
}, {
  persist: {
    storage: localStorage,
    paths: ['token']
  }
})
```

### Manual Persistence
```typescript
export const useSettingsStore = defineStore('settings', () => {
  const theme = ref('light')

  // Hydrate from localStorage
  if (typeof window !== 'undefined') {
    const saved = localStorage.getItem('settings-theme')
    if (saved) theme.value = saved
  }

  // Watch and persist
  watch(theme, (val) => {
    localStorage.setItem('settings-theme', val)
  })

  return { theme }
})
```

## Testing

```typescript
import { setActivePinia, createPinia } from 'pinia'
import { useCartStore } from './cart'

describe('Cart Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('adds items to cart', () => {
    const store = useCartStore()
    store.addItem({ id: '1', name: 'Product', price: 10 })

    expect(store.items).toHaveLength(1)
    expect(store.totalPrice).toBe(10)
  })
})
```

## Best Practices

- Use setup syntax for better TypeScript inference
- Keep stores focused on a single domain
- Use `storeToRefs()` when destructuring state/getters
- Reset stores with `$reset()` when needed
- Subscribe to changes with `$subscribe()` for side effects
