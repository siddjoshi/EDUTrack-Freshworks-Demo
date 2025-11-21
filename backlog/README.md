# Backlog Issue Creation

This document describes how GitHub issues have been created from the backlog markdown files with proper parent-child relationships, traceability, and execution order.

## Backlog Structure

The backlog is organized hierarchically:

```
backlog/
├── epics/          # Strategic initiatives (EP-XXXX)
├── features/       # Product capabilities (FE-XXXX)
├── stories/        # User stories (US-XXXX)
└── tasks/          # Implementation tasks (TSK-XXXX)
```

## Backlog Items

### Epic
- **EP-0001**: AI-Powered Learning & Training Platform
  - Strategic initiative for transforming organizational learning and training

### Features (Under EP-0001)
- **FE-0001**: Content Ingestion & Management
  - Parent: EP-0001
  - Target: Sprint 1-3
  - Automates content ingestion from multiple sources
  
- **FE-0002**: AI Content Generation
  - Parent: EP-0001
  - Target: Sprint 2-4
  - Leverages Azure OpenAI for automated training module generation

### Stories (Under FE-0001)
- **US-0001**: L&D Admin Document Upload
  - Parent: FE-0001
  - Target: Sprint 1
  - Enables local document upload via web interface

### Tasks (Under US-0001)
- **TSK-0001**: Provision Azure Blob Storage Account with Encryption at Rest
  - Parent: US-0001
  - Sprint: Sprint 1
  - Story Points: 3
  - Priority: Critical
  - Dependencies: None (foundational task)
  - Can execute in parallel with: TSK-0002
  
- **TSK-0002**: Design and Implement SQL Database Schema for Document Metadata
  - Parent: US-0001
  - Sprint: Sprint 1
  - Story Points: 5
  - Priority: Critical
  - Dependencies: None (foundational task)
  - Can execute in parallel with: TSK-0001

## Parent-Child Relationships

```
EP-0001 (Epic: AI-Powered Learning & Training Platform)
├── FE-0001 (Feature: Content Ingestion & Management)
│   └── US-0001 (Story: L&D Admin Document Upload)
│       ├── TSK-0001 (Task: Provision Blob Storage) [PARALLEL]
│       └── TSK-0002 (Task: Database Schema) [PARALLEL]
└── FE-0002 (Feature: AI Content Generation)
```

## Traceability Matrix

### To Requirements Documents
All backlog items maintain traceability to:
- **BRD** (Business Requirements Document): `docs/requirements/BRD.md`
- **PRD** (Product Requirements Document): `docs/requirements/PRD.md`
- **SRS** (Software Requirements Specification): `docs/requirements/SRS.md`
- **NFR** (Non-Functional Requirements): `docs/requirements/NFR.md`
- **RTM** (Requirements Traceability Matrix): `docs/requirements/RTM.md`

### To Design Artifacts
- **HLD** (High-Level Design): `docs/design/HLD.md`
- **Data Architecture**: `docs/design/data-architecture.md`
- **Threat Model**: `docs/design/threat-model.md`

## Execution Order

### Sequential Dependencies
Tasks must be executed in this order when there are dependencies:

1. **Foundational Tasks** (Can run in parallel):
   - TSK-0001: Provision Azure Blob Storage
   - TSK-0002: SQL Database Schema

2. **Backend API Development** (Depends on TSK-0001, TSK-0002):
   - Implementation of document upload API
   - Text extraction service integration

3. **Frontend Development** (Can run in parallel with backend):
   - Upload interface UI
   - Content repository views

### Parallel Execution Opportunities

#### Sprint 1 Tasks (Can Execute Concurrently):
- ✅ TSK-0001: Azure Blob Storage Provisioning (DevOps Lead)
- ✅ TSK-0002: SQL Database Schema (Data Lead)
- Frontend UI development (Frontend Team)
- Azure AD authentication integration (Security Team)

#### Key Principle:
- Infrastructure tasks (TSK-0001, TSK-0002) have NO dependencies on each other
- Both must complete before backend API implementation begins
- Frontend can proceed in parallel with backend once designs are approved

## Issue Labels

Issues are tagged with the following labels:

### Type Labels
- `epic`: Strategic initiative
- `feature`: Product capability
- `story`: User story
- `task`: Implementation task

### Priority Labels
- `priority:critical`: Must be completed first (blocking)
- `priority:high`: Important for sprint success
- `priority:medium`: Should be completed
- `priority:low`: Nice to have

### Status Labels
- `status:ready`: Ready for implementation
- `status:todo`: To be started
- `status:in-progress`: Currently being worked on
- `status:blocked`: Waiting on dependencies
- `status:done`: Completed

### Sprint/Release Labels
- `sprint:1-2`: Targeted for Sprint 1-2
- `release:mvp`: Part of MVP release (Q2 2026)

## Creating GitHub Issues

There are three ways to create GitHub issues from these backlog files:

### Option 1: GitHub CLI (Recommended)

```bash
# Install GitHub CLI (if not installed)
# See: https://cli.github.com/

# Authenticate
gh auth login

# Run the script
python3 scripts/create_github_issues.py

# Dry-run mode (preview without creating)
python3 scripts/create_github_issues.py --dry-run
```

### Option 2: Direct API (Requires GITHUB_TOKEN)

```bash
# Set your GitHub token
export GITHUB_TOKEN=your_personal_access_token

# Run the API script
python3 scripts/create_issues_via_api.py
```

### Option 3: Manual Commands

See `ISSUE_CREATION_COMMANDS.md` for ready-to-use `gh issue create` commands that you can copy-paste.

**Note:** The MCP GitHub tools currently only support read operations, so issue creation requires either GitHub CLI authentication or a GitHub API token.

All methods will:
1. Parse all markdown files in the backlog folder
2. Extract metadata, relationships, and dependencies
3. Create GitHub issues in hierarchical order (Epics → Features → Stories → Tasks)
4. Link parent-child relationships using issue references
5. Apply appropriate labels
6. Save an issue mapping file (`issue-mapping.json`)

## Issue Templates

### Epic Issue Format
```
Title: [EP-0001] AI-Powered Learning & Training Platform

Labels: epic, priority:critical, release:mvp

Body:
- Metadata (target release, status)
- Traceability (backlog file, requirement IDs)
- Linked items (features, stories, tasks)
- Executive summary
- Success metrics
- Link to full documentation
```

### Feature Issue Format
```
Title: [FE-0001] Content Ingestion & Management

Labels: feature, priority:high, sprint:1-2

Body:
- Parent: #<epic-issue-number>
- Metadata
- Traceability
- Linked stories and tasks
- Feature description
- Acceptance criteria overview
```

### Story Issue Format
```
Title: [US-0001] L&D Admin Document Upload

Labels: story, priority:high, sprint:1

Body:
- Parent: #<feature-issue-number>
- Metadata (story points, sprint)
- Traceability
- Linked tasks
- User story statement
- Acceptance criteria (Gherkin format)
```

### Task Issue Format
```
Title: [TSK-0001] Provision Azure Blob Storage

Labels: task, priority:critical, sprint:1

Body:
- Parent: #<story-issue-number>
- Metadata (story points, assignee, sprint)
- Dependencies (blocking/non-blocking)
- Parallel execution notes
- Definition of Done checklist
- Implementation guidance
```

## Verification

After issue creation, verify:
1. All 6 items have corresponding GitHub issues
2. Parent-child links are correctly established
3. Labels are applied appropriately
4. Dependencies are documented
5. Parallel execution tasks are clearly identified
6. Traceability links to backlog files are working

## Maintenance

When adding new backlog items:
1. Create markdown file in appropriate folder (epics/features/stories/tasks)
2. Follow the existing template structure
3. Include metadata table with ID, parent references, status
4. Document dependencies and execution order
5. Run the script to create corresponding GitHub issue
6. Update this README if hierarchy changes
