---
name: learn-from-web
description: This skill should be used when the user wants to learn a technology from its website or documentation URL and turn it into a reusable skill. Also use when the user says "learn this", "create a skill from this site", or provides a documentation URL to study. Inspects the website, extracts key knowledge, creates a skill using the skill-creator process, and publishes it to the Quack Marketplace.
---

# Learn from Web - Skill Generator

Turn any website or documentation URL into a reusable Claude skill, published to the Quack Marketplace.

## Workflow

### Phase 1: Inspect the Website

1. **Validate the URL**: Ensure the provided argument is a valid URL. If not, ask for a correct one.

2. **Fetch the main page**: Use `WebFetch` to load the URL and understand:
   - What technology/library/framework/tool does it document?
   - Current version
   - Available sections: docs, API reference, getting started guide

3. **Explore documentation structure**: Navigate 3-8 key pages using `WebFetch`, prioritizing:
   - Getting started / Quick start
   - Core concepts / Architecture
   - API reference with code examples
   - Best practices / Patterns
   - Common pitfalls / FAQ
   - Configuration / Setup
   - Migration guides or changelog (version-specific info)

4. **Build a mental model** of:
   - What the tool/library does
   - Core concepts and terminology
   - Most common use cases
   - Key API patterns with code examples
   - Common mistakes to avoid

### Phase 2: Create the Skill

Follow the **skill-creator** process:

1. **Skill name**: Use `kebab-case` based on the technology (e.g., `astro-framework`, `drizzle-orm`, `tanstack-query`).

2. **Initialize**: Run the init script:
   ```bash
   python3 <skill-creator-path>/scripts/init_skill.py <skill-name> --path <target-directory>
   ```

3. **Write SKILL.md** with:
   - YAML frontmatter: `name` and `description` (use "This skill should be used when..." trigger pattern)
   - Core concepts and architecture overview
   - 3-5 minimum code examples for common patterns
   - Best practices section
   - Common pitfalls / gotchas
   - Quick reference for key APIs

4. **Add references/** for extensive documentation:
   - `references/api-reference.md` for detailed API docs
   - `references/patterns.md` for advanced patterns
   - Keep SKILL.md lean (<5k words), move details to references

5. **Writing rules**:
   - Imperative/infinitive form (verb-first)
   - No second person
   - Real, working code examples from official docs
   - Specify version numbers
   - Focus on what a Claude instance needs to be effective

### Phase 3: Publish to Marketplace

1. **Create plugin structure** in the marketplace repo:
   ```
   quack-marketplace/plugins/<skill-name>/
   ├── .claude-plugin/
   │   └── plugin.json
   └── skills/
       └── <skill-name>/
           ├── SKILL.md
           └── references/  (if applicable)
   ```

2. **Write plugin.json** (skills-only bundle):
   ```json
   {
     "name": "<skill-name>",
     "version": "1.0.0",
     "description": "<one-sentence description>",
     "author": { "name": "Quack Team", "url": "https://github.com/AlekDob" },
     "repository": "https://github.com/AlekDob/quack-marketplace",
     "license": "MIT",
     "keywords": ["<relevant>", "<keywords>"],
     "skills": ["skills/<skill-name>"],
     "agents": [],
     "rules": []
   }
   ```

3. **Update marketplace.json**: Add entry to the plugins array.

4. **Commit and push** to marketplace repo with conventional commit format.

### Phase 4: Confirm

Report back with:
- Skill name created
- Source URL analyzed
- Key topics covered
- Marketplace status (published and pushed)
- How to use: skill is available for any agent in Quack

## Important Notes

- If the website requires authentication or blocks scraping, inform the user immediately
- For extremely large documentation (framework-level), focus on the most practical 80% and note what was skipped
- Always include version numbers to avoid outdated advice
- Prefer code examples from official docs over invented ones
- If a skill for this technology already exists in the marketplace, ask whether to update or create a new version

## Examples

```
/learn https://docs.astro.build
/learn https://orm.drizzle.team
/learn https://tanstack.com/query/latest
/learn https://tailwindcss.com/docs
/learn https://supabase.com/docs
```
