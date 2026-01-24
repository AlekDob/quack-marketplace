---
name: obsidian-markdown
description: Create and edit valid Obsidian Flavored Markdown files. Use this skill when writing .md files intended for Obsidian, using wikilinks, callouts, properties, embeds, or other Obsidian-specific syntax.
---

# Obsidian Flavored Markdown

Write valid Obsidian-compatible markdown combining CommonMark, GitHub Flavored Markdown, LaTeX, and Obsidian extensions.

## Obsidian-Specific Syntax

### Wikilinks (Internal Links)

```markdown
[[Note Name]]                    # Link to note
[[Note Name|Display Text]]       # Link with alias
[[Note Name#Heading]]            # Link to heading
[[Note Name#^block-id]]          # Link to block
[[##heading text]]               # Search vault for heading
[[^^block text]]                 # Search vault for block
```

### Obsidian URI Links

```markdown
[Open note](obsidian://open?vault=MyVault&file=Note.md)
[Search](obsidian://search?vault=MyVault&query=keyword)
```

### Embeds

```markdown
![[Note Name]]                   # Embed entire note
![[image.png]]                   # Embed image
![[image.png|300]]               # Image with width
![[audio.mp3]]                   # Embed audio
![[document.pdf]]                # Embed PDF
![[document.pdf#page=3]]         # Embed PDF at page
```

### Callouts

```markdown
> [!note] Title
> Content of the note callout

> [!warning] Be careful
> This is a warning

> [!tip]+ Collapsible (open by default)
> Use + for open, - for closed

> [!question]- Collapsed by default
> Hidden until clicked
```

**Callout types**: note, abstract, info, tip, success, question, warning, failure, danger, bug, example, quote

### Properties (Frontmatter)

```yaml
---
title: My Note
date: 2025-01-23
tags:
  - project/quack
  - type/decision
aliases:
  - Alternative Name
cssclasses:
  - wide-page
---
```

**Supported types**: text, number, date, datetime, checkbox, list

### Tags

```markdown
#tag
#nested/tag
#project/quack-app
```

Tags support: letters, numbers, underscores, hyphens, forward slashes (nesting).

### Highlights

```markdown
==highlighted text==
```

### Block IDs

```markdown
This is a paragraph with a block ID. ^my-block-id

- List item with ID ^list-id
```

### Comments (Hidden)

```markdown
%%
This text won't render in preview mode.
%%

Inline comment: %%hidden%% visible text
```

### Footnotes

```markdown
Here is a footnote[^1] reference.

[^1]: This is the footnote content.
```

### HTML Content

Obsidian supports inline HTML for advanced formatting:

```markdown
<details>
<summary>Collapsible section</summary>
Hidden content revealed on click.
</details>

<kbd>Ctrl</kbd> + <kbd>C</kbd> for keyboard shortcuts

<div style="background: #1a1a2e; padding: 1em; border-radius: 8px;">
Custom styled block
</div>
```

### Horizontal Rules

```markdown
---
***
___
```

## Standard Markdown (also supported)

- **Bold**: `**text**`
- *Italic*: `*text*`
- ~~Strikethrough~~: `~~text~~`
- Code: `` `inline` `` and fenced blocks
- Tables with `|` alignment
- Task lists: `- [ ]` and `- [x]`
- LaTeX: `$inline$` and `$$block$$`
- Mermaid diagrams in fenced code blocks
- Images with size: `![Alt|300](url)` or `![Alt|300x200](url)`

## URL Encoding

In standard markdown links (not wikilinks), encode spaces as `%20`:
```markdown
[Link](path%20with%20spaces/file.md)
```

## Escaping

Use backslash to escape special characters:
```markdown
\*not bold\*
\#not a heading
\[\[not a wikilink\]\]
```

## Best Practices

1. Use wikilinks `[[]]` for internal connections (not markdown links)
2. Put metadata in YAML frontmatter, not inline
3. Use callouts for structured information blocks
4. Use block IDs sparingly - only when needed for linking
5. Use hierarchical tags for organization: `#type/bug`, `#project/name`
