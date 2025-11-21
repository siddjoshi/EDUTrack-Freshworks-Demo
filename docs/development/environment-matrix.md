# Environment Matrix
## EDUTrack - Internal AI Learning & Training Platform

---

## Document Control
| Version | Date | Author | Reviewer | Notes |
|---------|------|--------|----------|-------|
| 0.1     | 2025-11-21 | DevOps Lead | | Draft |
| 1.0     | 2025-11-21 | DevOps Lead | Solution Architect, Security Architect, Operations Lead | Baseline |

## Approvals
| Name | Role | Signature | Date |
|------|------|-----------|------|
| TBD | DevOps Lead | | |
| TBD | Solution Architect | | |
| TBD | Security Architect | | |
| TBD | Operations Lead | | |
| TBD | Compliance Officer | | |

---

## 1. Executive Summary

### 1.1 Purpose

This Environment Matrix defines all environments used throughout the EDUTrack platform software development lifecycle (SDLC). It specifies the purpose, configuration, access controls, data handling policies, refresh cadence, observability, and compliance guardrails for each environment to ensure consistent, secure, and compliant software delivery.

**Intended Audience:**
- DevOps Engineers: Environment provisioning and configuration
- Engineering Teams: Understanding environment capabilities and limitations
- Security Team: Access control validation and security configuration
- QA Team: Test environment planning and data preparation
- Operations Team: Production support and monitoring
- Compliance Officers: Data handling and regulatory compliance

### 1.2 Scope

This matrix covers:
- Environment purposes and use cases
- Azure infrastructure topology and configuration
- Access control policies and authentication mechanisms
- Data management (seeding, refresh, retention, privacy)
- Configuration management and secrets handling
- Observability and monitoring setup
- Compliance and regulatory guardrails
- Environment lifecycle (provisioning, refresh, decommissioning)

**Out of Scope:**
- Detailed application architecture (covered in HLD)
- CI/CD pipeline implementation (covered in CI/CD Specification)
- Disaster recovery procedures (covered in Operations Runbook)

### 1.3 Environment Strategy Principles

1. **Parity with Production:** Pre-production environments mirror production configuration to reduce deployment surprises
2. **Data Privacy:** Minimize use of production data; use synthetic data where possible
3. **Access Control:** Least privilege access; role-based permissions enforced
4. **Automation First:** Infrastructure as Code (Bicep) for all environment provisioning
5. **Cost Optimization:** Right-size resources for environment purpose; auto-shutdown for non-production
6. **Compliance-Ready:** Audit trails, encryption, and data residency enforced in all environments
7. **Observability:** Comprehensive monitoring and logging in all environments
8. **Ephemeral Environments:** Support for short-lived environments (feature branches, testing)

---

## 2. Environment Overview

### 2.1 Environment Summary Table

| Environment | Purpose | Azure Subscription | Deployment Frequency | Uptime Requirement | Data Sensitivity | User Base |
|-------------|---------|-------------------|----------------------|-------------------|------------------|-----------|
| **LOCAL** | Developer workstation | N/A (local containers) | Continuous | Developer hours only | Synthetic data only | Individual developers |
| **DEV** | Integration and early testing | Non-Production | Multiple times/day | Business hours (8 AM - 8 PM ET) | Synthetic + obfuscated data | Development team, QA team |
| **TEST** | QA testing and regression | Non-Production | Daily | Business hours (8 AM - 10 PM ET) | Synthetic + obfuscated data | QA team, Product Owner |
| **STAGING** | Pre-production validation | Non-Production (isolated) | Weekly | 24/7 | Obfuscated production-like data | QA team, Release Manager, Stakeholders |
| **PROD** | Production user traffic | Production | Weekly (planned) | 24/7 (99.5% SLA) | Real production data | All 10,000 employees |

### 2.2 Environment Lifecycle Stages

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Environment Lifecycle                            │
│                                                                      │
│  Provision → Configure → Seed Data → Deploy Code → Test → Monitor   │
│      ↓                                                        ↓      │
│  (Automated via Bicep)                              (Refresh/Retire) │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Lifecycle Stages:**

1. **Provisioning:** Azure resources created via Bicep (automated)
2. **Configuration:** App settings, secrets, feature flags applied
3. **Data Seeding:** Databases populated with appropriate test data
4. **Code Deployment:** Application code deployed via CI/CD pipeline
5. **Validation:** Smoke tests and health checks executed
6. **Monitoring:** Observability tools configured and alerting enabled
7. **Refresh:** Data and configuration updated periodically
8. **Retirement:** Decommission temporary or deprecated environments

---

## 3. LOCAL Environment

### 3.1 Purpose & Use Cases

**Primary Purpose:** Individual developer coding, debugging, and unit testing on local workstations.

**Use Cases:**
- Code development and iteration
- Unit test execution
- Local debugging (Visual Studio, VS Code)
- API testing (Postman, Thunder Client)
- UI component development (React DevTools)
- Database schema prototyping (SQL Server LocalDB, Docker containers)

**Not Intended For:**
- Integration testing (use DEV environment)
- Performance testing (use STAGING environment)
- Security testing (use DEV/TEST environment)

### 3.2 Infrastructure Topology

**Hosting:** Developer workstations (Windows, macOS, Linux)

**Components:**

| Component | Technology | Configuration | Notes |
|-----------|------------|---------------|-------|
| Backend API | .NET 8.0 (IIS Express / Kestrel) | Local debug mode | Running on `https://localhost:5001` |
| Frontend | React Dev Server (Vite) | HMR enabled | Running on `http://localhost:5173` |
| Database | SQL Server LocalDB or Docker (SQL Server 2022) | Developer Edition | Seeded with minimal synthetic data |
| Blob Storage | Azurite (local emulator) | Default ports | Emulates Azure Blob Storage |
| Redis Cache | Docker (Redis 7.x) | Default config | For session/cache testing |
| Azure Functions | Azure Functions Core Tools | Local runtime | For serverless testing |

**No Cloud Resources:** All services run locally; no Azure subscription required for basic development.

### 3.3 Access Control

**Authentication:** Not enforced (local testing mode)

**Authorization:** Bypass RBAC checks (environment variable `ASPNETCORE_ENVIRONMENT=Development`)

**Network Access:** Localhost only (127.0.0.1)

**Secret Management:** Local `appsettings.Development.json` (never committed to Git); use User Secrets for sensitive data

**NFR Traceability:** MAINT-TOOL-004 (Local development environment setup)

### 3.4 Data Management

**Data Source:** Synthetic test data generated via seed scripts

**Data Volume:** Minimal (<100 users, <1,000 documents)

**Data Refresh:** On-demand by developer (`dotnet ef database update`)

**Data Privacy:** Synthetic data only; no real PII

**Data Retention:** Ephemeral; reset on database migration or developer action

**NFR Traceability:** SEC-DATA-003 (PII detection), PRIV-DATA-001 (Data minimization)

### 3.5 Configuration Management

**Configuration Files:**
- `appsettings.Development.json` (application settings)
- `.env.local` (frontend environment variables)
- User Secrets (sensitive local settings)

**Feature Flags:** Hardcoded or local JSON file

**Secrets:** User Secrets (dotnet) or `.env.local` (React); never commit secrets

**NFR Traceability:** SEC-APP-005 (Secrets management)

### 3.6 Observability

**Logging:** Console output (Serilog structured logging)

**Monitoring:** Not required (developer observes console/debugger)

**Tracing:** Not enabled (optional: local OpenTelemetry collector)

**Alerts:** None

### 3.7 Compliance Guardrails

**Data Residency:** N/A (local workstation)

**Encryption:** Not enforced (localhost traffic)

**Audit Logs:** Not collected

**Backup:** Developer responsibility (Git commits)

**NFR Traceability:** COMP-AUDIT-001 (Audit logging not required for LOCAL)

---

## 4. DEV Environment

### 4.1 Purpose & Use Cases

**Primary Purpose:** Continuous integration and early-stage testing of merged code.

**Use Cases:**
- Automated deployments from `develop` branch (CI/CD pipeline)
- Integration testing (API, database, Azure services)
- Exploratory testing by QA team
- Smoke testing after each deployment
- Feature demo to Product Owner and stakeholders

**Not Intended For:**
- Formal regression testing (use TEST environment)
- Performance testing (use STAGING environment)
- User acceptance testing (use STAGING environment)

### 4.2 Infrastructure Topology

**Hosting:** Azure App Service (Non-Production Subscription)

**Azure Resources:**

| Resource | SKU/Tier | Configuration | High Availability | Notes |
|----------|----------|---------------|-------------------|-------|
| **App Service Plan** | S1 (Standard) | 1 instance, Windows, 1.75 GB RAM | No | Auto-scale disabled |
| **App Service (Web)** | - | .NET 8.0 runtime, HTTPS only | No | Deployment slots: 1 (production) |
| **App Service (API)** | - | .NET 8.0 runtime, HTTPS only | No | Deployment slots: 1 (production) |
| **Azure SQL Database** | S0 (10 DTU) | 250 GB storage, geo-redundant backup | No | Automated backups (7 days) |
| **Azure Cosmos DB** | Serverless | Free tier, Request Units on-demand | No | For audit logs and analytics |
| **Azure Blob Storage** | Standard LRS | Hot tier, 100 GB quota | No | For document storage |
| **Azure AI Search** | Basic | 1 replica, 1 partition | No | For semantic search testing |
| **Azure Key Vault** | Standard | Soft-delete enabled, 90-day retention | No | For secrets and certificates |
| **Azure Application Insights** | Standard | 1 GB/day data cap | No | APM and logging |
| **Azure Redis Cache** | Basic C0 (250 MB) | No persistence | No | Session and caching |
| **Azure Virtual Network** | - | 10.0.0.0/16 CIDR | No | Network isolation |
| **Network Security Group** | - | Allow HTTPS from corporate IPs only | No | IP whitelisting |

**Estimated Monthly Cost:** ~$150 USD

**NFR Traceability:** PERF-RES-001 to PERF-RES-005 (Resource sizing)

### 4.3 Access Control

**Authentication:** Azure AD SSO (corporate tenant)

**Authorized Users:**
- Development team (Contributor role)
- QA team (Reader + Tester role)
- DevOps team (Owner role)
- Product Owner (Reader role)

**Role-Based Access Control (RBAC):**

| Role | Azure RBAC | Application Permissions | Access Level |
|------|------------|------------------------|--------------|
| **Developers** | Contributor (App Service, SQL, Storage) | Admin role (all features) | Read/Write code, deploy, view logs |
| **QA Engineers** | Reader (all resources) | Admin role (testing scenarios) | View resources, execute tests, report bugs |
| **DevOps** | Owner (resource group) | N/A | Full control, cost management |
| **Product Owner** | Reader (App Service, Application Insights) | Learner role (view-only) | View app, dashboards, logs |

**Network Access:** 
- App Service: Public internet (HTTPS only) with IP whitelisting (corporate IP ranges)
- Azure SQL: Private endpoint within VNet (no public access)
- Storage: Firewall rules (allow Azure services + corporate IPs)

**Secret Management:** Azure Key Vault (all secrets, connection strings, API keys)

**NFR Traceability:** SEC-IAM-001 (Azure AD SSO), SEC-IAM-002 (RBAC), SEC-APP-005 (Key Vault)

### 4.4 Data Management

**Data Source:**
- Synthetic data (primary): Generated via seed scripts
- Obfuscated production data (optional): PII redacted, anonymized

**Data Volume:** ~500 users, ~5,000 documents, ~10,000 learning records

**Data Refresh:** Weekly (Sunday 2 AM ET, automated)

**Data Privacy:**
- No real PII allowed
- Obfuscated names (e.g., "User-001", "Jane Doe")
- Fake email addresses (@example.com domain)
- Redacted employee IDs

**Data Retention:** Rolling 30 days (old data purged automatically)

**Data Seeding Process:**
1. Restore database from snapshot (baseline schema)
2. Run seed scripts (`/database/seeds/dev-seed.sql`)
3. Validate data integrity (row counts, foreign keys)

**NFR Traceability:** SEC-DATA-003 (PII detection), PRIV-DATA-001 (Data minimization), SEC-DATA-006 (Data retention)

### 4.5 Configuration Management

**Configuration Sources:**

| Setting Type | Source | Example |
|--------------|--------|---------|
| Application settings | Azure App Configuration | Feature flags, app behavior toggles |
| Secrets | Azure Key Vault | Database connection strings, API keys |
| Environment variables | App Service Application Settings | `ASPNETCORE_ENVIRONMENT=Development` |
| Feature flags | Azure App Configuration | EnableAIGeneration=true, EnableSearch=false |

**Configuration Validation:**
- Schema validation before deployment
- Secrets rotation every 90 days (automated)
- Configuration drift detection (compare deployed vs. IaC)

**NFR Traceability:** SEC-APP-005 (Key Vault), SEC-AI-006 (API key rotation)

### 4.6 Observability

**Logging:**
- Application logs: Application Insights (1 GB/day retention)
- Azure resource logs: Log Analytics (30 days retention)
- Log levels: Debug, Information, Warning, Error, Critical

**Monitoring:**
- Application Insights: APM, distributed tracing, custom metrics
- Azure Monitor: Resource health, metrics (CPU, memory, DTU)
- Dashboards: Pre-built Application Insights dashboard

**Tracing:** OpenTelemetry instrumentation (distributed tracing)

**Alerts:**
- Critical errors >10/hour → DevOps team (Teams notification)
- App Service CPU >80% → DevOps team
- SQL DTU >80% → DevOps team
- Failed deployments → DevOps Lead (email + Teams)

**NFR Traceability:** OBS-LOG-001 (Structured logging), OBS-MON-001 (Real-time monitoring)

### 4.7 Compliance Guardrails

**Data Residency:** East US region (corporate approved)

**Encryption:**
- In transit: TLS 1.2+ enforced (HTTPS only)
- At rest: Azure Storage encryption (Microsoft-managed keys)
- SQL: Transparent Data Encryption (TDE) enabled

**Audit Logs:**
- Azure Activity Log: 90 days retention
- Application audit events: Cosmos DB (90 days retention)

**Backup:**
- SQL Database: Automated backups (7-day retention, geo-redundant)
- Blob Storage: Soft-delete enabled (7 days)

**Policy Compliance:**
- Azure Policy: Enforce encryption, network isolation, tagging
- Tags: Environment=DEV, Project=EDUTrack, CostCenter=IT, Owner=DevOps

**NFR Traceability:** SEC-DATA-001 (Encryption at rest), SEC-DATA-002 (TLS 1.2+), SEC-DATA-008 (Data residency), COMP-AUDIT-001 (Audit logs)

---

## 5. TEST Environment

### 5.1 Purpose & Use Cases

**Primary Purpose:** QA regression testing, automated test execution, and defect validation.

**Use Cases:**
- Formal regression testing (manual and automated)
- End-to-end (E2E) test execution (Playwright)
- API integration testing
- Accessibility testing (WCAG 2.1 AA validation)
- Cross-browser testing (Chrome, Edge, Firefox)
- Defect reproduction and validation
- User story acceptance testing

**Not Intended For:**
- Performance testing (use STAGING environment)
- User acceptance testing (use STAGING environment)
- Production-like data testing (use STAGING environment)

### 5.2 Infrastructure Topology

**Hosting:** Azure App Service (Non-Production Subscription)

**Azure Resources:**

| Resource | SKU/Tier | Configuration | High Availability | Notes |
|----------|----------|---------------|-------------------|-------|
| **App Service Plan** | S2 (Standard) | 2 instances, Windows, 3.5 GB RAM | No | To support parallel testing |
| **App Service (Web)** | - | .NET 8.0 runtime, HTTPS only | No | Deployment slots: 1 (production) |
| **App Service (API)** | - | .NET 8.0 runtime, HTTPS only | No | Deployment slots: 1 (production) |
| **Azure SQL Database** | S1 (20 DTU) | 250 GB storage, geo-redundant backup | No | Automated backups (14 days) |
| **Azure Cosmos DB** | Serverless | Free tier, Request Units on-demand | No | For audit logs and analytics |
| **Azure Blob Storage** | Standard LRS | Hot tier, 200 GB quota | No | For document storage |
| **Azure AI Search** | Basic | 1 replica, 1 partition | No | For semantic search testing |
| **Azure Key Vault** | Standard | Soft-delete enabled, 90-day retention | No | For secrets and certificates |
| **Azure Application Insights** | Standard | 2 GB/day data cap | No | APM and logging |
| **Azure Redis Cache** | Basic C1 (1 GB) | No persistence | No | Session and caching |
| **Azure Virtual Network** | - | 10.1.0.0/16 CIDR | No | Network isolation |
| **Network Security Group** | - | Allow HTTPS from corporate IPs + test agents | No | IP whitelisting |

**Estimated Monthly Cost:** ~$300 USD

**NFR Traceability:** PERF-RES-001 to PERF-RES-005 (Resource sizing)

### 5.3 Access Control

**Authentication:** Azure AD SSO (corporate tenant)

**Authorized Users:**
- QA team (Contributor role)
- Development team (Reader role)
- DevOps team (Owner role)
- Product Owner (Reader role)

**Role-Based Access Control (RBAC):**

| Role | Azure RBAC | Application Permissions | Access Level |
|------|------------|------------------------|--------------|
| **QA Engineers** | Contributor (App Service, SQL, Storage) | Admin role (all features) | Read/Write, execute tests, deploy test data |
| **Developers** | Reader (all resources) | Learner role (view-only) | View resources, validate defect fixes |
| **DevOps** | Owner (resource group) | N/A | Full control, cost management |
| **Product Owner** | Reader (App Service, Application Insights) | Learner role (view-only) | View app, dashboards, acceptance validation |

**Network Access:**
- App Service: Public internet (HTTPS only) with IP whitelisting (corporate IPs + CI/CD agents)
- Azure SQL: Private endpoint within VNet
- Storage: Firewall rules (allow Azure services + corporate IPs)

**Secret Management:** Azure Key Vault (all secrets, connection strings, API keys)

**NFR Traceability:** SEC-IAM-001 (Azure AD SSO), SEC-IAM-002 (RBAC), SEC-APP-005 (Key Vault)

### 5.4 Data Management

**Data Source:**
- Synthetic data (primary): Generated via seed scripts
- Obfuscated production data (optional): PII redacted, anonymized
- Test-specific data: Edge cases, boundary values, negative test data

**Data Volume:** ~1,000 users, ~10,000 documents, ~50,000 learning records

**Data Refresh:** Nightly (2 AM ET, automated) to ensure consistent test baseline

**Data Privacy:**
- No real PII allowed
- Obfuscated names, emails, employee IDs
- Test data includes edge cases (special characters, long strings, Unicode)

**Data Retention:** Rolling 60 days (old data purged automatically)

**Data Seeding Process:**
1. Drop and recreate database schema (from EF migrations)
2. Run comprehensive seed scripts (`/database/seeds/test-seed.sql`)
3. Import edge case test data (CSV files)
4. Validate data integrity and coverage

**NFR Traceability:** SEC-DATA-003 (PII detection), PRIV-DATA-001 (Data minimization), SEC-DATA-006 (Data retention)

### 5.5 Configuration Management

**Configuration Sources:**

| Setting Type | Source | Example |
|--------------|--------|---------|
| Application settings | Azure App Configuration | Feature flags, app behavior toggles |
| Secrets | Azure Key Vault | Database connection strings, API keys |
| Environment variables | App Service Application Settings | `ASPNETCORE_ENVIRONMENT=Staging` |
| Feature flags | Azure App Configuration | All features enabled for full coverage |

**Configuration Validation:**
- Schema validation before deployment
- Secrets rotation every 90 days (automated)
- Configuration drift detection

**NFR Traceability:** SEC-APP-005 (Key Vault), SEC-AI-006 (API key rotation)

### 5.6 Observability

**Logging:**
- Application logs: Application Insights (2 GB/day retention)
- Azure resource logs: Log Analytics (60 days retention)
- Log levels: Information, Warning, Error, Critical (Debug disabled)

**Monitoring:**
- Application Insights: APM, distributed tracing, test result correlation
- Azure Monitor: Resource health, metrics (CPU, memory, DTU)
- Test result dashboards: Azure Test Plans integration

**Tracing:** OpenTelemetry instrumentation (distributed tracing)

**Alerts:**
- Critical errors >20/hour → QA Lead + DevOps team
- App Service CPU >80% → DevOps team
- SQL DTU >80% → DevOps team
- Failed deployments → DevOps Lead + QA Lead

**NFR Traceability:** OBS-LOG-001 (Structured logging), OBS-MON-001 (Real-time monitoring)

### 5.7 Compliance Guardrails

**Data Residency:** East US region (corporate approved)

**Encryption:**
- In transit: TLS 1.2+ enforced (HTTPS only)
- At rest: Azure Storage encryption (Microsoft-managed keys)
- SQL: Transparent Data Encryption (TDE) enabled

**Audit Logs:**
- Azure Activity Log: 90 days retention
- Application audit events: Cosmos DB (90 days retention)

**Backup:**
- SQL Database: Automated backups (14-day retention, geo-redundant)
- Blob Storage: Soft-delete enabled (14 days)

**Policy Compliance:**
- Azure Policy: Enforce encryption, network isolation, tagging
- Tags: Environment=TEST, Project=EDUTrack, CostCenter=IT, Owner=QA

**NFR Traceability:** SEC-DATA-001 (Encryption at rest), SEC-DATA-002 (TLS 1.2+), SEC-DATA-008 (Data residency), COMP-AUDIT-001 (Audit logs)

---

## 6. STAGING Environment

### 6.1 Purpose & Use Cases

**Primary Purpose:** Pre-production validation with production-like configuration and data.

**Use Cases:**
- User acceptance testing (UAT) by Product Owner and stakeholders
- Performance testing (load, stress, spike tests)
- Security testing (DAST, penetration testing)
- Integration testing with external systems (SharePoint, Confluence, GitHub)
- Rehearsal for production deployments (blue-green validation)
- Soak testing (24-48 hour validation of new releases)
- Stakeholder demos and training

**Not Intended For:**
- Active development (use DEV environment)
- Rapid iteration testing (use TEST environment)

### 6.2 Infrastructure Topology

**Hosting:** Azure App Service (Non-Production Subscription - Isolated)

**Azure Resources:**

| Resource | SKU/Tier | Configuration | High Availability | Notes |
|----------|----------|---------------|-------------------|-------|
| **App Service Plan** | P1v3 (Premium) | 3 instances, Windows, 8 GB RAM | Yes (zone redundancy) | Auto-scale enabled (3-10 instances) |
| **App Service (Web)** | - | .NET 8.0 runtime, HTTPS only | Yes | Deployment slots: 2 (blue, green) |
| **App Service (API)** | - | .NET 8.0 runtime, HTTPS only | Yes | Deployment slots: 2 (blue, green) |
| **Azure SQL Database** | S3 (100 DTU) | 500 GB storage, geo-redundant backup | Yes | Automated backups (35 days), read replica |
| **Azure Cosmos DB** | Provisioned (400 RU/s) | Multi-region writes disabled | Yes | For audit logs and analytics |
| **Azure Blob Storage** | Standard GRS | Hot tier, 1 TB quota | Yes | Geo-redundant storage |
| **Azure AI Search** | Standard (S1) | 2 replicas, 1 partition | Yes | For semantic search |
| **Azure Key Vault** | Standard | Soft-delete enabled, 90-day retention | Yes | For secrets and certificates |
| **Azure Application Insights** | Standard | 5 GB/day data cap | Yes | APM and logging |
| **Azure Redis Cache** | Standard C1 (1 GB) | Persistence enabled | Yes | Session and caching |
| **Azure Virtual Network** | - | 10.2.0.0/16 CIDR | Yes | Network isolation |
| **Network Security Group** | - | Allow HTTPS from corporate IPs + stakeholder IPs | No | IP whitelisting |
| **Azure Load Testing** | Standard | 1,000 concurrent users | No | For performance testing |

**Estimated Monthly Cost:** ~$1,200 USD

**NFR Traceability:** PERF-RES-001 to PERF-RES-005 (Resource sizing), REL-AVAIL-001 (High availability)

### 6.3 Access Control

**Authentication:** Azure AD SSO (corporate tenant)

**Authorized Users:**
- Product Owner (Contributor role)
- QA team (Contributor role)
- Release Manager (Contributor role)
- DevOps team (Owner role)
- Stakeholders (Reader role, invited for UAT)

**Role-Based Access Control (RBAC):**

| Role | Azure RBAC | Application Permissions | Access Level |
|------|------------|------------------------|--------------|
| **Product Owner** | Contributor (App Service) | Admin role (all features) | Acceptance validation, UAT coordination |
| **QA Engineers** | Contributor (App Service, SQL, Storage) | Admin role (all features) | Performance testing, security testing |
| **Release Manager** | Contributor (App Service) | Admin role | Deployment validation, rollback testing |
| **DevOps** | Owner (resource group) | N/A | Full control, cost management |
| **Stakeholders** | Reader (App Service, Application Insights) | Learner role (view-only) | UAT participation, demo viewing |

**Network Access:**
- App Service: Public internet (HTTPS only) with IP whitelisting (corporate IPs + stakeholder IPs)
- Azure SQL: Private endpoint within VNet
- Storage: Firewall rules (allow Azure services + corporate IPs)

**Secret Management:** Azure Key Vault (all secrets, connection strings, API keys)

**NFR Traceability:** SEC-IAM-001 (Azure AD SSO), SEC-IAM-002 (RBAC), SEC-APP-005 (Key Vault)

### 6.4 Data Management

**Data Source:**
- Obfuscated production data (primary): Subset of production data with PII redacted
- Synthetic data (supplemental): For edge cases not present in production

**Data Volume:** ~5,000 users, ~100,000 documents, ~500,000 learning records (50% of production scale)

**Data Refresh:** Weekly (Saturday 11 PM ET, automated)

**Data Privacy:**
- Production data obfuscated using Azure Data Factory
- PII fields masked (names, emails, employee IDs replaced with pseudonyms)
- Salary and sensitive fields redacted
- Compliance with GDPR right to be forgotten (exclude deleted users)

**Data Obfuscation Process:**
1. Export production data to staging storage account (encrypted)
2. Run Azure Data Factory pipeline to obfuscate PII
3. Import obfuscated data to STAGING database
4. Validate data quality and completeness
5. Delete source export (secure deletion)

**Data Retention:** Rolling 90 days (old data purged automatically)

**NFR Traceability:** SEC-DATA-003 (PII detection), PRIV-DATA-001 (Data minimization), SEC-DATA-006 (Data retention), PRIV-DATA-002 (Data obfuscation)

### 6.5 Configuration Management

**Configuration Sources:**

| Setting Type | Source | Example |
|--------------|--------|---------|
| Application settings | Azure App Configuration | Feature flags, app behavior toggles |
| Secrets | Azure Key Vault | Database connection strings, API keys |
| Environment variables | App Service Application Settings | `ASPNETCORE_ENVIRONMENT=Staging` |
| Feature flags | Azure App Configuration | Mirror production configuration |

**Configuration Validation:**
- Schema validation before deployment
- Secrets rotation every 90 days (automated)
- Configuration drift detection (compare with PROD)

**NFR Traceability:** SEC-APP-005 (Key Vault), SEC-AI-006 (API key rotation)

### 6.6 Observability

**Logging:**
- Application logs: Application Insights (5 GB/day retention)
- Azure resource logs: Log Analytics (90 days retention)
- Log levels: Information, Warning, Error, Critical

**Monitoring:**
- Application Insights: APM, distributed tracing, performance profiling
- Azure Monitor: Resource health, metrics (CPU, memory, DTU)
- Dashboards: Production-like dashboards for stakeholder visibility

**Tracing:** OpenTelemetry instrumentation (distributed tracing)

**Alerts:**
- Critical errors >5/hour → On-call engineer + Release Manager
- App Service CPU >70% → DevOps team
- SQL DTU >70% → DevOps team
- Failed deployments → Release Manager + Engineering Lead
- Performance degradation (P95 >2s) → QA Lead + Engineering Lead

**NFR Traceability:** OBS-LOG-001 (Structured logging), OBS-MON-001 (Real-time monitoring)

### 6.7 Compliance Guardrails

**Data Residency:** East US region (corporate approved)

**Encryption:**
- In transit: TLS 1.2+ enforced (HTTPS only)
- At rest: Azure Storage encryption (customer-managed keys for sensitive data)
- SQL: Transparent Data Encryption (TDE) enabled, Always Encrypted for PII columns

**Audit Logs:**
- Azure Activity Log: 2 years retention (compliance requirement)
- Application audit events: Cosmos DB (2 years retention)

**Backup:**
- SQL Database: Automated backups (35-day retention, geo-redundant)
- Blob Storage: Soft-delete enabled (30 days), versioning enabled

**Policy Compliance:**
- Azure Policy: Enforce encryption, network isolation, tagging, cost limits
- Tags: Environment=STAGING, Project=EDUTrack, CostCenter=IT, Owner=Release, Compliance=ISO27001

**NFR Traceability:** SEC-DATA-001 (Encryption at rest), SEC-DATA-002 (TLS 1.2+), SEC-DATA-007 (Column-level encryption), SEC-DATA-008 (Data residency), COMP-AUDIT-001 (Audit logs)

---

## 7. PROD Environment

### 7.1 Purpose & Use Cases

**Primary Purpose:** Production environment serving all 10,000 employees globally.

**Use Cases:**
- Live user traffic (learners, managers, L&D admins, executives)
- Business-critical learning operations (compliance training, onboarding, upskilling)
- Real-time analytics and reporting
- AI-powered content generation for production courses
- Integration with production SharePoint, Confluence, GitHub, Microsoft Learn

**Not Intended For:**
- Testing or experimentation (use DEV/TEST/STAGING)
- Performance testing (use STAGING)

### 7.2 Infrastructure Topology

**Hosting:** Azure App Service (Production Subscription)

**Azure Resources:**

| Resource | SKU/Tier | Configuration | High Availability | Notes |
|----------|----------|---------------|-------------------|-------|
| **App Service Plan** | P2v3 (Premium) | 5 instances, Windows, 16 GB RAM | Yes (zone redundancy, multi-region) | Auto-scale enabled (5-20 instances) |
| **App Service (Web)** | - | .NET 8.0 runtime, HTTPS only | Yes | Deployment slots: 2 (blue, green) |
| **App Service (API)** | - | .NET 8.0 runtime, HTTPS only | Yes | Deployment slots: 2 (blue, green) |
| **Azure SQL Database** | P2 (250 DTU) | 1 TB storage, geo-redundant backup | Yes | Automated backups (35 days), active geo-replication (West Europe) |
| **Azure Cosmos DB** | Provisioned (1,000 RU/s) | Multi-region writes enabled | Yes | Replicated to West Europe |
| **Azure Blob Storage** | Premium GRS | Hot tier, 5 TB quota | Yes | Geo-redundant storage, read-access geo-redundancy |
| **Azure AI Search** | Standard (S2) | 3 replicas, 2 partitions | Yes | For semantic search |
| **Azure Key Vault** | Premium | HSM-backed keys, soft-delete, 90-day retention | Yes | For secrets, certificates, encryption keys |
| **Azure Application Insights** | Standard | 10 GB/day data cap | Yes | APM and logging |
| **Azure Redis Cache** | Premium P1 (6 GB) | Persistence + clustering enabled | Yes | Session and caching |
| **Azure Virtual Network** | - | 10.3.0.0/16 CIDR | Yes | Network isolation |
| **Azure Front Door** | Premium | WAF enabled, caching, SSL offload | Yes | Global load balancing, DDoS protection |
| **Azure DDoS Protection** | Standard | Network-level DDoS mitigation | Yes | Protection for public endpoints |
| **Azure Firewall** | Standard | Network traffic filtering | Yes | Outbound traffic control |

**Estimated Monthly Cost:** ~$3,500 USD

**NFR Traceability:** PERF-TH-001 (10,000 concurrent users), REL-AVAIL-001 (99.5% uptime), REL-DR-001 (Disaster recovery)

### 7.3 Access Control

**Authentication:** Azure AD SSO (corporate tenant)

**Authorized Users:**
- All 10,000 employees (learners, managers, L&D admins, executives)
- Operations team (Owner role for Azure resources)
- DevOps team (Contributor role for deployments)
- Security team (Reader role for audit)

**Role-Based Access Control (RBAC):**

| Role | Azure RBAC | Application Permissions | Access Level |
|------|------------|------------------------|--------------|
| **Employees (Learners)** | N/A (app-level auth only) | Learner role | Access courses, dashboards, assessments |
| **Managers** | N/A | Manager role | View team progress, assign learning paths |
| **L&D Admins** | N/A | L&D Admin role | Content management, user management, reporting |
| **Executives** | N/A | Executive role | View executive dashboard, analytics |
| **Operations Team** | Owner (resource group) | N/A | Full control, incident response, cost management |
| **DevOps Team** | Contributor (App Service) | N/A | Deployments, monitoring, log access |
| **Security Team** | Reader (all resources) | N/A | Audit, compliance validation, security monitoring |

**Network Access:**
- App Service: Public internet (HTTPS only) via Azure Front Door (global)
- Azure SQL: Private endpoint within VNet (no public access)
- Storage: Private endpoint within VNet
- Redis Cache: Private endpoint within VNet

**Secret Management:** Azure Key Vault Premium (HSM-backed keys for encryption)

**NFR Traceability:** SEC-IAM-001 (Azure AD SSO), SEC-IAM-002 (RBAC with 4 roles), SEC-APP-005 (Key Vault)

### 7.4 Data Management

**Data Source:** Real production data (employee PII, training records, proprietary content)

**Data Volume:** ~10,000 users, ~1,000,000 documents, ~5,000,000 learning records

**Data Refresh:** Not applicable (live production data)

**Data Privacy:**
- Full GDPR compliance (right to access, rectification, erasure)
- PII encryption at rest and in transit
- Column-level encryption for sensitive fields (employee IDs, salaries)
- Data residency in approved regions (East US primary, West Europe secondary)

**Data Retention:**
- Training records: 7 years (compliance requirement)
- Audit logs: 2 years (ISO 27001 requirement)
- User data: Until user requests deletion (GDPR right to erasure, 30-day SLA)
- Soft-deleted data: 30 days (recoverable)

**Data Backup:**
- SQL Database: Automated backups (35-day retention, geo-redundant to West Europe)
- Point-in-time restore: Any point within 35 days
- Long-term retention: Yearly backups retained for 7 years (compliance)
- Blob Storage: Versioning enabled, soft-delete (30 days), geo-redundant

**NFR Traceability:** SEC-DATA-001 (Encryption at rest), SEC-DATA-003 (PII protection), SEC-DATA-006 (GDPR right to erasure), SEC-DATA-007 (Column-level encryption), SEC-DATA-008 (Data residency), REL-RES-002 (Data backup)

### 7.5 Configuration Management

**Configuration Sources:**

| Setting Type | Source | Example |
|--------------|--------|---------|
| Application settings | Azure App Configuration (Premium) | Feature flags, app behavior toggles |
| Secrets | Azure Key Vault Premium | Database connection strings, API keys, certificates |
| Environment variables | App Service Application Settings | `ASPNETCORE_ENVIRONMENT=Production` |
| Feature flags | Azure App Configuration | Gradual rollout, A/B testing, kill switches |

**Configuration Validation:**
- Schema validation before deployment
- Secrets rotation every 90 days (automated, zero-downtime)
- Configuration drift detection (weekly scan)
- Change management (CAB approval for config changes)

**NFR Traceability:** SEC-APP-005 (Key Vault), SEC-AI-006 (API key rotation)

### 7.6 Observability

**Logging:**
- Application logs: Application Insights (10 GB/day retention, 2 years)
- Azure resource logs: Log Analytics (2 years retention)
- Audit logs: Cosmos DB (2 years retention, write to secure storage)
- Log levels: Information, Warning, Error, Critical (Debug disabled)

**Monitoring:**
- Application Insights: APM, distributed tracing, live metrics, profiling
- Azure Monitor: Resource health, metrics, alerts
- Dashboards: Executive dashboard, operations dashboard, SRE dashboard
- SLA monitoring: 99.5% uptime target (REL-AVAIL-001)

**Tracing:** OpenTelemetry instrumentation (distributed tracing across all services)

**Alerts:**

| Alert | Threshold | Severity | Alert Target | Response Time |
|-------|-----------|----------|--------------|---------------|
| Application errors | >10/min | Critical | On-call engineer (PagerDuty) | <5 min |
| Availability | <99.5% over 5 min | Critical | On-call engineer + SRE Lead | <5 min |
| API response time P95 | >2s | High | On-call engineer | <15 min |
| SQL DTU | >70% | High | DBA + DevOps | <15 min |
| App Service CPU | >70% | High | DevOps team | <15 min |
| Failed logins | >100/min (potential attack) | Critical | Security team + CISO | <5 min |
| Deployment failures | Any | High | Release Manager + Engineering Lead | <10 min |
| Security scan failures | Critical/High findings | Critical | Security Architect + CISO | <15 min |

**Auto-Remediation:**
- Auto-scale triggers: CPU >70% or requests >1,000/sec
- Auto-rollback: Error rate >10% for >5 min after deployment
- Health endpoint failures: Remove instance from load balancer

**NFR Traceability:** OBS-LOG-001 (Structured logging), OBS-LOG-002 (Audit logs 2 years), OBS-MON-001 (Real-time monitoring), OBS-ALERT-001 (Alerting), REL-AVAIL-001 (99.5% uptime)

### 7.7 Compliance Guardrails

**Data Residency:** East US (primary), West Europe (secondary) - Corporate approved regions

**Encryption:**
- In transit: TLS 1.3 enforced (HTTPS only), minimum TLS 1.2
- At rest: Azure Storage encryption (customer-managed keys in Key Vault Premium)
- SQL: Transparent Data Encryption (TDE) enabled, Always Encrypted for PII columns
- Backups: Encrypted with customer-managed keys

**Audit Logs:**
- Azure Activity Log: 2 years retention (archived to secure storage)
- Application audit events: Cosmos DB (2 years retention, immutable)
- Admin actions: Require re-authentication + logged + reviewed monthly

**Backup:**
- SQL Database: Automated backups (35-day retention, geo-redundant)
- Long-term retention: Yearly backups for 7 years
- Blob Storage: Versioning enabled, soft-delete (30 days), geo-redundant
- Disaster recovery RPO: <1 hour, RTO: <4 hours

**Policy Compliance:**
- Azure Policy: Enforce encryption, network isolation, tagging, cost limits, security baselines
- Tags: Environment=PROD, Project=EDUTrack, CostCenter=IT, Owner=Operations, Compliance=ISO27001, Criticality=Tier1
- ISO 27001 controls: Enforced via Azure Policy
- SOC 2 Type II: Audit trail completeness, access reviews quarterly
- GDPR: Data subject rights automation, privacy impact assessments

**Regulatory Compliance:**
- ISO 27001: Information security management
- SOC 2 Type II: Security, availability, confidentiality
- GDPR: Data protection and privacy
- Corporate IT Policy: Data residency, encryption, access control

**NFR Traceability:** SEC-DATA-001 (Encryption at rest), SEC-DATA-002 (TLS 1.2+), SEC-DATA-007 (Column-level encryption), SEC-DATA-008 (Data residency), COMP-AUDIT-001 (Audit logs 2 years), COMP-CERT-001 (ISO 27001), COMP-CERT-002 (SOC 2), COMP-CERT-003 (GDPR), REL-DR-001 (Disaster recovery)

---

## 8. Environment Comparison Matrix

| Aspect | LOCAL | DEV | TEST | STAGING | PROD |
|--------|-------|-----|------|---------|------|
| **Purpose** | Individual development | Integration testing | QA regression | UAT, performance testing | Live production |
| **Deployment Frequency** | Continuous | Multiple/day | Daily | Weekly | Weekly (planned) |
| **Uptime Requirement** | Developer hours | Business hours (8 AM-8 PM) | Business hours (8 AM-10 PM) | 24/7 | 24/7 (99.5% SLA) |
| **Data Type** | Synthetic | Synthetic + obfuscated | Synthetic + obfuscated | Obfuscated production | Real production data |
| **Data Volume** | <100 users | ~500 users | ~1,000 users | ~5,000 users | ~10,000 users |
| **Azure Subscription** | N/A | Non-Production | Non-Production | Non-Production (Isolated) | Production |
| **App Service Plan** | Local (IIS Express) | S1 (1 instance) | S2 (2 instances) | P1v3 (3-10 instances) | P2v3 (5-20 instances) |
| **SQL Database** | LocalDB / Docker | S0 (10 DTU) | S1 (20 DTU) | S3 (100 DTU) | P2 (250 DTU) |
| **High Availability** | No | No | No | Yes (zone redundancy) | Yes (multi-region) |
| **Disaster Recovery** | No | No | No | Yes (geo-backup) | Yes (active geo-replication) |
| **Encryption** | Not enforced | TLS + at-rest | TLS + at-rest | TLS + at-rest + CMK | TLS + at-rest + CMK + Always Encrypted |
| **Monitoring** | Console logs | Application Insights (1 GB/day) | Application Insights (2 GB/day) | Application Insights (5 GB/day) | Application Insights (10 GB/day) |
| **Alerts** | None | DevOps team | QA Lead + DevOps | Release Manager + On-call | On-call engineer (PagerDuty) |
| **Estimated Cost** | $0 | ~$150/month | ~$300/month | ~$1,200/month | ~$3,500/month |

---

## 9. Environment Provisioning & Decommissioning

### 9.1 Provisioning Process

**Infrastructure as Code (IaC):** All environments provisioned via Bicep templates

**Provisioning Steps:**

1. **Request Approval:**
   - Submit environment request (Azure DevOps work item)
   - Approvals: DevOps Lead (DEV/TEST), Engineering Lead (STAGING), CTO (PROD)

2. **IaC Template Selection:**
   - Select appropriate Bicep template (`/infrastructure/environments/{env}.bicep`)
   - Review and customize parameters (SKU, region, tagging)

3. **Azure Resource Deployment:**
   - Run Bicep deployment pipeline in Azure Pipelines
   - Provision Azure resources (App Service, SQL, Storage, etc.)
   - Estimated duration: 15-30 minutes

4. **Configuration & Secrets:**
   - Populate Azure Key Vault with secrets
   - Configure Azure App Configuration with feature flags
   - Setup network security groups and firewall rules

5. **Data Seeding:**
   - Restore database from baseline snapshot or run seed scripts
   - Import test data (CSV, JSON)
   - Validate data integrity

6. **Application Deployment:**
   - Deploy application code via CI/CD pipeline
   - Run smoke tests
   - Validate health endpoints

7. **Observability Setup:**
   - Configure Application Insights dashboards
   - Setup alerts and notification channels
   - Enable log collection

8. **Access Control:**
   - Configure Azure AD RBAC assignments
   - Grant application permissions to users
   - Document access procedures

9. **Validation & Handoff:**
   - Run environment smoke tests
   - Document environment URL, credentials, access procedures
   - Handoff to requesting team

**NFR Traceability:** MAINT-TOOL-003 (Infrastructure as Code)

### 9.2 Refresh & Maintenance

**Scheduled Maintenance Windows:**

| Environment | Frequency | Window | Activities |
|-------------|-----------|--------|------------|
| DEV | Weekly (Sunday 2 AM ET) | 1 hour | Data refresh, OS patches, cleanup |
| TEST | Nightly (2 AM ET) | 30 min | Data refresh, test data reset |
| STAGING | Weekly (Saturday 11 PM ET) | 2 hours | Data refresh, OS patches, performance baseline |
| PROD | Monthly (1st Saturday 11 PM ET) | 4 hours | OS patches, configuration drift remediation |

**Maintenance Activities:**
- Database maintenance: Index rebuild, statistics update
- OS patching: Apply security updates (auto-reboot if required)
- Configuration drift: Compare deployed vs. IaC, remediate differences
- Data refresh: Import latest obfuscated data (STAGING), reset test data (TEST)
- Cost optimization: Review resource utilization, right-size SKUs
- Security review: Rotate secrets, review access logs, validate firewall rules

**NFR Traceability:** MAINT-PATCH-001 (OS patching), MAINT-CODE-002 (Technical debt)

### 9.3 Decommissioning Process

**Triggers:**
- Environment no longer needed (e.g., temporary feature branch environment)
- Migration to new environment (e.g., platform upgrade)
- Cost optimization (consolidate environments)

**Decommissioning Steps:**

1. **Approval:**
   - Submit decommissioning request
   - Approvals: DevOps Lead + Environment Owner

2. **Data Backup:**
   - Export critical data to archive storage
   - Document data retention period

3. **User Notification:**
   - Notify users 2 weeks in advance
   - Provide migration instructions (if applicable)

4. **Resource Deletion:**
   - Delete Azure resources via Bicep (reverse deployment)
   - Verify deletion via Azure Portal

5. **Access Revocation:**
   - Remove Azure RBAC assignments
   - Revoke application permissions

6. **Documentation Update:**
   - Update environment matrix
   - Archive decommissioning logs

7. **Cost Verification:**
   - Verify resources deleted (no hidden costs)
   - Update cost forecasts

**NFR Traceability:** COST-OPT-001 (Cost optimization)

---

## 10. Cost Management

### 10.1 Environment Cost Breakdown

| Environment | Estimated Monthly Cost | Primary Cost Drivers | Cost Optimization Opportunities |
|-------------|------------------------|----------------------|--------------------------------|
| LOCAL | $0 | N/A (developer workstations) | N/A |
| DEV | ~$150 | App Service S1, SQL S0, Blob storage | Auto-shutdown during non-business hours |
| TEST | ~$300 | App Service S2 (2 instances), SQL S1 | Auto-shutdown during weekends |
| STAGING | ~$1,200 | App Service P1v3, SQL S3, Redis Standard | Right-size during non-UAT periods |
| PROD | ~$3,500 | App Service P2v3, SQL P2, Redis Premium, Front Door | Reserved instances, commitment discounts |
| **Total** | **~$5,150/month** | | |

### 10.2 Cost Optimization Strategies

**Auto-Shutdown (DEV, TEST):**
- DEV: Shutdown weekdays 8 PM - 8 AM ET, weekends (save ~40%)
- TEST: Shutdown weekends only (save ~30%)
- Implementation: Azure Automation runbooks

**Right-Sizing:**
- Monthly review of CPU, memory, DTU utilization
- Scale down underutilized resources
- Target: 60-70% average utilization

**Reserved Instances:**
- PROD: 1-year reserved instances for App Service, SQL Database (save ~30%)
- Commitment: Azure Hybrid Benefit for Windows licenses

**Storage Optimization:**
- Lifecycle management: Move blobs to Cool tier after 90 days
- Delete soft-deleted items after retention period
- Compress large files before upload

**Cost Monitoring:**
- Budget alerts: Alert when environment cost exceeds 80% of budget
- Cost anomaly detection: Alert on unexpected cost spikes
- Monthly cost review: DevOps Lead + Finance

**NFR Traceability:** COST-OPT-001 (Cost optimization), COST-MON-001 (Cost monitoring)

---

## 11. Security & Compliance

### 11.1 Security Controls by Environment

| Security Control | LOCAL | DEV | TEST | STAGING | PROD |
|------------------|-------|-----|------|---------|------|
| **Network Isolation** | No | VNet + NSG | VNet + NSG | VNet + NSG + Private Endpoints | VNet + NSG + Private Endpoints + Firewall |
| **TLS Enforcement** | No | Yes (TLS 1.2+) | Yes (TLS 1.2+) | Yes (TLS 1.2+) | Yes (TLS 1.3, min 1.2) |
| **Azure AD Authentication** | No | Yes (SSO) | Yes (SSO) | Yes (SSO) | Yes (SSO + MFA for admins) |
| **Key Vault** | User Secrets | Standard | Standard | Standard | Premium (HSM) |
| **Data Encryption (at rest)** | No | Microsoft-managed | Microsoft-managed | Customer-managed | Customer-managed + Always Encrypted |
| **Audit Logging** | No | 90 days | 90 days | 2 years | 2 years (immutable) |
| **DDoS Protection** | No | No | No | Basic | Standard |
| **WAF** | No | No | No | No | Yes (Azure Front Door) |
| **Vulnerability Scanning** | No | Weekly | Weekly | Weekly | Weekly + DAST |
| **Penetration Testing** | No | No | No | Annual | Annual |

**NFR Traceability:** SEC-DATA-001 (Encryption), SEC-DATA-002 (TLS), SEC-IAM-001 (Azure AD), SEC-APP-005 (Key Vault), COMP-AUDIT-001 (Audit logs)

### 11.2 Compliance Validation

**Audit Cadence:**

| Environment | Frequency | Auditor | Scope |
|-------------|-----------|---------|-------|
| DEV | Quarterly | Security Team | Access logs, configuration drift |
| TEST | Quarterly | Security Team | Access logs, data privacy |
| STAGING | Monthly | Security Team + Compliance | Access logs, data obfuscation, policy compliance |
| PROD | Weekly (automated), Quarterly (manual) | Security Team + Compliance + External Auditors | ISO 27001, SOC 2, GDPR |

**Compliance Artefacts:**
- Access control matrix: Monthly review
- Security scan reports: Weekly (archived 2 years)
- Audit logs: Exported monthly to secure archive
- Incident reports: Documented and reviewed in PIR
- Policy compliance reports: Generated quarterly

**NFR Traceability:** COMP-CERT-001 (ISO 27001), COMP-CERT-002 (SOC 2), COMP-CERT-003 (GDPR)

---

## 12. Disaster Recovery & Business Continuity

### 12.1 Disaster Recovery by Environment

| Environment | RPO | RTO | DR Strategy | Backup Location |
|-------------|-----|-----|-------------|-----------------|
| LOCAL | N/A | N/A | Developer responsibility (Git) | N/A |
| DEV | 24 hours | 4 hours | Restore from backup | East US (geo-redundant) |
| TEST | 24 hours | 4 hours | Restore from backup | East US (geo-redundant) |
| STAGING | 4 hours | 4 hours | Restore from backup + geo-failover | East US + West Europe |
| PROD | <1 hour | <4 hours | Active geo-replication + automated failover | East US (primary) + West Europe (secondary) |

### 12.2 Production Disaster Recovery

**Disaster Scenarios:**

1. **Azure Region Outage (East US):**
   - Automated failover to West Europe (SQL active geo-replication)
   - Azure Front Door redirects traffic to West Europe App Service
   - RTO: <4 hours, RPO: <1 hour

2. **Database Corruption:**
   - Point-in-time restore from automated backup
   - RTO: <2 hours, RPO: <1 hour

3. **Application Defect:**
   - Rollback to previous deployment slot (blue-green swap)
   - RTO: <30 minutes, RPO: N/A

4. **Security Incident (Ransomware, Data Breach):**
   - Isolate affected resources (network segmentation)
   - Restore from immutable backups
   - RTO: <8 hours, RPO: <1 hour

**NFR Traceability:** REL-DR-001 (Disaster recovery), REL-RES-002 (Data backup), REL-DEPLOY-002 (Rollback capability)

---

## 13. Action Items & Next Steps

### 13.1 Immediate Actions (Sprint 0)

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| Provision DEV environment (Bicep) | DevOps Team | Week 1 | 🔲 Not Started |
| Provision TEST environment (Bicep) | DevOps Team | Week 1 | 🔲 Not Started |
| Configure Azure Key Vault (DEV, TEST) | DevOps Lead | Week 1 | 🔲 Not Started |
| Setup Application Insights (DEV, TEST) | DevOps Team | Week 1 | 🔲 Not Started |
| Create seed data scripts (DEV, TEST) | QA Team | Week 2 | 🔲 Not Started |
| Document access procedures | DevOps Lead | Week 2 | 🔲 Not Started |

### 13.2 Sprint 1-2 Actions

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| Provision STAGING environment (Bicep) | DevOps Team | Sprint 1 | 🔲 Not Started |
| Configure data obfuscation pipeline (STAGING) | Data Team | Sprint 2 | 🔲 Not Started |
| Setup auto-shutdown for DEV/TEST | DevOps Team | Sprint 1 | 🔲 Not Started |
| Configure cost alerts | DevOps Lead | Sprint 1 | 🔲 Not Started |
| Test disaster recovery procedures (STAGING) | DevOps Team | Sprint 2 | 🔲 Not Started |

### 13.3 Pre-Production Actions

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| Provision PROD environment (Bicep) | DevOps Team | Sprint 8 | 🔲 Not Started |
| Configure active geo-replication (PROD) | DevOps Team | Sprint 8 | 🔲 Not Started |
| Setup Azure Front Door + WAF (PROD) | DevOps Team | Sprint 8 | 🔲 Not Started |
| Conduct penetration testing (STAGING) | Security Team | Sprint 9 | 🔲 Not Started |
| Validate compliance controls (PROD) | Compliance Officer | Sprint 9 | 🔲 Not Started |
| Execute disaster recovery drill (PROD) | DevOps Lead + SRE | Sprint 10 | 🔲 Not Started |

---

## 14. References

### 14.1 Internal References

| Document | Location | Relevance |
|----------|----------|-----------|
| CI/CD Specification | `docs/development/cicd-spec.md` | Deployment automation, pipeline integration |
| SBOM Strategy | `docs/development/sbom-strategy.md` | Artifact tracking, compliance |
| Coding Standards | `docs/development/coding-standards.md` | Technology stack, configuration standards |
| Readiness Checklist | `docs/development/readiness-checklist.md` | Environment setup prerequisites |
| NFR Catalogue | `docs/requirements/NFR.md` | Performance, security, compliance requirements |
| Threat Model | `docs/design/threat-model.md` | Security controls, network isolation |
| Data Architecture | `docs/design/data-architecture.md` | Data models, retention, privacy |

### 14.2 External References

1. **Azure Well-Architected Framework:** https://learn.microsoft.com/en-us/azure/well-architected/
2. **Azure App Service Best Practices:** https://learn.microsoft.com/en-us/azure/app-service/app-service-best-practices
3. **Azure SQL Database High Availability:** https://learn.microsoft.com/en-us/azure/azure-sql/database/high-availability-sla
4. **Azure Bicep Documentation:** https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/
5. **Azure Cost Management:** https://learn.microsoft.com/en-us/azure/cost-management-billing/

---

## Document Approval

This Environment Matrix has been reviewed and approved by:

| Name | Role | Signature | Date |
|------|------|-----------|------|
| TBD | DevOps Lead | | |
| TBD | Solution Architect | | |
| TBD | Security Architect | | |
| TBD | Operations Lead | | |
| TBD | Compliance Officer | | |

---

**Document Status:** ✅ Baseline  
**Last Updated:** 2025-11-21  
**Next Review:** 2026-02-21 (Quarterly)
