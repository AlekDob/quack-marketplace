---
name: obsidian-canvas-creator
description: Create Obsidian Canvas files from text content, supporting both MindMap and freeform layouts. Use this skill when users want to visualize content as an interactive canvas, create mind maps, or organize information spatially in Obsidian format.
---

# Obsidian Canvas Creator

Transform text content into structured Obsidian Canvas files with support for MindMap and freeform layouts.

## When to Use This Skill

- User requests to create a canvas, mind map, or visual diagram from text
- User wants to organize information spatially
- User mentions "Obsidian Canvas" or similar visualization tools
- Converting structured content (articles, notes, outlines) into visual format

## Core Workflow

### 1. Analyze Content

Read and understand the input content:
- Identify main topics and hierarchical relationships
- Extract key points, facts, and supporting details
- Note any existing structure (headings, lists, sections)

### 2. Determine Layout Type

**MindMap Layout:**
- Radial structure from center
- Parent-child relationships
- Clear hierarchy
- Good for: brainstorming, topic exploration, hierarchical content

**Freeform Layout:**
- Custom positioning
- Flexible relationships
- Multiple connection types
- Good for: complex networks, non-hierarchical content, custom arrangements

### 3. Plan Structure

**For MindMap:**
- Identify central concept (root node)
- Map primary branches (main topics)
- Organize secondary branches (subtopics)
- Position leaf nodes (details)

**For Freeform:**
- Group related concepts
- Identify connection patterns
- Plan spatial zones
- Consider visual flow

### 4. Generate Canvas

Create JSON following the Canvas specification:

**Node Creation:**
- Assign unique 8-12 character hex IDs
- Set appropriate dimensions based on content length
- Apply consistent color schemes
- Ensure no coordinate overlaps

**Edge Creation:**
- Connect parent-child relationships
- Use appropriate arrow styles
- Add labels for complex relationships

### 5. Apply Layout Algorithm

**MindMap:**
- Center root at (0, 0)
- Distribute primary nodes radially
- Space secondary nodes based on sibling count
- Maintain minimum spacing: 320px horizontal, 200px vertical

**Freeform:**
- Start with logical groupings
- Position groups with clear separation
- Connect across groups with curved edges
- Balance visual weight across canvas

### 6. Validate and Output

**Validation Checklist:**
- All nodes have unique IDs
- No coordinate overlaps (distance > node dimensions + spacing)
- All edges reference valid node IDs
- Colors use consistent format (hex or preset numbers)
- JSON is properly escaped

**Output**: Complete, valid `.canvas` JSON file directly importable into Obsidian.

## Node Sizing Guidelines

| Text Length | Dimensions |
|---|---|
| Short (<30 chars) | 220 x 100 px |
| Medium (30-60 chars) | 260 x 120 px |
| Long (60-100 chars) | 320 x 140 px |
| Very long (>100 chars) | 320 x 180 px |

## Color Presets

| Value | Color | Use for |
|---|---|---|
| `"1"` | Red | Warnings, important |
| `"2"` | Orange | Action items |
| `"3"` | Yellow | Questions, notes |
| `"4"` | Green | Positive, completed |
| `"5"` | Cyan | Information, details |
| `"6"` | Purple | Concepts, abstract |

## Node Types

### Text Node
```json
{
  "id": "a1b2c3d4e5f6",
  "type": "text",
  "x": 0, "y": 0,
  "width": 260, "height": 120,
  "color": "4",
  "text": "Markdown content here"
}
```

### File Node (references vault files)
```json
{
  "id": "file01abc",
  "type": "file",
  "x": 400, "y": 0,
  "width": 260, "height": 120,
  "file": "path/to/note.md",
  "subpath": "#heading-or-^block-id"
}
```

### Link Node (external URLs)
```json
{
  "id": "link01abc",
  "type": "link",
  "x": 800, "y": 0,
  "width": 260, "height": 120,
  "url": "https://example.com"
}
```

### Group Node (visual container)
```json
{
  "id": "group01abc",
  "type": "group",
  "x": -50, "y": -50,
  "width": 600, "height": 400,
  "label": "Category Name",
  "background": "path/to/image.png",
  "backgroundStyle": "cover"
}
```

`backgroundStyle`: `"cover"` | `"ratio"` | `"repeat"`

## Canvas JSON Structure

```json
{
  "nodes": [
    {
      "id": "a1b2c3d4e5f6",
      "type": "text",
      "x": 0, "y": 0,
      "width": 260, "height": 120,
      "color": "4",
      "text": "Node content here"
    }
  ],
  "edges": [
    {
      "id": "edge01abc",
      "fromNode": "a1b2c3d4e5f6",
      "toNode": "b2c3d4e5f6a1",
      "fromSide": "right",
      "toSide": "left"
    }
  ]
}
```

## Edge Properties

```json
{
  "id": "edge01abc",
  "fromNode": "nodeId1",
  "toNode": "nodeId2",
  "fromSide": "right",
  "toSide": "left",
  "fromEnd": "none",
  "toEnd": "arrow",
  "color": "2",
  "label": "relationship"
}
```

- `fromSide`/`toSide`: `"top"` | `"right"` | `"bottom"` | `"left"`
- `fromEnd`/`toEnd`: `"none"` | `"arrow"` (default: `"none"` for from, `"arrow"` for to)

## Critical Rules

1. **IDs**: 8-12 character random hex strings, unique across all nodes/edges
2. **Quote escaping**: Use `\"` for English quotes in JSON
3. **Z-order**: Groups first (bottom), then nodes (top)
4. **Spacing**: Min 320px horizontal, 200px vertical between centers
5. **Output**: Only JSON, no explanation text. File extension: `.canvas`
6. **Validation**: All edge fromNode/toNode must reference existing node IDs
7. **Coordinates**: Can be negative. Width/height must be positive integers
