---
name: ios-version-updater
description: This skill should be used when updating iOS/Xcode app version numbers. Handles MARKETING_VERSION (user-facing version like 1.0.5) and CURRENT_PROJECT_VERSION (build number like 4) in Xcode project files (project.pbxproj). Use when user asks to bump version, update build number, or release a new app version.
---

# iOS Version Updater

## Overview

This skill provides guidance for updating iOS app version numbers in Xcode projects. It handles both the marketing version (displayed to users in the App Store) and the build number (internal tracking).

## Version Components

### MARKETING_VERSION
- **Format**: Semantic versioning (e.g., `1.0.5`, `2.1.0`)
- **Purpose**: User-facing version shown in App Store
- **Pattern**: `MAJOR.MINOR.PATCH`
  - MAJOR: Breaking changes or major releases
  - MINOR: New features, backwards compatible
  - PATCH: Bug fixes, minor improvements

### CURRENT_PROJECT_VERSION
- **Format**: Integer (e.g., `1`, `4`, `127`)
- **Purpose**: Internal build tracking, must increment for each App Store upload
- **Rule**: Always increment, never decrement

## Workflow

### Step 1: Locate project.pbxproj
To find the Xcode project file containing version info:

```bash
# Pattern to find the file
find . -name "project.pbxproj" -path "*.xcodeproj/*"
```

The file is typically at: `<ProjectName>.xcodeproj/project.pbxproj`

### Step 2: Read Current Versions
Before updating, read the file to get current versions:

```
# Search for current versions
MARKETING_VERSION = X.X.X;
CURRENT_PROJECT_VERSION = X;
```

### Step 3: Update Versions
Use the Edit tool with `replace_all: true` to update all occurrences:

```swift
// Update marketing version
old_string: "MARKETING_VERSION = 1.0.4;"
new_string: "MARKETING_VERSION = 1.0.5;"
replace_all: true

// Update build number
old_string: "CURRENT_PROJECT_VERSION = 3;"
new_string: "CURRENT_PROJECT_VERSION = 4;"
replace_all: true
```

**Important**: Use `replace_all: true` because Xcode projects have multiple build configurations (Debug, Release) that all need updating.

### Step 4: Confirm Changes
After editing, confirm the number of replacements matches expected configurations (typically 2-4 for Debug/Release across app and extensions).

## Common User Requests

| User Says | Action |
|-----------|--------|
| "Bump version to 1.0.5" | Update MARKETING_VERSION only |
| "New build" | Increment CURRENT_PROJECT_VERSION only |
| "Release 1.0.5 build 4" | Update both values |
| "Bump patch version" | Increment last number (1.0.4 → 1.0.5) |
| "Bump minor version" | Increment middle number (1.0.4 → 1.1.0) |
| "Bump major version" | Increment first number (1.0.4 → 2.0.0) |
| "Porta versione a X.X.X" | Update MARKETING_VERSION to specified value |

## Best Practices

1. **Always read before editing** - Verify current versions before making changes
2. **Use replace_all** - Ensures all configurations stay in sync
3. **Increment build for each upload** - App Store requires unique build numbers
4. **Confirm success** - Report how many occurrences were replaced
5. **Keep versions in sync** - All targets should have same version when releasing

## Example Response Format

When updating versions, report:

```
✅ Fatto!

Versione aggiornata:
- **Marketing Version**: `1.0.4` → **`1.0.5`**
- **Build Number**: `3` → **`4`**
```
