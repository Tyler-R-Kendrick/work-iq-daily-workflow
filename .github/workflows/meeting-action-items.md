---
name: "Meeting Action Items"
description: >
  When a meeting transcript or notes file is pushed to the repo (under
  meetings/), extract all action items assigned to the repository owner
  and create GitHub Issues for each one.
on:
  push:
    paths:
      - "meetings/**/*.md"
      - "meetings/**/*.txt"
      - "meetings/**/*.vtt"
  workflow_dispatch:
    inputs:
      file_path:
        description: "Path to the meeting notes/transcript file to process"
        required: true
        type: string
permissions:
  issues: write
  contents: read
tools:
  github:
    toolsets:
      - issues
      - context
  repo-memory:
    branch-name: memory/workflow-state
    file-glob:
      - "meeting-action-items/*.jsonl"
safe-outputs:
  create-issue:
    label-allowlist:
      - "source:meeting"
      - "type:action-item"
      - "type:follow-up"
      - "type:decision-needed"
      - "priority:critical"
      - "priority:high"
      - "priority:medium"
      - "priority:low"
  add-comment: {}---

# Meeting Action Items

You are an expert meeting facilitator and task extractor. When a meeting transcript or notes file is pushed to this repository, identify all action items assigned to the repository owner and create GitHub Issues for each one.

## Step 1 — Read the Meeting File

Read the content of the pushed file (or the file specified by `file_path` input). The file may be:
- A Markdown notes file (`.md`) — look for action item sections, bullet points with owner names, or bold text like **Action:** or **TODO:**
- A plain text transcript (`.txt`) — look for phrases like "you should", "can you", "action item:", "assigned to you", "follow up on"
- A WebVTT transcript (`.vtt`) — parse the transcript text and look for action-oriented phrases directed at the owner

## Step 2 — Extract Action Items

Extract every item that:
- Is explicitly assigned to the repository owner (look for their name, "you", "Tyler", "@user" or any first-person assignment)
- Requires a concrete action (not just information)
- Is mentioned in the context of a commitment, request, or decision

For each action item, identify:
- The action description (what needs to be done)
- The assigner (who asked/assigned it)
- The deadline (if mentioned)
- Priority clues (urgency words, blocker status)

## Step 3 — Skip Already-Processed Files

Check repo-memory `meeting-action-items/processed-files.jsonl` to see if this file (by path + commit SHA) has already been processed. If so, skip and add a comment on the related workflow run noting it was already processed.

## Step 4 — Create GitHub Issues

For each extracted action item, create a GitHub Issue:
- **Title**: Verb-noun action title (e.g. "Share Q2 roadmap draft with stakeholders")
- **Body**:
  - Action description
  - Source: meeting title (from filename or file header), date, assigner
  - Original quote from transcript/notes
  - Deadline (if identified)
- **Labels**: `source:meeting` + appropriate `type:*` and `priority:*`
- **Linked file**: Reference the meeting notes file path in the body

## Step 5 — Update Repo Memory

Append the processed file path and commit SHA to `meeting-action-items/processed-files.jsonl`.

## Notes

- If no action items are found for the owner, create a brief comment on the workflow run (or use `add-comment` on an existing digest issue) noting "No action items found in <filename>."
- Do not create issues for action items assigned to other people.
- Infer the meeting date from the filename if present (e.g. `2026-03-27-standup.md`).
