# Work IQ Daily Workflow — Copilot Instructions

This repository orchestrates an AI-powered daily productivity loop that connects **Microsoft Work IQ** (emails, Teams messages, meeting transcripts, follow-ups) to **GitHub Projects** via a set of agentic workflows.

## Purpose & Architecture

The system is built around a **collect → triage → maintain** pipeline:

1. **Collect** (`daily-task-creator`) — Runs every morning, queries Work IQ for actionable items (unread emails, Teams mentions, meeting action items, follow-up flags), and creates GitHub Issues in the project board.
2. **Triage** (`issue-triage`) — Runs after new issues are created (on `issues.opened`), labels each issue, assigns priority, and updates project fields.
3. **Maintain** (`janitor`) — Runs nightly, removes completed/stale issues, merges duplicates, and keeps the board clean.

Complementary workflows:
- **`meeting-action-items`** — Triggered when a meeting transcript or notes file is pushed to the repo; extracts action items and creates individual issues.
- **`daily-digest`** — Creates a daily digest issue summarising outstanding tasks, priorities, and items due today.
- **`followup-reminder`** — Scans issues labelled `follow-up` and adds reminder comments when they become stale.

## Repository Conventions

- **Work IQ source data** is queried at runtime via the `workiq` CLI inside the GitHub Actions runner (credentials provided via repository secrets `WORKIQ_TENANT_ID`, `WORKIQ_CLIENT_ID`, `WORKIQ_REFRESH_TOKEN`).
- All agentic workflow source files live in `.github/workflows/*.md`; compiled versions are `*.lock.yml` in the same directory.
- **Labels used:**
  - `source:email`, `source:teams`, `source:meeting`, `source:followup` — origin of the task
  - `priority:critical`, `priority:high`, `priority:medium`, `priority:low`
  - `type:action-item`, `type:follow-up`, `type:fyi`, `type:decision-needed`
  - `status:stale`, `status:duplicate`
- **GitHub Project fields** expected: `Priority` (single-select), `Due Date` (date), `Source` (text).
- **Repo memory** is stored on branch `memory/workflow-state` (managed automatically by gh-aw).

## Secrets Required

| Secret | Description |
|---|---|
| `WORKIQ_TENANT_ID` | Microsoft 365 tenant ID (Azure AD Directory ID) |
| `WORKIQ_CLIENT_ID` | Work IQ app registration client ID |
| `WORKIQ_REFRESH_TOKEN` | OAuth 2.0 refresh token (obtained via `workiq login`; see README) |
| `PROJECT_NUMBER` | GitHub Project number for this repo |

> **Note on WorkIQ auth**: The Work IQ CLI uses delegated (user-based) OAuth authentication. Non-interactive CI auth is achieved by pre-seeding a `WORKIQ_REFRESH_TOKEN` obtained from a one-time `workiq login`. Service principal auth is not yet supported (tracked in [microsoft/work-iq#77](https://github.com/microsoft/work-iq/issues/77)).

## Development Workflow

When modifying agentic workflow source files (`.md`):
1. Edit the `.md` file in `.github/workflows/`
2. Run `gh aw compile <workflow-name>` to regenerate the `.lock.yml`
3. Commit **both** the `.md` and the regenerated `.lock.yml`

Use `gh aw run <workflow-name>` to test a workflow manually.
