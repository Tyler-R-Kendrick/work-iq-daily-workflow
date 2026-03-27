---
name: "Trial: Issue Triage"
description: >
  Uses 'gh aw trial' to test the issue-triage workflow in an isolated temporary
  repository. Creates test issues covering each triage scenario and verifies
  the expected labels and comments are applied.
on:
  workflow_dispatch:
    inputs:
      repeat:
        description: "Number of trial runs for consistency checking"
        required: false
        type: string
        default: "1"
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

# Trial: Issue Triage

You are a test runner for the `issue-triage` agentic workflow. Use `gh aw trial` to run the workflow in an isolated temporary repository with carefully crafted test scenarios.

## Step 1 — Run the Trial

Execute the following trial command to test `issue-triage` in an isolated environment:

```bash
gh aw trial .github/workflows/issue-triage.md \
  --delete-host-repo-after \
  --repeat {{ inputs.repeat || 1 }}
```

## Step 2 — Test Scenarios

The trial must cover these scenarios. For each, create a test issue in the trial repo and trigger the workflow, then verify the expected outcome:

### Scenario A — Email requiring action
- Issue body contains: "From: manager@company.com, Subject: Q2 Budget Review needed by Friday"
- Expected: `source:email`, `type:action-item`, `priority:high` (deadline this week), `effort:*`

### Scenario B — Teams @mention, no deadline
- Issue body contains: "Teams @mention in #engineering channel: can you review the PR?"  
- Expected: `source:teams`, `type:action-item`, `priority:medium`, `effort:small`

### Scenario C — FYI newsletter email
- Issue body contains: "Company Newsletter: Monthly engineering roundup"
- Expected: `source:email`, `type:fyi`, `priority:low`

### Scenario D — Decision needed, critical
- Issue body contains: "Escalated from director: URGENT approval needed for production deployment today"
- Expected: `type:decision-needed`, `priority:critical`

### Scenario E — Missing information
- Issue body contains only: "Reminder from meeting"
- Expected: `needs-info` label, comment asking for clarification

## Step 3 — Report Results

After the trial completes, examine the `trials/*.json` output. Report:
- Which scenarios passed (correct labels applied)
- Which scenarios failed (unexpected or missing labels)
- Any errors or unexpected behaviour

Create a comment on this workflow run issue (or the latest digest issue) with the full trial report.

## Pass Criteria

The trial **passes** if:
- All 5 scenarios produce the expected primary labels
- No issues are created without at least one `source:*` and one `type:*` label
- The `needs-info` label is applied to scenario E and a comment is left
