---
name: "Daily Task Creator"
description: >
  Every weekday morning, query Microsoft Work IQ for actionable items from the
  past 24 hours (emails, Teams messages, mentions, meeting action items, and
  follow-up flags) and create corresponding GitHub Issues in the project board.
on:
  schedule:
    - cron: "0 7 * * 1-5"
  workflow_dispatch: {}
permissions:
  issues: write
  contents: read
env:
  WORKIQ_TENANT_ID: ${{ secrets.WORKIQ_TENANT_ID }}
  WORKIQ_CLIENT_ID: ${{ secrets.WORKIQ_CLIENT_ID }}
  WORKIQ_CLIENT_SECRET: ${{ secrets.WORKIQ_CLIENT_SECRET }}
  PROJECT_NUMBER: ${{ secrets.PROJECT_NUMBER }}
tools:
  github:
    toolsets:
      - issues
      - context
  workiq:
    toolsets:
      - email
      - teams
      - meetings
      - followups
  repo-memory:
    branch-name: memory/workflow-state
    file-glob:
      - "daily-task-creator/*.json"
      - "daily-task-creator/*.jsonl"
safe-outputs:
  create-issue:
    label-allowlist:
      - "source:email"
      - "source:teams"
      - "source:meeting"
      - "source:followup"
      - "type:action-item"
      - "type:follow-up"
      - "type:fyi"
      - "type:decision-needed"
      - "priority:high"
      - "priority:medium"
      - "priority:low"
    add-to-project: true
  add-comment: {}
---

# Daily Task Creator

You are a personal productivity assistant. Every weekday morning, help the repository owner stay on top of their Microsoft 365 workday by converting actionable items into GitHub Issues.

## Step 1 — Query Work IQ

Using the Work IQ tools, retrieve the following from the past 24 hours (or since the last run recorded in repo-memory):

1. **Unread / flagged emails** — emails that are flagged for follow-up, marked important, or addressed directly to the user requiring a response.
2. **Teams direct messages and @mentions** — messages in chats or channels where the user was mentioned or messaged directly.
3. **Meeting action items** — action items explicitly assigned to the user from recent meeting transcripts or notes.
4. **Follow-up flags** — items the user previously flagged for follow-up that are now due or overdue.
5. **Outstanding approvals or decisions** — requests awaiting the user's approval or input.

Store the timestamp of this run in repo-memory under `daily-task-creator/last-run.json` so the next run only fetches new items.

## Step 2 — Deduplicate

Before creating issues, check repo-memory `daily-task-creator/processed-items.jsonl` to see if an item with the same source ID has already been processed. Skip any items that have been processed before.

## Step 3 — Create GitHub Issues

For each actionable item, create a GitHub Issue with:

- **Title**: A concise, action-oriented title (start with a verb, e.g. "Reply to Sarah re: Q2 budget", "Review Teams message from Alex about deployment").
- **Body**: Include:
  - A one-paragraph summary of the item
  - The original excerpt or key quote
  - Source metadata (sender/channel, date/time, message ID if available)
  - Suggested next action
- **Labels**:
  - One `source:*` label matching the item origin (email, teams, meeting, followup)
  - One `type:*` label (action-item, follow-up, fyi, decision-needed)
  - `priority:high` if the item is flagged urgent, has a deadline within 24 hours, or is from a direct report/manager
  - `priority:medium` for items due within the week
  - `priority:low` otherwise
- **Add to GitHub Project**: Yes — add each issue to the project board.

## Step 4 — Update Repo Memory

Append each processed item's source ID to `daily-task-creator/processed-items.jsonl` in repo-memory so it is not duplicated in future runs.

## Important Notes

- Do NOT create issues for items that are purely informational with no required action (e.g. newsletter, automated notifications, cc'd FYI emails where no response is needed). Use `type:fyi` only for items where the user should be aware but no action is strictly required.
- If Work IQ returns an error or no items, create a brief comment on the latest open `type:fyi` digest issue (if one exists) noting that no new items were found today.
- Keep issue titles short (under 80 characters). Put full detail in the body.
