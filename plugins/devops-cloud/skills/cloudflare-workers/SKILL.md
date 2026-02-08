---
name: cloudflare-workers
description: Cloudflare Workers patterns for edge computing, KV storage, and serverless APIs.
---

# Cloudflare Workers

Production-ready patterns for building serverless APIs and edge applications with Cloudflare Workers. Covers fetch handlers, KV storage for key-value data, D1 for relational databases, R2 for object storage, Durable Objects for stateful coordination, scheduled cron workers, and wrangler configuration. Perfect for deploying low-latency APIs at the edge with minimal cold starts.

## Project Setup

```bash
# Create new project
npm create cloudflare@latest my-worker

# Or with Wrangler
npx wrangler init my-worker
```

### wrangler.toml Configuration
```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
ENVIRONMENT = "production"

[[kv_namespaces]]
binding = "MY_KV"
id = "xxx"

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxx"

[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"
```

## Basic Worker

### Fetch Handler
```typescript
export interface Env {
  MY_KV: KVNamespace;
  DB: D1Database;
  BUCKET: R2Bucket;
  API_KEY: string;
}

export default {
  async fetch(
    request: Request,
    env: Env,
    ctx: ExecutionContext
  ): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/api/health") {
      return new Response(JSON.stringify({ status: "ok" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    if (url.pathname.startsWith("/api/")) {
      return handleApiRequest(request, env, ctx);
    }

    return new Response("Not Found", { status: 404 });
  },
};
```

### Request Handling
```typescript
async function handleApiRequest(
  request: Request,
  env: Env,
  ctx: ExecutionContext
): Promise<Response> {
  const url = new URL(request.url);

  // CORS headers
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
  };

  if (request.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Route handling
    if (request.method === "GET" && url.pathname === "/api/users") {
      const users = await getUsers(env);
      return Response.json(users, { headers: corsHeaders });
    }

    if (request.method === "POST" && url.pathname === "/api/users") {
      const body = await request.json();
      const user = await createUser(env, body);
      return Response.json(user, {
        status: 201,
        headers: corsHeaders,
      });
    }

    return new Response("Not Found", { status: 404, headers: corsHeaders });
  } catch (error) {
    console.error(error);
    return Response.json(
      { error: "Internal Server Error" },
      { status: 500, headers: corsHeaders }
    );
  }
}
```

## KV Storage

```typescript
// Store data
await env.MY_KV.put("user:123", JSON.stringify({ name: "Alice" }));

// With expiration (TTL in seconds)
await env.MY_KV.put("session:abc", token, { expirationTtl: 3600 });

// Retrieve data
const data = await env.MY_KV.get("user:123", "json");

// List keys
const keys = await env.MY_KV.list({ prefix: "user:" });

// Delete
await env.MY_KV.delete("user:123");
```

## D1 Database

```typescript
// Query
const { results } = await env.DB.prepare(
  "SELECT * FROM users WHERE id = ?"
)
  .bind(userId)
  .all();

// Insert
const { success, meta } = await env.DB.prepare(
  "INSERT INTO users (name, email) VALUES (?, ?)"
)
  .bind(name, email)
  .run();

// Batch operations
const statements = users.map((user) =>
  env.DB.prepare("INSERT INTO users (name) VALUES (?)").bind(user.name)
);
await env.DB.batch(statements);
```

## R2 Object Storage

```typescript
// Upload
await env.BUCKET.put("images/photo.jpg", imageData, {
  httpMetadata: {
    contentType: "image/jpeg",
  },
});

// Download
const object = await env.BUCKET.get("images/photo.jpg");
if (object) {
  return new Response(object.body, {
    headers: {
      "Content-Type": object.httpMetadata?.contentType ?? "application/octet-stream",
    },
  });
}

// List objects
const listed = await env.BUCKET.list({ prefix: "images/" });

// Delete
await env.BUCKET.delete("images/photo.jpg");
```

## Durable Objects

```typescript
// durable-object.ts
export class Counter {
  private state: DurableObjectState;
  private value: number = 0;

  constructor(state: DurableObjectState) {
    this.state = state;
  }

  async fetch(request: Request): Promise<Response> {
    // Load persisted state
    this.value = (await this.state.storage.get("value")) || 0;

    if (request.method === "POST") {
      this.value++;
      await this.state.storage.put("value", this.value);
    }

    return Response.json({ value: this.value });
  }
}

// Usage in worker
const id = env.COUNTER.idFromName("global");
const stub = env.COUNTER.get(id);
return stub.fetch(request);
```

## Scheduled Workers (Cron)

```typescript
export default {
  async scheduled(
    event: ScheduledEvent,
    env: Env,
    ctx: ExecutionContext
  ): Promise<void> {
    ctx.waitUntil(performCleanup(env));
  },
};
```

```toml
# wrangler.toml
[triggers]
crons = ["0 * * * *"]  # Every hour
```

## Best Practices

- Use `ctx.waitUntil()` for non-blocking background tasks
- Cache responses at the edge with Cache API
- Use KV for read-heavy, D1 for relational data
- Keep cold starts minimal with lazy imports
- Use environment-specific configs in wrangler.toml
