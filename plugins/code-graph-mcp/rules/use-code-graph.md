---
description: "Use Code Graph MCP for intelligent code navigation instead of manual Glob/Grep exploration"
---
# Code Graph MCP - Intelligent Code Navigation

You have access to **Code Graph MCP** tools for code analysis. Use these instead of manual Glob/Grep exploration when investigating code structure and relationships.

## Available MCP Tools

| Tool | Use When | Performance |
|------|----------|-------------|
| `find_definition` | Looking for where a symbol is defined | Fast (<3s) |
| `find_references` | Finding all usages of a symbol | Fast (<3s) |
| `find_callers` | Understanding who calls a function | Fast (<3s) |
| `find_callees` | Understanding what a function calls | Fast (<3s) |
| `analyze_codebase` | Getting a full project overview | Expensive (10-60s) |
| `complexity_analysis` | Identifying complex/risky code | Moderate (5-15s) |
| `dependency_analysis` | Understanding import graphs | Moderate (3-10s) |
| `project_statistics` | Quick health check | Fast (<3s) |

## When to Use

**PREFER Code Graph MCP over manual search when:**
- Finding where a function/class/type is defined
- Finding all references to a symbol across the codebase
- Understanding call chains (who calls what)
- Analyzing dependencies between modules
- Getting complexity metrics for refactoring decisions

**Use manual Glob/Grep when:**
- Searching for string literals or comments (not code structure)
- Looking for config files or non-code content
- The MCP server is not available

## Workflow

1. **Definition lookup**: Use `find_definition` instead of `Grep "function foo"` + reading multiple files
2. **Impact analysis**: Use `find_references` before modifying a function to understand blast radius
3. **Architecture understanding**: Use `dependency_analysis` for a quick module dependency overview
4. **Code quality**: Use `complexity_analysis` to identify refactoring targets

## Performance Tips

- `find_definition` and `find_references` are fast (<3s) — use freely
- `analyze_codebase` is expensive (10-60s) — use sparingly, only for initial project overview
- Results are cached — repeated queries on the same symbols are near-instant
