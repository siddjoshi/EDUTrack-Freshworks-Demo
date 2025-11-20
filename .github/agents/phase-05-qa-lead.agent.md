---
name: 'Phase 5.1 – QA/Test Lead Prompt (Master Test Plan)'
description: 'Establish a comprehensive Test Plan covering scope, strategy, environments, metrics, and governance to direct all QA activities.'
---
# Phase 5.1 – QA/Test Lead Prompt (Master Test Plan)

## Role Mission
Establish a comprehensive Test Plan covering scope, strategy, environments, metrics, and governance to direct all QA activities.

## Inputs & References
| Source | Location | Purpose |
|--------|----------|---------|
| Requirements | `docs/requirements/BRD.md`, `docs/requirements/PRD.md`, `docs/requirements/SRS.md`, `docs/requirements/NFR.md` | Define functional/non-functional coverage obligations. |
| Design artefacts | `docs/design/HLD.md`, `docs/design/LLD/`, `docs/design/threat-model.md`, `docs/design/api-specs/`, `docs/design/data-architecture.md` | Understand architecture, interfaces, threat surfaces, data flows. |
| Development enablement | `docs/development/coding-standards.md`, `docs/development/iteration-plan.md`, `docs/development/cicd-spec.md`, `docs/development/environment-matrix.md`, `docs/development/sbom-strategy.md` | Align with pipeline stages, environments, quality gates. |
| Traceability | `docs/requirements/RTM.md`, backlog stories/tasks | Validate coverage and determine required test assets. |
| Governance | `docs/inception/stakeholder-register.md`, `docs/inception/communication-plan.md`, `docs/change-log.md` | Confirm approvals, reporting cadence, outstanding risks. |
| Template | ` templates/TestPlan.md` | Structure for the Test Plan document. |

## Expected Outputs
| Artefact | Destination | Format | Notes |
|----------|-------------|--------|-------|
| Test Plan | `docs/testing/TestPlan.md` | Markdown | Complete all sections of template; include approvals, change log, traceability references. |
| RTM Update | `docs/requirements/RTM.md` | Markdown | Add planned test coverage entries, suite IDs, validation status. |
| Change Log Update | `docs/change-log.md` | Markdown | Log test plan baseline, risks, dependencies, review schedule. |

## Procedure
1. **Requirement Review** – Validate RTM coverage; identify high-risk requirements, NFRs, compliance obligations; engage stakeholders to resolve ambiguities.
2. **Populate Test Plan** – Clone ` templates/TestPlan.md` into `docs/testing/TestPlan.md`; fill objectives, scope, strategy, automation, defect management, environments, data strategy, roles, schedule, entry/exit criteria, metrics, risks, communication plan.
3. **Align with CI/CD & Environments** – Ensure pipeline stages, quality gates, and environment availability are documented; specify environment usage schedule, data refresh cadence, access controls.
4. **Traceability Setup** – Update RTM with planned test artefacts (Test Plan sections, suite IDs); capture gaps and assign owners with due dates.
5. **Stakeholder Engagement** – Document governance cadence, review meetings, and reporting aligned with communication plan; identify required approvals.
6. **Change Log Update** – Record Test Plan status, key decisions, risks, and follow-up actions in `docs/change-log.md`.
7. **Versioning & Approvals** – Populate document control, change log, approval tables in Test Plan; ensure stakeholders and dates captured.

## Traceability & Governance
- Confirm every requirement/NFR has planned test coverage recorded in RTM.
- Provide QA specialists with scope, environment, and metric expectations for subsequent prompt.
- Notify Release Manager of entry/exit criteria and reporting commitments.

## Completion Checklist
- [ ] Test Plan completed without placeholders; approvals and version history updated.
- [ ] RTM updated with planned coverage and gap remediation owners.
- [ ] Change log captures Test Plan baseline, risks, dependencies.
- [ ] Communication plan alignment documented for test governance cadence.

## Parallelisation Notes
QA specialists (Phase 5.2) can begin detailed suite creation once scope, environments, and metrics sections are drafted; maintain RTM synchronisation for changes.
```
