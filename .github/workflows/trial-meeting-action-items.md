---
name: "Trial: Meeting Action Items"
description: >
  Uses 'gh aw trial' to test the meeting-action-items workflow using sample
  transcript fixtures. Verifies that action items are correctly extracted and
  converted into GitHub Issues.
on:
  workflow_dispatch:
    inputs:
      fixture:
        description: "Which test fixture to use (sample-meeting | minimal | no-actions)"
        required: false
        type: string
        default: "sample-meeting"
permissions:
  contents: read
tools:
  github:
    toolsets:
      - issues
      - context
      - shell
safe-outputs:
  add-comment:
    max: 1
---

# Trial: Meeting Action Items

You are a test runner for the `meeting-action-items` agentic workflow. Use `gh aw trial` to run the workflow in an isolated temporary repository with sample meeting transcripts.

## Step 1 — Select Fixture

Based on the `fixture` input, select the corresponding test file:
- `sample-meeting` → `tests/fixtures/sample-meeting.md` (rich meeting notes with multiple action items)
- `minimal` → `tests/fixtures/minimal-meeting.txt` (brief transcript with one action item)
- `no-actions` → `tests/fixtures/no-actions-meeting.md` (meeting transcript with no actions for the owner)

## Step 2 — Run the Trial

Copy the selected fixture file to a `meetings/` directory in the trial repo and trigger the workflow:

```bash
gh aw trial .github/workflows/meeting-action-items.md \
  --delete-host-repo-after \
  --append "Use the file at meetings/{{ fixture }}.md as the trigger file."
```

## Step 3 — Verify Results

### For `sample-meeting` fixture:
- Expected: **4 issues** created from the sample meeting (see `tests/fixtures/sample-meeting.md` for the 4 action items assigned to Tyler)
- Each issue should have: `source:meeting` label, `type:action-item` or `type:follow-up`, appropriate priority
- Issue titles should start with action verbs
- Issue bodies should reference the source meeting file

### For `minimal` fixture:
- Expected: **1 issue** created

### For `no-actions` fixture:
- Expected: **0 issues** created, but a comment noting no action items were found

## Step 4 — Report Results

Create a comment on the latest digest issue summarising:
- Number of issues created vs expected
- Whether labels and titles match expected format
- Any errors encountered

## Pass Criteria

- `sample-meeting`: 4 correctly labelled issues created
- `minimal`: 1 correctly labelled issue created
- `no-actions`: 0 issues, informational comment added
