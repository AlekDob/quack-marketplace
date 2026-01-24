# Kanban MCP Tools Reference

Complete documentation for all 8 Kanban MCP tools available in Quack.

## Tool: kanban_list_agents

List all available agents from the sidebar. **Always use this first** before creating tasks.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectPath | string | No | Filter agents by project path |

**Returns:**
```json
{
  "totalAgents": 5,
  "agents": [
    {
      "id": "uuid-...",
      "name": "Agent Magnus",
      "color": "#FF6B35",
      "avatar": "robot",
      "projectPath": "/path/to/project",
      "projectName": "my-project",
      "branch": "main",
      "workingOn": "Building UI components"
    }
  ],
  "byProject": [
    {
      "projectName": "my-project",
      "agents": [{ "id": "...", "name": "Magnus", "branch": "main" }]
    }
  ]
}
```

---

## Tool: kanban_list_tasks

List and filter Kanban tasks.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| status | string | No | Filter: "todo", "in_progress", "done" |
| projectPath | string | No | Filter by project path |
| agentId | string | No | Filter by assigned agent ID |
| includeCompleted | boolean | No | Include done tasks (default: true) |

**Returns:**
```json
{
  "total": 10,
  "byStatus": { "todo": 5, "in_progress": 2, "done": 3 },
  "tasks": [
    {
      "id": "kanban-123456",
      "title": "Implement dark mode",
      "prompt": "Full task description...",
      "status": "in_progress",
      "projectName": "quack-app",
      "assignedAgent": { "id": "...", "name": "Magnus" },
      "progress": 50,
      "createdAt": 1703000000000
    }
  ]
}
```

---

## Tool: kanban_create_task

Create a new Kanban task with optional agent assignment.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| title | string | **Yes** | Short title (5-10 words) |
| prompt | string | **Yes** | Full task description |
| projectPath | string | **Yes** | Absolute project path |
| projectName | string | **Yes** | Display name |
| status | string | No | "todo" (default) or "in_progress" |
| branch | string | No | Git branch name |
| parentTaskId | string | No | ID for subtask linking |
| assignedAgentId | string | No | Exact agent UUID |
| assignedAgentName | string | No | Fuzzy name match (e.g., "Magnus") |

**Example:**
```javascript
kanban_create_task({
  title: "Implement user preferences panel",
  prompt: "Create a settings panel with:\n- Theme toggle (light/dark)\n- Language selection\n- Notification preferences\n\nUse the existing PreferencesContext and match current UI patterns.",
  projectPath: "/Users/alek/projects/quack-app",
  projectName: "quack-app",
  branch: "feature/settings",
  assignedAgentName: "frontend-developer"
})
```

**Returns:**
```
Created task "Implement user preferences panel" (ID: kanban-1703123456-abc123) in todo
Assigned to: Agent Frontend Developer
```

---

## Tool: kanban_move_task

Move a task between columns. When moving to "done", triggers automatic documentation.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| taskId | string | **Yes** | Task ID to move |
| newStatus | string | **Yes** | "todo", "in_progress", "done" |
| completionNote | string | No | Note when completing |
| skipDocumentation | boolean | No | Skip auto-docs (default: false) |

**Example:**
```javascript
// Start working on a task
kanban_move_task({
  taskId: "kanban-123456-abc123",
  newStatus: "in_progress"
})

// Complete a task
kanban_move_task({
  taskId: "kanban-123456-abc123",
  newStatus: "done",
  completionNote: "Implemented with full test coverage. Merged to main."
})
```

---

## Tool: kanban_update_task

Update task metadata without changing status.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| taskId | string | **Yes** | Task ID to update |
| title | string | No | New title |
| prompt | string | No | Updated description |
| progress | number | No | Percentage (0-100) |
| notes | string | No | Additional notes (appended) |
| blockedBy | string | No | Blocking task ID |

**Example:**
```javascript
kanban_update_task({
  taskId: "kanban-123456-abc123",
  progress: 75,
  notes: "Core logic complete. Remaining: styling and tests."
})
```

---

## Tool: kanban_delete_task

Delete a task permanently. Use with caution.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| taskId | string | **Yes** | Task ID to delete |
| reason | string | No | Deletion reason (audit trail) |

**Note:** Cannot delete tasks with subtasks. Delete or reassign subtasks first.

---

## Tool: kanban_get_workload

Get workload summary for capacity planning.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| agentId | string | No | Specific agent (omit for all) |
| projectPath | string | No | Filter by project |

**Returns:**
```json
{
  "totalAgents": 3,
  "agentWorkloads": [
    {
      "agentId": "uuid-...",
      "agentName": "Agent Magnus",
      "projectName": "quack-app",
      "todo": 2,
      "in_progress": 1,
      "done": 5,
      "tasks": [
        { "id": "...", "title": "Fix dropdown", "status": "in_progress" }
      ]
    }
  ],
  "unassignedTasks": 3
}
```

---

## Tool: kanban_get_session_context

Read an agent's conversation history for coordination.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| agentId | string | **Yes** | Agent's UUID |
| messageLimit | number | No | Messages to retrieve (default: 10, max: 50) |

**Returns:**
```json
{
  "agentId": "uuid-...",
  "sessionId": "session-...",
  "totalMessages": 45,
  "messagesReturned": 10,
  "lastUpdated": "2024-12-25T10:30:00Z",
  "tokenUsage": { "inputTokens": 5000, "outputTokens": 3000, "totalCost": 0.15 },
  "conversation": [
    {
      "role": "user",
      "content": "Implement the settings panel",
      "timestamp": "2024-12-25T10:25:00Z"
    },
    {
      "role": "assistant",
      "content": "I'll create a settings panel with...",
      "timestamp": "2024-12-25T10:26:00Z",
      "toolsUsed": ["Read", "Write", "Edit"]
    }
  ],
  "quickSummary": {
    "userMessages": 5,
    "assistantMessages": 5,
    "toolsUsed": ["Read", "Write", "Edit", "Bash"],
    "lastUserMessage": "Implement the settings panel",
    "lastAssistantMessage": "I've completed the settings panel..."
  }
}
```

**Use Cases:**
- Understand what an agent has done before assigning related work
- Coordinate multi-agent workflows
- Debug agent behavior
- Resume work on partially completed tasks
