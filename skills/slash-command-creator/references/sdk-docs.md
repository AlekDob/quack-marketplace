# Slash Commands - Claude Agent SDK Reference

## Overview

Slash commands are pre-configured prompts stored as Markdown files in `.claude/commands/`. They enable quick execution of common workflows with customizable arguments.

## Command File Structure

### Location
- **Project commands**: `.claude/commands/` (project-specific)
- **Global commands**: `~/.claude/commands/` (user-wide)

### File Format

Each command is a `.md` file with:
1. **YAML frontmatter** (required) - Metadata
2. **Markdown body** (required) - Instructions for Claude

## YAML Frontmatter

### Required Fields

```yaml
---
description: Brief description of what the command does
---
```

### Optional Fields

```yaml
---
description: Create a new Git Flow feature branch from develop
argument-hint: <feature-name>
allowed-tools: [Bash(git:*), Read, Write]
model: sonnet
category: project
tags: [git, workflow]
---
```

#### Field Descriptions

**`description`** (required)
- Brief, clear description of the command's purpose
- Shown in command list and autocomplete
- Should be specific enough to distinguish from similar commands

**`argument-hint`** (optional)
- Shows users the expected argument format
- Syntax:
  - `<required>` - Required argument
  - `[optional]` - Optional argument
  - `[option1|option2]` - Enum choices
  - Multiple arguments: `<name> [options] [--flags]`
- Examples:
  - `<feature-name>`
  - `[--staged] [--focus <categories>]`
  - `[summary] [next:<text>] [category:dev|design|docs]`

**`allowed-tools`** (optional)
- Restricts which tools Claude can use during command execution
- Security feature to prevent unintended operations
- Syntax:
  - `[Read, Write, Bash]` - Specific tools
  - `Bash(git:*)` - Tool with pattern matching (only git commands)
  - `[Read, Bash(npm:*)]` - Mix of unrestricted and restricted
- Examples:
  ```yaml
  allowed-tools: [Bash(git:*)]  # Only git commands
  allowed-tools: [Read, Grep, Bash(eslint*)]  # Read, grep, and eslint
  allowed-tools: [Read, Write, Edit]  # File operations only
  ```

**`model`** (optional)
- Specifies which Claude model to use
- Options: `opus`, `sonnet`, `haiku`
- Default: Uses user's configured default model
- Use cases:
  - `opus` - Complex reasoning, analysis, planning
  - `sonnet` - Balance of speed and capability (most commands)
  - `haiku` - Fast, simple tasks

**`category`** (optional)
- Organizes commands in UI/lists
- Common values: `project`, `git`, `testing`, `documentation`

**`tags`** (optional)
- Array of searchable keywords
- Example: `[git, code-quality, security, review]`

## Markdown Body

### Accessing Arguments

Use `$ARGUMENTS` to access user-provided arguments:

```markdown
Create feature branch: **$ARGUMENTS**

# Will create branch: feature/$ARGUMENTS
git checkout -b feature/$ARGUMENTS
```

### Shell Commands

Use `!` prefix to execute shell commands inline:

```markdown
- Current branch: !`git branch --show-current`
- Git status: !`git status --porcelain`
```

### Argument Parsing Patterns

#### Simple Argument
```markdown
Feature name: $ARGUMENTS
# Usage: /feature user-authentication
# Result: $ARGUMENTS = "user-authentication"
```

#### Complex Argument Parsing
```markdown
Parse $ARGUMENTS for:
- **Summary**: Text in quotes or first argument
- **next**: Text after "next:" keyword
- **category**: Value after "category:" (enum: dev|design|docs)
- **mood**: Value after "mood:" (enum: productive|blocked)

Examples:
- `/diary "completed auth"` → summary="completed auth"
- `/diary next:"add tests"` → next="add tests"
- `/diary category:dev mood:productive` → category=dev, mood=productive
```

#### Flag-Based Arguments
```markdown
Parse command options from $ARGUMENTS:
- `--staged`: Review staged changes only
- `--focus <categories>`: Focus on specific areas
- `--severity <level>`: Filter by severity
- `--file <pattern>`: Limit to file pattern

Example: `/code-review --staged --focus security,performance`
```

### Command Structure

Recommended sections for SKILL.md body:

1. **Task Description** - What the command does
2. **Current State** - Show context using `!` commands
3. **Workflow Steps** - Numbered procedural steps
4. **Error Handling** - Common failure scenarios and solutions
5. **Examples** - Usage examples with expected outcomes
6. **Related Commands** - Links to related workflows

## Best Practices

### DO

✅ **Use descriptive descriptions**
```yaml
description: Intelligent code review of uncommitted changes with security, performance, and quality analysis
```

✅ **Provide argument hints**
```yaml
argument-hint: <feature-name>
```

✅ **Restrict tools for security**
```yaml
allowed-tools: [Bash(git:*)]  # Only git commands
```

✅ **Show current state**
```markdown
- Current branch: !`git branch --show-current`
- Uncommitted changes: !`git status --porcelain`
```

✅ **Handle errors gracefully**
```markdown
### Error: Branch Already Exists
If branch exists, offer options:
1. Switch to existing branch
2. Use different name
3. Delete and recreate (destructive!)
```

✅ **Provide examples**
```markdown
Usage: /feature <feature-name>

Examples:
  /feature user-profile-page
  /feature api-v2-integration
```

### DON'T

❌ **Vague descriptions**
```yaml
description: Does git stuff  # Too vague
```

❌ **Missing argument hints**
```yaml
# No argument-hint when command takes arguments
```

❌ **Unrestricted tool access for sensitive operations**
```yaml
# No allowed-tools specified for git/file operations
```

❌ **No error handling**
```markdown
# Command assumes everything succeeds
```

❌ **No examples**
```markdown
# Users left guessing how to use the command
```

## Common Patterns

### Git Flow Commands

```yaml
---
description: Create a new Git Flow feature branch from develop
argument-hint: <feature-name>
allowed-tools: [Bash(git:*)]
model: sonnet
---

# Git Flow Feature Branch

Create feature branch: **$ARGUMENTS**

## Current Repository State
- Current branch: !`git branch --show-current`
- Git status: !`git status --porcelain`

## Workflow
1. Validate feature name is provided
2. Check for uncommitted changes
3. Switch to develop and pull latest
4. Create feature/$ARGUMENTS branch
5. Push to remote with tracking

## Error Handling
[Handle: no feature name, uncommitted changes, branch exists]
```

### Analysis Commands

```yaml
---
description: Analyze code quality and suggest improvements
argument-hint: [file-pattern] [--focus <areas>]
allowed-tools: [Read, Grep, Bash(eslint*)]
model: opus
---

# Code Quality Analysis

Target: $ARGUMENTS

## Analysis Steps
1. Parse file pattern and focus areas from $ARGUMENTS
2. Read target files
3. Run static analysis
4. Generate report with severity levels

## Output Format
- Score: X/100
- Critical issues: [list]
- Suggestions: [list]
```

### Documentation Commands

```yaml
---
description: Document daily work progress and plan next steps
argument-hint: [summary] [next:<text>] [category:dev|design|docs]
---

# Daily Work Documentation

Arguments: $ARGUMENTS

## Workflow
1. Parse $ARGUMENTS for summary, next, category, mood
2. Analyze git commits: !`git log --oneline --since="today"`
3. Check modified files: !`find . -name "*.md" -newermt "today"`
4. Generate diary entry with parsed data
5. Save to diary/YYYY-MM-DD.md

## Argument Parsing
- Summary: Text in quotes or first arg
- next: Text after "next:"
- category: dev|design|docs|research
- mood: productive|blocked|inspired
```

## Validation Checklist

Before finalizing a command, verify:

- [ ] YAML frontmatter has `description`
- [ ] `argument-hint` provided if command takes arguments
- [ ] `allowed-tools` restricts sensitive operations
- [ ] `model` specified if not default sonnet
- [ ] Markdown body uses imperative/infinitive form
- [ ] `$ARGUMENTS` handling is clear
- [ ] Shell commands use `!` syntax correctly
- [ ] Error handling covers common failures
- [ ] Examples show realistic usage
- [ ] Related commands are cross-referenced

## References

- [Claude Agent SDK Documentation](https://platform.claude.com/docs/en/agent-sdk)
- [Slash Commands Guide](https://platform.claude.com/docs/en/agent-sdk/slash-commands)
