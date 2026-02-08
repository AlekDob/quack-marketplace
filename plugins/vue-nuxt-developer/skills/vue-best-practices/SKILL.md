---
name: vue-best-practices
description: Vue 3 Composition API best practices, reactive patterns, and component design guidelines.
---

# Vue 3 Best Practices

Expert guidance for building Vue 3 applications using the Composition API with TypeScript and modern reactive patterns. Covers script setup syntax, typed props and emits, ref vs reactive, computed properties, watchers, composable extraction (use* pattern), provide/inject for dependency injection, template best practices, and performance techniques like defineAsyncComponent and v-memo. The definitive style guide for writing clean, type-safe, and performant Vue components.

## Core Principles

### Composition API First
- Always use `<script setup>` syntax for cleaner, more concise components
- Prefer `ref()` for primitives, `reactive()` for objects
- Use `computed()` for derived state, avoid inline calculations in templates
- Extract reusable logic into composables (use* pattern)

### Component Design
```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

// Props with TypeScript
const props = defineProps<{
  title: string
  count?: number
}>()

// Emits with type safety
const emit = defineEmits<{
  update: [value: number]
  close: []
}>()

// Reactive state
const isOpen = ref(false)

// Computed properties
const displayTitle = computed(() => props.title.toUpperCase())
</script>
```

### Reactivity Best Practices
- Use `toRefs()` when destructuring reactive objects
- Prefer `shallowRef()` for large objects that don't need deep reactivity
- Use `watchEffect()` for automatic dependency tracking
- Use `watch()` when you need access to old/new values

### Template Guidelines
- Keep templates simple, move logic to computed properties
- Use `v-if` for conditional rendering, `v-show` for frequent toggles
- Always use `:key` with `v-for` loops
- Avoid `v-if` and `v-for` on the same element

### Performance
- Use `defineAsyncComponent()` for code splitting
- Implement `v-memo` for expensive list rendering
- Use `<KeepAlive>` for preserving component state
- Mark event handlers with `.passive` modifier when appropriate

### TypeScript Integration
- Define prop types using TypeScript generics
- Use `PropType<T>` for complex prop types
- Create typed composables with explicit return types
- Leverage Vue's built-in type inference

## Common Patterns

### Composables Structure
```typescript
// useCounter.ts
export function useCounter(initial = 0) {
  const count = ref(initial)
  const increment = () => count.value++
  const decrement = () => count.value--

  return { count, increment, decrement }
}
```

### Provide/Inject for Dependency Injection
```typescript
// Parent
const theme = ref('dark')
provide('theme', theme)

// Child
const theme = inject<Ref<string>>('theme')
```

### Form Handling
- Use `v-model` with custom components
- Implement form validation composables
- Handle async form submission with loading states
