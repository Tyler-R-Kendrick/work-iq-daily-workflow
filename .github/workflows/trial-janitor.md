---
name: "Trial: Janitor"
description: >
  Uses 'gh aw trial' to test the janitor workflow with a pre-seeded set of
  stale, duplicate, and FYI issues. Verifies correct closure, labelling, and
  deduplication behaviour.
on:
  workflow_dispatch:
    inputs:
      dry_run:
        description: "Run with dry_run=true to verify reporting without mutations"
        required: false
        type: boolean
        default: true
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

# Trial: Janitor

You are a test runner for the `janitor` agentic workflow. Use `gh aw trial` to run the workflow in an isolated temporary repository pre-seeded with known test cases.

## Step 1 — Seed the Trial Repository

Before running the trial, create the following issues in the trial repo:

| # | Title | Labels | Age (days) | Expected action |
|---|-------|--------|-----------|----------------|
| 1 | "FYI: Engineering newsletter" | `type:fyi` | 8 | Close (FYI > 7 days) |
| 2 | "Reply to Sarah about budget" | `type:action-item` | 22 | Close (stale > 21 days) |
| 3 | "Review deployment PR" | `type:action-item`, `status:stale` | 16 | Close (already stale > 7 days) |
| 4 | "Reply to John about project X" | `type:action-item` | 15 | Add `status:stale`, post check-in comment |
| 5 | "Reply to John re: project X" | `type:action-item` | 14 | Detect as duplicate of #4, close |
| 6 | "Critical deployment decision" | `type:decision-needed`, `priority:critical` | 3 | Do NOT close (critical) |

## Step 2 — Run the Trial

```bash
gh aw trial .github/workflows/janitor.md \
  --delete-host-repo-after \
  --append "Use dry_run={{ inputs.dry_run }} mode."
```

## Step 3 — Verify Results

After the trial, verify:

- Issue #1: Closed with comment "Closing as FYI item is older than 7 days"
- Issue #2: Closed with stale comment
- Issue #3: Closed (already stale > 7 days)
- Issue #4: `status:stale` label added, check-in comment posted
- Issue #5: `status:duplicate` label added, closed referencing #4
- Issue #6: NOT closed (critical — requires human confirmation)
- A summary report is present (either as comment on digest issue or as new issue)

If `dry_run=true`:
- None of the above mutations should occur
- A report issue/comment should exist describing what would have happened

## Pass Criteria

All 6 issues behave as specified in the expected action column.
Critical issues are NEVER closed by the janitor.
