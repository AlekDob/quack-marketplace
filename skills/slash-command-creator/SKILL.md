---
name: slash-command-creator
description: This skill should be used when creating or updating slash commands for the Claude Agent SDK. Provides comprehensive guidance on proper YAML frontmatter structure, argument parsing, tool restrictions, error handling, and best practices for building robust, user-friendly commands that follow SDK conventions.
---

# Slash Command Creator

Expert guidance for creating correct, well-structured slash commands that follow Claude Agent SDK best practices.

## When to Use This Skill

Use this skill when:
- Creating a new slash command from scratch
- Updating existing commands to follow best practices
- Debugging command structure or YAML frontmatter issues
- Implementing complex argument parsing
- Adding tool restrictions for security
- Improving command error handling
- Standardizing commands across a project

## What Are Slash Commands

Slash commands are pre-configured prompts stored as Markdown files in `.claude/commands/`. They enable quick execution of common workflows with customizable arguments.

**Command locations:**
- Project-specific: `.claude/commands/` (in project root)
- Global: `~/.claude/commands/` (user-wide)

**Structure:**
1. YAML frontmatter (metadata)
2. Markdown body (instructions for Claude)

## Command Creation Process

### Step 1: Understand the Use Case

Before creating a command, identify:
1. **What the command does** - Clear purpose in one sentence
2. **Who will use it** - Developer? PM? Anyone?
3. **What arguments it needs** - Simple string? Complex parsing? Flags?
4. **What tools it requires** - Git? File operations? Web requests?
5. **Common failure scenarios** - What could go wrong?

### Step 2: Choose the Right Template

Based on the use case, select from:

**Simple Command** (`assets/examples/simple-command.md`)
- Single argument
- Straightforward workflow
- Minimal error handling
- Example: `/delete-file <filename>`

**Complex Parsing Command** (`assets/examples/complex-parsing-command.md`)
- Multiple arguments with keywords
- Enum validation
- Flags and options
- Example: `/task "summary" priority:high tags:dev,urgent --now`

**Git Workflow Command** (`assets/examples/git-workflow-command.md`)
- Git operations
- Tool restrictions (`allowed-tools: [Bash(git:*)]`)
- Pre-flight validation
- Rich error handling
- Example: `/feature <branch-name>`

Or start from the blank template: `assets/command-template.md`

### Step 3: Configure YAML Frontmatter

Reference `references/sdk-docs.md` for complete field documentation.

**Minimum viable frontmatter:**
```yaml
---
description: Brief description of what this command does
---
```

**Recommended frontmatter:**
```yaml
---
description: Create a new Git Flow feature branch from develop
argument-hint: <feature-name>
allowed-tools: [Bash(git:*)]
model: sonnet
---
```

**Full frontmatter with all fields:**
```yaml
---
description: Document daily work progress and plan next steps
argument-hint: [summary] [next:<text>] [category:dev|design|docs] [mood:productive|blocked]
allowed-tools: [Read, Write, Bash(git:*)]
model: sonnet
category: project
tags: [documentation, productivity, diary]
---
```

#### Field Selection Guide

**`description`** (always required)
- Be specific and descriptive
- Include key verbs: "Create", "Analyze", "Deploy", "Review"
- Mention primary outcome
- Good: "Analyze code quality and suggest improvements"
- Bad: "Does code stuff"

**`argument-hint`** (required if command takes arguments)
- Show expected format with placeholders
- Use `<required>`, `[optional]`, `[enum1|enum2]`
- Examples:
  - Simple: `<filename>`
  - Multiple: `<source> <destination>`
  - Complex: `[summary] [priority:high|medium|low] [--flags]`

**`allowed-tools`** (highly recommended)
- Always specify for git, file, or network operations
- Use pattern matching for fine-grained control
- Security best practice
- Examples:
  - Git only: `[Bash(git:*)]`
  - Files only: `[Read, Write, Edit]`
  - Mixed: `[Read, Grep, Bash(npm:*)]`

**`model`** (optional, defaults to sonnet)
- `haiku` - Fast, simple tasks (<5 steps)
- `sonnet` - Most commands (balance speed/capability)
- `opus` - Complex reasoning, planning, analysis

**`category`** (optional)
- Helps organize commands in UI
- Common: `project`, `git`, `testing`, `documentation`, `deployment`

**`tags`** (optional)
- Searchable keywords
- Use for filtering/discovery
- Example: `[git, workflow, feature-branch]`

### Step 4: Write the Markdown Body

Use **imperative/infinitive form** (verb-first instructions), not second person.

**Good:** "To create the branch, execute the following commands..."
**Bad:** "You should create the branch by..."

#### Required Sections

**1. Command Overview**
```markdown
# [Command Name]

[Brief description of purpose]

Target/Input: **$ARGUMENTS**
```

**2. Current State (for context-aware commands)**
```markdown
## Current State

- Current branch: !`git branch --show-current`
- Working directory: !`pwd`
- Git status: !`git status --porcelain`
```

**3. Task Description**
```markdown
## Task

[Describe what this command will accomplish in detail]
```

**4. Workflow Steps**
```markdown
### Workflow

1. Validate inputs
2. Perform pre-flight checks
3. Execute main operation
4. Verify success
5. Display status report
```

**5. Error Handling**
```markdown
### Error Handling

**Error Scenario 1:**
```
❌ [Error message]

[Explanation]

Options:
1. [Solution]
2. [Alternative]
```
```

**6. Examples**
```markdown
## Examples

**Basic Usage:**
```
/command value
```
Result: [What happens]

**Advanced Usage:**
```
/command value --option1 --option2
```
Result: [What happens]
```

#### Optional But Recommended Sections

**Argument Parsing (for complex arguments)**
```markdown
## Argument Parsing

Parse $ARGUMENTS for:
- **field1**: Description and format
- **field2**: Enum values (option1|option2)
- **--flag**: Boolean flag

Parsing logic:
1. Extract field1 from quotes or first token
2. Look for "field2:" keyword, validate enum
3. Check for --flag presence
```

**Related Commands**
```markdown
## Related Commands

- `/other-command` - What it does
- `/follow-up` - Next step workflow
```

**Best Practices**
```markdown
## Best Practices

**DO:**
- ✅ Practice 1
- ✅ Practice 2

**DON'T:**
- ❌ Anti-pattern 1
- ❌ Anti-pattern 2
```

### Step 5: Test the Command

Create the command file in `.claude/commands/`:

```bash
# Project-specific
touch .claude/commands/my-command.md

# Global
touch ~/.claude/commands/my-command.md
```

Test by running:
```
/my-command test-argument
```

Verify:
1. Command appears in autocomplete
2. Description is clear
3. Argument parsing works
4. Error handling triggers appropriately
5. Output is helpful and actionable

### Step 6: Iterate and Refine

After testing, refine:
- Make error messages more helpful
- Add missing edge cases
- Improve examples
- Clarify ambiguous instructions
- Add links to related commands

## Common Patterns

### Pattern 1: Simple File Operation

```yaml
---
description: Create a new file with boilerplate content
argument-hint: <filename>
allowed-tools: [Write]
---

# Create File

Create: **$ARGUMENTS**

## Task
Create file with standard boilerplate.

### Workflow
1. Validate filename
2. Check if file exists
3. Write boilerplate content
4. Confirm creation

### Error Handling
**File Exists:**
Offer to: overwrite, rename, or cancel
```

### Pattern 2: Git Operation

```yaml
---
description: Create and push new branch
argument-hint: <branch-name>
allowed-tools: [Bash(git:*)]
model: sonnet
---

# Create Branch

Branch: **$ARGUMENTS**

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --porcelain`

## Task
Create branch following Git Flow.

### Pre-Flight
- Validate branch name
- Check uncommitted changes
- Verify on correct base branch

### Workflow
```bash
git checkout main
git pull origin main
git checkout -b $ARGUMENTS
git push -u origin $ARGUMENTS
```

### Error Handling
Handle: uncommitted changes, branch exists, not on main
```

### Pattern 3: Complex Argument Parsing

```yaml
---
description: Create task with priority and tags
argument-hint: [summary] [priority:high|medium|low] [tags:<list>]
model: sonnet
---

# Create Task

Task: **$ARGUMENTS**

## Argument Parsing

Parse $ARGUMENTS for:
- **summary**: Text in quotes or first token
- **priority**: Value after "priority:" (high|medium|low)
- **tags**: Comma-separated values after "tags:"

Default values:
- priority: medium
- tags: []

## Task
Create task with parsed arguments.

### Workflow
1. Parse and validate arguments
2. Apply defaults for missing values
3. Create task object
4. Save to tasks.json
5. Display confirmation

### Examples
```
/task "Fix bug" priority:high tags:urgent,backend
```
Parsed: summary="Fix bug", priority=high, tags=[urgent, backend]
```

### Pattern 4: Analysis Command

```yaml
---
description: Analyze code quality and suggest improvements
argument-hint: [file-pattern] [--focus <areas>]
allowed-tools: [Read, Grep, Bash(eslint*)]
model: opus
---

# Code Quality Analysis

Target: **$ARGUMENTS**

## Task
Analyze code quality with focus areas.

### Workflow
1. Parse file pattern and focus areas
2. Read target files using Read tool
3. Run static analysis (if applicable)
4. Generate quality report with scores
5. Provide actionable suggestions

### Output Format
```
📊 Quality Score: X/100

🔴 Critical Issues (N)
[List with file:line references]

🟡 Warnings (N)
[List with suggestions]

💡 Suggestions (N)
[Optimization opportunities]
```

### Focus Areas
Parse --focus flag for:
- security
- performance
- maintainability
- testing

Example: `/analyze src/ --focus security,performance`
```

## Quality Checklist

Before finalizing a command, verify:

### YAML Frontmatter
- [ ] `description` is clear and specific
- [ ] `argument-hint` provided if command takes arguments
- [ ] `allowed-tools` restricts sensitive operations appropriately
- [ ] `model` specified if not default sonnet
- [ ] `category` set for organization (optional)
- [ ] `tags` added for discoverability (optional)

### Markdown Body
- [ ] Uses imperative/infinitive form (not second person)
- [ ] `$ARGUMENTS` usage is clear
- [ ] Shell commands use `!` syntax correctly
- [ ] Current state shown for context-aware commands
- [ ] Workflow steps are numbered and clear
- [ ] Error handling covers common failures
- [ ] Examples show realistic usage patterns
- [ ] Related commands are cross-referenced

### Testing
- [ ] Command appears in autocomplete
- [ ] Arguments parse correctly
- [ ] Error messages are helpful
- [ ] Output is actionable
- [ ] Edge cases are handled

## Resources

**Reference Documentation:**
- See `references/sdk-docs.md` for complete SDK documentation
- Covers all YAML fields, syntax patterns, and best practices

**Templates:**
- `assets/command-template.md` - Blank template with all sections
- Copy and customize for new commands

**Examples:**
- `assets/examples/simple-command.md` - Simple single-argument command
- `assets/examples/complex-parsing-command.md` - Complex argument parsing
- `assets/examples/git-workflow-command.md` - Git workflow with restrictions

## Quick Start

**Creating a new command:**

1. Copy template:
   ```bash
   cp ~/.claude/skills/slash-command-creator/assets/command-template.md .claude/commands/my-command.md
   ```

2. Edit frontmatter with correct metadata

3. Write task description and workflow

4. Add error handling

5. Provide examples

6. Test: `/my-command test-arg`

**Improving existing command:**

1. Check against quality checklist above
2. Reference `references/sdk-docs.md` for best practices
3. Compare with examples in `assets/examples/`
4. Add missing sections (error handling, examples, etc.)
5. Test improvements

## Common Mistakes to Avoid

❌ **Missing argument-hint when command takes arguments**
```yaml
---
description: Create feature branch
# Missing: argument-hint: <branch-name>
---
```

❌ **Vague description**
```yaml
---
description: Does git stuff  # Too vague!
---
```

❌ **No tool restrictions for sensitive operations**
```yaml
---
# Missing: allowed-tools: [Bash(git:*)]
# Command can execute ANY bash command!
---
```

❌ **Using second person instead of imperative**
```markdown
## Task
You should create a branch...  # Wrong
```

Should be:
```markdown
## Task
Create a branch...  # Correct
```

❌ **No error handling**
```markdown
## Workflow
1. Create branch
2. Push to remote
# What if branch exists? What if uncommitted changes?
```

❌ **No examples**
```markdown
# Users left guessing how to use the command
```

## Summary

Creating great slash commands requires:

1. **Clear purpose** - Know exactly what the command does
2. **Proper metadata** - Complete YAML frontmatter
3. **Tool restrictions** - Security via `allowed-tools`
4. **Robust error handling** - Handle common failures
5. **Good examples** - Show realistic usage
6. **Testing** - Verify everything works

Use this skill's resources:
- **Reference docs** (`references/sdk-docs.md`) for complete API
- **Template** (`assets/command-template.md`) for structure
- **Examples** (`assets/examples/`) for patterns

Follow the quality checklist, avoid common mistakes, and iterate based on real usage.

Happy command creating! 🚀
