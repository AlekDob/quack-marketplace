---
name: agent-browser
description: "Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to open a website, fill out a form, click a button, take a screenshot, scrape data from a page, test a web app, login to a site, automate browser actions, or any task requiring programmatic web interaction."
---

# Browser Automation with agent-browser

Fast, AI-optimized browser automation CLI built on Playwright. 93% less context usage than Playwright MCP.

## Setup Check (run FIRST)

Before using any agent-browser command, **always verify it is installed**:

```bash
which agent-browser || echo "NOT_INSTALLED"
```

If `NOT_INSTALLED`, guide the user through setup:

### Installation

```bash
npm install -g agent-browser
```

This installs the CLI globally. Requires Node.js 18+.

After installation, verify:
```bash
agent-browser --version
```

### Binary Location

- **macOS ARM (Apple Silicon)**: `/opt/homebrew/bin/agent-browser`
- **macOS Intel**: `/usr/local/bin/agent-browser`
- **Linux**: depends on npm global prefix (`npm config get prefix`)

If `which agent-browser` returns nothing after install, the npm global bin may not be in PATH. Fix with:
```bash
export PATH="$(npm config get prefix)/bin:$PATH"
```

## Core Workflow

Every browser automation follows this pattern:

1. **Navigate**: `agent-browser open <url>`
2. **Snapshot**: `agent-browser snapshot -i` (get element refs like `@e1`, `@e2`)
3. **Interact**: Use refs to click, fill, select
4. **Re-snapshot**: After navigation or DOM changes, get fresh refs

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
# Output: @e1 [input "email"], @e2 [input "password"], @e3 [button] "Submit"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i  # Check result
```

## Essential Commands

```bash
# Navigation
agent-browser open <url>              # Navigate (aliases: goto, navigate)
agent-browser close                   # Close browser

# Snapshot
agent-browser snapshot -i             # Interactive elements with refs (recommended)
agent-browser snapshot -i -C          # Include cursor-interactive elements
agent-browser snapshot -s "#selector" # Scope to CSS selector

# Interaction (use @refs from snapshot)
agent-browser click @e1               # Click element
agent-browser fill @e2 "text"         # Clear and type text
agent-browser type @e2 "text"         # Type without clearing
agent-browser select @e1 "option"     # Select dropdown option
agent-browser check @e1               # Check checkbox
agent-browser press Enter             # Press key
agent-browser scroll down 500         # Scroll page

# Get information
agent-browser get text @e1            # Get element text
agent-browser get url                 # Get current URL
agent-browser get title               # Get page title

# Wait
agent-browser wait @e1                # Wait for element
agent-browser wait --load networkidle # Wait for network idle
agent-browser wait --url "**/page"    # Wait for URL pattern
agent-browser wait 2000               # Wait milliseconds

# Capture
agent-browser screenshot              # Screenshot to temp dir
agent-browser screenshot --full       # Full page screenshot
agent-browser pdf output.pdf          # Save as PDF
```

## Common Patterns

### Form Submission

```bash
agent-browser open https://example.com/signup
agent-browser snapshot -i
agent-browser fill @e1 "Jane Doe"
agent-browser fill @e2 "jane@example.com"
agent-browser select @e3 "California"
agent-browser check @e4
agent-browser click @e5
agent-browser wait --load networkidle
```

### Authentication with State Persistence

```bash
# Login once and save state
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$USERNAME"
agent-browser fill @e2 "$PASSWORD"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser state save auth.json

# Reuse in future sessions
agent-browser state load auth.json
agent-browser open https://app.example.com/dashboard
```

### Session Persistence

```bash
# Auto-save/restore cookies and localStorage
agent-browser --session-name myapp open https://app.example.com/login
# ... login flow ...
agent-browser close  # State auto-saved

# Next time, auto-loaded
agent-browser --session-name myapp open https://app.example.com/dashboard
```

### Data Extraction

```bash
agent-browser open https://example.com/products
agent-browser snapshot -i
agent-browser get text @e5           # Get specific element text
agent-browser get text body > page.txt  # Get all page text

# JSON output for parsing
agent-browser snapshot -i --json
agent-browser get text @e1 --json
```

### Parallel Sessions

```bash
agent-browser --session site1 open https://site-a.com
agent-browser --session site2 open https://site-b.com

agent-browser --session site1 snapshot -i
agent-browser --session site2 snapshot -i

agent-browser session list
```

### Connect to Existing Chrome (CDP)

For sites with Cloudflare or bot protection, connect to the user's real Chrome:

```bash
# Auto-discover running Chrome with remote debugging
agent-browser --auto-connect snapshot

# Or with explicit CDP port
agent-browser --cdp 9222 snapshot
agent-browser --cdp 9222 open https://example.com
```

**Setup**: User must launch Chrome with debugging enabled:
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug
```

### Visual Browser (Debugging)

```bash
agent-browser --headed open https://example.com
agent-browser highlight @e1          # Highlight element
```

### JavaScript Evaluation

Use `eval` for complex interactions. For complex JS, use `--stdin` to avoid shell quoting issues:

```bash
# Simple expressions
agent-browser eval 'document.title'
agent-browser eval 'document.querySelectorAll("img").length'

# Complex JS: use --stdin with heredoc (RECOMMENDED)
agent-browser eval --stdin <<'EVALEOF'
JSON.stringify(
  Array.from(document.querySelectorAll("img"))
    .filter(i => !i.alt)
    .map(i => ({ src: i.src.split("/").pop(), width: i.width }))
)
EVALEOF
```

## Ref Lifecycle (Important)

Refs (`@e1`, `@e2`, etc.) are invalidated when the page changes. Always re-snapshot after:

- Clicking links or buttons that navigate
- Form submissions
- Dynamic content loading (dropdowns, modals)

```bash
agent-browser click @e5              # Navigates to new page
agent-browser snapshot -i            # MUST re-snapshot
agent-browser click @e1              # Use new refs
```

## Semantic Locators (Alternative to Refs)

When refs are unavailable or unreliable:

```bash
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find role button click --name "Submit"
agent-browser find placeholder "Search" type "query"
agent-browser find testid "submit-btn" click
```

## Cloudflare / Bot Protection Sites

Many sites (Medium, LinkedIn, etc.) block Playwright's Chromium. The solution is CDP to the user's real Chrome:

1. **Pre-flight check**: `curl -s http://localhost:9222/json/version`
2. If fails, ask user to launch Chrome with debugging (see CDP section above)
3. Use `--cdp 9222` flag **before** every command: `agent-browser --cdp 9222 <command>`
4. The `--cdp` flag must come before the command, not after arguments

### Contenteditable Editors (Medium, Notion, etc.)

For rich text editors, `fill` and `type` often fail. Use `document.execCommand('insertText')` via eval:

```bash
# Click the editor area first
agent-browser --cdp 9222 click "selector"

# Insert text via execCommand (works with contenteditable)
agent-browser --cdp 9222 eval "document.execCommand('insertText', false, 'Your text here')"

# Press Enter for new paragraphs
agent-browser --cdp 9222 press Enter
```

**Never use `fill` or `type`** on contenteditable editors — they cause save errors or silent failures.
