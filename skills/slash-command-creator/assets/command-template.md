---
description: [Brief description of what this command does]
argument-hint: [<required-arg>] [[optional-arg]] [[--flags]]
allowed-tools: [Tool1, Tool2, Bash(pattern:*)]
model: sonnet
category: [project|git|testing|docs]
tags: [tag1, tag2, tag3]
---

# [Command Name]

[Brief introduction to what this command does]

Target/Input: **$ARGUMENTS**

## Current State

[Show relevant current state using ! syntax]
- Current directory: !`pwd`
- [Other relevant state]: !`command`

## Task

[Describe what this command will accomplish]

### 1. Pre-Flight Validation

[List validation steps]
- **Check X**: Verify condition
- **Validate Y**: Ensure requirement
- **Confirm Z**: Check precondition

### 2. Main Workflow

Execute the following workflow:

```bash
# Step 1: [Description]
command-here

# Step 2: [Description]
another-command

# Step 3: [Description]
final-command
```

### 3. Provide Status Report

After successful execution, display:

```
✓ Step 1 completed
✓ Step 2 completed
✓ Step 3 completed

🎯 [Command Name] Complete

[Summary of what was done]

🎯 Next Steps:
1. [Next action]
2. [Follow-up task]
3. [Related command to run]
```

### 4. Error Handling

Handle these scenarios gracefully:

**Error Scenario 1:**
```
❌ [Error message]

[Explanation of what went wrong]

Options:
1. [Solution 1]
2. [Solution 2]
3. [Solution 3]
```

**Error Scenario 2:**
```
⚠️  [Warning message]

[Explanation]

✓ [Auto-fix action taken]
✓ Ready to proceed
```

## Argument Parsing

[If command uses complex argument parsing, explain here]

Parse $ARGUMENTS for:
- **argument1**: Description and format
- **argument2**: Description and format
- **flag**: Description and usage

Examples:
- `/command value1` → argument1="value1"
- `/command --flag value2` → flag=true, argument2="value2"

## Examples

**Example 1: Basic Usage**
```
/command simple-value
```
Result: [What happens]

**Example 2: With Options**
```
/command value --option1 --option2
```
Result: [What happens]

**Example 3: Complex Arguments**
```
/command "complex value" option:setting flag:enabled
```
Result: [What happens]

## Related Commands

- `/related-command-1` - [What it does]
- `/related-command-2` - [What it does]
- `/related-command-3` - [What it does]

## Best Practices

**DO:**
- ✅ [Best practice 1]
- ✅ [Best practice 2]
- ✅ [Best practice 3]

**DON'T:**
- ❌ [Anti-pattern 1]
- ❌ [Anti-pattern 2]
- ❌ [Anti-pattern 3]

## Notes

[Any additional context, tips, or warnings]

---

[Footer with credits, version, or additional info if needed]
