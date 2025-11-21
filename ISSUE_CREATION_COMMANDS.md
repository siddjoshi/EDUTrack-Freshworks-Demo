# GitHub Issue Creation Commands

This file contains the exact commands to create GitHub issues for all backlog items.
Run these commands after authenticating with `gh auth login`.

## Epic: EP-0001

```bash
gh issue create \
  --repo siddjoshi/EDUTrack-Demo \
  --title "[EP-0001] AI-Powered Learning & Training Platform" \
  --label "epic,priority:critical,release:mvp,status:ready" \
  --body "## Metadata
- **Target Release:** MVP: Q2 2026 / Full Platform: Q3 2027
- **Status:** Ready

## Traceability
- **Item ID:** EP-0001
- **Backlog File:** \`backlog/epics/EP-0001.md\`
- **BRD:** docs/requirements/BRD.md (12 business objectives, 79 requirements)
- **PRD:** docs/requirements/PRD.md (24 features, user personas)
- **SRS:** docs/requirements/SRS.md (250+ functional requirements)
- **NFR:** docs/requirements/NFR.md (121 non-functional requirements)
- **RTM:** docs/requirements/RTM.md (Complete traceability matrix)

## Linked Items
- **Features:** FE-0001, FE-0002, FE-0004, FE-0005, FE-0006, FE-0007, FE-0008, FE-0009, FE-0010, FE-0011, FE-0012, FE-0013, FE-0014, FE-0015, FE-0016, FE-0017, FE-0018, FE-0019, FE-0020, FE-0021, FE-0022, FE-0023, FE-0024

## Executive Summary

**Problem / Opportunity:**
The organization's learning and development operations cannot meet the rapidly evolving skill requirements of 10,000 employees. Manual content creation takes 40-60 hours per module, creating a 200+ request backlog. Training content is fragmented across SharePoint, Confluence, and local drives with no centralized discovery. Employees spend 15 minutes on average searching for relevant training, and 82% compliance training completion creates regulatory risk.

**Desired Outcome:**
Transform EDUTrack into an AI-powered platform that automates training content generation, delivers personalized learning experiences, and provides comprehensive analytics. Reduce content creation time from 50 hours to <15 hours per module, increase output from 60 to 120+ modules annually, enable content discovery in <2 minutes, and achieve 98% compliance training completion.

**Business Value:**
\$7.81M quantified benefits over 3 years with 285% ROI and 14-month payback. Benefits include: \$1.54M in content creation cost savings, \$2.4M in productivity gains from faster skill acquisition, \$900K in compliance risk mitigation, and \$1.8M in retention improvement.

## Success Metrics
- Transform content creation efficiency: 70% reduction in SME time per module (from 50 hours to <15 hours)
- Scale content production capacity: 100% increase in modules published per year (from 60 to 120+)
- Achieve personalized learning at scale: 10,000 users with personalized paths (100% coverage)
- Improve learning path completion: From 45% to 75% (67% increase)
- Drive organizational adoption: 8,500 Monthly Active Users (85% of 10,000)
- Reduce content discovery time: From 15 minutes to <2 minutes (87% reduction)
- Achieve compliance excellence: From 82% to 98% mandatory training completion
- Reduce training costs: From \$450 to \$135 per employee per year (70% reduction)
- Demonstrate financial ROI: 285% over 3 years

---
📄 **Full Documentation:** See [\`EP-0001.md\`](backlog/epics/EP-0001.md)"
```

## Feature: FE-0001

```bash
# First, get the Epic issue number from above and replace <EPIC_ISSUE_NUMBER> below
gh issue create \
  --repo siddjoshi/EDUTrack-Demo \
  --title "[FE-0001] Content Ingestion & Management" \
  --label "feature,priority:high,sprint:1-2,release:mvp,status:ready" \
  --body "**Parent:** #<EPIC_ISSUE_NUMBER>

## Metadata
- **Target Release:** MVP - Q2 2026 (Sprint 1-3)
- **Status:** Ready

## Traceability
- **Item ID:** FE-0001
- **Epic:** EP-0001 - AI-Powered Learning & Training Platform
- **Backlog File:** \`backlog/features/FE-0001.md\`
- **BRD:** BRD-FR-004, BRD-FR-005, BRD-FR-006, BRD-FR-007, BRD-OBJ-01
- **PRD:** PRD-F-001
- **SRS:** SRS-FUNC-001 to SRS-FUNC-015

## Linked Items
- **Stories:** US-0001, US-0002, US-0003, US-0004, US-0005, US-0006
- **Tasks:** TSK-0001, TSK-0002, TSK-0003, TSK-0004, TSK-0005, TSK-0006, TSK-0007, TSK-0008, TSK-0009, TSK-0010, TSK-0011, TSK-0012

## Overview

**Problem Statement:**
Training content is scattered across SharePoint (40%), Confluence (35%), GitHub (15%), and local drives (10%) without centralized discovery or governance. L&D teams spend excessive time manually gathering and formatting content from multiple sources, creating a bottleneck in the content creation process.

**Proposed Outcome:**
Implement automated content ingestion from SharePoint Online, Confluence Cloud, GitHub repositories, and local file uploads. Extract text with >95% accuracy while preserving formatting. Deduplicate content based on file hash, maintain version history, and store documents in a structured repository with searchable metadata. Enable the platform to support 1M documents with efficient retrieval.

**Business Value:**
Reduce content preparation time from hours to minutes. Eliminate manual content gathering across fragmented sources. Enable reuse of existing organizational knowledge. Provide single source of truth for training content. Foundation for AI content generation (FE-0002) and semantic search (FE-0012).

## Key Features (MVP)
- Local file upload interface (PDF, DOCX, PPTX, MD, HTML up to 50MB)
- SharePoint Online document ingestion via Microsoft Graph API
- Text extraction with >95% accuracy
- Content deduplication based on SHA-256 file hash
- Document metadata storage
- Raw source file storage in Azure Blob Storage with encryption at rest
- Content lifecycle management (archive, soft delete, hard delete)
- Audit logging for all ingestion events

---
📄 **Full Documentation:** See [\`FE-0001.md\`](backlog/features/FE-0001.md)"
```

## Feature: FE-0002

```bash
# Replace <EPIC_ISSUE_NUMBER> with the Epic issue number
gh issue create \
  --repo siddjoshi/EDUTrack-Demo \
  --title "[FE-0002] AI Content Generation" \
  --label "feature,priority:high,sprint:1-2,release:mvp,status:ready" \
  --body "**Parent:** #<EPIC_ISSUE_NUMBER>

## Metadata
- **Target Release:** MVP - Q2 2026 (Sprint 2-4)
- **Status:** Ready

## Traceability
- **Item ID:** FE-0002
- **Epic:** EP-0001 - AI-Powered Learning & Training Platform
- **Backlog File:** \`backlog/features/FE-0002.md\`
- **BRD:** BRD-FR-008, BRD-FR-009, BRD-FR-010, BRD-FR-011, BRD-FR-012, BRD-FR-039, BRD-OBJ-01, BRD-OBJ-02, BRD-OBJ-12
- **PRD:** PRD-F-002
- **SRS:** SRS-FUNC-031 to SRS-FUNC-045

## Linked Items
- **Stories:** US-0010, US-0011, US-0012, US-0013, US-0014, US-0015
- **Tasks:** TSK-0020, TSK-0021, TSK-0022, TSK-0023, TSK-0024, TSK-0025, TSK-0026, TSK-0027, TSK-0028, TSK-0029, TSK-0030, TSK-0031

## Overview

**Problem Statement:**
Manual training content creation takes 40-60 hours per module, with SMEs spending excessive time drafting summaries, objectives, concepts, instructions, and assessments. This creates a 200+ request backlog and limits organizational content production capacity to 60 modules per year.

**Proposed Outcome:**
Leverage Azure OpenAI (GPT-4) to automatically transform ingested documents into structured training modules in <20 seconds. Generate comprehensive module components including executive summaries, learning objectives, key concepts, instructions, and automated assessments (10+ MCQs and 3+ scenario questions). Implement hallucination detection scoring to flag low-quality content. Auto-tag modules with relevant skills from the organization skill taxonomy.

**Business Value:**
Achieve 70% reduction in SME content creation time (from 50 hours to <15 hours per module). Increase content production capacity by 100% (from 60 to 120+ modules per year). Improve content consistency and quality through standardized AI generation. Achieve >95% SME approval rate for AI-generated content. Reduce content creation cost from \$6,000 to \$1,800 per module (\$450K annual savings).

## Key Features (MVP)
- Azure OpenAI (GPT-4) integration for training module generation
- AI generation in <20 seconds (P95)
- Automated module components (summary, objectives, concepts, instructions)
- Auto-generated assessments (10+ MCQs, 3+ scenarios with explanations)
- Automated skill tagging (3-10 skills per module)
- Hallucination detection scoring (0-100%; >30% flagged)
- PII filtering before AI processing
- Complete audit logging of AI interactions (7-year retention)

## Critical Dependencies
⚠️ **CRITICAL PATH:** Azure OpenAI Service approval and quota allocation (100K TPM) required by Week 2

---
📄 **Full Documentation:** See [\`FE-0002.md\`](backlog/features/FE-0002.md)"
```

## Story: US-0001

```bash
# Replace <FEATURE_ISSUE_NUMBER> with the FE-0001 issue number
gh issue create \
  --repo siddjoshi/EDUTrack-Demo \
  --title "[US-0001] L&D Admin Document Upload" \
  --label "story,priority:high,sprint:1,status:ready" \
  --body "**Parent:** #<FEATURE_ISSUE_NUMBER>

## Metadata
- **Target Release:** Sprint 1
- **Status:** Ready
- **Story Points:** (calculated from tasks: 3 + 5 = 8)

## User Story
> As an **L&D Administrator**, I want to **upload a training document locally via a web interface**, so that **it can be automatically processed by the AI content generator without manual file format conversion or content preparation**.

## Traceability
- **Item ID:** US-0001
- **Feature:** FE-0001 - Content Ingestion & Management
- **Epic:** EP-0001 - AI-Powered Learning & Training Platform
- **Backlog File:** \`backlog/stories/US-0001.md\`
- **BRD:** BRD-FR-004, BRD-FR-005, BRD-FR-006, BRD-OBJ-01
- **PRD:** PRD-F-001, PRD-US-002-01
- **SRS:** SRS-FUNC-004, SRS-FUNC-005, SRS-FUNC-009, SRS-FUNC-010

## Linked Items
- **Tasks:** TSK-0001, TSK-0002, TSK-0003, TSK-0004, TSK-0005, TSK-0006, TSK-0007, TSK-0008, TSK-0009, TSK-0010

## Business Context

**Problem / Need:**
L&D Administrators currently spend 2-4 hours manually gathering and formatting training content from various sources (SharePoint, local drives, email attachments) before it can be used for module creation. There is no centralized upload interface or automated text extraction, forcing admins to copy-paste content manually.

**Expected Outcome / Benefit:**
Enable L&D Admins to upload documents (PDF, DOCX, PPTX, MD, HTML) up to 50MB directly through a web interface in <2 minutes. System automatically validates file format and size, extracts text with >95% accuracy, stores the document securely in Azure Blob Storage, and queues it for AI content generation. This reduces content preparation time from 2-4 hours to <10 minutes.

## Acceptance Criteria (Summary)
- ✅ Valid PDF upload (10MB) completes successfully with progress bar
- ✅ Invalid file format (.exe) rejected with clear error message
- ✅ File size limit (>50MB) enforced with actionable guidance
- ✅ Drag-and-drop upload supported across modern browsers
- ✅ File picker upload alternative available
- ✅ Progress bar updates accurately (0% → 100%)
- ✅ Asynchronous text extraction with background processing
- ✅ Network interruption recovery with resume capability
- ✅ Duplicate document detection and handling
- ✅ Keyboard navigation and screen reader compatibility

---
📄 **Full Documentation:** See [\`US-0001.md\`](backlog/stories/US-0001.md)"
```

## Task: TSK-0001

```bash
# Replace <STORY_ISSUE_NUMBER> with the US-0001 issue number
gh issue create \
  --repo siddjoshi/EDUTrack-Demo \
  --title "[TSK-0001] Provision Azure Blob Storage Account with Encryption at Rest" \
  --label "task,priority:critical,sprint:1,status:todo" \
  --body "**Parent:** #<STORY_ISSUE_NUMBER>

## Metadata
- **Target Release:** Sprint 1
- **Status:** To Do
- **Story Points:** 3
- **Assigned To:** DevOps Lead
- **Sprint:** Sprint 1

## Objective
Provision and configure an Azure Blob Storage account in the development environment with encryption at rest (AES-256) enabled to store uploaded training documents securely.

## Traceability
- **Item ID:** TSK-0001
- **Parent Story:** US-0001 - L&D Admin Document Upload
- **Feature:** FE-0001 - Content Ingestion & Management
- **Epic:** EP-0001 - AI-Powered Learning & Training Platform
- **Backlog File:** \`backlog/tasks/TSK-0001.md\`
- **BRD:** BRD-FR-004, BRD-FR-052
- **SRS:** SRS-FUNC-004, SRS-FUNC-010
- **NFR:** NFR-SEC-DATA-001 (Encryption at rest AES-256)

## Dependencies
### Blocking Dependencies (Must be completed first)
- ✅ Azure subscription provisioned and active
- ✅ Resource group \`rg-edutrack-dev\` created
- ⏳ Azure Key Vault provisioned for secrets storage (TSK-0011)

### Downstream Dependencies (Tasks that depend on this task)
- TSK-0004: Build upload interface UI
- TSK-0005: Implement backend API

## Parallel Execution
✅ **Can run in PARALLEL with TSK-0002** (Database Schema)

Both are foundational infrastructure tasks with NO dependencies on each other.

## Implementation Tasks
1. Create Azure Storage account using Bicep or Azure CLI
2. Configure storage account settings:
   - Performance tier: Standard (LRS for dev, GRS for prod)
   - Access tier: Hot
   - Enable encryption at rest with Microsoft-managed keys (AES-256)
   - Disable public blob access
   - Enable soft delete (7-day retention)
   - Enable versioning
3. Create blob container \`documents\`
4. Store connection string in Azure Key Vault
5. Configure network security rules
6. Enable monitoring and diagnostics
7. Test connectivity

## Acceptance Criteria
- ✅ Storage account created with encryption enabled (AES-256)
- ✅ Blob container \`documents\` exists with Private access level
- ✅ Connection string stored in Key Vault secret \`StorageConnectionString\`
- ✅ Network security configured (authorized access only)
- ✅ Soft delete enabled (7-day retention)
- ✅ Monitoring enabled (logs to Log Analytics)
- ✅ Connectivity tested (upload/download operations successful)

## Definition of Done
- [ ] Bicep template created and deployed
- [ ] Storage account follows naming convention
- [ ] Encryption at rest verified (AES-256)
- [ ] Public blob access disabled
- [ ] Soft delete and versioning enabled
- [ ] Container \`documents\` created
- [ ] Connection string in Key Vault
- [ ] Network security rules configured
- [ ] Manual tests passed (upload/download/delete/recovery)
- [ ] Documentation updated
- [ ] Code review completed (2+ reviewers)
- [ ] DevOps Lead and Engineering Lead approval

## Estimated Effort
- Development: 2 hours
- Deployment: 30 minutes
- Testing: 1 hour
- Documentation: 30 minutes
- **Total: 4 hours (0.5 days) = 3 story points**

---
📄 **Full Documentation:** See [\`TSK-0001.md\`](backlog/tasks/TSK-0001.md)"
```

## Task: TSK-0002

```bash
# Replace <STORY_ISSUE_NUMBER> with the US-0001 issue number
gh issue create \
  --repo siddjoshi/EDUTrack-Demo \
  --title "[TSK-0002] Design and Implement SQL Database Schema for Document Metadata" \
  --label "task,priority:critical,sprint:1,status:todo" \
  --body "**Parent:** #<STORY_ISSUE_NUMBER>

## Metadata
- **Target Release:** Sprint 1
- **Status:** To Do
- **Story Points:** 5
- **Assigned To:** Data Lead
- **Sprint:** Sprint 1

## Objective
Design and implement the SQL Database schema for storing document metadata (title, description, source, file type, size, blob URL, status) to support content ingestion and repository management.

## Traceability
- **Item ID:** TSK-0002
- **Parent Story:** US-0001 - L&D Admin Document Upload
- **Feature:** FE-0001 - Content Ingestion & Management
- **Epic:** EP-0001 - AI-Powered Learning & Training Platform
- **Backlog File:** \`backlog/tasks/TSK-0002.md\`
- **BRD:** BRD-FR-006
- **SRS:** SRS-FUNC-009, SRS-FUNC-007
- **NFR:** NFR-PERF-TH-006 (Support 1M documents)

## Dependencies
### Blocking Dependencies
- ✅ Azure SQL Database provisioned

### Downstream Dependencies
- TSK-0005: Implement backend API (requires Document entity model)
- TSK-0006: Implement duplicate detection (requires FileHash unique index)

## Parallel Execution
✅ **Can run in PARALLEL with TSK-0001** (Blob Storage Provisioning)

Both are foundational infrastructure tasks with NO dependencies on each other.

## Database Tables
1. **Documents Table** (\`dbo.Documents\`)
   - DocumentId (uniqueidentifier, PK)
   - Title, Description, SourceType, SourceUrl, SourceAuthor
   - FileType, FileSizeBytes, FileHash (SHA-256, UNIQUE)
   - BlobUrl, IngestionDate, Status, Version
   - CreatedBy, CreatedAt, UpdatedBy, UpdatedAt
   - IsDeleted, DeletedAt (soft delete)

2. **DocumentTags Table** (\`dbo.DocumentTags\`)
   - DocumentTagId, DocumentId (FK), Tag, CreatedAt

3. **Indexes:**
   - Clustered index on DocumentId
   - Unique index on FileHash (deduplication)
   - Non-clustered indexes on SourceType, Status
   - Full-text index on Title, Description

## Acceptance Criteria
- ✅ \`Documents\` and \`DocumentTags\` tables created with correct schema
- ✅ Unique constraint on FileHash enforced
- ✅ Indexes created (query performance <10ms for 1000 rows)
- ✅ Seed data inserted (10 test documents)
- ✅ EF Core entity models validated

## Definition of Done
- [ ] C# entity models created (Document, DocumentTag)
- [ ] DbContext class created
- [ ] EF Core migration generated and applied
- [ ] Indexes created (FileHash unique, Status, SourceType)
- [ ] Full-text index configured
- [ ] Seed data script executed
- [ ] Unit tests passed (validation rules)
- [ ] Integration tests passed (insert, query, deduplication)
- [ ] ERD diagram created
- [ ] Documentation updated
- [ ] Code review completed (2+ reviewers)
- [ ] Data Lead and Solution Architect approval

## Estimated Effort
- Development: 3 hours
- Testing: 1.5 hours
- Documentation: 0.5 hours
- **Total: 5 hours (0.625 days) = 5 story points**

---
📄 **Full Documentation:** See [\`TSK-0002.md\`](backlog/tasks/TSK-0002.md)"
```

## Execution Instructions

Run these commands in order, replacing the placeholder issue numbers as you go:

1. Create Epic (EP-0001) - Note the issue number
2. Create Feature FE-0001 - Replace `<EPIC_ISSUE_NUMBER>` with Epic's number
3. Create Feature FE-0002 - Replace `<EPIC_ISSUE_NUMBER>` with Epic's number
4. Create Story US-0001 - Replace `<FEATURE_ISSUE_NUMBER>` with FE-0001's number
5. Create Task TSK-0001 - Replace `<STORY_ISSUE_NUMBER>` with US-0001's number
6. Create Task TSK-0002 - Replace `<STORY_ISSUE_NUMBER>` with US-0001's number

After creating all issues, save the mapping:

```bash
cat > backlog/issue-mapping.json << 'EOF'
{
  "EP-0001": <EPIC_ISSUE_NUMBER>,
  "FE-0001": <FE0001_ISSUE_NUMBER>,
  "FE-0002": <FE0002_ISSUE_NUMBER>,
  "US-0001": <US0001_ISSUE_NUMBER>,
  "TSK-0001": <TSK0001_ISSUE_NUMBER>,
  "TSK-0002": <TSK0002_ISSUE_NUMBER>
}
EOF
```

## Verification

After creating all issues, verify:
- [ ] All 6 issues created
- [ ] Parent references correctly point to parent issues
- [ ] Labels applied correctly
- [ ] TSK-0001 and TSK-0002 both note they can run in parallel
- [ ] Dependencies documented
- [ ] Traceability links working
