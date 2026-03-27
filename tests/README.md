# Tests

This directory contains test fixtures and supporting files for validating the agentic workflows in this repository.

## Test Infrastructure

### 1. Automated Validation (`validate-workflows.yml`)

Runs on every push/PR that touches `.github/workflows/*.md`. Checks:
- All workflow `.md` files have valid YAML frontmatter
- All required frontmatter fields are present (`name`, `on`, `permissions`, `tools`, `safe-outputs`)
- Every workflow has a `workflow_dispatch` trigger (for manual testing)
- All labels referenced in `safe-outputs` are documented in the README
- All required secrets are documented in both README and `devcontainer.json`

### 2. Agentic Workflow Trials (`trial-*.md`)

Trial workflows use `gh aw trial` to run each main workflow in an isolated temporary repository with no side effects on production data.

| Trial Workflow | Tests | Trigger |
|---|---|---|
| `trial-issue-triage.md` | 5 triage scenarios with expected label outcomes | `workflow_dispatch` |
| `trial-meeting-action-items.md` | 3 fixture files: rich meeting, minimal, no-actions | `workflow_dispatch` |
| `trial-janitor.md` | Pre-seeded stale/duplicate issues; verifies closure logic | `workflow_dispatch` |
| `trial-daily-task-creator.md` | Auth error handling + dry-run mode | `workflow_dispatch` |

Run a trial from the command line:
```bash
gh aw trial .github/workflows/issue-triage.md --delete-host-repo-after
```

Or trigger via the GitHub UI: **Actions → Trial: <Name> → Run workflow**.

## Fixtures

### `fixtures/sample-meeting.md`

Rich Q2 Engineering Planning meeting notes with **4 action items** assigned to Tyler:
1. Share Q2 roadmap draft with stakeholders (due: March 29)
2. Review and approve deployment automation PR #142 (due: April 3)
3. Follow up with Jordan re: payment test coverage (due: April 7)
4. Review and approve Acme Corp demo script (due: April 4)

Used by: `trial-meeting-action-items.md` (scenario: `sample-meeting`)

### `fixtures/minimal-meeting.vtt`

WebVTT transcript of a short standup with **2 action items** for Tyler:
1. Write release notes for v2.1 (due: Friday)
2. Review security audit findings document (due: Thursday)

Used by: `trial-meeting-action-items.md` (scenario: `minimal`)

### `fixtures/no-actions-meeting.md`

Meeting notes where Tyler was absent and **no action items** were assigned to Tyler.

Used by: `trial-meeting-action-items.md` (scenario: `no-actions`)

## Running Tests Locally

```bash
# Validate all workflow frontmatter
npm install -g js-yaml
bash .github/workflows/validate-workflows.yml  # (or trigger via gh act / GitHub UI)

# Run a trial for issue-triage
gh aw trial .github/workflows/issue-triage.md --delete-host-repo-after

# Run a trial for meeting-action-items with a fixture
gh aw trial .github/workflows/meeting-action-items.md \
  --delete-host-repo-after \
  --append "Use the file at tests/fixtures/sample-meeting.md as the trigger file."

# Dry-run the janitor
gh aw trial .github/workflows/janitor.md \
  --delete-host-repo-after \
  --append "Use dry_run=true mode."
```
