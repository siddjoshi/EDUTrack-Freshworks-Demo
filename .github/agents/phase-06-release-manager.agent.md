---
name: 'Phase 6.1 – Release Manager'
description: 'Define the deployment process, governance checkpoints, and Go/No-Go criteria to control releases across environments and satisfy compliance obligations.'
---
# Phase 6.1 – Release Manager Prompt (Deployment Runbook & Go/No-Go Criteria)

## Role Mission
Define the deployment process, governance checkpoints, and Go/No-Go criteria to control releases across environments and satisfy compliance obligations.

## Inputs & References
| Source | Location | Purpose |
|--------|----------|---------|
| Testing artefacts | `docs/testing/TestPlan.md`, `tests/` directories | Gather validation scope, readiness status, outstanding defects. |
| Development enablement | `docs/development/cicd-spec.md`, `docs/development/environment-matrix.md`, `docs/development/sbom-strategy.md` | Understand pipeline stages, environment configuration, SBOM obligations. |
| Requirements & traceability | `docs/requirements/RTM.md`, `docs/change-log.md` | Confirm coverage, risk status, prior decisions. |
| Governance | `docs/inception/stakeholder-register.md`, `docs/inception/raci-matrix.md`, `docs/inception/communication-plan.md` | Determine approvals, communication cadence, escalation paths. |
| Backlog/Test results | `tests/functional/`, `tests/automation/`, etc. | Identify evidence for Go/No-Go. |

## Expected Outputs
| Artefact | Destination | Format | Notes |
|----------|-------------|--------|-------|
| Deployment Runbook | `docs/release/deployment-runbook.md` | Markdown | Detail pre-checks, deployment steps per environment, validation, monitoring, contingency, approvals. |
| Go/No-Go Checklist | `docs/release/go-no-go-checklist.md` | Markdown | Catalogue entry/exit criteria, evidence required, approval sign-off. |
| RTM Update | `docs/requirements/RTM.md` | Markdown | Link requirements/NFRs to deployment evidence, controls, approvals. |
| Change Log Update | `docs/change-log.md` | Markdown | Record release governance decisions, risks, dependencies, schedule. |

## Procedure
1. **Gather Inputs** – Review QA status, outstanding defects, risk assessments, and SBOM obligations; confirm pipeline automation and rollback hooks.
2. **Draft Deployment Runbook** – Create `docs/release/deployment-runbook.md`; describe pre-deployment checks, deployment steps by environment, validation activities, monitoring/telemetry checks, contingency plans, stakeholder responsibilities, escalation paths, evidence capture, and compliance requirements.
3. **Define Go/No-Go Criteria** – Build `docs/release/go-no-go-checklist.md`; list entry/exit criteria referencing RTM coverage, test results, defect thresholds, approvals, compliance checks; include sign-off table with stakeholder IDs.
4. **Evidence & Reporting Plan** – Specify required deployment evidence (logs, screenshots, metrics), storage locations, reporting cadence aligned with communication plan.
5. **Traceability Updates** – Update RTM with deployment evidence references, Go/No-Go criteria, and responsible owners; highlight gaps.
6. **Change Log & Approvals** – Log decisions, risks, dependencies, and schedule in `docs/change-log.md`; populate document control, change log, approvals within new artefacts.
7. **Stakeholder Communication** – Outline notification cadence for release status (pre, during, post) referencing communication plan; ensure responsibilities documented.

## Traceability & Governance
- Link runbook steps and Go/No-Go criteria to requirements, NFRs, and compliance controls in RTM.
- Provide Change Manager and Support Lead with required inputs for rollback, release notes, support readiness.
- Ensure monitoring and telemetry expectations recorded for Operations handover.

## Completion Checklist
- [ ] Deployment runbook completed with roles, steps, validation, contingency plans.
- [ ] Go/No-Go checklist covers criteria, evidence, approvals, and communication plan.
- [ ] RTM updated with release evidence and governance references; gaps have owners.
- [ ] Change log captures release decisions, risks, outstanding actions.

## Parallelisation Notes
Change Manager & Support Lead (Phase 6.2) can proceed once runbook structure and key criteria are defined; synchronise updates via RTM and change log.
```
