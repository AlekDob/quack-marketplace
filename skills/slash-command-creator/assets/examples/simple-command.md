---
description: Example of a simple command with single argument
argument-hint: <name>
allowed-tools: [Write]
model: sonnet
---

# Simple Command Example

Create file: **$ARGUMENTS**

## Task

Create a new file with the provided name.

### Workflow

```bash
# Create the file
touch $ARGUMENTS

# Confirm creation
ls -la $ARGUMENTS
```

### Success Report

```
✓ Created file: $ARGUMENTS

File is ready for editing.
```

### Error Handling

**File Already Exists:**
```
❌ File $ARGUMENTS already exists

Options:
1. Choose a different name
2. Overwrite existing file
3. Append timestamp to name
```

## Example

```
/simple hello.txt
```
Result: Creates `hello.txt` file
