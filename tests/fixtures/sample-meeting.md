# Meeting Notes: Q2 Engineering Planning
**Date:** 2026-03-27
**Attendees:** Tyler Kendrick (Engineering Lead), Sarah Chen (PM), Alex Rivera (Backend), Jordan Wu (QA)
**Meeting Type:** Sprint Planning

---

## Agenda

1. Q2 roadmap priorities
2. Deployment process improvements
3. Testing coverage gaps
4. Upcoming customer demos

---

## Discussion

### Q2 Roadmap

Sarah presented the updated Q2 roadmap. The team reviewed the top priority items. Several features are gated on infrastructure improvements that need to be scoped first.

**Action: Tyler to share the Q2 roadmap draft document with all stakeholders by end of week (Friday, March 29).**

### Deployment Process

Alex described issues with the current deployment pipeline — manual steps are causing ~2 hour delays on each release. The team discussed automating the approval gate.

Jordan mentioned that QA sign-off is blocking deployments every time because the checklist is not automated.

**Action: Tyler to review and approve Alex's deployment automation PR (#142) before next Thursday.** This is blocking the team's velocity for Q2.

### Testing Coverage

Jordan flagged that the payment module has dropped below 60% test coverage after recent changes. The issue tracker shows three related items that have been open for two weeks.

**Action (Jordan): Add tests for the payment module by April 5th.**

Note: Tyler should follow up with Jordan the week of April 7th to verify this is done.

**Action: Tyler to follow up with Jordan re: payment module test coverage on April 7th.**

### Customer Demo

The customer demo for Acme Corp is scheduled for April 10th. Sarah confirmed the demo environment is prepared, but needs Tyler's sign-off on the demo script.

**Action: Tyler to review and approve the Acme Corp demo script (shared by Sarah in the #demos Teams channel). Needed by April 4th.**

---

## Summary

| Action Item | Owner | Due Date |
|---|---|---|
| Share Q2 roadmap draft with stakeholders | Tyler | March 29 |
| Review/approve deployment automation PR #142 | Tyler | April 3 |
| Follow up with Jordan re: payment test coverage | Tyler | April 7 |
| Review/approve Acme Corp demo script | Tyler | April 4 |

---

## Next Meeting

Sprint Review: April 3, 2026 at 10:00 AM PT
