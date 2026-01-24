---
description: Example of command with complex argument parsing
argument-hint: [summary] [priority:high|medium|low] [tags:<tag1,tag2>] [--urgent]
model: sonnet
---

# Complex Parsing Command Example

Create task: **$ARGUMENTS**

## Argument Parsing

Parse $ARGUMENTS for:
- **summary**: Main task description (text in quotes or first argument)
- **priority**: Priority level (high|medium|low) after "priority:"
- **tags**: Comma-separated tags after "tags:"
- **--urgent**: Flag for urgent tasks

### Parsing Logic

1. Extract summary:
   - If quotes: Everything between quotes
   - Else: First space-separated token

2. Extract priority:
   - Look for "priority:" keyword
   - Take value after colon
   - Validate against enum: high|medium|low
   - Default: medium

3. Extract tags:
   - Look for "tags:" keyword
   - Split comma-separated values after colon
   - Trim whitespace

4. Check for --urgent flag:
   - Present: urgent = true
   - Absent: urgent = false

## Task

Create a new task with parsed arguments.

### Workflow

1. Parse all arguments from $ARGUMENTS
2. Validate parsed values
3. Create task with parsed data
4. Save to tasks.json
5. Display confirmation

## Examples

**Example 1: Simple**
```
/task "Fix login bug"
```
Parsed:
- summary: "Fix login bug"
- priority: medium (default)
- tags: []
- urgent: false

**Example 2: With Priority**
```
/task "Implement OAuth" priority:high
```
Parsed:
- summary: "Implement OAuth"
- priority: high
- tags: []
- urgent: false

**Example 3: Full Options**
```
/task "Deploy to production" priority:high tags:deployment,backend --urgent
```
Parsed:
- summary: "Deploy to production"
- priority: high
- tags: ["deployment", "backend"]
- urgent: true

**Example 4: Complex Summary**
```
/task "Fix critical security issue in auth system" priority:high tags:security,critical --urgent
```
Parsed:
- summary: "Fix critical security issue in auth system"
- priority: high
- tags: ["security", "critical"]
- urgent: true

## Error Handling

**Invalid Priority:**
```
❌ Invalid priority: "urgent" (must be high|medium|low)

Valid options:
- priority:high
- priority:medium
- priority:low
```

**Missing Summary:**
```
❌ Task summary is required

Usage: /task <summary> [options]

Example: /task "My task description" priority:high
```
