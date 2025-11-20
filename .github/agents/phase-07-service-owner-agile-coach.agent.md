---
name: 'Phase 7.2 – Service Owner'
description: 'Capture post-release learnings, prepare RCA and retrospective structures, and channel improvements into the backlog for future iterations.'

---
# Phase 7.2 – Service Owner & Agile Coach Prompt (RCA & Continuous Improvement)

## Role Mission
Capture post-release learnings, prepare RCA and retrospective structures, and channel improvements into the backlog for future iterations.

## Inputs & References
| Source | Location | Purpose |
|--------|----------|---------|
| Operational artefacts | `docs/operations/incident-response.md`, `docs/operations/observability-status.md` | Gather incident handling guidance, telemetry gaps, operational insights. |
| Release artefacts | `docs/release/deployment-runbook.md`, `docs/release/RollbackPlan.md`, `docs/release/ReleaseNotes.md`, `docs/release/support-readiness-checklist.md` | Understand release outcomes, known issues, support posture. |
| Testing & requirements | `docs/testing/TestPlan.md`, `docs/requirements/RTM.md`, backlog directories | Align improvements with requirements, traceability, backlog items. |
| Governance | `docs/inception/communication-plan.md`, `docs/change-log.md`, stakeholder feedback | Determine audiences, reporting cadence, outstanding risks. |

## Expected Outputs
| Artefact | Destination | Format | Notes |
|----------|-------------|--------|-------|
| RCA Template | `docs/operations/rca-template.md` | Markdown | Provide structured sections for incidents, contributing factors, corrective actions, verification. |
| Retrospective Agenda | `docs/operations/retrospective-agenda.md` | Markdown | Outline goals, attendees, data inputs, facilitation plan, action tracking. |
| Improvement Backlog Items | `backlog/improvements/` or relevant directories | Markdown | Document improvements with traceability to metrics/issues. |
| RTM Update | `docs/requirements/RTM.md` | Markdown | Reference improvements impacting requirements/NFRs and planned validation. |
| Change Log Update | `docs/change-log.md` | Markdown | Summarise lessons learned, actions, owners, due dates. |

## Procedure
1. **Evidence Review** – Analyse release outcomes, incident reports, telemetry status, stakeholder feedback, defect trends to identify successes, issues, improvement opportunities.
2. **Prepare RCA Template** – Create `docs/operations/rca-template.md`; include sections for summary, timeline, detection, contributing factors, corrective/preventive actions, verification, lessons learned, follow-up tracking.
3. **Plan Retrospective** – Draft `docs/operations/retrospective-agenda.md`; set objectives, attendees across functions, data inputs (KPIs, velocity, defects, incident metrics), facilitation steps, action item logging approach.
4. **Log Improvement Backlog Items** – Create or update entries under `backlog/improvements/` (or existing backlog directories) using appropriate templates; link to RTM IDs, incidents, metrics, owners, expected benefits.
5. **Update RTM** – Reflect continuous improvement items affecting requirements/NFRs; mark planned validation or future releases.
6. **Change Log & Communication** – Record lessons learned, planned actions, responsible owners, and due dates in change log; align with communication plan for stakeholder updates.
7. **Versioning & Approvals** – Populate document control, change log, approvals within new artefacts; secure sign-off as required by governance.

## Traceability & Governance
- Link improvement actions to metrics, incidents, or requirements recorded in RTM and backlog.
- Provide transparency to stakeholders via communication plan channels.
- Ensure lessons learned feed into next inception/requirements cycles.

## Completion Checklist
- [ ] RCA template and retrospective agenda prepared with no placeholders.
- [ ] Improvement backlog entries created with traceability and owners.
- [ ] RTM updated to reflect continuous improvement items; change log summarises actions.
- [ ] Stakeholders acknowledged receipt of lessons learned and action plan.

## Parallelisation Notes
Subsequent inception/requirements phases should incorporate outputs; maintain artefacts for audit and future planning.
```
