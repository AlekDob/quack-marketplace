---
name: quack-architecture
description: Quack app architecture patterns, multi-agent system, and core domain concepts for contributing to the project.
---

# Quack Architecture

Architecture guide for developers contributing to or extending the Quack desktop application.

## Core Concepts

Quack is a multi-agentic Tauri desktop app that combines:
- Integrated terminals (xterm.js)
- AI assistant powered by Claude Agent SDK
- File explorer and Git integration
- Voice recording and PIP windows
- Marketplace for plugins, skills, and agent bundles

### Domain Model
```
Projects -> Agents -> Sessions/Tasks
                   -> Droids (invisible workers)
```

- **Projects**: Root entities containing all context for a workspace
- **Agents**: Visible AI assistants in the sidebar — each has a personality, model, color, and skills
- **Droids**: Invisible worker agents defined in `.claude/agents/` — called by agents for specialized tasks
- **Sessions**: Conversation threads between user and agent
- **Tasks**: Work items on the Kanban board

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Desktop shell | Tauri 2.x (Rust) |
| Frontend | React 19, TypeScript 5.x, Vite |
| Terminal | xterm.js 5.x with addon-fit, addon-webgl |
| Editor | Monaco Editor |
| AI/SDK | Claude Agent SDK, Anthropic SDK |
| Testing | Vitest |
| Styling | CSS (no Tailwind in Quack — custom design system) |

## Project Structure

```
quack-app/
├── src/                     # React frontend
│   ├── components/          # UI components
│   │   ├── settings/        # Settings panel categories
│   │   ├── kanban/          # Kanban board
│   │   └── ...
│   ├── hooks/               # React hooks
│   ├── types/               # TypeScript type definitions
│   ├── utils/               # Utility functions
│   └── App.tsx              # Main application (single file orchestrator)
├── src-tauri/               # Rust backend
│   ├── src/
│   │   ├── lib.rs           # Tauri command registration
│   │   ├── hooks.rs         # Git hooks, Claude settings
│   │   ├── preferences.rs   # User preferences store
│   │   └── ...
│   ├── templates/           # Agent personality templates
│   │   └── agents/
│   └── capabilities/        # Tauri v2 permissions
├── docs/                    # Project documentation
├── .quack/                  # Quack Brain (project knowledge)
│   └── brain/
└── .claude/                 # Claude Code configuration
    ├── agents/              # Droid definitions
    ├── skills/              # Installed skills
    └── plugins/             # Installed marketplace plugins
```

## Agent System

### Agent vs Droid

| Property | Agent | Droid |
|----------|-------|-------|
| Visibility | Sidebar (user-facing) | Invisible (worker) |
| Location | Runtime (created by user) | `.claude/agents/*.md` |
| Personality | Rich (name, avatar, color) | Minimal (just instructions) |
| Interaction | Direct chat with user | Called by agents/system |
| Skills | Configurable via UI | Defined in markdown |

### Agent Configuration
Agents are created through the UI or installed from the marketplace. Each has:
- **Name, avatar, color** — visual identity
- **Role** — what they specialize in
- **Model** — which Claude model to use (opus, sonnet, haiku)
- **Skills** — injected knowledge/capabilities
- **Communication style** — tone of responses

### Marketplace Integration
Plugins from the marketplace install to:
- Skills: `~/.claude/skills/{name}/SKILL.md`
- Rules: project or global `.claude/rules/`
- Agent templates: define suggested agent configurations

## Key Patterns

### Single-File App Orchestrator
`App.tsx` is the main orchestrator — it manages all top-level state, bootstrap sequence, and component composition. This is intentionally a large file that coordinates the entire application.

### Bootstrap Sequence
```
App mounts → Tauri available check → Load preferences → Load projects
→ Load agents → Load terminals → booting=false → Splash fade-out
```

Critical: `setBooting(false)` must only be called from the main bootstrap, after all data is loaded. Do not call it from individual loaders.

### IPC Pattern (Frontend to Rust)
```typescript
// Always use invoke with typed generics
const result = await invoke<ReturnType>('command_name', { param1, param2 })
```

### Settings Pattern
Settings are organized in categories (`ClaudeCodeSettings`, `GeneralSettings`, etc.) with:
- Rust commands to read/write preferences
- React components with optimistic updates and rollback
- IOSSwitch toggles for boolean settings

### CSS Design System
Quack uses custom CSS (not Tailwind) with:
- Glassmorphism (`backdrop-blur`)
- Dark-first color scheme
- CSS custom properties for theming
- No emojis in UI text

## Development Guidelines

1. **Read before writing** — Always check existing patterns before adding new ones
2. **Functions < 20 lines** — Extract when complexity grows
3. **Files < 300 lines** — Split by domain, not by tech type
4. **TypeScript strict** — No `any`, explicit types at boundaries
5. **Test with Vitest** — Test new features with complex logic
6. **English in code** — Italian only in user-facing communication
7. **No emojis in UI** — Keep the interface clean and professional

## Common Tasks

### Adding a New Tauri Command
1. Define the command in the appropriate Rust file
2. Register it in `lib.rs` via `generate_handler!`
3. Call from React with `invoke<T>('command_name', args)`
4. Add permissions in capability files if needed

### Adding a New Settings Section
1. Create a new component in `src/components/settings/categories/`
2. Add the Rust read/write commands in `preferences.rs` or relevant file
3. Register commands in `lib.rs`
4. Use the existing `SettingsRow` + `IOSSwitch` pattern

### Adding a New Sidebar Section
1. Add the section in `SidePanelAccordion.tsx`
2. Define the color in `CATEGORY_COLORS`
3. Add the icon in the `icons` object
4. Include the section ID in `sectionIds` array
