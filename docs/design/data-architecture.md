# Data Architecture
## EDUTrack - Internal AI Learning & Training Platform

---

## Document Control
| Version | Date | Author | Reviewer | Notes |
|---------|------|--------|----------|-------|
| 0.1     | 2025-11-21 | Data Architect | | Draft |
| 1.0     | 2025-11-21 | Data Architect | Solution Architect, DPO | Baseline |

## Approvals
| Name | Role | Stakeholder ID | Signature | Date |
|------|------|----------------|-----------|------|
| TBD | Solution Architect | STK-014 | | |
| TBD | Data Protection Officer | STK-011 | | |
| TBD | Development Lead | STK-015 | | |
| TBD | Compliance Officer | STK-006 | | |

---

## 1. Executive Summary

### 1.1 Purpose

This Data Architecture document provides a comprehensive specification of data models, flows, governance, and management strategies for the EDUTrack platform. It defines conceptual, logical, and physical data models, data classifications, retention policies, privacy controls, and data lineage to ensure data integrity, security, and compliance throughout the platform lifecycle.

**Intended Audience:**
- Solution Architects and Data Architects
- Database Administrators and Development Teams
- Data Protection Officer and Compliance Team
- QA and Testing Teams
- Operations and Support Teams

### 1.2 Scope

This data architecture covers:
- **Data Models:** Conceptual, logical, and physical entity models
- **Data Flows:** End-to-end data movement and transformations
- **Data Governance:** Classification, ownership, stewardship, quality
- **Data Storage:** Database schemas, indexing, partitioning strategies
- **Data Privacy:** PII handling, GDPR compliance, consent management
- **Data Retention:** Retention policies, archival, deletion procedures
- **Data Lineage:** Source-to-target traceability for audit and compliance
- **Data Integration:** External system interfaces and data synchronization

**Out of Scope:**
- Application logic and business rules (covered in SRS)
- Infrastructure provisioning details (covered in HLD)
- Security controls beyond data-specific measures (covered in Threat Model)

### 1.3 Data Architecture Principles

1. **Data as a Strategic Asset:** Treat data as a valuable corporate asset requiring protection, governance, and quality management
2. **Single Source of Truth:** Establish authoritative data sources to prevent duplication and inconsistency
3. **Privacy by Design:** Embed data privacy and protection throughout the data lifecycle
4. **Data Quality First:** Implement validation, cleansing, and monitoring to ensure data accuracy and completeness
5. **Scalability and Performance:** Design data structures to support 10,000 users and 1M documents
6. **Compliance-Ready:** Ensure data architecture supports GDPR, ISO 27001, and corporate retention policies
7. **Auditability:** Maintain complete lineage and audit trails for regulatory compliance
8. **Interoperability:** Design data models to support integrations and future extensibility

---

## 2. Conceptual Data Model

### 2.1 Domain Model Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     EDUTrack Data Domains                        │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐     │
│  │   Identity   │    │   Content    │    │   Learning   │     │
│  │   Domain     │───▶│   Domain     │───▶│   Domain     │     │
│  └──────────────┘    └──────────────┘    └──────────────┘     │
│         │                    │                    │             │
│         │                    │                    │             │
│         ▼                    ▼                    ▼             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐     │
│  │  Governance  │    │  Analytics   │    │ Integration  │     │
│  │   Domain     │    │   Domain     │    │   Domain     │     │
│  └──────────────┘    └──────────────┘    └──────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Core Entities and Relationships

```
User (Identity Domain)
  │
  ├──> SkillProfile (Learning Domain)
  │      │
  │      └──> Skill (Reference Data)
  │
  ├──> LearningPath (Learning Domain)
  │      │
  │      └──> Module (Content Domain)
  │             │
  │             ├──> Assessment (Content Domain)
  │             └──> Document (Content Domain)
  │
  ├──> CompletionRecord (Learning Domain)
  │      │
  │      └──> Module
  │
  └──> AuditLog (Governance Domain)


Document (Content Domain)
  │
  ├──> Module (Content Domain)
  │      │
  │      ├──> Assessment (Content Domain)
  │      ├──> SkillTag (Reference Data)
  │      └──> ContentVersion (Governance Domain)
  │
  └──> ContentMetadata (Content Domain)


Analytics (Analytics Domain)
  │
  ├──> LearnerAnalytics
  ├──> ManagerAnalytics
  ├──> PlatformAnalytics
  └──> ComplianceAnalytics
```

### 2.3 Entity Descriptions

| Domain | Entity | Description | Cardinality | Key Attributes |
|--------|--------|-------------|-------------|----------------|
| **Identity** | User | Employee account synced from Azure AD | 10,000 records | user_id, email, name, job_title, department, manager |
| **Identity** | Role | RBAC roles (Admin, ContentReviewer, Manager, Learner) | 4 records | role_id, role_name, permissions |
| **Content** | Document | Ingested source content (PDF, DOCX, etc.) | 1M+ records | document_id, title, source_type, file_hash, extracted_text |
| **Content** | Module | AI-generated training modules | 10K+ records | module_id, document_id, summary, objectives, content |
| **Content** | Assessment | Quiz and scenario questions | 100K+ records | assessment_id, module_id, question_text, correct_answer |
| **Learning** | SkillProfile | Individual skill proficiency levels | 10K users x 50 skills avg | user_id, skill_id, proficiency, last_assessed |
| **Learning** | LearningPath | Personalized learning journeys | 15K+ records | path_id, user_id, status, modules[], assigned_by |
| **Learning** | CompletionRecord | Training completion tracking | 500K+ records/year | record_id, user_id, module_id, score, completed_at |
| **Analytics** | PlatformMetrics | Aggregated usage metrics | Time-series data | metric_date, MAU, DAU, sessions, engagement |
| **Governance** | AuditLog | Security and compliance audit trail | Millions of records | log_id, timestamp, user_id, action, entity_type, details |
| **Reference** | Skill | Organization skill taxonomy | 500+ records | skill_id, skill_name, category, parent_skill |

---

## 3. Logical Data Model

### 3.1 Identity Domain

**User Entity**
```sql
User {
  user_id: UUID [PK]
  azure_ad_id: STRING [UNIQUE, NOT NULL]  -- Azure AD object ID
  email: STRING [UNIQUE, NOT NULL, INDEXED]
  first_name: STRING(100)
  last_name: STRING(100)
  job_title: STRING(200)
  department: STRING(200)
  manager_id: UUID [FK -> User.user_id]
  role: ENUM(Admin, ContentReviewer, Manager, Learner)
  created_at: TIMESTAMP [DEFAULT CURRENT_TIMESTAMP]
  last_login: TIMESTAMP
  status: ENUM(Active, Inactive, Deleted) [DEFAULT Active]
}

Indexes:
  - PRIMARY KEY (user_id)
  - UNIQUE INDEX idx_azure_ad_id (azure_ad_id)
  - INDEX idx_email (email)
  - INDEX idx_manager (manager_id)
  - INDEX idx_status (status)
```

**Role Entity**
```sql
Role {
  role_id: INT [PK]
  role_name: STRING(50) [UNIQUE, NOT NULL]
  description: TEXT
  permissions: JSON  -- Array of permission strings
  created_at: TIMESTAMP
}

Data:
  1, 'Admin', 'Platform administrator', ['*']
  2, 'ContentReviewer', 'SME content reviewer', ['review_content', 'approve_modules']
  3, 'Manager', 'Team manager', ['view_team_analytics', 'assign_training']
  4, 'Learner', 'Employee learner', ['view_courses', 'take_assessments']
```

### 3.2 Content Domain

**Document Entity**
```sql
Document {
  document_id: UUID [PK]
  title: STRING(500) [NOT NULL]
  description: TEXT
  source_type: ENUM(SharePoint, Confluence, GitHub, LocalUpload)
  source_url: STRING(2000)
  source_author: STRING(200)
  file_type: STRING(50)  -- PDF, DOCX, PPTX, MD, HTML
  file_size: BIGINT  -- bytes
  file_hash: STRING(64) [INDEXED]  -- SHA-256 for deduplication
  blob_url: STRING(2000) [NOT NULL]  -- Azure Blob Storage SAS URL
  extracted_text: TEXT  -- Full text extraction
  ingestion_date: TIMESTAMP [DEFAULT CURRENT_TIMESTAMP]
  status: ENUM(Ingested, Processed, Error, Archived, Deleted) [DEFAULT Ingested]
  version: INT [DEFAULT 1]
  created_by: UUID [FK -> User.user_id]
  metadata: JSON  -- Additional metadata (tags, custom fields)
}

Indexes:
  - PRIMARY KEY (document_id)
  - INDEX idx_file_hash (file_hash)  -- Deduplication
  - INDEX idx_source_type (source_type)
  - INDEX idx_status (status)
  - INDEX idx_ingestion_date (ingestion_date DESC)
  - FULLTEXT INDEX idx_extracted_text (extracted_text)  -- If supported
```

**Module Entity**
```sql
Module {
  module_id: UUID [PK]
  document_id: UUID [FK -> Document.document_id]
  title: STRING(500) [NOT NULL]
  summary: TEXT(500)
  detailed_explanation: TEXT
  learning_objectives: JSON  -- Array of strings (3-7 objectives)
  key_concepts: JSON  -- Array of {concept, definition} (5-15 concepts)
  instructions: TEXT  -- Step-by-step instructions for procedural content
  duration_minutes: INT  -- Estimated completion time
  difficulty: ENUM(Beginner, Intermediate, Advanced)
  generated_at: TIMESTAMP [DEFAULT CURRENT_TIMESTAMP]
  hallucination_score: DECIMAL(5,2)  -- 0.00 to 100.00
  status: ENUM(Generated, UnderReview, Approved, Rejected, Published, Archived)
  approved_by: UUID [FK -> User.user_id]
  approved_at: TIMESTAMP
  published_at: TIMESTAMP
  version: INT [DEFAULT 1]
  metadata: JSON
}

Indexes:
  - PRIMARY KEY (module_id)
  - INDEX idx_document_id (document_id)
  - INDEX idx_status (status)
  - INDEX idx_published_at (published_at DESC)
  - INDEX idx_hallucination_score (hallucination_score)
```

**Assessment Entity**
```sql
Assessment {
  assessment_id: UUID [PK]
  module_id: UUID [FK -> Module.module_id]
  question_type: ENUM(MCQ, Scenario, HandsOn)
  question_text: TEXT [NOT NULL]
  answer_choices: JSON  -- Array of strings (for MCQ)
  correct_answer: JSON  -- String or array depending on question type
  explanation: TEXT  -- Explanation for correct answer
  difficulty: ENUM(Easy, Medium, Hard)
  order: INT  -- Display order within module
  points: INT [DEFAULT 1]
  metadata: JSON
}

Indexes:
  - PRIMARY KEY (assessment_id)
  - INDEX idx_module_id (module_id)
  - INDEX idx_question_type (question_type)
```

**ModuleSkill (Many-to-Many Relationship)**
```sql
ModuleSkill {
  module_id: UUID [FK -> Module.module_id]
  skill_id: UUID [FK -> Skill.skill_id]
  relevance: DECIMAL(3,2)  -- 0.00 to 1.00 (confidence score)
  created_at: TIMESTAMP
}

Indexes:
  - PRIMARY KEY (module_id, skill_id)
  - INDEX idx_skill_id (skill_id)
```

### 3.3 Learning Domain

**SkillProfile Entity**
```sql
SkillProfile {
  user_id: UUID [FK -> User.user_id]
  skill_id: UUID [FK -> Skill.skill_id]
  proficiency: ENUM(None, Beginner, Intermediate, Advanced, Expert)
  last_assessed: TIMESTAMP
  evidence_source: ENUM(Assessment, ManagerInput, SelfReport, External)
  confidence: DECIMAL(3,2)  -- 0.00 to 1.00
  metadata: JSON
}

Indexes:
  - PRIMARY KEY (user_id, skill_id)
  - INDEX idx_skill_id (skill_id)
  - INDEX idx_proficiency (proficiency)
  - INDEX idx_last_assessed (last_assessed DESC)
```

**LearningPath Entity**
```sql
LearningPath {
  path_id: UUID [PK]
  user_id: UUID [FK -> User.user_id]
  path_type: ENUM(Recommended, Mandatory, SelfDirected)
  name: STRING(200)
  description: TEXT
  assigned_by: UUID [FK -> User.user_id]  -- Manager if mandatory
  due_date: DATE
  status: ENUM(NotStarted, InProgress, Completed, Overdue)
  modules: JSON  -- Ordered array of module_ids
  created_at: TIMESTAMP [DEFAULT CURRENT_TIMESTAMP]
  completed_at: TIMESTAMP
  metadata: JSON
}

Indexes:
  - PRIMARY KEY (path_id)
  - INDEX idx_user_id (user_id)
  - INDEX idx_status (status)
  - INDEX idx_due_date (due_date)
  - INDEX idx_path_type (path_type)
```

**CompletionRecord Entity**
```sql
CompletionRecord {
  record_id: UUID [PK]
  user_id: UUID [FK -> User.user_id]
  module_id: UUID [FK -> Module.module_id]
  learning_path_id: UUID [FK -> LearningPath.path_id, NULL]
  started_at: TIMESTAMP
  completed_at: TIMESTAMP
  time_spent_seconds: INT
  assessment_score: DECIMAL(5,2)  -- 0.00 to 100.00
  attempts: INT [DEFAULT 1]
  status: ENUM(InProgress, Completed, Failed)
  metadata: JSON
}

Indexes:
  - PRIMARY KEY (record_id)
  - INDEX idx_user_id (user_id)
  - INDEX idx_module_id (module_id)
  - INDEX idx_completed_at (completed_at DESC)
  - INDEX idx_status (status)
  - COMPOSITE INDEX idx_user_module (user_id, module_id)
```

### 3.4 Governance Domain

**AuditLog Entity**
```sql
AuditLog {
  log_id: UUID [PK]
  timestamp: TIMESTAMP [DEFAULT CURRENT_TIMESTAMP, INDEXED]
  event_type: STRING(100) [INDEXED]  -- e.g., ai_generation, content_approval, user_login
  user_id: UUID [FK -> User.user_id]
  entity_type: STRING(100)  -- Document, Module, User, etc.
  entity_id: UUID
  action: STRING(200)  -- created, updated, deleted, approved, etc.
  details: JSON  -- Full event context
  ip_address: STRING(45)
  user_agent: STRING(500)
  session_id: STRING(100)
}

Indexes:
  - PRIMARY KEY (log_id)
  - INDEX idx_timestamp (timestamp DESC)  -- Time-series queries
  - INDEX idx_event_type (event_type)
  - INDEX idx_user_id (user_id)
  - INDEX idx_entity (entity_type, entity_id)
  - COMPOSITE INDEX idx_user_timestamp (user_id, timestamp DESC)
```

**AIInteractionLog (Specialized Audit Log)**
```sql
AIInteractionLog {
  interaction_id: UUID [PK]
  timestamp: TIMESTAMP [DEFAULT CURRENT_TIMESTAMP]
  user_id: UUID [FK -> User.user_id]
  document_id: UUID [FK -> Document.document_id]
  module_id: UUID [FK -> Module.module_id]
  prompt: TEXT  -- Full prompt sent to OpenAI
  response: TEXT  -- Full AI response
  model: STRING(50)  -- e.g., gpt-4, gpt-3.5-turbo
  tokens_used: INT
  cost_usd: DECIMAL(10,4)
  hallucination_score: DECIMAL(5,2)
  pii_detected: BOOLEAN [DEFAULT FALSE]
  pii_entities: JSON  -- Array of detected PII entities
  metadata: JSON
}

Indexes:
  - PRIMARY KEY (interaction_id)
  - INDEX idx_timestamp (timestamp DESC)
  - INDEX idx_user_id (user_id)
  - INDEX idx_document_id (document_id)
  - INDEX idx_pii_detected (pii_detected)
```

### 3.5 Reference Data Domain

**Skill Entity**
```sql
Skill {
  skill_id: UUID [PK]
  skill_name: STRING(200) [UNIQUE, NOT NULL]
  description: TEXT
  category: STRING(100)  -- e.g., Technical, Leadership, Compliance
  parent_skill_id: UUID [FK -> Skill.skill_id, NULL]  -- Hierarchical skills
  is_active: BOOLEAN [DEFAULT TRUE]
  created_at: TIMESTAMP
  metadata: JSON
}

Indexes:
  - PRIMARY KEY (skill_id)
  - UNIQUE INDEX idx_skill_name (skill_name)
  - INDEX idx_category (category)
  - INDEX idx_parent_skill (parent_skill_id)
```

---

## 4. Physical Data Model

### 4.1 Data Storage Strategy

| Data Type | Storage System | Rationale | Performance Target | Cost Optimization |
|-----------|----------------|-----------|-------------------|-------------------|
| **Relational Data** | Azure SQL Database | ACID compliance, complex joins, referential integrity | <100ms query P95 | Standard S3 tier; scale up as needed |
| **Document Store** | Azure Cosmos DB | High-write audit logs, flexible schema, global distribution | <10ms write latency | Provisioned throughput 400 RU/s; auto-scale |
| **File Storage** | Azure Blob Storage | Scalable object storage for documents, low cost | <2s upload/download | Hot tier for active; Cool tier for archived |
| **Search Index** | Azure AI Search | Full-text and semantic search, AI embeddings | <500ms search P95 | Standard S1 tier; 1 partition, 1 replica |
| **Cache Layer** | Azure Redis Cache | Session data, frequently accessed lookups | <10ms latency | Basic tier (1GB); upgrade to Standard for HA |
| **Analytics** | Azure Synapse Analytics (future) | OLAP workloads, data warehousing | N/A (Phase 3) | Deferred until Phase 3 |

### 4.2 Database Schemas

**Azure SQL Database (Relational Data)**

**Schema: `identity`**
- Tables: User, Role, UserRole

**Schema: `content`**
- Tables: Document, Module, Assessment, ModuleSkill, ContentVersion

**Schema: `learning`**
- Tables: SkillProfile, LearningPath, CompletionRecord, Skill

**Partitioning Strategy:**
- CompletionRecord: Partitioned by `completed_at` (monthly partitions)
- Document: Partitioned by `ingestion_date` (yearly partitions)
- AuditLog: Time-series partitioning (monthly) with automated archival

**Azure Cosmos DB (NoSQL - Audit Logs)**

**Container: `audit_logs`**
- Partition Key: `/user_id` (distribute writes across users)
- TTL: 7 years (2,555 days)
- Indexing: Automatic for all properties

**Container: `ai_interaction_logs`**
- Partition Key: `/document_id` (distribute by document)
- TTL: 7 years
- Indexing: timestamp, user_id, pii_detected

### 4.3 Data Volumes and Growth

| Entity | Initial Volume | Annual Growth | 3-Year Projection | Storage Estimate |
|--------|----------------|---------------|-------------------|------------------|
| User | 10,000 | 5% (500/year) | 11,500 | 10 MB |
| Document | 10,000 | 20% (2,000/year) | 16,000 | 500 GB (with blobs) |
| Module | 1,000 | 30% (300/year) | 1,900 | 50 MB |
| Assessment | 10,000 | 30% (3,000/year) | 19,000 | 20 MB |
| CompletionRecord | 50,000 | 100% (50,000/year) | 200,000 | 100 MB |
| AuditLog | 1M | 50% (500K/year) | 2.5M | 5 GB |
| AIInteractionLog | 10,000 | 30% (3,000/year) | 19,000 | 200 MB (large JSON) |
| **Total** | N/A | N/A | N/A | **~700 GB** |

**Reference:** PERF-TH-006 (NFR - 1M document storage capacity)

---

## 5. Data Flows and Lineage

### 5.1 Content Ingestion Flow

```
[SharePoint/Confluence/GitHub] 
       │
       │ (1) API Request (OAuth 2.0)
       ▼
[Integration Service]
       │
       │ (2) Download Document
       ▼
[Azure Blob Storage]  ──────────┐
       │                         │
       │ (3) Extract Text         │ (Parallel)
       ▼                         │
[Text Extraction Service]       │
       │                         │
       │ (4) Store Metadata      │
       ▼                         │
[Azure SQL: Document Table]     │
       │                         │
       │ (5) Trigger Event       │
       ▼                         │
[Event Grid/Queue]               │
       │                         │
       │ (6) Dequeue             │
       ▼                         │
[AI Generation Service] ◄────────┘
       │
       │ (7) PII Detection
       ▼
[PII Filter]
       │
       │ (8) OpenAI API Call (if PII-free)
       ▼
[Azure OpenAI]
       │
       │ (9) AI Response
       ▼
[Azure SQL: Module Table]
       │
       │ (10) Log AI Interaction
       ▼
[Cosmos DB: AIInteractionLog]
```

**Data Lineage:**
- Document ID → Module ID → Assessment IDs → CompletionRecord IDs
- All transformations logged in AuditLog with before/after snapshots

### 5.2 Learning Path Generation Flow

```
[User Profile] + [Skill Gap Analysis]
       │
       │ (1) Query User Skills
       ▼
[Azure SQL: SkillProfile]
       │
       │ (2) Calculate Gaps
       ▼
[Recommendation Engine]
       │
       │ (3) Query Available Modules
       ▼
[Azure SQL: Module + ModuleSkill]
       │
       │ (4) Filter by Relevance
       ▼
[Azure AI Search: Semantic Ranking]
       │
       │ (5) Generate Path
       ▼
[Azure SQL: LearningPath]
       │
       │ (6) Log Generation
       ▼
[Cosmos DB: AuditLog]
```

### 5.3 Analytics Aggregation Flow

```
[CompletionRecord] + [SkillProfile] + [LearningPath]
       │
       │ (1) Batch Query (Nightly)
       ▼
[Azure SQL: Aggregation Queries]
       │
       │ (2) Transform
       ▼
[ETL Pipeline (Azure Data Factory - Future)]
       │
       │ (3) Store Metrics
       ▼
[Azure SQL: PlatformMetrics View]
       │
       │ (4) Cache for Dashboards
       ▼
[Azure Redis Cache]
       │
       │ (5) Serve Dashboards
       ▼
[Frontend: Analytics Dashboards]
```

---

## 6. Data Governance

### 6.1 Data Classification

| Classification | Definition | Examples | Handling Requirements | Retention |
|----------------|------------|----------|----------------------|-----------|
| **Public** | Non-sensitive information | Published training modules (non-confidential topics) | TLS in transit | 7 years |
| **Internal** | Non-PII business data | Skill taxonomy, draft content, analytics aggregates | TLS + encryption at rest | 7 years |
| **Confidential** | Sensitive business/employee data | Employee PII, training records, assessment scores | TLS + encryption at rest + column-level encryption | 7 years |
| **Restricted** | Highly sensitive audit data | Audit logs, API keys, AI prompts/responses | TLS + encryption at rest + access logging + RBAC | 7 years |

**Reference:** SEC-DATA-005 (NFR), SRS Section 5.5

### 6.2 Data Ownership

| Domain | Data Owner | Data Steward | Data Custodian | Approval Authority |
|--------|------------|--------------|----------------|-------------------|
| Identity | CHRO (STK-003) | HR Manager | IT Operations | CHRO |
| Content | CLO (STK-001) | L&D Manager (STK-021) | Content Manager (STK-022) | CLO |
| Learning | CLO (STK-001) | L&D Manager | QA Team | CLO |
| Governance | Compliance Officer (STK-006) | Security Analyst (STK-027) | DevOps | CISO (STK-010) |
| Analytics | CLO (STK-001) | Data Scientist (STK-019) | Analytics Team | CLO |

### 6.3 Data Quality Rules

| Quality Dimension | Rule | Validation Method | Remediation |
|-------------------|------|-------------------|-------------|
| **Completeness** | All required fields populated (user.email, document.title, etc.) | Database NOT NULL constraints, API validation | Reject submission; user correction required |
| **Accuracy** | Email format valid; employee ID matches Azure AD | Regex validation, Azure AD sync | Auto-correction from Azure AD; user notification |
| **Consistency** | Skill proficiency levels consistent with assessment scores | Business rule validation | Recalculate proficiency; flag for review |
| **Timeliness** | Training records updated within 30 seconds of completion | SLA monitoring | Auto-save every 30s (SRS-FUNC-116) |
| **Uniqueness** | No duplicate users (email unique); no duplicate documents (file hash) | Unique constraints, hash-based deduplication | Reject duplicate; link to existing record |
| **Validity** | Assessment scores 0-100; dates in valid range | Range checks, data type validation | Reject invalid input; error message |

### 6.4 Data Retention and Archival

| Data Type | Active Retention | Archive Period | Total Retention | Deletion Trigger | Archive Location |
|-----------|------------------|----------------|-----------------|------------------|------------------|
| User Profiles | While employed + 90 days | N/A | Terminated + 90 days | GDPR erasure request OR 90 days post-termination | Soft delete (SQL) |
| Training History | 7 years | N/A | 7 years | After 7 years | Azure SQL → Azure Blob (cool tier) |
| Audit Logs | 7 years | N/A | 7 years | After 7 years | Cosmos DB (TTL 7 years) |
| Content Versions | 1 year active | 6 years archived | 7 years total | After 7 years | SQL → Blob Storage (archive tier) |
| Analytics Aggregates | 3 years active | Indefinite | Indefinite | Never deleted | SQL → Synapse Analytics (future) |
| Raw Events | 1 year | 2 years | 3 years | After 3 years | Cosmos DB → Azure Data Lake (future) |
| Unpublished Content | 90 days | N/A | 90 days | If not published/approved | Soft delete |

**Reference:** COMP-005 (NFR), SRS Section 5.4

### 6.5 Data Privacy and PII Handling

**PII Elements:**
- Direct Identifiers: Name, email, employee ID, Azure AD ID
- Indirect Identifiers: Job title, department, manager relationship
- Sensitive Data: Assessment scores, skill proficiency, training history

**Privacy Controls:**
1. **Minimization:** Collect only necessary PII; avoid extraneous data
2. **Consent:** Privacy policy displayed during first login; explicit consent for optional data
3. **Access Control:** RBAC restricts PII access; managers see only their team's data
4. **Anonymization:** Analytics dashboards use aggregated, anonymized data (no individual PII)
5. **Pseudonymization:** User IDs replace names in audit logs where possible
6. **Encryption:** Column-level encryption for PII fields (SEC-DATA-007)
7. **PII Detection:** Automated scanning before AI processing (SEC-DATA-003, SEC-AI-003)
8. **Right to Access:** Users can export their data via self-service dashboard
9. **Right to Erasure:** Automated deletion workflow within 30 days (SEC-DATA-006)
10. **Breach Notification:** 72-hour GDPR notification SLA if PII breach occurs

**Reference:** COMP-001 (NFR - GDPR Compliance), SRS Section 5.5

---

## 7. Data Integration

### 7.1 Integration Interfaces

| External System | API Type | Authentication | Data Direction | Frequency | Data Volume | Error Handling |
|-----------------|----------|----------------|----------------|-----------|-------------|----------------|
| **Azure AD** | Microsoft Graph API | OAuth 2.0 | Inbound (user profiles) | Daily sync | 10K users (~10 MB) | Retry 3x; alert on failure |
| **SharePoint Online** | Microsoft Graph API | OAuth 2.0 (app token) | Inbound (documents) | Hourly change detection | ~100 docs/day (~500 MB) | Retry 3x; skip on failure; log error |
| **Confluence Cloud** | REST API v2 | Basic Auth (API token) | Inbound (pages) | Hourly change detection | ~50 pages/day (~100 MB) | Retry 3x; skip on failure |
| **GitHub** | REST API v3 | Personal Access Token | Inbound (files) | Daily | ~20 files/day (~10 MB) | Retry 3x; skip on failure |
| **Microsoft Learn** | Public REST API | None (or API key) | Inbound (module metadata) | Weekly catalog update | ~1000 modules (~5 MB) | Use cached catalog if API unavailable |
| **Azure OpenAI** | Azure SDK / REST | API key (Key Vault) | Bidirectional (prompts/responses) | On-demand | 10K requests/month | Retry 3x; queue if quota exceeded |
| **Azure AI Search** | Azure SDK / REST | API key (Key Vault) | Outbound (indexing) + Inbound (search) | Indexing on publish; search on-demand | 10K modules indexed | Fallback to keyword search if unavailable |

**Reference:** SRS Section 4.3 (Software Interfaces)

### 7.2 Data Synchronization

**User Profile Sync (Azure AD → EDUTrack)**
```
Schedule: Daily at 2 AM UTC
Process:
  1. Query Azure AD for all users (Microsoft Graph API)
  2. Compare with EDUTrack User table (by azure_ad_id)
  3. Insert new users, update changed users (email, name, job_title, department, manager)
  4. Mark inactive users (not in Azure AD) as Status=Inactive
  5. Log sync results (users added, updated, inactivated)
Conflict Resolution: Azure AD is source of truth; overwrite EDUTrack data
Error Handling: Retry 3x; alert IT Operations if all fail; skip user on error; continue with remaining
```

**Document Sync (SharePoint/Confluence/GitHub → EDUTrack)**
```
Schedule: Hourly change detection (based on modified_date)
Process:
  1. Query external system for documents modified since last sync
  2. For each document:
     a. Calculate SHA-256 hash
     b. Check for duplicate in EDUTrack (by file_hash)
     c. If new or changed: Download file, upload to Blob Storage, create/update Document record
     d. Queue for text extraction and AI generation
  3. Log sync results (documents ingested, duplicates skipped, errors)
Conflict Resolution: Most recent version wins
Error Handling: Retry 3x per document; skip on failure; log error; continue with remaining
```

### 7.3 Data Transformation Rules

| Source Data | Target Data | Transformation Logic | Data Quality Check |
|-------------|-------------|----------------------|--------------------|
| Azure AD: displayName | User: first_name, last_name | Split on space; if single word, use as last_name | Validate non-empty |
| Azure AD: jobTitle | User: job_title | Direct mapping | Validate length <200 |
| SharePoint: FileLeafRef | Document: title | Direct mapping; strip file extension | Validate non-empty; truncate to 500 chars |
| Confluence: body.storage.value (HTML) | Document: extracted_text | HTML to plain text conversion | Validate extraction accuracy >95% |
| GitHub: README.md (Markdown) | Document: extracted_text | Markdown to plain text conversion | Validate non-empty |
| OpenAI: response.choices[0].text | Module: detailed_explanation | Direct mapping | Validate length >100 chars; flag if empty |
| Module: assessment_score | SkillProfile: proficiency | 90-100 → Expert; 75-89 → Advanced; 60-74 → Intermediate; 40-59 → Beginner; <40 → None | Validate score range 0-100 |

---

## 8. Data Security

### 8.1 Encryption Strategy

| Data State | Encryption Method | Key Management | Algorithm | Performance Impact |
|------------|-------------------|----------------|-----------|-------------------|
| **At Rest (Azure SQL)** | Transparent Data Encryption (TDE) | Microsoft-managed keys | AES-256 | Negligible (<5% overhead) |
| **At Rest (Blob Storage)** | Azure Storage Service Encryption (SSE) | Microsoft-managed keys | AES-256 | Negligible |
| **At Rest (Cosmos DB)** | Automatic encryption | Microsoft-managed keys | AES-256 | Negligible |
| **In Transit (All)** | TLS 1.2+ (HTTPS) | Azure-managed certificates | TLS 1.2 minimum | Negligible |
| **Column-Level (PII)** | Always Encrypted (Azure SQL) | Customer-managed keys (Key Vault) | AES-256 | Moderate (query limitations) |
| **Application-Level (Secrets)** | Azure Key Vault | Azure Key Vault RBAC | AES-256 | Negligible (cached) |

**Reference:** SEC-DATA-001, SEC-DATA-002, SEC-DATA-007 (NFR)

### 8.2 Access Control Matrix

| Role | User | Document | Module | Assessment | SkillProfile | CompletionRecord | AuditLog | AIInteractionLog |
|------|------|----------|--------|------------|--------------|------------------|----------|------------------|
| **Admin** | CRUD | CRUD | CRUD | CRUD | CRUD | CRUD | Read | Read |
| **ContentReviewer** | Read (self) | Read | RU (assigned) | RU (assigned) | Read (self) | Read (self) | None | None |
| **Manager** | Read (team) | Read | Read | Read | Read (team) | Read (team) | None | None |
| **Learner** | Read (self) | Read | Read | Read (self) | Read (self) | Read (self) | None | None |

**Legend:** C=Create, R=Read, U=Update, D=Delete

**Reference:** SEC-IAM-002 (RBAC), SRS-FUNC-192

### 8.3 Data Masking

| Field | Masking Method | Visible to Roles | Example |
|-------|----------------|------------------|---------|
| email | Partial masking (show first 2 chars + domain) | Admin, Manager (team only), Self | j***@company.com |
| first_name, last_name | Full masking (replace with asterisks) | Admin, Manager (team only), Self | John → J*** |
| assessment_score | Aggregation only | Manager (team avg only), Admin (all) | Individual scores hidden; show team average |
| audit_log.details (JSON) | PII fields redacted | Admin only | {"user": "USER_ID_123", "name": "[REDACTED]"} |

---

## 9. Data Migration

### 9.1 Initial Data Load

**User Migration (Azure AD → EDUTrack)**
```
Source: Azure AD (10,000 users)
Target: Azure SQL (User table)
Method: Microsoft Graph API batch query
Steps:
  1. Export all users from Azure AD via Graph API
  2. Transform to EDUTrack User schema
  3. Bulk insert into Azure SQL (batch size 1000)
  4. Validate record count and sample data
Validation: 100% of Azure AD users present in EDUTrack
Timeline: Week 1 of deployment
Rollback: Delete all records; re-run migration
```

**Historical Training Records (Optional - if CSV export available)**
```
Source: L&D spreadsheets (~50,000 historical completion records)
Target: Azure SQL (CompletionRecord table)
Method: CSV import via Azure Data Factory
Steps:
  1. Cleanse CSV data (remove duplicates, validate formats)
  2. Map CSV columns to CompletionRecord schema
  3. Load into staging table
  4. Validate data quality (no nulls in required fields, valid date ranges)
  5. Insert into CompletionRecord table
Validation: Spot-check 10% of records; reconciliation report
Timeline: Week 2 of deployment (optional)
Rollback: Truncate CompletionRecord table; re-run migration
```

### 9.2 Cutover Strategy

**No cutover required** - EDUTrack is a greenfield platform with no existing system to replace. Historical data migration is optional and does not impact go-live.

**Data Freeze:** Not applicable (no legacy system)

---

## 10. Monitoring and Observability

### 10.1 Data Quality Metrics

| Metric | Target | Measurement Method | Alert Threshold | Owner |
|--------|--------|-------------------|-----------------|-------|
| User profile completeness | 100% | Count of users with all required fields | <98% | HR Manager |
| Document text extraction accuracy | >95% | Sample validation against manual extraction | <90% | Content Manager (STK-022) |
| Skill tagging accuracy | >85% | SME validation rate | <80% | L&D Manager (STK-021) |
| Duplicate document rate | <1% | Count of duplicates / total documents | >2% | Content Manager |
| Missing assessment scores | 0% | Count of completed modules without scores | >0 | QA Lead (STK-016) |
| PII detection false positive rate | <10% | Manual review of PII flags | >15% | Data Scientist (STK-019) |
| Data sync failure rate | <5% | Failed sync records / total records | >10% | DevOps Lead (STK-017) |

### 10.2 Database Performance Metrics

| Metric | Target | Measurement Tool | Alert Threshold | Remediation |
|--------|--------|------------------|-----------------|-------------|
| SQL Database DTU utilization | <70% avg | Azure Monitor | >80% for 15 min | Scale up database tier |
| SQL query P95 latency | <100ms | Application Insights | >200ms | Optimize queries; add indexes |
| Cosmos DB RU/s utilization | <80% | Azure Monitor | >90% for 5 min | Auto-scale RU/s |
| Blob Storage read latency | <2s P95 | Azure Monitor | >5s | Investigate network; CDN configuration |
| Redis cache hit rate | >90% | Azure Monitor | <80% | Increase cache size; review cache strategy |

**Reference:** PERF-RES-001 to PERF-RES-006 (NFR)

### 10.3 Data Lineage Tracking

**Audit Trail Requirements:**
- All data transformations logged with source_id, target_id, transformation_type, timestamp
- AI-generated content: Document ID → Module ID → Assessment IDs (AIInteractionLog)
- User actions: User ID → Action → Entity Type → Entity ID (AuditLog)
- Data sync: External System → Document ID → Module ID (Sync logs)

**Tools:**
- Azure SQL: Built-in change tracking and temporal tables
- Cosmos DB: TTL-based audit log retention (7 years)
- Azure Data Factory (future): Data lineage visualization

---

## 11. Appendices

### Appendix A: Entity Relationship Diagram (ERD)

**Reference:** `docs/diagrams/data-model-erd.png` (to be created with HLD)

**Key Relationships:**
- User 1:N LearningPath (one user has many learning paths)
- User 1:N CompletionRecord (one user has many completion records)
- User N:M Skill via SkillProfile (many-to-many with proficiency attribute)
- Document 1:1 Module (one document generates one module)
- Module 1:N Assessment (one module has many assessments)
- Module N:M Skill via ModuleSkill (many-to-many with relevance attribute)
- LearningPath N:M Module (many-to-many via JSON array)

### Appendix B: Data Dictionary

**Available in:** `docs/design/data-dictionary.xlsx` (to be created)

**Contents:**
- Entity name, description, owner
- Attribute name, data type, length, nullable, default value, description
- Primary keys, foreign keys, indexes
- Business rules and validation constraints

### Appendix C: Sample Data

**User Sample**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "azure_ad_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "email": "john.doe@company.com",
  "first_name": "John",
  "last_name": "Doe",
  "job_title": "Senior Software Engineer",
  "department": "Engineering",
  "manager_id": "660e8400-e29b-41d4-a716-446655440001",
  "role": "Learner",
  "created_at": "2025-11-01T00:00:00Z",
  "last_login": "2025-11-21T08:30:00Z",
  "status": "Active"
}
```

**Module Sample**
```json
{
  "module_id": "770e8400-e29b-41d4-a716-446655440002",
  "document_id": "880e8400-e29b-41d4-a716-446655440003",
  "title": "Introduction to Azure OpenAI",
  "summary": "Learn how to integrate Azure OpenAI into applications for intelligent content generation and analysis.",
  "learning_objectives": [
    "Understand Azure OpenAI service capabilities",
    "Set up Azure OpenAI resource and API keys",
    "Make API calls for text generation and embeddings"
  ],
  "hallucination_score": 12.5,
  "status": "Published",
  "approved_by": "990e8400-e29b-41d4-a716-446655440004",
  "published_at": "2025-11-15T10:00:00Z"
}
```

### Appendix D: Change Log

| Version | Date | Author | Changes | Approved By |
|---------|------|--------|---------|-------------|
| 0.1 | 2025-11-21 | Data Architect | Initial draft | - |
| 1.0 | 2025-11-21 | Data Architect | Baseline with all sections | Pending Solution Architect, DPO |

---

## Validation Checklist

- [x] Conceptual, logical, and physical data models defined
- [x] All entities have primary keys, foreign keys, and indexes
- [x] Data flows documented end-to-end with lineage tracking
- [x] Data classification, ownership, and governance defined
- [x] Data quality rules and validation methods specified
- [x] Data retention and archival policies documented (7-year compliance)
- [x] Privacy controls for PII handling (GDPR compliance)
- [x] Integration interfaces and synchronization strategies defined
- [x] Data security (encryption, access control, masking) specified
- [x] Data migration plan for initial load
- [x] Monitoring metrics and observability requirements defined
- [x] All data requirements traced to SRS, NFR, and backlog items
- [x] Approval workflow and stakeholder IDs included
- [ ] ERD and data dictionary created (to be completed with HLD)
- [ ] Data Protection Officer review and approval

---

**Document Status:** ✅ Baseline Ready for Review  
**Last Updated:** 2025-11-21  
**Next Review:** Q1 2026 (or upon significant data model change)  
**Owner:** Solution Architect (STK-014)  
**Approver:** Data Protection Officer (STK-011)
