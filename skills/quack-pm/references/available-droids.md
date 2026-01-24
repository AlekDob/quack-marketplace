# Available Droids Reference

Droids are specialized AI subagents that can be invoked via the Task tool. They live in `.claude/agents/` folders (project or global).

## Project Droids

These droids are defined in the project's `.claude/agents/` folder and are optimized for that project's tech stack.

### frontend-developer

**Purpose:** Frontend development specialist for React applications.

**Use for:**
- React component creation
- UI/UX implementation
- State management (Redux, Zustand, Context)
- Responsive design with Tailwind
- Performance optimization
- Accessibility (WCAG compliance)

**Invocation:**
```javascript
Task({
  subagent_type: "frontend-developer",
  prompt: "Create a responsive card component with hover effects"
})
```

---

### data-engineer

**Purpose:** Backend and data pipeline specialist.

**Use for:**
- Rust backend development
- API design and implementation
- Database schema design
- ETL/ELT pipelines
- Data transformation
- Supabase integration

---

### test-engineer

**Purpose:** Test automation and QA specialist.

**Use for:**
- Vitest unit tests
- Integration tests
- E2E test scenarios
- Coverage analysis
- Test strategy planning
- CI/CD testing

**Invocation:**
```javascript
Task({
  subagent_type: "test-engineer",
  prompt: "Write comprehensive tests for the AuthService module"
})
```

---

### code-reviewer

**Purpose:** Code quality and security reviewer.

**Use for:**
- Pull request reviews
- Security vulnerability detection
- Performance analysis
- Best practices enforcement
- Refactoring suggestions

---

### documentation-writer-expert

**Purpose:** Technical documentation specialist.

**Use for:**
- API documentation
- Architecture docs
- README files
- Code comments
- User guides

---

### quack-docs-writer

**Purpose:** Quack-specific user documentation.

**Use for:**
- User guides in docs/guide/
- Feature documentation
- In-app help content

---

### git-flow-manager

**Purpose:** Git Flow workflow specialist.

**Use for:**
- Feature branch creation
- Release management
- Hotfix handling
- Branch merging
- PR creation

**Invocation:**
```javascript
Task({
  subagent_type: "git-flow-manager",
  prompt: "Create a release branch for version 1.5.0"
})
```

---

### code-explorer

**Purpose:** Codebase navigation and analysis.

**Use for:**
- Understanding code structure
- Finding implementations
- Tracing dependencies
- Architecture discovery

---

### carmelo-prompt-engineer

**Purpose:** Prompt optimization specialist.

**Use for:**
- Improving vague prompts
- Structuring AI requests
- Adding missing context
- Clarifying requirements

---

## Global Droids

These droids are defined in `~/.claude/agents/` and available across all projects.

### second-brain-manager

**Purpose:** MCP Memory and Obsidian vault management.

**Use for:**
- Creating daily journal entries
- Technical note documentation
- Knowledge organization
- Memory entity creation
- Cross-linking notes

**Special Features:**
- Manages Obsidian Vault at `/Users/alekdob/Documents/Obsidian Vault/`
- Uses `#wiki` tags for technical notes
- Creates bidirectional links

---

### git-context-manager

**Purpose:** Git operations and context file management.

**Use for:**
- Committing changes
- Pushing to repository
- Updating session context files
- Managing `.claude/context/` folder

---

## Droid Selection Guide

### By Task Type

| I need to... | Use this droid |
|--------------|----------------|
| Build a UI component | frontend-developer |
| Create an API endpoint | data-engineer |
| Write tests | test-engineer |
| Review my code | code-reviewer |
| Write documentation | documentation-writer-expert |
| Create Git branches | git-flow-manager |
| Understand the codebase | code-explorer |
| Save to knowledge base | second-brain-manager |
| Commit my changes | git-context-manager |
| Improve a prompt | carmelo-prompt-engineer |

### By Technology

| Technology | Droid |
|------------|-------|
| React/TypeScript | frontend-developer |
| Rust | data-engineer |
| Vitest | test-engineer |
| Git Flow | git-flow-manager |
| Supabase | data-engineer |
| MCP Memory | second-brain-manager |
| Obsidian | second-brain-manager |

---

## Invoking Droids

### Via Task Tool

```javascript
Task({
  subagent_type: "droid-name",
  prompt: "Detailed description of what to do",
  model: "sonnet"  // Optional: sonnet, opus, haiku
})
```

### Via /background Command

```bash
/background @frontend-developer Create a responsive header component
/background @test-engineer Write tests for utils/formatDate.ts
```

### Parallel Droid Execution

Launch multiple droids simultaneously:

```javascript
// Both run in parallel
Task({ subagent_type: "frontend-developer", prompt: "Build the UI" })
Task({ subagent_type: "test-engineer", prompt: "Write the tests" })
```

---

## Creating Custom Droids

Droids are markdown files with YAML frontmatter:

```markdown
---
name: my-custom-droid
description: What this droid does and when to use it
tools: Read, Write, Edit, Bash
model: sonnet
---

You are a specialized agent for...

## Focus Areas
- Area 1
- Area 2

## Approach
1. Step 1
2. Step 2

## Output
- Expected output format
```

Save to:
- Project droid: `.claude/agents/my-custom-droid.md`
- Global droid: `~/.claude/agents/my-custom-droid.md`
