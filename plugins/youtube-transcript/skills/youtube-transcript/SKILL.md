---
name: youtube-transcript
description: "Extract YouTube video transcripts with timestamps, chapters, and AI summaries. Use when the user provides a YouTube URL and wants text output, transcript extraction, video summarization, or subtitle download. Triggers on: YouTube links, 'transcript', 'sottotitoli', 'what does this video say', 'summarize this video'."
---

# YouTube Transcript Extractor

Extract transcripts, chapters, and generate summaries from any YouTube video using yt-dlp.

## Quick Start

1. The user provides a YouTube URL (any format: watch, youtu.be, shorts, embed)
2. Run the Python extraction script
3. Parse the JSON output
4. Format the result as readable markdown with a generated summary

## Setup Check

Before running the script, verify yt-dlp is installed:

```bash
which yt-dlp
```

If yt-dlp is NOT found, install it automatically:

```bash
# macOS (preferred)
brew install yt-dlp

# Fallback (any platform)
pip3 install yt-dlp
```

Also ensure Python 3 is available:

```bash
python3 --version
```

## Usage

Run the extraction script with the YouTube URL:

```bash
python3 <skill-dir>/scripts/extract_transcript.py <youtube-url>
```

To request a specific language:

```bash
python3 <skill-dir>/scripts/extract_transcript.py <youtube-url> --lang it
```

Where `<skill-dir>` is the directory containing this SKILL.md file.

### Examples

```bash
# Standard URL
python3 <skill-dir>/scripts/extract_transcript.py "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Short URL
python3 <skill-dir>/scripts/extract_transcript.py "https://youtu.be/dQw4w9WgXcQ"

# Force Italian subtitles
python3 <skill-dir>/scripts/extract_transcript.py "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --lang it
```

## Output Format

The script outputs JSON to stdout. You MUST parse this JSON and format it as markdown.

### JSON Structure

```json
{
  "title": "Video Title",
  "channel": "Channel Name",
  "duration": 1234,
  "duration_string": "20:34",
  "language": "en",
  "is_auto_generated": false,
  "chapters": [
    {"title": "Intro", "start_time": 0},
    {"title": "Main Topic", "start_time": 150}
  ],
  "transcript": [
    {"start": 0.0, "text": "Hello everyone"},
    {"start": 2.5, "text": "Welcome to the video"}
  ],
  "available_languages": ["en", "it", "fr", "de"]
}
```

### Markdown Formatting

Format the JSON output into this exact structure:

```
# [Video Title]

**Channel:** Channel Name | **Duration:** MM:SS | **Language:** en (auto-generated: yes/no)

## Summary

[Generate a 3-5 sentence summary based on the transcript content. Read the full transcript and write a concise summary capturing the main points, key arguments, and conclusions.]

## Chapters

- [0:00] Intro
- [2:30] Main topic
- [10:15] Conclusion

## Full Transcript

[0:00] First line of the transcript...
[0:15] Second line of the transcript...
[0:32] Third line of the transcript...
```

**Rules for formatting:**

- The **Summary** section is ALWAYS present. YOU generate it by reading the transcript content.
- The **Chapters** section is only included if the video has chapters (the `chapters` array is non-empty).
- Timestamps use `M:SS` for videos under 1 hour, `H:MM:SS` for longer videos.
- Each transcript entry is on its own line prefixed with its timestamp in brackets.

## Multi-language Support

The script handles language selection automatically:

1. **Manual subtitles** are preferred over auto-generated ones
2. If `--lang` is provided, the script looks for that language first
3. If the requested language is not available, it falls back to the video's original language
4. Auto-generated subtitles are used as a last resort

The `available_languages` field in the output lists all subtitle tracks found (both manual and auto-generated).

When the user asks for subtitles in a specific language (e.g., "dammi i sottotitoli in italiano"), pass `--lang` with the appropriate ISO code:

| Language | Code |
|----------|------|
| English | en |
| Italian | it |
| French | fr |
| German | de |
| Spanish | es |
| Portuguese | pt |
| Japanese | ja |
| Korean | ko |
| Chinese | zh |

## Error Handling

### yt-dlp not installed

If the script exits with code 2 and message about yt-dlp not found:

1. Try `brew install yt-dlp` (macOS)
2. If brew fails, try `pip3 install yt-dlp`
3. Re-run the script after installation

### Private or unavailable video

If the script exits with code 3:
- The video may be private, age-restricted, or region-locked
- Inform the user that the video cannot be accessed

### No subtitles available

If the script exits with code 4:
- The video has no subtitles (neither manual nor auto-generated)
- Inform the user that no transcript is available for this video
- Suggest they try a different video or check if the video has captions enabled

### Network or parsing errors

If the script exits with code 1:
- A general error occurred (network issue, XML parse failure, etc.)
- The stderr output contains the error details
- Report the error to the user

## Important

1. **Always run the script FIRST**, then format the JSON output as markdown
2. **Generate the Summary section yourself** based on the transcript content - the script does NOT generate summaries
3. If the transcript is very long (>500 entries), you may truncate the Full Transcript section and note that it was truncated
4. Always show the available languages so the user knows what options exist
5. The script uses temporary files that are cleaned up automatically - no manual cleanup needed
