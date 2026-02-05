---
name: turborepo-monorepo
description: Turborepo patterns for monorepo management, caching, and pipeline optimization.
---

# Turborepo Monorepo

High-performance build system for monorepos.

## Project Structure

```
my-monorepo/
├── apps/
│   ├── web/                 # Next.js app
│   │   ├── package.json
│   │   └── ...
│   └── api/                 # Backend service
│       ├── package.json
│       └── ...
├── packages/
│   ├── ui/                  # Shared UI components
│   │   ├── package.json
│   │   └── src/
│   ├── config/              # Shared configs
│   │   ├── eslint/
│   │   └── typescript/
│   └── utils/               # Shared utilities
│       └── package.json
├── turbo.json
├── package.json
└── pnpm-workspace.yaml
```

## Configuration

### turbo.json
```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "lint": {
      "dependsOn": ["^lint"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"],
      "inputs": ["src/**/*.tsx", "src/**/*.ts", "test/**/*.ts"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "typecheck": {
      "dependsOn": ["^typecheck"]
    }
  }
}
```

### Root package.json
```json
{
  "name": "my-monorepo",
  "private": true,
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "typecheck": "turbo run typecheck",
    "format": "prettier --write \"**/*.{ts,tsx,md}\""
  },
  "devDependencies": {
    "turbo": "^2.0.0"
  },
  "packageManager": "pnpm@8.15.0"
}
```

### pnpm-workspace.yaml
```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

## Internal Packages

### packages/ui/package.json
```json
{
  "name": "@repo/ui",
  "version": "0.0.0",
  "private": true,
  "exports": {
    ".": "./src/index.ts",
    "./button": "./src/button.tsx",
    "./card": "./src/card.tsx"
  },
  "scripts": {
    "build": "tsup src/index.ts --format esm,cjs --dts",
    "lint": "eslint src/",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@repo/config": "workspace:*",
    "tsup": "^8.0.0",
    "typescript": "^5.3.0"
  },
  "peerDependencies": {
    "react": "^18.0.0"
  }
}
```

### Using Internal Packages
```json
{
  "name": "web",
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  }
}
```

## Pipeline Optimization

### Task Dependencies
```json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],  // Build deps first
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"],   // Same package build
      "outputs": []
    },
    "deploy": {
      "dependsOn": ["build", "test", "lint"],
      "outputs": []
    }
  }
}
```

### Selective Inputs
```json
{
  "pipeline": {
    "test": {
      "inputs": [
        "src/**/*.ts",
        "src/**/*.tsx",
        "tests/**/*.ts",
        "jest.config.js"
      ]
    }
  }
}
```

### Environment Variables
```json
{
  "pipeline": {
    "build": {
      "env": ["NODE_ENV", "API_URL"],
      "outputs": ["dist/**"]
    }
  },
  "globalEnv": ["CI", "VERCEL"]
}
```

## Remote Caching

### Vercel Remote Cache
```bash
# Login to Vercel
npx turbo login

# Link to Vercel project
npx turbo link
```

### Self-Hosted Cache
```bash
# Run with custom cache
turbo run build --api="http://localhost:3000" --token="xxx"
```

## CLI Commands

```bash
# Build all packages
turbo run build

# Build specific app
turbo run build --filter=web

# Build app and its dependencies
turbo run build --filter=web...

# Build only changed packages
turbo run build --filter=[origin/main]

# Dry run (show what would run)
turbo run build --dry-run

# Graph visualization
turbo run build --graph

# Run in parallel with concurrency limit
turbo run lint --concurrency=4
```

## Filtering

```bash
# By package name
turbo run build --filter=@repo/ui

# By directory
turbo run build --filter=./apps/*

# Changed since commit
turbo run build --filter=[HEAD^1]

# Changed in PR
turbo run build --filter=[origin/main]

# Exclude packages
turbo run build --filter=!@repo/docs
```

## Best Practices

- Use `workspace:*` for internal dependencies
- Define clear outputs for caching
- Use `dependsOn: ["^build"]` for transitive deps
- Keep shared configs in `packages/config`
- Use filtering in CI to run only affected tests
- Enable remote caching for faster CI
