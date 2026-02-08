<p align="center">
  <img src="assets/hero-banner.png" alt="Quack Store" width="100%" />
</p>

<h1 align="center">Quack Store</h1>

<p align="center">
  <strong>Skills, Agents, and Rules for the Claude Agent SDK</strong><br>
  The official marketplace for <a href="https://quack.build">Quack</a> — install with one click from the built-in Store.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/plugins-22-00D9FF?style=flat-square" alt="22 plugins" />
  <img src="https://img.shields.io/badge/skills-33-FF6B35?style=flat-square" alt="33 skills" />
  <img src="https://img.shields.io/badge/agents-12-F7931E?style=flat-square" alt="12 agents" />
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT" />
</p>

---

## What is the Quack Store?

The Quack Store is a curated collection of **skills**, **agent templates**, and **rules** that extend what your AI agents can do inside [Quack](https://quack.build).

Think of it like the App Store for your AI development environment:

- **Skills** teach your agents new capabilities (React patterns, testing strategies, image generation)
- **Agent Templates** spawn pre-configured specialists (a React developer, a project manager, a DevOps engineer)
- **Rules** define behavioral guidelines that shape how agents work (structured workflows, knowledge management)

Everything installs in one click from the built-in Quack Store — no manual configuration needed.

---

## Browsing & Installing

Open the **Quack Store** from the sidebar in Quack. Browse by category, search by name, or explore featured items.

Each item shows:
- **Name and author** with version number
- **Verified badge** for official Quack Team plugins
- **Get / Installed** status at a glance
- **Detailed description** when you click for more info

Install globally (available to all projects) or per-project. Remove anytime.

---

## Available Plugins

### Agent Templates

Pre-configured AI specialists ready to join your team.

| Agent | Role | Skills Included |
|-------|------|-----------------|
| **Agent Alex** | React/Next.js Developer | React 19, Next.js 15, Vitest |
| **Agent Evan** | Vue/Nuxt Developer | Vue 3, Nuxt 3, Pinia |
| **Agent Misko** | Angular Developer | Signals, Components, Routing |
| **Agent Tim** | Flutter Developer | Widgets, State, Navigation |
| **Agent Guido** | Python Backend Developer | Async, Testing, FastAPI |
| **Agent Graydon** | Rust Systems Developer | Async, Memory, Error Handling |
| **Agent Swift** | Swift/iOS Developer | SwiftUI, Concurrency, HIG |
| **Agent Kelsey** | DevOps & Cloud Engineer | Cloudflare, Turborepo, GitHub Actions |
| **Agent Jack** | Project Manager | Planning, Feasibility, Quality |
| **Agent Sophie** | Product Manager | UX, Prioritization, Market Fit |
| **Agent Fredric** | Marketing & Comms | Brand Voice, Content, Community |
| **Agent Roberta** | Personal Assistant | Research, Drafting, Organizing |

### Skills

Standalone capabilities you can assign to any agent.

| Skill | What It Does |
|-------|-------------|
| **Quack Brain** | File-based Second Brain with auto-learn and knowledge management |
| **Codebase Map** | Auto-generated export index — reduces search calls by 60-80% |
| **OpenAI Image Gen** | Generate images with GPT Image API (gpt-image-1.5, DALL-E 3) |
| **Learn from Web** | Turn any documentation URL into a reusable skill |
| **Skill Creator** | Meta-skill for building and packaging new skills |
| **Idea Validator** | Brutally honest app idea validation before building |
| **Brand Guidelines** | Quack's design system with colors, typography, components |
| **Discord Community** | Server management, engagement strategies, moderation |
| **Obsidian Markdown** | Create and edit notes with proper Obsidian formatting |
| **Obsidian Canvas** | Generate visual canvas files mapping concept relationships |
| **Obsidian Bases** | Work with structured data and database-like views |
| **Human Test Plan** | Generate manual QA test plans after feature implementation |

### Rules

Behavioral guidelines that shape agent workflows.

| Rule | Purpose |
|------|---------|
| **APATR-D** | Analyze-Plan-Act-Test-Review-Document methodology |
| **Use Codebase Map** | Read the codebase map before exploratory searches |
| **Use Quack Brain** | Leverage the Second Brain for context and memory |

---

## For Developers

### Repository Structure

```
quack-marketplace/
  .claude-plugin/
    marketplace.json        # Central plugin index
  plugins/
    {plugin-name}/
      .claude-plugin/
        plugin.json         # Plugin metadata
      skills/               # Skill definitions (SKILL.md)
      agents/               # Agent personality files
      rules/                # Rule definitions
```

### Creating a Plugin

1. Create a directory under `plugins/` with your plugin name
2. Add `.claude-plugin/plugin.json` with metadata
3. Add your skills, agents, or rules as markdown files
4. Register in `.claude-plugin/marketplace.json`

See the [Skill Creator](plugins/skill-creator) plugin for a meta-skill that guides you through creating new skills with proper structure.

### Plugin Types

**Skills-only** — Standalone capabilities (e.g., `openai-image-gen`)
```json
{
  "name": "my-skill",
  "skills": ["skills/my-skill"],
  "agents": [],
  "rules": []
}
```

**Agent Template** — Pre-configured specialist with bundled skills (e.g., `react-nextjs-developer`)
```json
{
  "name": "my-agent",
  "skills": ["skills/skill-one", "skills/skill-two"],
  "agentTemplate": {
    "suggestedName": "Agent Name",
    "role": "Role Title",
    "skills": ["skill-one", "skill-two"]
  }
}
```

**Rules-only** — Behavioral guidelines (e.g., `apatr-d`)
```json
{
  "name": "my-rule",
  "skills": [],
  "agents": [],
  "rules": ["rules/my-rule.md"]
}
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  Built with Quack by <a href="https://github.com/AlekDob">Alek Dobrohotov</a>
</p>
