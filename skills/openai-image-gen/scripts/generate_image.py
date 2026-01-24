#!/usr/bin/env python3
"""
OpenAI Image Generation Script

Generates images using OpenAI's gpt-image-1 model and saves them to disk.
Requires OPENAI_API_KEY environment variable to be set.

Usage:
    python3 generate_image.py --prompt "Your prompt" --output ./image.png
    python3 generate_image.py --prompt "Your prompt" --output ./image.webp --quality high --size 1536x1024
    python3 generate_image.py --prompt "Your prompt" --output ./image.png --background transparent --n 3
"""

import argparse
import base64
import json
import os
import sys
import time
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError


API_URL = "https://api.openai.com/v1/images/generations"
MAX_RETRIES = 3
RETRY_DELAY = 2  # seconds, doubles each retry
QUACK_PREFS_PATH = os.path.expanduser(
    "~/Library/Application Support/com.quack.terminal/app-preferences.json"
)


def get_quack_preferences() -> dict:
    """Load Quack app preferences from disk."""
    if os.path.exists(QUACK_PREFS_PATH):
        try:
            with open(QUACK_PREFS_PATH, "r") as f:
                prefs = json.load(f)
            return prefs.get("preferences", {})
        except (json.JSONDecodeError, Exception) as e:
            print(f"Warning: Could not read Quack preferences: {e}", file=sys.stderr)
    return {}


def get_api_key() -> str:
    """Get OpenAI API key from environment or Quack preferences."""
    # 1. Check environment variable first
    key = os.environ.get("OPENAI_API_KEY")
    if key:
        return key

    # 2. Try reading from Quack app preferences (base64-encoded)
    prefs = get_quack_preferences()
    encoded_key = prefs.get("openai_api_key")
    if encoded_key:
        try:
            decoded = base64.b64decode(encoded_key).decode("utf-8")
            if decoded.startswith("sk-"):
                return decoded
        except Exception:
            pass

    print("Error: OpenAI API key not found.", file=sys.stderr)
    print("Set OPENAI_API_KEY env var or configure in Quack Settings > AI Assistant.", file=sys.stderr)
    sys.exit(1)


def get_preferred_image_model() -> str:
    """Get preferred image model from Quack preferences."""
    prefs = get_quack_preferences()
    return prefs.get("image_model", "gpt-image-1.5")


def get_output_format(filepath: str) -> str:
    """Infer output format from file extension."""
    ext = Path(filepath).suffix.lower()
    format_map = {
        ".png": "png",
        ".webp": "webp",
        ".jpg": "jpeg",
        ".jpeg": "jpeg",
    }
    fmt = format_map.get(ext)
    if not fmt:
        print(f"Error: Unsupported file extension '{ext}'. Use .png, .webp, or .jpg", file=sys.stderr)
        sys.exit(1)
    return fmt


def generate_image(
    prompt: str,
    output_format: str,
    size: str = "auto",
    quality: str = "high",
    background: str = "opaque",
    n: int = 1,
    model: str = "gpt-image-1",
) -> list[str]:
    """Call OpenAI Images API and return list of base64-encoded images."""
    api_key = get_api_key()

    payload = {
        "model": model,
        "prompt": prompt,
        "n": n,
        "size": size,
        "quality": quality,
        "background": background,
        "output_format": output_format,
    }

    # Remove 'auto' values to let API use defaults
    if size == "auto":
        del payload["size"]

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    data = json.dumps(payload).encode("utf-8")
    request = Request(API_URL, data=data, headers=headers, method="POST")

    for attempt in range(MAX_RETRIES):
        try:
            with urlopen(request, timeout=120) as response:
                result = json.loads(response.read().decode("utf-8"))
                return [item["b64_json"] for item in result["data"]]
        except HTTPError as e:
            error_body = e.read().decode("utf-8") if e.readable() else ""
            try:
                error_json = json.loads(error_body)
                error_msg = error_json.get("error", {}).get("message", error_body)
            except json.JSONDecodeError:
                error_msg = error_body

            if e.code == 429 or e.code >= 500:
                if attempt < MAX_RETRIES - 1:
                    delay = RETRY_DELAY * (2 ** attempt)
                    print(f"Retry {attempt + 1}/{MAX_RETRIES} after {delay}s (HTTP {e.code})", file=sys.stderr)
                    time.sleep(delay)
                    continue
            print(f"Error: OpenAI API returned HTTP {e.code}: {error_msg}", file=sys.stderr)
            sys.exit(1)
        except URLError as e:
            if attempt < MAX_RETRIES - 1:
                delay = RETRY_DELAY * (2 ** attempt)
                print(f"Retry {attempt + 1}/{MAX_RETRIES} after {delay}s (network error)", file=sys.stderr)
                time.sleep(delay)
                continue
            print(f"Error: Network error: {e.reason}", file=sys.stderr)
            sys.exit(1)
        except Exception as e:
            print(f"Error: Unexpected error: {e}", file=sys.stderr)
            sys.exit(1)

    print("Error: Max retries exceeded", file=sys.stderr)
    sys.exit(1)


def save_images(images: list[str], output_path: str) -> list[str]:
    """Save base64-encoded images to disk. Returns list of saved paths."""
    output = Path(output_path)
    output.parent.mkdir(parents=True, exist_ok=True)

    saved_paths = []

    if len(images) == 1:
        img_data = base64.b64decode(images[0])
        output.write_bytes(img_data)
        saved_paths.append(str(output))
    else:
        stem = output.stem
        suffix = output.suffix
        parent = output.parent
        for i, img_b64 in enumerate(images, 1):
            img_data = base64.b64decode(img_b64)
            path = parent / f"{stem}_{i}{suffix}"
            path.write_bytes(img_data)
            saved_paths.append(str(path))

    return saved_paths


def main():
    parser = argparse.ArgumentParser(description="Generate images with OpenAI image models")
    parser.add_argument("--prompt", required=True, help="Image generation prompt (max 32,000 chars)")
    parser.add_argument("--output", required=True, help="Output file path (.png, .webp, .jpg)")
    parser.add_argument("--size", default="auto", choices=["1024x1024", "1536x1024", "1024x1536", "auto"],
                        help="Image size (default: auto)")
    parser.add_argument("--quality", default="high", choices=["low", "medium", "high"],
                        help="Image quality (default: high)")
    parser.add_argument("--background", default="opaque", choices=["opaque", "transparent", "auto"],
                        help="Background type (default: opaque)")
    parser.add_argument("--n", type=int, default=1, help="Number of images to generate (1-10)")
    preferred_model = get_preferred_image_model()
    parser.add_argument("--model", default=preferred_model,
                        choices=["gpt-image-1.5", "gpt-image-1", "gpt-image-1-mini", "dall-e-3", "dall-e-2"],
                        help=f"Model to use (default: {preferred_model} from Quack settings)")

    args = parser.parse_args()

    if args.n < 1 or args.n > 10:
        print("Error: --n must be between 1 and 10", file=sys.stderr)
        sys.exit(1)

    if len(args.prompt) > 32000:
        print(f"Error: Prompt too long ({len(args.prompt)} chars, max 32,000)", file=sys.stderr)
        sys.exit(1)

    output_format = get_output_format(args.output)

    if args.background == "transparent" and output_format == "jpeg":
        print("Warning: JPEG doesn't support transparency. Switching to PNG.", file=sys.stderr)
        args.output = str(Path(args.output).with_suffix(".png"))
        output_format = "png"

    print(f"Generating {args.n} image(s) with {args.model}...", file=sys.stderr)
    print(f"  Quality: {args.quality} | Size: {args.size} | Format: {output_format}", file=sys.stderr)

    images = generate_image(
        prompt=args.prompt,
        output_format=output_format,
        size=args.size,
        quality=args.quality,
        background=args.background,
        n=args.n,
        model=args.model,
    )

    saved_paths = save_images(images, args.output)

    for path in saved_paths:
        print(path)

    print(f"Done! Generated {len(saved_paths)} image(s).", file=sys.stderr)


if __name__ == "__main__":
    main()
