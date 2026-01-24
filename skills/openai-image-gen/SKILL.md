---
name: openai-image-gen
description: Generate images using OpenAI's GPT Image API (gpt-image-1.5). This skill should be used when the user asks to generate, create, or produce images, illustrations, or visual assets. Handles prompt optimization, API calls, and saves output images to disk. Supports transparent backgrounds, multiple sizes, and quality levels.
---

# OpenAI Image Generation

Generate high-quality images using OpenAI's `gpt-image-1.5` model (or other image models) via the Images API.

## Prerequisites

The script automatically reads the OpenAI API key from one of these sources (in order):

1. **Environment variable** `OPENAI_API_KEY` (if set)
2. **Quack app preferences** at `~/Library/Application Support/com.quack.terminal/app-preferences.json` (base64-encoded)

If using Quack, configure the key in **Settings > AI Assistant > API Key**. No additional setup needed.

The image generation model is also read from Quack settings (**Settings > AI Assistant > Image Generation Model**). Default is `gpt-image-1.5`. Override with `--model` flag if needed.

## Usage

To generate an image, run the bundled script:

```bash
python3 <skill-path>/scripts/generate_image.py \
  --prompt "Your detailed prompt here" \
  --output /path/to/output.png \
  --size 1024x1024 \
  --quality high
```

### Parameters

| Parameter | Required | Default | Options |
|-----------|----------|---------|---------|
| `--prompt` | Yes | - | Up to 32,000 chars |
| `--output` | Yes | - | Output file path (.png, .webp, .jpg) |
| `--size` | No | `auto` | `1024x1024`, `1536x1024`, `1024x1536`, `auto` |
| `--quality` | No | `high` | `low`, `medium`, `high` |
| `--background` | No | `opaque` | `opaque`, `transparent`, `auto` |
| `--n` | No | `1` | Number of images (1-10) |
| `--model` | No | From Settings | `gpt-image-1.5`, `gpt-image-1`, `gpt-image-1-mini`, `dall-e-3`, `dall-e-2` |

### Output Format

The output format is inferred from the file extension:
- `.png` - PNG (supports transparency)
- `.webp` - WebP (supports transparency, smaller file size)
- `.jpg` / `.jpeg` - JPEG (no transparency, smaller file size)

### Examples

Generate a single high-quality illustration:
```bash
python3 <skill-path>/scripts/generate_image.py \
  --prompt "Flat graphic illustration of Planet Quack. Style: 1960s Italian radical design." \
  --output ./planet-quack.png \
  --size 1536x1024 \
  --quality high
```

Generate with transparent background (for overlays):
```bash
python3 <skill-path>/scripts/generate_image.py \
  --prompt "A rubber duck astronaut floating in space" \
  --output ./duck-astronaut.webp \
  --size 1024x1024 \
  --quality high \
  --background transparent
```

Generate multiple variations:
```bash
python3 <skill-path>/scripts/generate_image.py \
  --prompt "Soviet constructivist space poster with rubber duck" \
  --output ./poster.png \
  --n 3 \
  --quality medium
```

When generating multiple images (`--n > 1`), output files are named with suffixes: `poster_1.png`, `poster_2.png`, `poster_3.png`.

## Workflow Integration

After generating images, use them in downstream tasks:

1. **Website assets**: Generate, then copy to `public/images/` in the project
2. **Iterations**: Generate with `--quality low` first for fast previews, then `--quality high` for final
3. **Transparent overlays**: Use `--background transparent` with `.webp` or `.png` for compositing
4. **Batch generation**: Call the script multiple times with different prompts for a complete image set

## Prompt Best Practices

For the best results with gpt-image-1:

1. **Be specific about style**: "1960s Italian radical design, screen print aesthetic, no 3D"
2. **Specify what NOT to do**: "No photorealism, no gradients, no shadows"
3. **Include color codes**: "Navy blue (#0A1628), orange (#FF6B35)"
4. **Structure the prompt**: Use STYLE, SUBJECT, MOOD sections
5. **Reference artists/movements**: "Enzo Mari, Bruno Munari, Soviet constructivism"

## Pricing Reference

| Quality | Approx. Cost per Image |
|---------|----------------------|
| Low | ~$0.02 |
| Medium | ~$0.07 |
| High | ~$0.19 |

## Error Handling

The script returns structured output:
- **Success**: Prints the saved file path(s) to stdout and exits with code 0
- **Failure**: Prints error message to stderr and exits with code 1

Common errors:
- Missing `OPENAI_API_KEY` environment variable
- Invalid prompt (too long, content policy violation)
- Network timeout (retries 3 times with exponential backoff)
