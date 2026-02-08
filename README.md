<p align="center">
  <img src="assets/hero-banner.png" alt="Quack Store" width="100%" />
</p>

<h1 align="center">Quack Store</h1>

<p align="center">
  <strong>Skills, Agents, and Rules for the Claude Agent SDK</strong><br>
  The official marketplace for <a href="https://quack.build">Quack</a> — install with one click from the built-in Store.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT" />
</p>

---

## What is the Quack Store?

The Quack Store is a curated collection of **skills**, **agent templates**, and **rules** that extend what your AI agents can do inside [Quack](https://quack.build).

Think of it like the App Store for your AI development environment:

- **Skills** teach your agents new capabilities — from React patterns to image generation
- **Agent Templates** spawn pre-configured specialists — a React developer, a project manager, a DevOps engineer
- **Rules** define behavioral guidelines that shape how agents work — structured workflows, knowledge management

Everything installs in one click from the built-in Quack Store. No manual configuration needed.

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

## What's Inside

The marketplace is constantly growing. Here are some examples of what you'll find:

### Agent Templates

Pre-configured AI specialists ready to join your team. Each comes with bundled skills and a tuned personality.

> **Agent Alex** — React/Next.js Developer
> Comes with React 19, Next.js 15, and Vitest skills. Writes strict TypeScript, styles with Tailwind, and follows modern Server Component patterns.

> **Agent Jack** — Project Manager
> Bundles the APATR-D workflow, Quack Brain, and Codebase Map. Plans sprints, evaluates feasibility, and coordinates quality across your team.

> **Agent Kelsey** — DevOps & Cloud Engineer
> Equipped with Cloudflare Workers, Turborepo monorepo, and GitHub Actions skills. Handles CI/CD pipelines, edge deployments, and infrastructure as code.

Other examples: Swift/iOS Developer, Python Backend, Vue/Nuxt, Angular, Flutter, Rust Systems, Product Manager, Marketing & Comms, Personal Assistant.

### Skills

Standalone capabilities you can assign to any agent. A few highlights:

> **Quack Brain** — File-based Second Brain with auto-learn. Your agents remember patterns, bug fixes, and decisions across sessions.

> **OpenAI Image Gen** — Generate images with GPT Image 1.5 or DALL-E 3. Supports transparent backgrounds, multiple sizes, and batch generation.

> **Learn from Web** — Point at any documentation URL and turn it into a reusable Claude skill, published to the marketplace.

Other examples: Codebase Map, Skill Creator, Idea Validator, Brand Guidelines, Discord Community Manager, Obsidian integration suite.

### Rules

Behavioral guidelines that shape agent workflows:

> **APATR-D** — Analyze, Plan, Act, Test, Review, Document. A structured methodology for quality and traceability in every task.

> **Use Codebase Map** — Instructs agents to read the auto-generated export map before exploratory searches, reducing tool calls by 60-80%.

Browse the full and up-to-date catalog directly in the Quack Store inside the app.

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

See the [Skill Creator](plugins/skill-creator) plugin for a meta-skill that guides you through the process.

### Plugin Types

**Skills-only** — Standalone capabilities (e.g., `openai-image-gen`)
```json
{
  "name": "my-skill",
  "version": "1.0.0",
  "description": "Short description for the store listing.",
  "longDescription": "Rich multi-paragraph description shown in the detail view.",
  "skills": ["skills/my-skill"],
  "agents": [],
  "rules": []
}
```

**Agent Template** — Pre-configured specialist with bundled skills (e.g., `react-nextjs-developer`)
```json
{
  "name": "my-agent",
  "version": "1.0.0",
  "description": "Short description.",
  "longDescription": "Detailed description of what this agent can do.",
  "skills": ["skills/skill-one", "skills/skill-two"],
  "agentTemplate": {
    "suggestedName": "Agent Name",
    "role": "Role Title",
    "communicationStyle": "technical",
    "suggestedColor": "#61DAFB",
    "skills": ["skill-one", "skill-two"]
  }
}
```

**Rules-only** — Behavioral guidelines (e.g., `apatr-d`)
```json
{
  "name": "my-rule",
  "version": "1.0.0",
  "description": "Short description.",
  "longDescription": "Detailed explanation of when and how this rule applies.",
  "skills": [],
  "agents": [],
  "rules": ["rules/my-rule.md"]
}
```

### SKILL.md Format

Each skill file uses YAML frontmatter with a proactive trigger description:

```markdown
---
name: my-skill
description: Use this skill when [specific trigger scenarios].
---

# My Skill

Content with patterns, examples, and best practices.
```

The `description` field is critical — it tells the agent when to invoke the skill proactively.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<p align="center">
  Built with Quack by <a href="https://github.com/AlekDob">Alek Dobrohotov</a>
</p>
