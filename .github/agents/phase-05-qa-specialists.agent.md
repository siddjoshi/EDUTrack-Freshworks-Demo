---
name: 'Phase 5.2 – QA Specialists'
description: 'Create detailed test artefacts (manual, automated, performance, security) and supporting data strategy aligned with the Test Plan and RTM.'
---
# Phase 5.2 – QA Specialists Prompt (Test Suites, Automation, Performance & Security Validation)

## Role Mission
Create detailed test artefacts (manual, automated, performance, security) and supporting data strategy aligned with the Test Plan and RTM.

## Inputs & References
| Source | Location | Purpose |
|--------|----------|---------|
| Test Plan | `docs/testing/TestPlan.md` | Provide scope, approach, environment/data strategy, metrics, governance. |
| Requirements & Design | `docs/requirements/SRS.md`, `docs/requirements/NFR.md`, `docs/requirements/RTM.md`, `docs/design/HLD.md`, `docs/design/LLD/`, `docs/design/threat-model.md`, `docs/development/cicd-spec.md`, `docs/development/environment-matrix.md` | Ensure test coverage addresses functional, non-functional, and compliance requirements. |
| Backlog | `backlog/stories/`, `backlog/tasks/` | Align tests with acceptance criteria, tasks, and readiness notes. |
| Change Log | `docs/change-log.md` | Monitor outstanding risks, blockers, decisions. |

## Expected Outputs
| Artefact | Destination | Format | Notes |
|----------|-------------|--------|-------|
| Functional/Regression Suites | `tests/functional/` | Markdown | Create structured test cases with IDs, preconditions, steps, expected results, data needs, traceability. |
| Automation Framework Docs | `tests/automation/README.md` + supporting files | Markdown | Describe tooling, setup, execution commands, CI/CD integration checkpoints. |
| Performance Test Artefacts | `tests/performance/` | Markdown | Document scenarios, workloads, metrics, scripts references, NFR mappings. |
| Security Test Artefacts | `tests/security/` | Markdown | Capture manual + automated security test charters, tooling, mapping to threat model. |
| Test Data Strategy | `docs/testing/test-data-strategy.md` | Markdown | Cover data sourcing, masking/synthetic approaches, refresh cadence, compliance. |
| RTM Update | `docs/requirements/RTM.md` | Markdown | Link requirement IDs to test cases, automation suites, performance/security artefacts, evidence. |
| Change Log Update | `docs/change-log.md` | Markdown | Record QA readiness, blockers, risks, metrics commitments. |

## Procedure
1. **Scope Allocation** – Divide responsibilities among functional, automation, performance, and security testers; confirm acceptance criteria and design references for each item.
2. **Author Functional & Regression Suites** – Create test cases under `tests/functional/`; include unique IDs, requirement references, preconditions, step-by-step execution, expected results, data needs, and traceability notes.
3. **Establish Automation Framework** – Document framework structure, tooling, execution steps, environment requirements, pipeline integration in `tests/automation/README.md`; outline directories/scripts for automated suites.
4. **Define Performance Testing Artefacts** – Under `tests/performance/`, document scenarios, workload models, SLAs/SLOs, tooling, data, metrics collection, pass/fail thresholds aligned with NFRs.
5. **Document Security Testing Plan** – In `tests/security/`, define automated scans, manual penetration charters, compliance checks, mapping to threat model mitigations and NFR security requirements.
6. **Draft Test Data Strategy** – Produce `docs/testing/test-data-strategy.md`; describe data sources, masking/anonymisation, synthetic data plans, refresh cadence, access controls, compliance considerations.
7. **Update RTM** – Map each test asset to requirement IDs and planned evidence; note automation coverage, performance/security validation, and owners.
8. **Change Log & Communication** – Record readiness status, blockers, tool dependencies, metrics commitments in change log; coordinate with DevOps and Release for pipeline hooks and evidence storage.
9. **Versioning & Approvals** – Populate document control, change log, approvals across all new artefacts; capture review/approval stakeholders per RACI.

## Traceability & Governance
- Ensure every test artefact links to requirement IDs, NFR metrics, backlog items, and evidence expectations in RTM.
- Provide Release Manager with verification evidence plans and reporting cadence.
- Highlight dependencies requiring engineering or environment support.

## Completion Checklist
- [ ] Functional, automation, performance, and security artefacts documented with no placeholders.
- [ ] Test data strategy completed with compliance, masking, refresh details.
- [ ] RTM updated with detailed test coverage and evidence links; gaps assigned owners.
- [ ] Change log records QA readiness, blockers, and next steps.

## Parallelisation Notes
Release planning (Phase 6) can begin once test coverage scope is clear; continue updating RTM and change log to reflect progress and results.
```
