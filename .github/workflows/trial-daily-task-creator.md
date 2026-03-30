---
name: "Trial: Daily Task Creator"
description: >
  Uses 'gh aw trial' to test the daily-task-creator workflow in dry-run mode.
  Since Work IQ requires live M365 credentials, this trial focuses on validating
  authentication handling, error paths, and dry-run reporting.
on:
  workflow_dispatch:
    inputs:
      scenario:
        description: "Test scenario: auth-missing | auth-valid-dry-run"
        required: false
        type: string
        default: "auth-valid-dry-run"
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

# Trial: Daily Task Creator

You are a test runner for the `daily-task-creator` agentic workflow. Use `gh aw trial` to validate the workflow's authentication handling and dry-run mode.

## Important Note on Work IQ

Work IQ requires live Microsoft 365 credentials. These tests focus on:
1. **Authentication error handling** — what happens when credentials are missing/invalid
2. **Dry-run mode** — verifying the workflow reports correctly without creating issues

## Scenario: `auth-missing`

Run the trial **without** Work IQ secrets to verify graceful degradation:

```bash
gh aw trial .github/workflows/daily-task-creator.md \
  --delete-host-repo-after \
  --append "Simulate missing WORKIQ_REFRESH_TOKEN by treating any auth error as a test pass."
```

**Expected outcome:**
- No issues created from Work IQ
- A single issue is created titled "⚠️ Work IQ authentication required" with instructions to update the WORKIQ_REFRESH_TOKEN secret
- The workflow exits without error (graceful failure)

## Scenario: `auth-valid-dry-run`

Run the trial with Work IQ secrets and `dry_run=true`:

```bash
gh aw trial .github/workflows/daily-task-creator.md \
  --delete-host-repo-after \
  --push-secrets \
  --append "Set dry_run=true. Do not create any issues. Output a dry-run report."
```

**Expected outcome:**
- Work IQ is queried successfully
- No real issues are created
- A report comment/issue exists titled `[Dry Run] Daily Task Creator Report — <date>` listing what would have been created

## Step 3 — Report

Summarise the trial results as a comment on the latest digest issue.

## Pass Criteria

- `auth-missing`: Graceful error issue created, no crash
- `auth-valid-dry-run`: Dry-run report generated, no production issues created
