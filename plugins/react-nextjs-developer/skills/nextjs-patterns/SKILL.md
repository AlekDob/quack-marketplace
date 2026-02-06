---
name: nextjs-patterns
description: Next.js 15 App Router patterns, Server Components, Server Actions, and data fetching strategies.
---

# Next.js Patterns

Expert guidance for building Next.js 15 applications with App Router.

## App Router Architecture

### File Conventions
```
app/
├── layout.tsx          # Root layout (wraps all pages)
├── page.tsx            # Home page
├── loading.tsx         # Loading UI (Suspense boundary)
├── error.tsx           # Error boundary
├── not-found.tsx       # 404 page
├── (auth)/             # Route group (no URL segment)
│   ├── login/page.tsx
│   └── register/page.tsx
├── dashboard/
│   ├── layout.tsx      # Nested layout
│   ├── page.tsx
│   └── settings/
│       └── page.tsx
└── api/
    └── users/
        └── route.ts    # API route handler
```

### Server vs Client Components
- **Default to Server Components** — they run on the server, reduce bundle size
- Add `'use client'` only when you need: event handlers, useState, useEffect, browser APIs
- Push `'use client'` boundaries as deep as possible in the component tree
- Server Components can import Client Components, not vice versa

```tsx
// Server Component (default) - can fetch data directly
async function UserProfile({ userId }: { userId: string }) {
  const user = await getUser(userId) // Direct DB/API call
  return (
    <div>
      <h1>{user.name}</h1>
      <UserActions user={user} /> {/* Client Component */}
    </div>
  )
}

// Client Component - handles interactivity
'use client'
function UserActions({ user }: { user: User }) {
  const [isEditing, setIsEditing] = useState(false)
  return <button onClick={() => setIsEditing(true)}>Edit</button>
}
```

## Data Fetching

### Server Components
- Fetch data directly in Server Components using `async/await`
- Use `fetch()` with caching options or direct database queries
- Parallel data fetching with `Promise.all()` for independent requests

```tsx
async function Dashboard() {
  // Parallel fetching
  const [stats, recentOrders, notifications] = await Promise.all([
    getStats(),
    getRecentOrders(),
    getNotifications(),
  ])

  return (
    <div>
      <StatsOverview stats={stats} />
      <OrderList orders={recentOrders} />
      <NotificationBell count={notifications.unread} />
    </div>
  )
}
```

### Streaming with Suspense
```tsx
import { Suspense } from 'react'

async function Page() {
  return (
    <div>
      <h1>Dashboard</h1>
      {/* Fast data loads first */}
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>
      {/* Slow data streams in */}
      <Suspense fallback={<ChartSkeleton />}>
        <AnalyticsChart />
      </Suspense>
    </div>
  )
}
```

## Server Actions

### Form Handling
```tsx
// actions.ts
'use server'

import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  await db.post.create({ data: { title, content } })
  revalidatePath('/posts')
}
```

```tsx
// page.tsx - Server Component with form
import { createPost } from './actions'

function NewPostPage() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  )
}
```

### With useActionState
```tsx
'use client'

import { useActionState } from 'react'
import { createPost } from './actions'

function NewPostForm() {
  const [state, formAction, isPending] = useActionState(createPost, null)

  return (
    <form action={formAction}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Post'}
      </button>
      {state?.error && <p className="text-red-500">{state.error}</p>}
    </form>
  )
}
```

## Routing Patterns

### Dynamic Routes
```tsx
// app/posts/[slug]/page.tsx
interface PageProps {
  params: Promise<{ slug: string }>
}

export default async function PostPage({ params }: PageProps) {
  const { slug } = await params
  const post = await getPostBySlug(slug)
  if (!post) notFound()
  return <article>{post.content}</article>
}

// Generate static paths
export async function generateStaticParams() {
  const posts = await getAllPosts()
  return posts.map((post) => ({ slug: post.slug }))
}
```

### Middleware
```tsx
// middleware.ts (root level)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const token = request.cookies.get('session')

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*'],
}
```

## API Routes

```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams
  const page = parseInt(searchParams.get('page') ?? '1')

  const users = await getUsers({ page, limit: 20 })
  return NextResponse.json(users)
}

export async function POST(request: NextRequest) {
  const body = await request.json()
  const user = await createUser(body)
  return NextResponse.json(user, { status: 201 })
}
```

## Metadata & SEO

```tsx
import type { Metadata } from 'next'

// Static metadata
export const metadata: Metadata = {
  title: 'My App',
  description: 'A description of my app',
  openGraph: {
    title: 'My App',
    description: 'A description of my app',
    images: ['/og-image.png'],
  },
}

// Dynamic metadata
export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params
  const post = await getPostBySlug(slug)
  return {
    title: post.title,
    description: post.excerpt,
  }
}
```

## Performance

- Use `next/image` for automatic optimization, lazy loading, responsive sizing
- Use `next/font` for zero-layout-shift font loading
- Implement route-level code splitting (automatic with App Router)
- Use `loading.tsx` for streaming SSR with instant loading states
- Cache aggressively with `revalidate` options
- Use `next/dynamic` for client-only components
