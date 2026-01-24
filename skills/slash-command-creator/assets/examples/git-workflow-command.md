---
description: Example of Git workflow command with tool restrictions
argument-hint: <branch-name>
allowed-tools: [Bash(git:*)]
model: sonnet
category: git
tags: [git, workflow, branching]
---

# Git Workflow Command Example

Create branch: **$ARGUMENTS**

## Current Repository State

- Current branch: !`git branch --show-current`
- Git status: !`git status --porcelain`
- Remote status: !`git remote -v`

## Task

Create a new Git branch and switch to it following best practices.

### 1. Pre-Flight Validation

- **Check git repository**: Verify we're in a valid git repo
- **Validate branch name**: Ensure $ARGUMENTS follows naming conventions:
  - ✅ Valid: `feature-auth`, `bugfix-login`, `docs-readme`
  - ❌ Invalid: `my branch`, `Feature_1`, empty name
- **Check for uncommitted changes**:
  - If changes exist, warn user and ask to commit/stash first
  - OR offer to stash changes automatically
- **Verify base branch exists**: Ensure main/develop branch exists

### 2. Create Branch

Execute workflow:

```bash
# Fetch latest changes
git fetch origin

# Switch to base branch (main or develop)
git checkout main

# Pull latest changes
git pull origin main

# Create new branch
git checkout -b $ARGUMENTS

# Push to remote with tracking
git push -u origin $ARGUMENTS
```

### 3. Provide Status Report

After successful creation:

```
✓ Fetched latest changes from origin
✓ Switched to main branch
✓ Pulled latest changes
✓ Created branch: $ARGUMENTS
✓ Set up remote tracking: origin/$ARGUMENTS
✓ Pushed branch to remote

🌿 Branch Ready

Branch: $ARGUMENTS
Base: main
Status: Clean working directory

🎯 Next Steps:
1. Start making changes
2. Commit regularly with: git commit -m "message"
3. Push changes with: git push
4. Create PR when ready with: /create-pr
```

### 4. Error Handling

**Uncommitted Changes:**
```
⚠️  You have uncommitted changes:
M  src/file1.js
M  src/file2.js

Options:
1. Commit changes first
2. Stash changes: git stash
3. Discard changes: git checkout .

What would you like to do? [1/2/3]
```

**Branch Name Not Provided:**
```
❌ Branch name is required

Usage: /branch <branch-name>

Examples:
  /branch feature-user-profile
  /branch bugfix-login-error
  /branch docs-api-reference

Branch names should:
- Be descriptive and concise
- Use kebab-case (lowercase-with-hyphens)
- Describe what the branch is for
```

**Branch Already Exists:**
```
❌ Branch $ARGUMENTS already exists

Existing branches:
  feature-auth
  bugfix-login
  $ARGUMENTS ← This one

Options:
1. Switch to existing branch: git checkout $ARGUMENTS
2. Use a different branch name
3. Delete existing and recreate (destructive!)
```

**Not a Git Repository:**
```
❌ Not a git repository

To initialize git:
  git init
  git remote add origin <url>
```

## Best Practices

**DO:**
- ✅ Use descriptive branch names
- ✅ Keep branch scope focused
- ✅ Pull latest before creating branch
- ✅ Push to remote regularly
- ✅ Use conventional naming (feature/, bugfix/, docs/)

**DON'T:**
- ❌ Use spaces in branch names
- ❌ Create branches from outdated base
- ❌ Let branches live too long
- ❌ Mix unrelated changes in one branch

## Related Commands

- `/commit` - Commit changes with conventional format
- `/create-pr` - Create pull request from branch
- `/merge-branch` - Merge branch back to base
- `/delete-branch` - Delete local and remote branch

## Notes

This command uses `allowed-tools: [Bash(git:*)]` to restrict execution to git commands only, preventing accidental file operations or other unintended actions.
