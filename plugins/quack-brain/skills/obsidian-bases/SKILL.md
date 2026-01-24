---
name: obsidian-bases
description: Create and edit Obsidian Bases (.base files) with views, filters, formulas, and summaries. Use this skill when users want database-like views of their notes, filtered tables, card galleries, or computed properties from frontmatter.
---

# Obsidian Bases

Create and edit valid `.base` files for Obsidian's database-like views. Bases read note properties (YAML frontmatter) and display them as filterable, sortable tables, cards, or lists.

## File Format

Base files use `.base` extension and contain valid YAML.

## Complete Schema

```yaml
# Global filters (apply to all views)
filter: 'type == "bug_fix"'

# Formula definitions
formulas:
  days_old: '(now() - date(created)) / duration("1d")'
  is_recent: 'if(days_old < 7, "Yes", "No")'

# Property display configuration
properties:
  title:
    displayName: Title
  created:
    displayName: Created
  tags:
    displayName: Tags

# Custom summary formulas
summaries:
  total_items: 'count()'

# View definitions (multiple allowed)
views:
  - name: All Items
    type: table
    order:
      - property: created
        direction: desc
    properties:
      - title
      - created
      - type
      - tags
  - name: Cards
    type: cards
    coverProperty: cover_image
    properties:
      - title
      - created
```

## Filter Syntax

```yaml
# Single filter
filter: 'status == "done"'

# AND (all must match)
filter:
  and:
    - 'type == "bug_fix"'
    - 'project == "quack-app"'

# OR (any matches)
filter:
  or:
    - 'type == "pattern"'
    - 'type == "decision"'

# NOT (exclude)
filter:
  not: 'type == "diary"'

# Nested
filter:
  and:
    - 'project == "quack-app"'
    - or:
      - 'type == "bug_fix"'
      - 'type == "gotcha"'
```

**Operators**: `==`, `!=`, `>`, `<`, `>=`, `<=`, `&&`, `||`, `!`

## Properties

Three property types:

1. **Note properties** (from frontmatter): `type`, `project`, `created`, `tags`
2. **File properties** (automatic): `file.name`, `file.basename`, `file.path`, `file.folder`, `file.ext`, `file.size`, `file.ctime`, `file.mtime`, `file.tags`, `file.links`, `file.backlinks`, `file.embeds`, `file.properties`
3. **Formula properties** (computed): `formula.days_old`, `formula.is_recent`

## Formula Functions

**Global**: `date()`, `duration()`, `now()`, `today()`, `if()`, `min()`, `max()`, `link()`, `file()`, `icon()`, `html()`

**String**: `contains()`, `startsWith()`, `endsWith()`, `lower()`, `title()`, `trim()`, `replace()`, `split()`

**Number**: `abs()`, `ceil()`, `floor()`, `round()`, `toFixed()`

**List**: `filter()`, `map()`, `reduce()`, `flat()`, `join()`, `sort()`, `unique()`

**Date**: `format()`, `relative()` + field access: `.year`, `.month`, `.day`, `.hour`, `.minute`

**File**: `hasLink()`, `hasTag()`, `hasProperty()`, `inFolder()`

## View Types

### Table
```yaml
views:
  - name: Bug List
    type: table
    filter: 'type == "bug_fix"'
    order:
      - property: created
        direction: desc
    group:
      - property: project
    properties:
      - file.name
      - created
      - tags
    summary:
      - property: file.name
        formula: count()
```

### Cards
```yaml
views:
  - name: Knowledge Cards
    type: cards
    coverProperty: cover_image
    properties:
      - file.name
      - type
      - created
```

### List
```yaml
views:
  - name: Simple List
    type: list
    properties:
      - file.name
      - type
```

### Map
Requires latitude/longitude properties and Obsidian Maps plugin.

## Default Summary Formulas

- `count()` - Number of items
- `countUnique(property)` - Unique values
- `countValues(property)` - Non-empty values
- `sum(property)` - Sum of numeric values
- `avg(property)` - Average
- `min(property)` / `max(property)` - Min/max values
- `range(property)` - Difference between max and min
- `earliest(property)` / `latest(property)` - Date extremes
- `dateRange(property)` - Date span

## Quack Brain Base Examples

### Project Knowledge Base
```yaml
filter:
  and:
    - 'inFolder("projects/quack-app")'
    - not: 'type == "diary"'

formulas:
  age_days: '(now() - date(created)) / duration("1d")'

views:
  - name: All Knowledge
    type: table
    order:
      - property: created
        direction: desc
    properties:
      - file.name
      - type
      - tags
      - created
      - formula.age_days
    summary:
      - property: file.name
        formula: count()
  - name: By Type
    type: cards
    group:
      - property: type
    properties:
      - file.name
      - tags
      - created
```

### Bug Tracker Base
```yaml
filter: 'type == "bug_fix"'

formulas:
  project_link: 'link(project)'

views:
  - name: All Bugs
    type: table
    order:
      - property: created
        direction: desc
    properties:
      - file.name
      - project
      - tags
      - created
    group:
      - property: project
    summary:
      - property: file.name
        formula: count()
```

## Embedding Bases

Embed a base view in any note:

```markdown
![[my-base.base#View Name]]
```

## YAML Quoting Rules

- Strings with special chars must be quoted: `'status == "done"'`
- Use single quotes for filter expressions
- Use double quotes inside expressions for string values
- Escape literal single quotes with `''` (doubled)

## Critical Rules

1. Extension must be `.base`
2. Content must be valid YAML
3. All referenced properties must exist in note frontmatter or be file/formula properties
4. Filter expressions use single quotes wrapping, double quotes for values
5. View names should be descriptive and unique within the file
