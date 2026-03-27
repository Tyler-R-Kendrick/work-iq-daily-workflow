# Work IQ Daily Workflow

An AI-powered daily productivity system that connects **Microsoft Work IQ** (emails, Teams messages, meeting transcripts, follow-ups) to a **GitHub Projects** board via agentic workflows powered by [GitHub Agentic Workflows (`gh-aw`)](https://github.github.com/gh-aw/).

## Overview

Every workday, this system automatically:

1. **Collects** actionable items from your Microsoft 365 inbox (emails, Teams mentions, meeting action items, follow-up flags) via Work IQ.
2. **Creates** GitHub Issues for each item, adding them to your project board.
3. **Triages** each issue — assigning labels, priority, effort estimates, and project fields.
4. **Reminds** you about stale follow-ups and overdue items.
5. **Digests** your day into a single morning summary issue.
6. **Maintains** the board nightly — closing stale issues, merging duplicates, and archiving completed work.

---

## Agentic Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| [`daily-task-creator`](.github/workflows/daily-task-creator.md) | Weekdays 7:00 UTC | Queries Work IQ and creates issues from emails, Teams messages, meetings, and follow-up flags |
| [`issue-triage`](.github/workflows/issue-triage.md) | On issue opened/reopened | Labels issues, sets priority and effort, updates GitHub Project fields |
| [`janitor`](.github/workflows/janitor.md) | Nightly 23:00 UTC | Closes stale/FYI issues, merges duplicates, archives completed work |
| [`daily-digest`](.github/workflows/daily-digest.md) | Weekdays 7:30 UTC | Creates a morning digest issue with today's priorities and stats |
| [`meeting-action-items`](.github/workflows/meeting-action-items.md) | On push to `meetings/` | Extracts action items from meeting notes/transcripts pushed to the repo |
| [`followup-reminder`](.github/workflows/followup-reminder.md) | Weekdays 9:00 UTC | Nudges stale follow-up and decision-needed issues |

---

## Prerequisites

- **GitHub Copilot** license (for agentic workflow execution)
- **Microsoft 365 with Work IQ** access (and admin consent for the Work IQ app registration)
- **GitHub Projects** — a project board connected to this repository

---

## Setup

### 1. Clone and Open in Codespaces / Dev Container

```bash
gh repo clone Tyler-R-Kendrick/work-iq-daily-workflow
cd work-iq-daily-workflow
```

Or open directly in GitHub Codespaces — the universal dev container will automatically install all required tools.

### 2. Configure Repository Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description |
|--------|-------------|
| `WORKIQ_TENANT_ID` | Your Microsoft 365 tenant ID |
| `WORKIQ_CLIENT_ID` | App registration client ID for Work IQ |
| `WORKIQ_CLIENT_SECRET` | App registration client secret |
| `PROJECT_NUMBER` | Your GitHub Project number (from the project URL) |

### 3. Create GitHub Project Labels

Run the following to create the required labels (or create them via the GitHub UI):

```bash
# Source labels
gh label create "source:email"   --color "0075ca" --description "Sourced from email"
gh label create "source:teams"   --color "6f42c1" --description "Sourced from Teams"
gh label create "source:meeting" --color "e4e669" --description "Sourced from meeting notes/transcript"
gh label create "source:followup" --color "d93f0b" --description "Sourced from follow-up flags"

# Type labels
gh label create "type:action-item"      --color "b60205" --description "Requires a concrete action"
gh label create "type:follow-up"        --color "e99695" --description "Requires tracking until resolved"
gh label create "type:fyi"              --color "c2e0c6" --description "Informational, no action required"
gh label create "type:decision-needed"  --color "f9d0c4" --description "Requires a decision"

# Priority labels
gh label create "priority:critical" --color "b60205" --description "Critical priority"
gh label create "priority:high"     --color "e11d48" --description "High priority"
gh label create "priority:medium"   --color "f59e0b" --description "Medium priority"
gh label create "priority:low"      --color "6ee7b7" --description "Low priority"

# Effort labels
gh label create "effort:small"  --color "0e8a16" --description "< 30 minutes"
gh label create "effort:medium" --color "fbca04" --description "30 min – 2 hours"
gh label create "effort:large"  --color "e4e669" --description "> 2 hours"

# Status labels
gh label create "status:stale"     --color "cccccc" --description "No recent activity"
gh label create "status:duplicate" --color "cccccc" --description "Duplicate of another issue"
gh label create "needs-info"       --color "d876e3" --description "More information needed"
gh label create "digest"           --color "bfd4f2" --description "Daily digest issue"
```

### 4. Compile and Enable Agentic Workflows

```bash
# Install the gh-aw extension (if not already done by dev container)
gh extension install github/gh-aw

# Initialise agentic workflows for this repo
gh aw init

# Compile all workflow source files (.md → .lock.yml)
gh aw compile --all

# Verify the compiled workflows
gh aw list
```

### 5. Authenticate Work IQ

```bash
# Log in to Work IQ (requires M365 account with admin-consented app registration)
workiq login

# Test connectivity
workiq ask -q "What emails do I have flagged for follow-up?"
```

---

## Repository Memory

Workflow state is persisted to a dedicated Git branch (`memory/workflow-state`) using the [`gh-aw` repo-memory](https://github.github.com/gh-aw/reference/repo-memory/) feature. This allows workflows to:
- Track which Work IQ items have already been processed (avoiding duplicates)
- Resume after interruptions
- Share state across workflows (e.g., triage knowing what digest was created today)

---

## Adding Meeting Notes

Drop meeting transcript or notes files into the [`meetings/`](meetings/) directory and push them. The `meeting-action-items` workflow will automatically extract action items and create issues.

See [`meetings/README.md`](meetings/README.md) for supported formats and naming conventions.

---

## Development

See [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for architecture details, label conventions, and Copilot workspace context.

When modifying an agentic workflow:
1. Edit the `.md` source file in `.github/workflows/`
2. Run `gh aw compile <workflow-name>` to regenerate the `.lock.yml`
3. Commit both the `.md` and the regenerated `.lock.yml`