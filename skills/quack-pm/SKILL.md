---
name: quack-pm
description: This skill should be used when managing projects through Quack's Kanban board, assigning tasks to AI agents, coordinating droids for specialized work, or running background scripts. Use this skill when the user asks to create tasks, delegate work to agents, check workload, or run automated scripts in the background.
---

# Quack Project Manager

## Overview

This skill enables intelligent project management through Quack's Kanban MCP tools. It provides the knowledge to:
- Create and manage tasks on the Kanban board
- Assign tasks to the most appropriate AI agents
- Delegate specialized work to droids (subagents)
- Run background scripts via `/background` command
- Coordinate multi-agent workflows

## Core Workflow

### 1. Discovery Phase (Always Start Here)

Before creating or assigning tasks, discover available resources:

```
1. List available agents: kanban_list_agents
2. List existing tasks: kanban_list_tasks
3. Check workload: kanban_get_workload
```

This ensures you assign to the right agent with capacity.

### 2. Task Creation

Create tasks with proper context:

```javascript
kanban_create_task({
  title: "Short descriptive title",
  prompt: "Detailed prompt with requirements, context, and expected output",
  projectPath: "/absolute/path/to/project",
  projectName: "project-name",
  branch: "feature/branch-name",
  assignedAgentName: "Agent Name"  // Fuzzy matching supported
})
```

**Best Practices:**
- Title: 5-10 words max, action-oriented ("Implement user auth", "Fix dropdown bug")
- Prompt: Include full context, requirements, acceptance criteria
- Always specify projectPath and projectName
- Use branch when working on feature branches

### 3. Agent Assignment Matrix

Match tasks to agents based on their specialization:

| Task Type | Recommended Agent/Droid |
|-----------|------------------------|
| UI/React components | frontend-developer |
| Backend/Rust/APIs | data-engineer |
| Test writing | test-engineer |
| Code review | code-reviewer |
| Documentation | documentation-writer-expert |
| Quack user docs | quack-docs-writer |
| Git operations | git-flow-manager |
| Code exploration | code-explorer |
| Prompt crafting | carmelo-prompt-engineer |
| Knowledge base | second-brain-manager |
| Git context | git-context-manager |

### 4. Running Background Tasks

For long-running operations, use the `/background` command:

**Shell commands:**
```bash
/background npm run build
/background npm test
/background ./scripts/deploy.sh
```

**Agent tasks:**
```bash
/background @frontend-developer Implement the new dashboard component
/background @test-engineer Write tests for the auth module
```

**Python scripts:**
```bash
/background python scripts/analyze_codebase.py
/background python -c "print('Quick inline script')"
```

### 5. Multi-Agent Coordination

For complex tasks requiring multiple agents:

1. **Create parent task** for the overall feature
2. **Create subtasks** linked via `parentTaskId`
3. **Assign different agents** to each subtask
4. **Use `kanban_get_session_context`** to share context between agents

Example workflow:
```
1. Create: "Implement new settings page" → assign to frontend-developer
2. Create subtask: "Write tests for settings" → assign to test-engineer (parentTaskId: parent.id)
3. Create subtask: "Document settings API" → assign to documentation-writer-expert
4. Monitor with: kanban_get_workload
```

### 6. Task Lifecycle Management

**Moving tasks:**
```javascript
// Start working
kanban_move_task({ taskId: "id", newStatus: "in_progress" })

// Complete with note
kanban_move_task({
  taskId: "id",
  newStatus: "done",
  completionNote: "All tests passing, feature complete"
})
```

**Updating progress:**
```javascript
kanban_update_task({
  taskId: "id",
  progress: 75,
  notes: "Implemented main logic, styling remaining"
})
```

## MCP Kanban Tools Reference

| Tool | Purpose |
|------|---------|
| `kanban_list_agents` | List available agents with project info |
| `kanban_list_tasks` | List/filter tasks by status, project, agent |
| `kanban_create_task` | Create new task with assignment |
| `kanban_move_task` | Move between todo/in_progress/done |
| `kanban_update_task` | Update title, progress, notes |
| `kanban_delete_task` | Delete a task (use with caution) |
| `kanban_get_workload` | Get agent capacity summary |
| `kanban_get_session_context` | Read agent's conversation history |

## Droids (Subagents)

Droids are specialized AI agents defined in `.claude/agents/` folders. They can be invoked via the Task tool with specific `subagent_type`.

### Project Droids (in project's `.claude/agents/`)
- `frontend-developer` - React, UI, state management
- `data-engineer` - Backend, Rust, data pipelines
- `test-engineer` - Vitest tests, QA
- `code-reviewer` - Code quality, security
- `documentation-writer-expert` - Technical docs
- `quack-docs-writer` - Quack user documentation
- `git-flow-manager` - Git Flow operations
- `code-explorer` - Codebase navigation
- `carmelo-prompt-engineer` - Prompt optimization

### Global Droids (in `~/.claude/agents/`)
- `second-brain-manager` - MCP Memory, Obsidian vault
- `git-context-manager` - Git commits, context files

### Using Droids

Invoke droids via the Task tool:
```javascript
Task({
  subagent_type: "frontend-developer",
  prompt: "Create a responsive navigation component with dark mode support"
})
```

Or via background:
```bash
/background @code-reviewer Review the changes in src/components/
```

## Best Practices

### Task Design
1. **Atomic tasks** - One clear objective per task
2. **Full context** - Include all relevant info in prompt
3. **Acceptance criteria** - Define what "done" means
4. **Dependencies** - Use `blockedBy` for task dependencies

### Agent Selection
1. **Check workload first** - Don't overload agents
2. **Match expertise** - UI tasks to frontend, tests to test-engineer
3. **Use fuzzy matching** - "Magnus" finds "Agent Magnus"
4. **Consider project context** - Filter by projectPath when needed

### Background Tasks
1. **Non-blocking** - Use for builds, tests, long analysis
2. **Monitor progress** - Check task panel for status
3. **Chain appropriately** - Use `&&` for sequential shell commands
4. **Log output** - Background tasks stream logs in real-time

## Resources

See the `references/` folder for:
- `kanban-mcp-tools.md` - Full MCP tool documentation
- `available-droids.md` - Complete droid specifications
