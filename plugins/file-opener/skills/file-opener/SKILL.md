---
name: file-opener
description: Use this skill when the user asks to open a file or folder in Finder, Explorer, or the system file manager. Also use when the user says "show in Finder", "reveal in Explorer", "open folder", or "apri in finder".
---

# File Opener

Open files and folders in the native file manager (Finder on macOS, Explorer on Windows, xdg-open on Linux).

## Commands

### Reveal a file in its parent folder (highlights the file)

**macOS:**
```bash
open -R "/path/to/file"
```

**Windows:**
```bash
explorer /select,"\path\to\file"
```

**Linux:**
```bash
xdg-open "$(dirname "/path/to/file")"
```

### Open a folder directly

**macOS:**
```bash
open "/path/to/folder"
```

**Windows:**
```bash
explorer "\path\to\folder"
```

**Linux:**
```bash
xdg-open "/path/to/folder"
```

### Open a file with its default application

**macOS:**
```bash
open "/path/to/file.pdf"
```

**Windows:**
```bash
start "" "\path\to\file.pdf"
```

**Linux:**
```bash
xdg-open "/path/to/file.pdf"
```

## Cross-Platform Detection

Detect the OS at runtime using `uname` or platform info:

```bash
case "$(uname -s)" in
  Darwin)  open -R "$FILE_PATH" ;;
  MINGW*|MSYS*|CYGWIN*) explorer /select,"$(cygpath -w "$FILE_PATH")" ;;
  Linux)   xdg-open "$(dirname "$FILE_PATH")" ;;
esac
```

## Important Notes

- Always use **absolute paths** to avoid ambiguity
- On macOS, `open -R` reveals (highlights) the file in Finder; `open` opens the folder/file
- On Windows, `explorer /select,` requires a comma with NO space after it
- On Windows in Git Bash/MSYS, convert paths with `cygpath -w` before passing to `explorer`
- Prefer `open -R` / `explorer /select,` when the user wants to "see" a file — it's more useful than just opening the parent folder
