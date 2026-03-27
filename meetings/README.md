# Meeting Notes & Transcripts

Place meeting notes, transcripts, and action item files in this directory to trigger the **Meeting Action Items** agentic workflow.

## Supported Formats

| Format | Extension | Description |
|--------|-----------|-------------|
| Markdown notes | `.md` | Structured meeting notes with action item sections |
| Plain text transcript | `.txt` | Verbatim meeting transcript |
| WebVTT caption file | `.vtt` | Exported Teams/Zoom/Meet caption file |

## Naming Convention

Use the following naming pattern for files to enable automatic date extraction:

```
YYYY-MM-DD-<meeting-name>.{md,txt,vtt}
```

Examples:
- `2026-03-27-standup.md`
- `2026-03-27-q2-planning.txt`
- `2026-03-27-1on1-with-manager.vtt`

## How It Works

1. Drop a meeting notes or transcript file into this directory and push to the repository.
2. The `Meeting Action Items` agentic workflow automatically triggers.
3. The workflow extracts all action items assigned to you.
4. Individual GitHub Issues are created for each action item on the project board.
5. The issues are then triaged by the `Issue Triage` workflow (labels, priority, effort).

## Manual Trigger

You can also process a file manually without pushing:

```bash
gh aw run meeting-action-items --input file_path=meetings/2026-03-27-standup.md
```
