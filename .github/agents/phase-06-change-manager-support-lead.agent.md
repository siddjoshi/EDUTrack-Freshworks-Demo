---
name: 'Phase 6.2 – Change Manager'
description: 'Develop rollback and communication artefacts that safeguard the release, inform stakeholders, and prepare support teams for post-deployment operations.'
---
# Phase 6.2 – Change Manager & Support Lead Prompt (Rollback Plan & Release Communications)

## Role Mission
Develop rollback and communication artefacts that safeguard the release, inform stakeholders, and prepare support teams for post-deployment operations.

## Inputs & References
| Source | Location | Purpose |
|--------|----------|---------|
| Deployment artefacts | `docs/release/deployment-runbook.md`, `docs/release/go-no-go-checklist.md` | Understand deployment flow, criteria, evidence requirements. |
| Testing outcomes | `docs/testing/TestPlan.md`, `tests/` directories | Incorporate validation status, known issues, residual risks. |
| Requirements & traceability | `docs/requirements/RTM.md`, `docs/change-log.md` | Ensure coverage and identify outstanding actions. |
| Governance | `docs/inception/stakeholder-register.md`, `docs/inception/raci-matrix.md`, `docs/inception/communication-plan.md` | Determine approval chains, communication cadence, support contacts. |
| Templates | ` templates/RollbackPlan.md`, ` templates/ReleaseNotes.md` | Provide structure for rollback and release notes. |

## Expected Outputs
| Artefact | Destination | Format | Notes |
|----------|-------------|--------|-------|
| Rollback Plan | `docs/release/RollbackPlan.md` | Markdown | Detail triggers, steps, validation, communication, post-rollback actions. |
| Release Notes | `docs/release/ReleaseNotes.md` | Markdown | Capture change inventory, known issues, dependencies, communication schedule. |
| Support Readiness Checklist | `docs/release/support-readiness-checklist.md` | Markdown | Document training, knowledge base updates, on-call roster, SLAs. |
| RTM Update | `docs/requirements/RTM.md` | Markdown | Link rollback controls, release notes, support evidence to requirements/NFRs. |
| Change Log Update | `docs/change-log.md` | Markdown | Record rollback decisions, communication commitments, outstanding actions. |

## Procedure
1. **Review Inputs** – Examine deployment runbook, Go/No-Go criteria, QA status, risk register, stakeholder expectations to identify rollback triggers and communication needs.
2. **Author Rollback Plan** – Clone ` templates/RollbackPlan.md` into `docs/release/RollbackPlan.md`; document triggers, decision tree, step-by-step procedure, data restoration, validation, communications, risk register, post-rollback actions, approvals.
3. **Prepare Release Notes** – Clone ` templates/ReleaseNotes.md` into `docs/release/ReleaseNotes.md`; capture feature/fix inventory, known issues, dependencies, validation evidence, communication plan, compliance notes, approvals.
4. **Assess Support Readiness** – Create/update `docs/release/support-readiness-checklist.md`; cover training completion, knowledge base updates, runbook changes, incident routing, SLA confirmation, on-call coverage.
5. **Traceability Updates** – Update RTM with rollback controls, release notes references, support readiness evidence tied to requirements/NFRs.
6. **Change Log & Communication** – Record decisions, risks, dependencies, communication schedule in change log; align announcements with communication plan.
7. **Versioning & Approvals** – Populate document control, change log, approvals across artefacts; secure sign-offs per stakeholder register.

## Traceability & Governance
- Map rollback steps and support readiness tasks to CI/CD controls, RTM entries, and compliance obligations.
- Provide Operations with failure scenarios, contact matrix, monitoring expectations.
- Share release notes with stakeholders via documented channels; confirm acknowledgement when required.

## Completion Checklist
- [ ] Rollback Plan, Release Notes, and Support Readiness Checklist completed with no placeholders.
- [ ] RTM updated with release governance artefacts and evidence references.
- [ ] Change log records rollback and communication decisions, risks, owners.
- [ ] Approvals recorded for all deliverables; communication schedule confirmed.

## Parallelisation Notes
Operations readiness (Phase 7.1) can begin once rollback strategy and support checklist are drafted; maintain RTM/change log alignment for updates.
```
