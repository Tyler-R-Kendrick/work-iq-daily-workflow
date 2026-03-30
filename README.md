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

| Workflow | Trigger | Manual inputs | Description |
|----------|---------|---------------|-------------|
| [`daily-task-creator`](.github/workflows/daily-task-creator.md) | Weekdays 7:00 UTC | `dry_run`, `lookback_hours` | Queries Work IQ; creates issues from emails, Teams, meetings, follow-ups |
| [`issue-triage`](.github/workflows/issue-triage.md) | On issue opened/reopened | `issue_number` | Labels issues, sets priority & effort, updates project fields |
| [`janitor`](.github/workflows/janitor.md) | Nightly 23:00 UTC | `dry_run` | Closes stale/FYI issues, merges duplicates, archives completed work |
| [`daily-digest`](.github/workflows/daily-digest.md) | Weekdays 7:30 UTC | `date_override` | Creates a morning digest issue with today's priorities and stats |
| [`meeting-action-items`](.github/workflows/meeting-action-items.md) | On push to `meetings/` | `file_path` | Extracts action items from meeting notes/transcripts |
| [`followup-reminder`](.github/workflows/followup-reminder.md) | Weekdays 9:00 UTC | `dry_run` | Nudges stale follow-up and decision-needed issues |

### Test/Trial Workflows

| Workflow | Description |
|----------|-------------|
| [`trial-issue-triage`](.github/workflows/trial-issue-triage.md) | Tests issue-triage in an isolated repo using `gh aw trial` |
| [`trial-meeting-action-items`](.github/workflows/trial-meeting-action-items.md) | Tests meeting extraction with sample fixtures |
| [`trial-janitor`](.github/workflows/trial-janitor.md) | Tests janitor with pre-seeded stale/duplicate issues |
| [`trial-daily-task-creator`](.github/workflows/trial-daily-task-creator.md) | Tests auth error handling and dry-run mode |
| [`validate-workflows`](.github/workflows/validate-workflows.yml) | CI: validates frontmatter, labels, and secret documentation |

---

## Prerequisites

- **GitHub Copilot** license (for agentic workflow execution)
- **Microsoft 365 with Work IQ** access — see [Work IQ CLI docs](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/workiq-overview)
- **GitHub Projects** — a project board connected to this repository

---

## Setup

### 1. Clone and Open in Codespaces / Dev Container

```bash
gh repo clone Tyler-R-Kendrick/work-iq-daily-workflow
cd work-iq-daily-workflow
```

Or open directly in GitHub Codespaces — the universal dev container will automatically install all required tools. When creating the Codespace, GitHub will prompt you to fill in the required secrets (defined in `devcontainer.json`).

---

### 2. Environment Variables and Secrets

All four secrets must be configured in **two places**:
- **GitHub Actions secrets** → `Settings → Secrets and variables → Actions` (for workflow runs)
- **GitHub Codespaces secrets** → `Settings → Secrets and variables → Codespaces` (for dev container)

| Secret | Required | Description |
|--------|----------|-------------|
| `WORKIQ_TENANT_ID` | ✅ | Your Microsoft 365 / Azure AD **Directory (tenant) ID**. Found in [Entra ID → Overview](https://entra.microsoft.com/). |
| `WORKIQ_CLIENT_ID` | ✅ | The Work IQ app registration **Application (client) ID**. Found in Entra ID → App registrations → your Work IQ app. |
| `WORKIQ_REFRESH_TOKEN` | ✅ | OAuth 2.0 refresh token for non-interactive auth. See [Obtaining a WorkIQ Refresh Token](#obtaining-a-workiq-refresh-token) below. |
| `PROJECT_NUMBER` | ✅ | Your GitHub Project number. Found in the project URL: `github.com/users/<user>/projects/<number>`. |

---

### 3. Obtaining a WorkIQ Refresh Token

> **Why a refresh token?** The Work IQ CLI uses delegated (user-based) OAuth authentication. It does not yet support service principal / client credentials flow ([issue #77](https://github.com/microsoft/work-iq/issues/77)). The supported approach for CI/CD is to obtain a refresh token once via interactive login and store it as a GitHub secret.

**Step-by-step:**

1. **Install Work IQ CLI** (if not already done via dev container):
   ```bash
   npm install -g @microsoft/workiq
   workiq accept-eula
   ```

2. **Run interactive login** (requires a browser):
   ```bash
   workiq login
   ```
   This opens a browser window to Microsoft Entra ID. Sign in with your Microsoft 365 account and complete any MFA prompts.

3. **Locate and extract the refresh token**:
   ```bash
   # The token cache is stored locally after login:
   cat ~/.workiq/config.json
   ```
   Find the `refreshToken` (or `refresh_token`) field and copy its value. This is your `WORKIQ_REFRESH_TOKEN`.

   > **Official reference:** [Microsoft Work IQ CLI authentication](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/workiq-overview)  
   > **Token lifetime:** Refresh tokens are valid for up to 90 days by default. You will need to repeat this process when the token expires or is revoked.  
   > **Security:** Treat `WORKIQ_REFRESH_TOKEN` with the same care as a password — store it only in GitHub Secrets, never in source code.

4. **Test connectivity** before storing the token:
   ```bash
   workiq ask -q "What emails do I have flagged for follow-up?"
   ```

5. **Add as GitHub Secrets** (`WORKIQ_REFRESH_TOKEN`, `WORKIQ_TENANT_ID`, `WORKIQ_CLIENT_ID`):
   ```bash
   gh secret set WORKIQ_TENANT_ID
   gh secret set WORKIQ_CLIENT_ID
   gh secret set WORKIQ_REFRESH_TOKEN
   gh secret set PROJECT_NUMBER
   ```
   Or set via the GitHub UI at `Settings → Secrets and variables → Actions`.

6. **Set the same secrets for Codespaces** (for dev container use):
   ```bash
   gh secret set --app codespaces WORKIQ_TENANT_ID
   gh secret set --app codespaces WORKIQ_CLIENT_ID
   gh secret set --app codespaces WORKIQ_REFRESH_TOKEN
   gh secret set --app codespaces PROJECT_NUMBER
   ```

---

### 4. Create GitHub Project Labels

Run the following to create the required labels (or create them via the GitHub UI):

```bash
# Source labels
gh label create "source:email"    --color "0075ca" --description "Sourced from email"
gh label create "source:teams"    --color "6f42c1" --description "Sourced from Teams"
gh label create "source:meeting"  --color "e4e669" --description "Sourced from meeting notes/transcript"
gh label create "source:followup" --color "d93f0b" --description "Sourced from follow-up flags"

# Type labels
gh label create "type:action-item"     --color "b60205" --description "Requires a concrete action"
gh label create "type:follow-up"       --color "e99695" --description "Requires tracking until resolved"
gh label create "type:fyi"             --color "c2e0c6" --description "Informational, no action required"
gh label create "type:decision-needed" --color "f9d0c4" --description "Requires a decision"

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
gh label create "status:wont-do"   --color "eeeeee" --description "Closed without action"
gh label create "needs-info"       --color "d876e3" --description "More information needed"
gh label create "digest"           --color "bfd4f2" --description "Daily digest issue"
```

---

### 5. Compile and Enable Agentic Workflows

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

---

## Testing Workflows

### Automated Validation (CI)

The `validate-workflows.yml` workflow runs automatically on every push/PR that modifies workflow files. It validates:
- YAML frontmatter syntax and required fields
- `workflow_dispatch` trigger presence
- Label and secret documentation completeness

### Manual Trial Testing

Use `gh aw trial` to run any workflow in an **isolated temporary repository** with no side effects:

```bash
# Test issue-triage with sample scenarios
gh aw trial .github/workflows/issue-triage.md --delete-host-repo-after

# Test meeting action item extraction
gh aw trial .github/workflows/meeting-action-items.md \
  --delete-host-repo-after \
  --append "Use the file at tests/fixtures/sample-meeting.md as the trigger file."

# Test janitor in dry-run mode
gh aw trial .github/workflows/janitor.md \
  --delete-host-repo-after \
  --append "Use dry_run=true mode."
```

Or run the dedicated trial workflows from the GitHub UI: **Actions → Trial: \<Name\> → Run workflow**.

See [`tests/README.md`](tests/README.md) for full test documentation and fixture descriptions.

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
3. Commit **both** the `.md` and the regenerated `.lock.yml`

### Refresh Token Rotation

When your `WORKIQ_REFRESH_TOKEN` expires (≤ 90 days), repeat the [token extraction steps](#obtaining-a-workiq-refresh-token) and update the secret:

```bash
workiq login   # re-authenticate interactively
cat ~/.workiq/config.json   # extract new refresh token
gh secret set WORKIQ_REFRESH_TOKEN   # update Actions secret
gh secret set --app codespaces WORKIQ_REFRESH_TOKEN   # update Codespaces secret
```
