---
name: open
description: Open a file or folder in the native file manager (Finder/Explorer)
parameters: [path]
---

# Open in File Manager

Use the `file-opener` subagent (droid) to open the specified path in the native OS file manager.

## Instructions

1. Launch the `file-opener` agent with `subagent_type: "file-opener"` and `model: "haiku"`
2. Pass the user's path argument: `$ARGUMENTS`
3. If no path is given, open the current working directory
4. The droid handles OS detection (macOS/Windows/Linux) automatically

## Prompt for the droid

```
Open this path in the native file manager: $ARGUMENTS

If the path is empty, open the current working directory.
If it's a glob pattern, find matching files first.
Always use absolute paths.
```
