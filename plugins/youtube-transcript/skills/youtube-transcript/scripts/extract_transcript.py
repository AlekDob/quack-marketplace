#!/usr/bin/env python3
"""
YouTube Transcript Extractor
Extracts video metadata and subtitles using yt-dlp, outputs JSON to stdout.

Exit codes:
  0 - Success
  1 - General error (network, parsing, etc.)
  2 - yt-dlp not found
  3 - Video unavailable (private, age-restricted, etc.)
  4 - No subtitles available
"""

import argparse
import html
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Extract YouTube video transcript"
    )
    parser.add_argument("url", help="YouTube video URL")
    parser.add_argument(
        "--lang",
        default=None,
        help="Preferred subtitle language code (e.g., en, it, fr)",
    )
    return parser.parse_args()


def normalize_url(url: str) -> str:
    """Normalize various YouTube URL formats to standard watch URL."""
    # youtu.be/VIDEO_ID
    match = re.match(
        r"https?://youtu\.be/([a-zA-Z0-9_-]+)", url
    )
    if match:
        return f"https://www.youtube.com/watch?v={match.group(1)}"

    # youtube.com/shorts/VIDEO_ID
    match = re.match(
        r"https?://(?:www\.)?youtube\.com/shorts/([a-zA-Z0-9_-]+)",
        url,
    )
    if match:
        return f"https://www.youtube.com/watch?v={match.group(1)}"

    # youtube.com/embed/VIDEO_ID
    match = re.match(
        r"https?://(?:www\.)?youtube\.com/embed/([a-zA-Z0-9_-]+)",
        url,
    )
    if match:
        return f"https://www.youtube.com/watch?v={match.group(1)}"

    return url


def check_ytdlp():
    """Check if yt-dlp is installed."""
    if shutil.which("yt-dlp") is None:
        print(
            "Error: yt-dlp is not installed. "
            "Install it with: brew install yt-dlp (or) pip3 install yt-dlp",
            file=sys.stderr,
        )
        sys.exit(2)


def get_video_metadata(url: str) -> dict:
    """Fetch video metadata using yt-dlp --dump-json."""
    result = subprocess.run(
        ["yt-dlp", "--dump-json", "--no-download", url],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        stderr = result.stderr.strip()
        if "Private video" in stderr or "unavailable" in stderr.lower():
            print(f"Error: Video unavailable - {stderr}", file=sys.stderr)
            sys.exit(3)
        print(f"Error fetching metadata: {stderr}", file=sys.stderr)
        sys.exit(1)

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as e:
        print(f"Error parsing metadata JSON: {e}", file=sys.stderr)
        sys.exit(1)


def format_duration(seconds: int) -> str:
    """Format seconds into M:SS or H:MM:SS string."""
    if seconds is None:
        return "0:00"
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    secs = seconds % 60
    if hours > 0:
        return f"{hours}:{minutes:02d}:{secs:02d}"
    return f"{minutes}:{secs:02d}"


def format_timestamp(seconds: float, use_hours: bool) -> str:
    """Format a timestamp in seconds to M:SS or H:MM:SS."""
    total = int(seconds)
    hours = total // 3600
    minutes = (total % 3600) // 60
    secs = total % 60
    if use_hours:
        return f"{hours}:{minutes:02d}:{secs:02d}"
    return f"{minutes}:{secs:02d}"


def pick_subtitle_track(
    metadata: dict, preferred_lang: str | None
) -> tuple[str, bool]:
    """
    Determine the best subtitle track to download.
    Returns (language_code, is_auto_generated).

    Priority:
    1. Manual subs in preferred language
    2. Auto subs in preferred language
    3. Manual subs in any available language
    4. Auto subs in any available language
    """
    manual_subs = metadata.get("subtitles") or {}
    auto_subs = metadata.get("automatic_captions") or {}

    # Filter out non-language keys (e.g., 'live_chat')
    manual_langs = {
        k for k in manual_subs if k != "live_chat"
    }
    auto_langs = {
        k for k in auto_subs if k != "live_chat"
    }

    if preferred_lang:
        if preferred_lang in manual_langs:
            return (preferred_lang, False)
        if preferred_lang in auto_langs:
            return (preferred_lang, True)

    # Try original language from metadata
    orig_lang = metadata.get("language")
    if orig_lang:
        if orig_lang in manual_langs:
            return (orig_lang, False)
        if orig_lang in auto_langs:
            return (orig_lang, True)

    # Fallback: first available manual, then first auto
    if manual_langs:
        lang = sorted(manual_langs)[0]
        return (lang, False)
    if auto_langs:
        lang = sorted(auto_langs)[0]
        return (lang, True)

    return (None, False)


def collect_available_languages(metadata: dict) -> list[str]:
    """Collect all available subtitle languages."""
    manual = set(metadata.get("subtitles") or {})
    auto = set(metadata.get("automatic_captions") or {})
    all_langs = (manual | auto) - {"live_chat"}
    return sorted(all_langs)


def download_subtitles(
    url: str,
    lang: str,
    is_auto: bool,
    tmpdir: str,
) -> str | None:
    """
    Download subtitles to tmpdir, return path to the SRV1 XML file.
    """
    sub_flag = "--write-auto-sub" if is_auto else "--write-sub"
    output_tpl = os.path.join(tmpdir, "subs")

    cmd = [
        "yt-dlp",
        sub_flag,
        "--sub-lang", lang,
        "--sub-format", "srv1",
        "--skip-download",
        "-o", output_tpl,
        url,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(
            f"Error downloading subtitles: {result.stderr.strip()}",
            file=sys.stderr,
        )
        return None

    # Find the downloaded subtitle file
    for fname in os.listdir(tmpdir):
        if fname.endswith(".srv1"):
            return os.path.join(tmpdir, fname)

    return None


def parse_srv1(filepath: str) -> list[dict]:
    """
    Parse SRV1 XML subtitle file.
    Returns list of {"start": float, "text": str}.
    """
    try:
        tree = ET.parse(filepath)
    except ET.ParseError as e:
        print(f"Error parsing subtitle XML: {e}", file=sys.stderr)
        return []

    root = tree.getroot()
    entries = []

    for text_elem in root.iter("text"):
        start = float(text_elem.get("start", "0"))
        raw_text = text_elem.text or ""
        # Decode HTML entities and clean up
        clean_text = html.unescape(raw_text).strip()
        # Remove newlines within a single entry
        clean_text = clean_text.replace("\n", " ")
        if clean_text:
            entries.append({"start": start, "text": clean_text})

    return entries


def build_output(
    metadata: dict,
    lang: str | None,
    is_auto: bool,
    transcript: list[dict],
    available_languages: list[str],
) -> dict:
    """Build the final JSON output structure."""
    duration = metadata.get("duration") or 0
    chapters_raw = metadata.get("chapters") or []

    chapters = [
        {
            "title": ch.get("title", ""),
            "start_time": int(ch.get("start_time", 0)),
        }
        for ch in chapters_raw
    ]

    return {
        "title": metadata.get("title", "Unknown Title"),
        "channel": metadata.get("channel", "Unknown Channel"),
        "duration": duration,
        "duration_string": format_duration(duration),
        "language": lang or "unknown",
        "is_auto_generated": is_auto,
        "chapters": chapters,
        "transcript": transcript,
        "available_languages": available_languages,
    }


def main():
    """Main entry point."""
    args = parse_args()
    check_ytdlp()

    url = normalize_url(args.url)

    # Fetch metadata
    metadata = get_video_metadata(url)

    # Determine subtitle track
    lang, is_auto = pick_subtitle_track(metadata, args.lang)
    available_languages = collect_available_languages(metadata)

    if lang is None:
        # No subtitles at all
        output = build_output(
            metadata, None, False, [], available_languages
        )
        print(json.dumps(output, ensure_ascii=False, indent=2))
        print(
            "Warning: No subtitles available for this video.",
            file=sys.stderr,
        )
        sys.exit(4)

    # Download and parse subtitles
    tmpdir = tempfile.mkdtemp(prefix="yt_transcript_")
    try:
        sub_path = download_subtitles(url, lang, is_auto, tmpdir)

        if sub_path is None:
            # Download failed, output metadata without transcript
            output = build_output(
                metadata, lang, is_auto, [], available_languages
            )
            print(json.dumps(output, ensure_ascii=False, indent=2))
            sys.exit(1)

        transcript = parse_srv1(sub_path)
        output = build_output(
            metadata, lang, is_auto, transcript, available_languages
        )
        print(json.dumps(output, ensure_ascii=False, indent=2))

    finally:
        # Clean up temp directory
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == "__main__":
    main()
