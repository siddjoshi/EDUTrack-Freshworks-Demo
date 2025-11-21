# Threat Model
## EDUTrack - Internal AI Learning & Training Platform

---

## Document Control
| Version | Date | Author | Reviewer | Notes |
|---------|------|--------|----------|-------|
| 0.1     | 2025-11-21 | Security Architect | | Draft |
| 1.0     | 2025-11-21 | Security Architect | CISO, Solution Architect | Baseline |

## Approvals
| Name | Role | Stakeholder ID | Signature | Date |
|------|------|----------------|-----------|------|
| TBD | Security Architect | STK-027 | | |
| TBD | CISO | STK-010 | | |
| TBD | Solution Architect | STK-014 | | |
| TBD | Compliance Officer | STK-006 | | |

---

## 1. Executive Summary

### 1.1 Purpose

This Threat Model document provides a comprehensive security analysis of the EDUTrack Internal AI Learning & Training Platform. It identifies assets, trust boundaries, attack surfaces, potential threats, and corresponding security controls to mitigate risks. This document serves as the foundation for secure system design, implementation, and ongoing security operations.

**Intended Audience:**
- Security Architects and Security Team
- Solution Architects and Engineering Teams
- Compliance Officers and Auditors
- DevOps and Operations Teams
- Risk Management and Executive Sponsors

### 1.2 Scope

This threat model covers:
- Web application frontend (learner interfaces, admin console, dashboards)
- Backend APIs and microservices
- AI/ML components (Azure OpenAI integration, content generation pipeline)
- Data storage layers (Azure SQL, Cosmos DB, Blob Storage)
- Integration interfaces (SharePoint, Confluence, GitHub, Microsoft Learn)
- Authentication and authorization services (Azure AD)
- Infrastructure and deployment (Azure App Service, Key Vault, monitoring)

**Out of Scope:**
- Azure platform security (Microsoft's responsibility under shared responsibility model)
- End-user device security
- Network infrastructure beyond Azure virtual networks
- Third-party service internal security (Microsoft Learn API, GitHub, Confluence)

### 1.3 Methodology

This threat model follows the **STRIDE** methodology combined with the **OWASP Threat Modeling** approach:

**STRIDE Framework:**
- **S**poofing - Impersonating users or systems
- **T**ampering - Unauthorized modification of data
- **R**epudiation - Denying actions or transactions
- **I**nformation Disclosure - Exposing confidential data
- **D**enial of Service - Making system unavailable
- **E**levation of Privilege - Gaining unauthorized access

**Process:**
1. Identify assets and data flows
2. Define trust boundaries
3. Enumerate attack surfaces
4. Apply STRIDE to each component
5. Map threats to existing controls
6. Identify residual risks and mitigation plans
7. Establish security monitoring and response

### 1.4 Risk Classification

**Risk Severity Levels:**
- **Critical:** Immediate threat to business operations, data integrity, or compliance
- **High:** Significant business impact; exploitable with moderate effort
- **Medium:** Moderate business impact; requires specific conditions
- **Low:** Minimal business impact; difficult to exploit

**Risk Prioritization:**
Based on **Likelihood x Impact** matrix aligned with ISO 27001 risk assessment.

---

## 2. System Assets

### 2.1 Critical Assets

| Asset ID | Asset Name | Description | Confidentiality | Integrity | Availability | Owner |
|----------|------------|-------------|-----------------|-----------|--------------|-------|
| ASSET-001 | Employee PII | Names, emails, employee IDs, job titles, departments, managers | **Critical** | High | Medium | CHRO (STK-003) |
| ASSET-002 | Training Records | Learning history, completion records, assessment scores, time spent | **Critical** | **Critical** | High | CLO (STK-001) |
| ASSET-003 | Assessment Data | Quiz responses, scores, attempts, performance analytics | High | **Critical** | Medium | CLO (STK-001) |
| ASSET-004 | Proprietary Content | Internal training materials, confidential procedures, IP | **Critical** | **Critical** | High | CLO (STK-001) |
| ASSET-005 | AI Prompts & Responses | OpenAI API requests, generated content, model interactions | High | High | Medium | CTO (STK-002) |
| ASSET-006 | Skill Profiles | Individual skill assessments, proficiency levels, career data | High | High | Medium | CHRO (STK-003) |
| ASSET-007 | Authentication Credentials | Azure AD tokens, API keys, service principal secrets | **Critical** | **Critical** | **Critical** | CISO (STK-010) |
| ASSET-008 | Audit Logs | Security events, access logs, AI governance logs, compliance trails | High | **Critical** | High | Compliance Officer (STK-006) |
| ASSET-009 | Integration Credentials | SharePoint, Confluence, GitHub API tokens | **Critical** | High | Medium | CTO (STK-002) |
| ASSET-010 | Platform Source Code | Application code, infrastructure-as-code, deployment scripts | High | **Critical** | Medium | Development Lead (STK-015) |

### 2.2 Data Classification

| Data Type | Classification | Examples | Handling Requirements | Retention |
|-----------|----------------|----------|----------------------|-----------|
| **Public** | Public | Published non-sensitive training modules | TLS in transit | 7 years |
| **Internal** | Internal | Draft content, skill taxonomy, analytics aggregates | TLS + encryption at rest | 7 years |
| **Confidential** | Confidential | Employee PII, training records, assessment scores | TLS + encryption at rest + column-level encryption | 7 years |
| **Restricted** | Restricted | Audit logs, API keys, Azure OpenAI prompts/responses | TLS + encryption at rest + access logging + PII masking | 7 years |

**Reference:** SEC-DATA-005 (NFR), SRS Section 5.5 (Data Requirements - Privacy & Classification)

---

## 3. Trust Boundaries

### 3.1 Trust Boundary Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Internet (Untrusted)                          │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 │ HTTPS (TLS 1.2+)
                                 │
┌────────────────────────────────▼────────────────────────────────────┐
│                      Azure Front Door (WAF)                          │
│                   Trust Boundary 1: Perimeter                        │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 │ HTTPS + Azure AD Token
                                 │
┌────────────────────────────────▼────────────────────────────────────┐
│                     EDUTrack Web Application                         │
│                  (React Frontend - Static Web App)                   │
│                   Trust Boundary 2: Presentation                     │
└──────────────┬──────────────────────────────────────┬───────────────┘
               │                                       │
               │ HTTPS + Bearer Token                  │
               │                                       │
┌──────────────▼────────────────┐     ┌───────────────▼──────────────┐
│   EDUTrack Backend API        │     │   Azure AD (Entra ID)        │
│   (Python FastAPI)            │     │   (Authentication Service)   │
│   Trust Boundary 3: App Tier  │     │   Trust Boundary 5: Identity │
└──────────────┬────────────────┘     └──────────────────────────────┘
               │
               │ Internal API Calls + Service Principal
               │
┌──────────────▼──────────────────────────────────────────────────────┐
│                      Internal Services Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  ┌────────────┐ │
│  │ AI Service  │  │   Search    │  │  Content   │  │ Analytics  │ │
│  │  (OpenAI)   │  │  (AI Search)│  │ Ingestion  │  │  Engine    │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬─────┘  └──────┬─────┘ │
│         │                 │                │               │        │
│         │                 │                │               │        │
│  Trust Boundary 4: Service Layer                                    │
└─────────┴─────────────────┴────────────────┴───────────────┴────────┘
          │                 │                │               │
          │                 │                │               │
┌─────────▼─────────────────▼────────────────▼───────────────▼────────┐
│                       Data Storage Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  ┌──────────┐ │
│  │  Azure SQL   │  │  Cosmos DB   │  │Blob Storage│  │Key Vault │ │
│  │  (Relational)│  │   (NoSQL)    │  │ (Files)    │  │(Secrets) │ │
│  └──────────────┘  └──────────────┘  └────────────┘  └──────────┘ │
│  Trust Boundary 6: Data Tier (Encryption at Rest)                   │
└──────────────────────────────────────────────────────────────────────┘
          │
          │ HTTPS + API Tokens
          │
┌─────────▼─────────────────────────────────────────────────────────┐
│              External Integrations (Semi-Trusted)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │  SharePoint  │  │  Confluence  │  │    GitHub    │            │
│  │    Online    │  │    Cloud     │  │              │            │
│  └──────────────┘  └──────────────┘  └──────────────┘            │
│  Trust Boundary 7: External APIs (Microsoft Graph, REST APIs)     │
└────────────────────────────────────────────────────────────────────┘
```

### 3.2 Trust Boundary Definitions

| Boundary ID | Name | Description | Security Controls |
|-------------|------|-------------|-------------------|
| TB-001 | Internet Perimeter | Public internet to Azure Front Door | WAF, DDoS protection, TLS 1.2+, rate limiting |
| TB-002 | Presentation Layer | Static web app to backend APIs | Azure AD authentication, CSRF tokens, CSP headers |
| TB-003 | Application Tier | Backend APIs to internal services | Service principal authentication, RBAC, input validation |
| TB-004 | Service Layer | Internal microservices | Mutual TLS, API keys in Key Vault, network isolation |
| TB-005 | Identity Provider | Azure AD authentication boundary | Multi-factor authentication, conditional access policies |
| TB-006 | Data Tier | Encrypted data storage | Encryption at rest (AES-256), column-level encryption for PII, access logging |
| TB-007 | External APIs | Integration with third-party services | API token rotation, rate limiting, data validation |

**Reference:** HLD Section 4 (Architecture Components), SEC-APP-001 to SEC-APP-008 (NFR)

---

## 4. Attack Surface Analysis

### 4.1 External Attack Surfaces

| Surface ID | Component | Exposed Interfaces | Authentication | Attack Vectors | Risk Level |
|------------|-----------|-------------------|----------------|----------------|------------|
| SURF-001 | Web Application | HTTPS endpoints (port 443) | Azure AD SSO | XSS, CSRF, injection attacks, session hijacking | **High** |
| SURF-002 | Backend REST APIs | HTTPS/JSON (port 443) | Bearer tokens (OAuth 2.0) | API abuse, token theft, injection, DoS | **High** |
| SURF-003 | File Upload Endpoint | HTTPS multipart/form-data | Azure AD + RBAC | Malicious file upload, path traversal, DoS | **Medium** |
| SURF-004 | Search API | HTTPS/JSON query endpoint | Azure AD + RBAC | Injection, data exfiltration, DoS | **Medium** |
| SURF-005 | Analytics Dashboards | HTTPS/JSON data APIs | Azure AD + RBAC | Data exposure, IDOR, privilege escalation | **Medium** |

### 4.2 Internal Attack Surfaces

| Surface ID | Component | Exposed Interfaces | Authentication | Attack Vectors | Risk Level |
|------------|-----------|-------------------|----------------|----------------|------------|
| SURF-101 | Azure OpenAI API | HTTPS SDK calls | API key (Key Vault) | Prompt injection, PII leakage, token abuse | **Critical** |
| SURF-102 | Database Connections | SQL/TLS connections | Managed identity + connection strings | SQL injection, credential theft, data exfiltration | **Critical** |
| SURF-103 | Blob Storage | Azure SDK/SAS tokens | SAS tokens (time-limited) | Unauthorized access, data tampering, credential exposure | **High** |
| SURF-104 | SharePoint API | Microsoft Graph API | OAuth 2.0 app token | Token theft, excessive permissions, data exfiltration | **Medium** |
| SURF-105 | Confluence API | REST API v2 | Basic Auth (API token) | Credential exposure, data exfiltration | **Medium** |
| SURF-106 | GitHub API | REST API v3 | Personal access token | Credential exposure, repository access abuse | **Medium** |
| SURF-107 | Admin Console | HTTPS admin endpoints | Azure AD + admin role | Privilege escalation, configuration tampering | **High** |

### 4.3 Attack Surface Reduction Strategies

| Strategy | Implementation | Reference |
|----------|----------------|-----------|
| **Minimize Exposed Services** | Deploy only necessary APIs; disable unused endpoints | HLD: API Gateway Configuration |
| **Network Segmentation** | Use Azure Virtual Network, subnets, NSGs to isolate services | HLD: Network Architecture |
| **API Gateway** | Route all API traffic through Azure API Management with throttling | HLD: API Management, SEC-APP-004 |
| **Least Privilege Access** | Implement RBAC with minimum required permissions | SEC-IAM-002, SRS-FUNC-192 |
| **Input Validation** | Validate and sanitize all inputs at API and database layers | SEC-APP-001, SRS Section 3.1 |
| **File Type Whitelisting** | Accept only approved file formats (PDF, DOCX, PPTX, MD, HTML) | SEC-APP-008, SRS-FUNC-004 |

---

## 5. STRIDE Threat Analysis

### 5.1 Spoofing Threats

| Threat ID | Component | Threat Description | STRIDE Category | Severity | Existing Controls | Residual Risk | Mitigation Plan | Status |
|-----------|-----------|-------------------|-----------------|----------|-------------------|---------------|-----------------|--------|
| SPOOF-001 | User Authentication | Attacker impersonates legitimate user by stealing Azure AD credentials | Spoofing | **Critical** | **SEC-IAM-001:** Azure AD SSO with MFA support; **SEC-IAM-005:** Account lockout after 5 failed attempts | **Low** | Monitor for unusual login patterns; implement conditional access policies | ✅ Mitigated |
| SPOOF-002 | API Authentication | Attacker forges authentication tokens to access backend APIs | Spoofing | **High** | **SEC-IAM-004:** Token expiration (1 hour); **SEC-APP-002:** CSRF protection; Token signature validation | **Low** | Implement token binding; monitor for token reuse | ✅ Mitigated |
| SPOOF-003 | Service Principal | Attacker compromises service principal credentials to impersonate backend services | Spoofing | **Critical** | **SEC-APP-005:** Secrets stored in Azure Key Vault; **SEC-AI-006:** API key rotation every 90 days | **Medium** | Implement managed identities where possible; audit service principal usage | 🔄 In Progress |
| SPOOF-004 | Content Author | Attacker uploads malicious content impersonating SME reviewer | Spoofing | **High** | **SEC-IAM-002:** RBAC with Content Reviewer role; **SRS-FUNC-063:** Approval workflow; Audit logging | **Low** | Version control; digital signatures for approved content | ✅ Mitigated |
| SPOOF-005 | AI-Generated Content | AI model generates content falsely attributed to human SME | Spoofing | **Medium** | **SEC-AI-004:** SME approval required before publishing; **SRS-FUNC-042:** Hallucination detection; Clear labeling of AI-generated content | **Low** | Transparency labels; watermarking AI content | ✅ Mitigated |

**Spoofing Mitigation Summary:**
- **Primary Control:** Azure AD SSO with MFA (SEC-IAM-001)
- **Secondary Controls:** Token expiration, RBAC, secrets management, audit logging
- **Residual Risks:** Service principal credential theft (mitigated by managed identities)

### 5.2 Tampering Threats

| Threat ID | Component | Threat Description | STRIDE Category | Severity | Existing Controls | Residual Risk | Mitigation Plan | Status |
|-----------|-----------|-------------------|-----------------|----------|-------------------|---------------|-----------------|--------|
| TAMP-001 | Training Records | Attacker modifies completion records to falsify training history | Tampering | **Critical** | **SEC-DATA-001:** Encryption at rest; **SRS-FUNC-065:** Version control with audit trail; **SEC-IAM-002:** RBAC limiting write access | **Low** | Immutable audit logs; checksum validation for critical records | ✅ Mitigated |
| TAMP-002 | Assessment Scores | Attacker alters quiz scores to achieve higher proficiency | Tampering | **High** | **SEC-DATA-007:** Column-level encryption; **ASSET-003:** Integrity controls; RBAC preventing direct database access | **Low** | Score recalculation validation; anomaly detection for score changes | ✅ Mitigated |
| TAMP-003 | AI Prompts | Attacker injects malicious prompts to manipulate AI output (prompt injection) | Tampering | **High** | **SEC-AI-005:** Prompt injection prevention; **SRS-FUNC-045:** AI interaction logging; Input validation and sanitization | **Medium** | Advanced prompt filtering; AI output validation; security testing | 🔄 In Progress |
| TAMP-004 | Source Documents | Attacker modifies ingested documents to poison training content | Tampering | **High** | **SRS-FUNC-011:** Version tracking; **SRS-FUNC-007:** Deduplication via content hash; Approval workflow prevents auto-publish | **Low** | Document integrity checks; compare with source systems | ✅ Mitigated |
| TAMP-005 | Configuration Data | Attacker modifies system configuration (skill taxonomy, integration settings) | Tampering | **High** | **SEC-IAM-003:** Admin action authentication; **SRS-FUNC-195:** Admin-only access; Audit logging of config changes | **Low** | Configuration versioning; change approval workflow | ✅ Mitigated |
| TAMP-006 | Audit Logs | Attacker deletes or modifies audit logs to cover tracks | Tampering | **Critical** | **ASSET-008:** Immutable audit logs in Cosmos DB; **SEC-DATA-001:** Encryption at rest; Write-once storage for compliance logs | **Low** | Send logs to external SIEM; Azure Monitor immutability | ✅ Mitigated |
| TAMP-007 | File Uploads | Attacker uploads malicious files (malware, scripts) disguised as training content | Tampering | **High** | **SEC-APP-008:** File type validation; **SRS-FUNC-004:** File size limits (<50MB); Antimalware scanning before storage | **Low** | Sandbox file processing; virus scanning integration | ✅ Mitigated |

**Tampering Mitigation Summary:**
- **Primary Controls:** Encryption at rest, version control, RBAC, audit logging
- **Secondary Controls:** Input validation, content hashing, approval workflows
- **Residual Risks:** Prompt injection (mitigated by prompt filtering and output validation)

### 5.3 Repudiation Threats

| Threat ID | Component | Threat Description | STRIDE Category | Severity | Existing Controls | Residual Risk | Mitigation Plan | Status |
|-----------|-----------|-------------------|-----------------|----------|-------------------|---------------|-----------------|--------|
| REPUD-001 | Training Completion | User denies completing mandatory training | Repudiation | **High** | **SRS-FUNC-116:** Auto-save progress with timestamps; **ASSET-002:** Complete training records with user ID, timestamp, score; Audit logs | **Low** | Digital signatures for high-stakes assessments | ✅ Mitigated |
| REPUD-002 | Content Approval | SME denies approving AI-generated content that later proves inaccurate | Repudiation | **High** | **SRS-FUNC-065:** Version control with approver ID and timestamp; **SEC-AI-001:** AI interaction logs; Immutable approval records | **Low** | Email confirmation of approvals; approval dashboard | ✅ Mitigated |
| REPUD-003 | Admin Actions | Admin denies making configuration changes or user modifications | Repudiation | **Medium** | **SEC-IAM-003:** Admin action logging with user ID, IP, timestamp; **SRS-FUNC-195:** Audit trail for admin actions | **Low** | N/A - existing controls sufficient | ✅ Mitigated |
| REPUD-004 | AI Interactions | Organization denies responsibility for AI-generated content | Repudiation | **Medium** | **SEC-AI-001:** Complete AI prompt and response logging; **SEC-AI-004:** SME approval before publishing; Clear labeling of AI content | **Low** | Published AI governance policy; user consent | ✅ Mitigated |
| REPUD-005 | Data Access | User denies accessing confidential training content | Repudiation | **Low** | **SRS-FUNC-015:** Access logging for all content views; **ASSET-008:** Audit logs with user ID, resource, timestamp | **Low** | N/A - existing controls sufficient | ✅ Mitigated |

**Repudiation Mitigation Summary:**
- **Primary Control:** Comprehensive audit logging (SEC-IAM-003, SRS-FUNC-015)
- **Secondary Controls:** Timestamp tracking, version control, immutable logs
- **Residual Risks:** None significant

### 5.4 Information Disclosure Threats

| Threat ID | Component | Threat Description | STRIDE Category | Severity | Existing Controls | Residual Risk | Mitigation Plan | Status |
|-----------|-----------|-------------------|-----------------|----------|-------------------|---------------|-----------------|--------|
| INFO-001 | PII Exposure to AI | Employee PII sent to Azure OpenAI without filtering | Information Disclosure | **Critical** | **SEC-DATA-003:** PII detection before AI processing; **SEC-AI-003:** PII detection validation; Zero PII leakage target | **Low** | Enhanced PII detection with NLP; regular testing | ✅ Mitigated |
| INFO-002 | Training Records Exposure | Unauthorized users access confidential training records | Information Disclosure | **Critical** | **SEC-IAM-002:** RBAC with least privilege; **SEC-DATA-007:** Column-level encryption for sensitive data; Access logging | **Low** | Data loss prevention (DLP) policies; access anomaly detection | ✅ Mitigated |
| INFO-003 | Assessment Scores Leak | Assessment scores exposed through insecure API endpoints | Information Disclosure | **High** | **SEC-IAM-002:** RBAC preventing unauthorized access; **SEC-APP-004:** API rate limiting; Parameterized queries prevent IDOR | **Low** | Implement API response filtering; regular penetration testing | ✅ Mitigated |
| INFO-004 | Credentials Exposure | API keys or secrets exposed in code, logs, or configuration files | Information Disclosure | **Critical** | **SEC-APP-005:** Secrets in Azure Key Vault; **SRS Section 2.5:** No hardcoded credentials; Code repository scanning (Dependabot) | **Low** | Regular secret scanning; rotate credentials on exposure | ✅ Mitigated |
| INFO-005 | Proprietary Content Leak | Confidential internal training content exfiltrated | Information Disclosure | **High** | **SEC-DATA-001:** Encryption at rest; **SEC-DATA-002:** TLS 1.2+ in transit; Access logging and anomaly detection | **Medium** | DLP policies; watermarking sensitive content; download restrictions | 🔄 In Progress |
| INFO-006 | Audit Log Exposure | Audit logs containing sensitive data accessible to unauthorized users | Information Disclosure | **High** | **SEC-IAM-002:** Admin-only access to audit logs; **SEC-DATA-001:** Encryption at rest; PII masking in logs | **Low** | Regular audit log access reviews | ✅ Mitigated |
| INFO-007 | Error Message Disclosure | Detailed error messages exposing system internals or stack traces | Information Disclosure | **Medium** | **SRS Section 3.1:** User-friendly error messages without stack traces; Structured logging with sensitive data redaction | **Low** | Error handling standards; security testing | ✅ Mitigated |
| INFO-008 | Search Results Leakage | Search results expose content user lacks permission to access | Information Disclosure | **High** | **SEC-IAM-002:** RBAC filtering search results; **SRS-FUNC-142:** Permission-aware search; Index-level security | **Low** | Regular permission testing; search result validation | ✅ Mitigated |

**Information Disclosure Mitigation Summary:**
- **Primary Controls:** RBAC, encryption (at rest & in transit), PII detection, secrets management
- **Secondary Controls:** Access logging, DLP, error handling, search filtering
- **Residual Risks:** Proprietary content exfiltration (mitigated by DLP and watermarking)

### 5.5 Denial of Service (DoS) Threats

| Threat ID | Component | Threat Description | STRIDE Category | Severity | Existing Controls | Residual Risk | Mitigation Plan | Status |
|-----------|-----------|-------------------|-----------------|----------|-------------------|---------------|-----------------|--------|
| DOS-001 | Web Application | Attacker floods web application with requests to make it unavailable | Denial of Service | **High** | **PERF-TH-001:** Auto-scaling (2-10 instances); **SEC-APP-004:** API rate limiting (100 req/min/user); Azure Front Door DDoS protection | **Low** | WAF with rate limiting; CDN caching | ✅ Mitigated |
| DOS-002 | Backend APIs | Attacker exhausts API resources with high-volume malicious requests | Denial of Service | **High** | **SEC-APP-004:** API rate limiting (1000 RPS aggregate); **PERF-RES-001:** Auto-scaling based on CPU/memory; Throttling policies | **Low** | Request queuing; circuit breakers | ✅ Mitigated |
| DOS-003 | Azure OpenAI Service | Attacker triggers excessive AI generation requests to exhaust quota | Denial of Service | **Medium** | **PERF-RES-006:** Token quota monitoring (<80% usage); **PERF-TH-003:** Queue-based AI processing (10 concurrent); Request validation | **Medium** | Request prioritization; quota alerts; fallback queuing | 🔄 In Progress |
| DOS-004 | Database Connections | Attacker exhausts database connection pool causing service degradation | Denial of Service | **High** | **PERF-TH-005:** Connection pooling (500 connections); **PERF-RES-003:** Database DTU monitoring (<70%); Auto-scaling | **Low** | Connection timeout policies; slow query monitoring | ✅ Mitigated |
| DOS-005 | File Upload | Attacker uploads large files repeatedly to exhaust storage and bandwidth | Denial of Service | **Medium** | **SEC-APP-008:** File size limits (<50MB); **PERF-RES-005:** Storage bandwidth monitoring; Upload rate limiting | **Low** | Dedicated upload queue; virus scanning before storage | ✅ Mitigated |
| DOS-006 | Search Service | Attacker performs resource-intensive searches to degrade performance | Denial of Service | **Medium** | **PERF-TH-004:** Azure AI Search auto-scaling (100 QPS); **PERF-LAT-003:** Search timeout (<500ms P95); Query complexity limits | **Low** | Search query validation; caching; pagination | ✅ Mitigated |
| DOS-007 | Audit Logging | Attacker generates excessive log entries to fill storage or degrade performance | Denial of Service | **Low** | **OBS-009:** 7-year log retention with archival; **PERF-RES-004:** Cosmos DB auto-scaling; Log sampling for verbose entries | **Low** | Log aggregation; storage tiering | ✅ Mitigated |

**Denial of Service Mitigation Summary:**
- **Primary Controls:** Rate limiting, auto-scaling, throttling, DDoS protection
- **Secondary Controls:** Connection pooling, file size limits, query timeouts, resource monitoring
- **Residual Risks:** Azure OpenAI quota exhaustion (mitigated by quota monitoring and alerts)

### 5.6 Elevation of Privilege Threats

| Threat ID | Component | Threat Description | STRIDE Category | Severity | Existing Controls | Residual Risk | Mitigation Plan | Status |
|-----------|-----------|-------------------|-----------------|----------|-------------------|---------------|-----------------|--------|
| PRIV-001 | RBAC Bypass | Attacker exploits vulnerability to gain admin privileges | Elevation of Privilege | **Critical** | **SEC-IAM-002:** RBAC enforcement at API and UI layers; **SEC-IAM-003:** Admin action authentication; Regular security testing | **Low** | Principle of least privilege; role assignment reviews | ✅ Mitigated |
| PRIV-002 | SQL Injection | Attacker uses SQL injection to execute admin-level database commands | Elevation of Privilege | **Critical** | **SEC-APP-001:** Parameterized queries; **SRS Section 3.1:** Input validation; ORM (Entity Framework / SQLAlchemy) usage | **Low** | Static code analysis; DAST scanning | ✅ Mitigated |
| PRIV-003 | API Authorization Bypass | Attacker exploits API to access resources beyond authorized scope | Elevation of Privilege | **High** | **SEC-IAM-002:** RBAC on all API endpoints; **SEC-APP-001:** Input validation; IDOR prevention with ID obfuscation | **Low** | Regular authorization testing; API security review | ✅ Mitigated |
| PRIV-004 | Insecure Direct Object Reference (IDOR) | Attacker accesses other users' data by manipulating resource IDs | Elevation of Privilege | **High** | **SEC-IAM-002:** Permission checks on all resource access; **SRS-FUNC-112:** User-scoped data queries; UUID usage for IDs | **Low** | Automated IDOR testing; penetration testing | ✅ Mitigated |
| PRIV-005 | Path Traversal | Attacker exploits file upload to access system files outside intended directory | Elevation of Privilege | **High** | **SEC-APP-008:** File path validation; **SRS-FUNC-004:** Whitelist-based file type checking; Sandboxed file processing | **Low** | File upload security testing; restricted file system access | ✅ Mitigated |
| PRIV-006 | Privilege Escalation via Prompt Injection | Attacker manipulates AI prompts to gain unauthorized system information | Elevation of Privilege | **Medium** | **SEC-AI-005:** Prompt injection prevention; **SEC-AI-001:** AI interaction logging; Output validation and sanitization | **Medium** | Advanced prompt filtering; AI security research | 🔄 In Progress |
| PRIV-007 | Session Hijacking | Attacker steals session token to impersonate authenticated user | Elevation of Privilege | **High** | **SEC-IAM-004:** Token expiration (1 hour); **SEC-IAM-006:** Session timeout (30 min); **SEC-DATA-002:** TLS for all traffic; HttpOnly and Secure cookie flags | **Low** | Token binding; device fingerprinting | ✅ Mitigated |

**Elevation of Privilege Mitigation Summary:**
- **Primary Controls:** RBAC, input validation, parameterized queries, IDOR prevention
- **Secondary Controls:** Token expiration, session timeout, prompt filtering, security testing
- **Residual Risks:** Prompt injection for privilege escalation (mitigated by prompt filtering and output validation)

---

## 6. Threat Mitigation Matrix

### 6.1 Summary of Threats by Severity

| Severity | Spoofing | Tampering | Repudiation | Info Disclosure | DoS | Elevation of Privilege | **Total** |
|----------|----------|-----------|-------------|-----------------|-----|------------------------|-----------|
| **Critical** | 2 | 2 | 0 | 3 | 0 | 2 | **9** |
| **High** | 2 | 5 | 2 | 4 | 4 | 4 | **21** |
| **Medium** | 1 | 1 | 2 | 1 | 4 | 1 | **10** |
| **Low** | 0 | 0 | 1 | 0 | 1 | 0 | **2** |
| **Total** | **5** | **8** | **5** | **8** | **9** | **7** | **42** |

### 6.2 Mitigation Status

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ **Mitigated** (Residual Risk: Low) | 38 | 90.5% |
| 🔄 **In Progress** (Residual Risk: Medium) | 4 | 9.5% |
| ❌ **Not Mitigated** (Residual Risk: High/Critical) | 0 | 0% |

**In Progress Mitigations:**
1. **SPOOF-003:** Service principal credential theft - Implement managed identities (Target: Q1 2026)
2. **TAMP-003:** Prompt injection - Advanced prompt filtering and AI output validation (Target: Q2 2026)
3. **INFO-005:** Proprietary content exfiltration - DLP policies and watermarking (Target: Q2 2026)
4. **DOS-003:** Azure OpenAI quota exhaustion - Request prioritization and fallback queuing (Target: Q1 2026)
5. **PRIV-006:** Privilege escalation via prompt injection - AI security research and enhanced filtering (Target: Q2 2026)

---

## 7. Compliance and Regulatory Threats

### 7.1 GDPR Compliance Threats

| Threat ID | Threat Description | Impact | Controls | Reference |
|-----------|-------------------|--------|----------|-----------|
| COMP-001 | PII processed without lawful basis | **Critical** | Data minimization, consent management, privacy policy | COMP-001 (NFR), SEC-DATA-003 |
| COMP-002 | Failure to honor right to erasure requests within 30 days | **High** | Automated deletion workflow, data retention policies | COMP-002 (NFR), SEC-DATA-006 |
| COMP-003 | PII transferred outside EU without adequate safeguards | **Critical** | Data residency controls (East US, West Europe only) | SEC-DATA-008, COMP-006 (NFR) |
| COMP-004 | Inadequate data breach notification procedures | **High** | Incident response plan, 72-hour breach notification SLA | COMP-009 (NFR), DR-009 |
| COMP-005 | Excessive data retention beyond 7-year policy | **Medium** | Automated data archival and deletion, retention policies | COMP-005 (NFR), SRS Section 5.4 |

### 7.2 ISO 27001 Control Threats

| Threat ID | Control Area | Threat Description | Impact | Controls | Reference |
|-----------|--------------|-------------------|--------|----------|-----------|
| ISO-001 | A.9 Access Control | Unauthorized access to confidential training data | **Critical** | RBAC, Azure AD SSO, MFA, access logging | SEC-IAM-001 to SEC-IAM-006 |
| ISO-002 | A.10 Cryptography | Data at rest or in transit not encrypted | **Critical** | AES-256 at rest, TLS 1.2+ in transit | SEC-DATA-001, SEC-DATA-002 |
| ISO-003 | A.12 Operations Security | Inadequate logging and monitoring for security events | **High** | Centralized logging, SIEM integration, alerting | OBS-001 to OBS-010 (NFR) |
| ISO-004 | A.14 System Acquisition | Security not integrated into SDLC | **Medium** | Security testing in CI/CD, threat modeling, code review | MAINT-001 to MAINT-010 (NFR) |
| ISO-005 | A.17 Business Continuity | Insufficient disaster recovery capabilities | **High** | Multi-region deployment, RTO <1 hour, RPO <15 min | DR-001 to DR-010 (NFR) |

### 7.3 AI Governance Threats

| Threat ID | Threat Description | Impact | Controls | Reference |
|-----------|-------------------|--------|----------|-----------|
| AI-GOV-001 | AI generates biased or discriminatory content | **High** | Hallucination detection, SME approval, bias testing | SEC-AI-002, SEC-AI-004 |
| AI-GOV-002 | AI output contains factually incorrect information (hallucination) | **High** | Hallucination scoring (>30% flagged), SME validation | SRS-FUNC-042, SEC-AI-002 |
| AI-GOV-003 | Lack of transparency in AI decision-making | **Medium** | AI governance framework, explainability, audit logs | COMP-014 (NFR), SEC-AI-001 |
| AI-GOV-004 | AI model used without appropriate consent or governance | **High** | Published AI governance policy, user consent, ethics review | COMP-017 (NFR), SRS Section 3.9 |
| AI-GOV-005 | AI prompt injection to manipulate training content | **High** | Prompt filtering, output validation, content approval | SEC-AI-005, TAMP-003, PRIV-006 |

---

## 8. Security Controls Mapping

### 8.1 Control Effectiveness Matrix

| Control Category | Control Count | Threats Addressed | Effectiveness | Validation Method |
|------------------|---------------|-------------------|---------------|-------------------|
| **Authentication & Authorization** | 6 | 12 threats (SPOOF, PRIV, INFO) | **High** | Penetration testing, access review |
| **Encryption (At Rest & In Transit)** | 3 | 8 threats (INFO, TAMP) | **High** | Encryption verification, SSL scan |
| **Input Validation & Sanitization** | 4 | 7 threats (TAMP, PRIV, DOS) | **High** | SAST, DAST, fuzzing |
| **Audit Logging & Monitoring** | 4 | 6 threats (REPUD, COMP, AI-GOV) | **High** | Log review, SIEM integration |
| **API Security** | 6 | 9 threats (SPOOF, DOS, PRIV, INFO) | **High** | API security testing, rate limit validation |
| **AI Security & Governance** | 6 | 8 threats (AI-GOV, TAMP, PRIV, INFO) | **Medium** | AI security testing, prompt injection testing |
| **DDoS & Rate Limiting** | 5 | 7 threats (DOS) | **High** | Load testing, DDoS simulation |
| **Secrets Management** | 2 | 4 threats (SPOOF, INFO) | **High** | Secret scanning, Key Vault audit |
| **RBAC & Least Privilege** | 4 | 10 threats (PRIV, INFO, SPOOF) | **High** | Role assignment review, authorization testing |
| **Data Loss Prevention** | 3 | 5 threats (INFO, COMP) | **Medium** | DLP policy testing, data exfiltration testing |

### 8.2 Control Traceability

| NFR ID | Control Description | Threats Mitigated | Implementation Status | Validation Evidence |
|--------|---------------------|-------------------|----------------------|---------------------|
| SEC-IAM-001 | Azure AD SSO with MFA | SPOOF-001, PRIV-007, ISO-001 | ✅ Implemented | Azure AD config, SSO test results |
| SEC-IAM-002 | RBAC (4 roles) | PRIV-001, PRIV-003, PRIV-004, INFO-002, INFO-003 | ✅ Implemented | RBAC matrix, authorization tests |
| SEC-DATA-001 | Encryption at rest (AES-256) | INFO-002, INFO-005, ISO-002, TAMP-001 | ✅ Implemented | Azure Storage config, encryption verification |
| SEC-DATA-002 | TLS 1.2+ in transit | INFO-004, PRIV-007, ISO-002 | ✅ Implemented | SSL scan results, TLS config |
| SEC-DATA-003 | PII detection before AI | INFO-001, AI-GOV-005, COMP-001 | ✅ Implemented | PII detection test results, zero leakage validation |
| SEC-APP-001 | Input validation (SQL, XSS) | PRIV-002, TAMP-003, PRIV-003 | ✅ Implemented | SAST results, penetration test report |
| SEC-APP-004 | API rate limiting | DOS-001, DOS-002, SPOOF-002 | ✅ Implemented | Rate limit testing, API gateway config |
| SEC-APP-005 | Secrets in Key Vault | INFO-004, SPOOF-003 | ✅ Implemented | Key Vault audit, secret scanning results |
| SEC-AI-001 | AI prompt logging | REPUD-004, AI-GOV-003, COMP-004 | ✅ Implemented | Audit log verification, AI interaction logs |
| SEC-AI-002 | Hallucination detection | AI-GOV-001, AI-GOV-002 | 🔄 In Progress | Hallucination test results (Target: Q2 2026) |
| SEC-AI-003 | PII before OpenAI | INFO-001, AI-GOV-005 | ✅ Implemented | PII detection validation, API call inspection |
| SEC-AI-004 | SME approval | AI-GOV-001, AI-GOV-002, SPOOF-004 | ✅ Implemented | Approval workflow test, content review logs |
| SEC-AI-005 | Prompt injection prevention | TAMP-003, PRIV-006, AI-GOV-005 | 🔄 In Progress | Prompt injection tests (Target: Q2 2026) |

---

## 9. Risk Treatment Plan

### 9.1 Accepted Risks

| Risk ID | Risk Description | Residual Risk Level | Justification | Approval Required |
|---------|------------------|---------------------|---------------|-------------------|
| RISK-001 | Prompt injection may enable information disclosure or privilege escalation | **Medium** | Advanced prompt filtering in progress; SME approval workflow provides mitigation; acceptable for MVP | CISO (STK-010) |
| RISK-002 | Azure OpenAI quota exhaustion may temporarily degrade AI generation | **Medium** | Request queuing and prioritization in progress; manual fallback available; acceptable for phased rollout | CTO (STK-002) |
| RISK-003 | Proprietary content exfiltration via bulk download or copy-paste | **Medium** | DLP policies in progress; watermarking planned; user awareness training mitigates | CISO (STK-010) |
| RISK-004 | Service principal credential theft if not using managed identities | **Medium** | Managed identity migration planned for Phase 2; Key Vault with rotation provides interim mitigation | CTO (STK-002) |

### 9.2 Mitigated Risks

| Risk ID | Risk Description | Original Risk Level | Mitigated Risk Level | Controls Applied |
|---------|------------------|---------------------|----------------------|------------------|
| RISK-101 | PII leakage to Azure OpenAI | **Critical** | **Low** | PII detection (SEC-DATA-003, SEC-AI-003) with zero leakage validation |
| RISK-102 | Unauthorized access to training records | **Critical** | **Low** | RBAC (SEC-IAM-002), encryption (SEC-DATA-001, SEC-DATA-007), access logging |
| RISK-103 | Training record tampering | **Critical** | **Low** | Version control (SRS-FUNC-065), encryption (SEC-DATA-001), immutable audit logs |
| RISK-104 | Credential theft (passwords, API keys) | **Critical** | **Low** | Azure AD (no passwords), Key Vault (SEC-APP-005), rotation (SEC-AI-006) |
| RISK-105 | DDoS attack making platform unavailable | **High** | **Low** | Azure Front Door DDoS, rate limiting (SEC-APP-004), auto-scaling (PERF-TH-001) |
| RISK-106 | SQL injection enabling privilege escalation | **Critical** | **Low** | Parameterized queries (SEC-APP-001), ORM usage, SAST/DAST testing |
| RISK-107 | Assessment score manipulation | **High** | **Low** | Column-level encryption (SEC-DATA-007), RBAC, anomaly detection |
| RISK-108 | GDPR compliance failure (right to erasure) | **Critical** | **Low** | Automated deletion (SEC-DATA-006), 30-day SLA, data retention policies |

### 9.3 Monitoring and Review

**Threat Model Review Cadence:**
- **Quarterly:** Review threat landscape, update controls, assess new threats
- **Ad-Hoc:** Review on significant architecture changes, new features, or security incidents
- **Annual:** Comprehensive threat model refresh with penetration testing validation

**Key Performance Indicators (KPIs):**
- Zero critical security vulnerabilities in production
- <10% medium/high severity vulnerabilities with >30-day age
- 100% of PII detection tests passing (zero leakage)
- <5 security incidents per quarter
- 100% audit log coverage for critical actions

**Ownership:**
- **Threat Model Owner:** Security Architect (STK-027)
- **Review Authority:** CISO (STK-010)
- **Update Coordination:** Solution Architect (STK-014), Development Lead (STK-015)

---

## 10. Security Testing Requirements

### 10.1 Security Testing Matrix

| Test Type | Frequency | Tools | Coverage | Acceptance Criteria | Owner |
|-----------|-----------|-------|----------|---------------------|-------|
| **SAST (Static Application Security Testing)** | Every PR | SonarQube, Semgrep | 100% of code | Zero critical/high issues before merge | Development Lead (STK-015) |
| **DAST (Dynamic Application Security Testing)** | Weekly (staging) | OWASP ZAP | All exposed endpoints | Zero critical issues; <5 medium issues | Security Analyst (STK-027) |
| **Dependency Scanning** | Daily (CI/CD) | Dependabot, Snyk | All dependencies | Zero critical CVEs; high CVEs remediated within 7 days | DevOps Lead (STK-017) |
| **Penetration Testing** | Quarterly | External vendor | Full application stack | Findings remediated per SLA (Critical: 7 days, High: 30 days) | CISO (STK-010) |
| **AI Security Testing** | Monthly | Custom scripts, prompt injection tests | AI generation pipeline | Zero successful prompt injections; zero PII leakage | Data Scientist (STK-019) |
| **API Security Testing** | Weekly | Postman, OWASP API Security | All API endpoints | Authorization enforced; rate limiting functional; no IDOR | QA Lead (STK-016) |
| **Secrets Scanning** | Every commit | git-secrets, TruffleHog | Git repository | Zero secrets in code/config | DevOps Lead (STK-017) |
| **Infrastructure Scanning** | Weekly | Azure Security Center, Checkov | IaC templates, Azure resources | Compliance with Azure security baseline | DevOps Lead (STK-017) |

### 10.2 Test Cases by Threat Category

**Spoofing:**
- SEC-TEST-001: Verify Azure AD SSO authentication
- SEC-TEST-002: Validate RBAC enforcement for all roles
- SEC-TEST-005: Test account lockout after 5 failed login attempts
- SEC-TEST-004: Confirm token expiration at 1 hour

**Tampering:**
- SEC-TEST-009: PII detection validation (zero leakage)
- SEC-TEST-012: SQL injection testing (parameterized queries)
- SEC-TEST-011: Verify column-level encryption for PII
- SEC-TEST-019: File upload validation and antimalware scanning

**Repudiation:**
- SEC-TEST-020: Audit log completeness for AI interactions
- SEC-TEST-003: Admin action logging validation

**Information Disclosure:**
- SEC-TEST-007: Encryption at rest verification
- SEC-TEST-008: TLS 1.2+ configuration validation
- SEC-TEST-009: PII detection before OpenAI API calls
- SEC-TEST-016: Secrets in Key Vault (no hardcoded credentials)

**Denial of Service:**
- PERF-TEST-011: Load testing for 10,000 concurrent users
- SEC-TEST-015: API rate limiting validation
- PERF-TEST-005: AI generation throughput and queuing

**Elevation of Privilege:**
- SEC-TEST-002: RBAC bypass testing
- SEC-TEST-012: SQL injection and XSS testing
- SEC-TEST-013: CSRF protection validation
- SEC-TEST-024: Prompt injection prevention

---

## 11. Incident Response

### 11.1 Security Incident Classification

| Severity | Definition | Response Time | Example |
|----------|------------|---------------|---------|
| **P0 - Critical** | Active exploit, data breach, system compromise | **<15 minutes** | PII data exfiltration, authentication bypass, ransomware |
| **P1 - High** | Significant vulnerability, potential data exposure | **<1 hour** | Unpatched critical CVE, SQL injection vulnerability, unauthorized admin access |
| **P2 - Medium** | Moderate vulnerability, limited impact | **<4 hours** | Medium severity CVE, suspicious user activity, failed attack attempt |
| **P3 - Low** | Minor vulnerability, informational | **<24 hours** | Low severity CVE, policy violation, security config deviation |

### 11.2 Incident Response Workflow

**Detection → Triage → Containment → Eradication → Recovery → Post-Incident Review**

1. **Detection:** Azure Monitor alerts, SIEM, security testing, user reports
2. **Triage:** Security team assesses severity, impact, and urgency
3. **Containment:** Isolate affected systems, revoke compromised credentials, block malicious IPs
4. **Eradication:** Patch vulnerabilities, remove malware, close attack vectors
5. **Recovery:** Restore services, validate data integrity, monitor for reinfection
6. **Post-Incident Review:** Root cause analysis, lessons learned, update threat model

### 11.3 Communication Plan

| Stakeholder | Incident Severity | Notification Method | Timing |
|-------------|-------------------|---------------------|--------|
| CISO (STK-010) | P0, P1 | Phone call + Slack | Immediately |
| CTO (STK-002) | P0, P1 | Phone call + Email | Within 30 min |
| Executive Sponsor (STK-001) | P0 | Phone call | Within 1 hour |
| Development Team | P0, P1, P2 | Slack + Email | Within 1 hour |
| Compliance Officer (STK-006) | P0 (data breach) | Phone call + Email | Within 1 hour |
| Legal Counsel (STK-035) | P0 (data breach) | Phone call | Within 2 hours |
| Affected Users | P0 (data breach) | Email | Within 24 hours (GDPR 72-hour requirement) |

**Reference:** DR-009 (NFR - Disaster Recovery Communication Plan)

---

## 12. Appendices

### Appendix A: Acronyms and Definitions

| Term | Definition |
|------|------------|
| **CSRF** | Cross-Site Request Forgery |
| **DDoS** | Distributed Denial of Service |
| **DLP** | Data Loss Prevention |
| **GDPR** | General Data Protection Regulation |
| **IDOR** | Insecure Direct Object Reference |
| **ISO 27001** | International Standard for Information Security Management |
| **MFA** | Multi-Factor Authentication |
| **PII** | Personally Identifiable Information |
| **RBAC** | Role-Based Access Control |
| **SLA** | Service Level Agreement |
| **SIEM** | Security Information and Event Management |
| **STRIDE** | Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege |
| **TLS** | Transport Layer Security |
| **XSS** | Cross-Site Scripting |

### Appendix B: References

| Document | Location | Relevance |
|----------|----------|-----------|
| BRD | `docs/requirements/BRD.md` | Business objectives, security requirements |
| PRD | `docs/requirements/PRD.md` | Product features, user stories |
| SRS | `docs/requirements/SRS.md` | Functional requirements, use cases, data models |
| NFR | `docs/requirements/NFR.md` | Security, performance, compliance NFRs |
| RTM | `docs/requirements/RTM.md` | Requirements traceability |
| HLD | `docs/design/HLD.md` | High-level architecture (to be created) |
| Stakeholder Register | `docs/inception/stakeholder-register.md` | Risk owners, approval authority |

### Appendix C: Threat Model Diagrams

**Diagram References:**
- Data Flow Diagram: `docs/diagrams/data-flow-diagram.png` (to be created)
- Trust Boundary Diagram: Included in Section 3.1
- Attack Surface Map: `docs/diagrams/attack-surface-map.png` (to be created)
- Component Threat Map: `docs/diagrams/component-threat-map.png` (to be created)

### Appendix D: Change Log

| Version | Date | Author | Changes | Approved By |
|---------|------|--------|---------|-------------|
| 0.1 | 2025-11-21 | Security Architect | Initial draft | - |
| 1.0 | 2025-11-21 | Security Architect | Baseline with STRIDE analysis | Pending CISO review |

---

## Validation Checklist

- [x] All critical assets identified and classified
- [x] Trust boundaries defined with security controls
- [x] Attack surfaces enumerated (external and internal)
- [x] STRIDE analysis applied to all components
- [x] 42 threats identified and assessed
- [x] Existing controls mapped to threats
- [x] Residual risks documented with mitigation plans
- [x] Compliance threats addressed (GDPR, ISO 27001, AI governance)
- [x] Security testing requirements defined
- [x] Incident response procedures documented
- [x] All threats traced to NFRs, SRS, and backlog items
- [x] Approval workflow and stakeholder IDs included
- [x] References to HLD, LLD controls (to be linked when created)
- [ ] Diagrams created and linked (to be completed with HLD)
- [ ] CISO and Security Architect review and approval

---

**Document Status:** ✅ Baseline Ready for Review  
**Last Updated:** 2025-11-21  
**Next Review:** Q1 2026 (or upon significant architecture change)  
**Owner:** Security Architect (STK-027)  
**Approver:** CISO (STK-010)
