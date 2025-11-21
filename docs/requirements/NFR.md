# Non-Functional Requirements (NFR) Specification
## EDUTrack - Internal AI Learning & Training Platform

---

## Document Control
| Version | Date | Author | Reviewer | Changes |
|---------|------|--------|----------|---------|
| 0.1     | 2025-11-20 | Solution Architect | | Draft |
| 1.0     | 2025-11-20 | Solution Architect | QA Lead, Security Architect, Product Owner | Baseline |

## Approvals
| Name | Role | Signature | Date |
|------|------|-----------|------|
| TBD | Product Manager | | |
| TBD | Solution Architect | | |
| TBD | QA Lead | | |
| TBD | Security Architect | | |
| TBD | DevOps Lead | | |

---

## 1. Overview

### 1.1 Purpose

This Non-Functional Requirements (NFR) Specification document defines the quality attributes, system constraints, and operational requirements for the EDUTrack platform. This document complements the Business Requirements Document (BRD), Product Requirements Document (PRD), and Software Requirements Specification (SRS) by specifying measurable, testable criteria for system quality attributes including performance, security, reliability, scalability, usability, and compliance.

**Intended Use:**
- Guide architectural and design decisions
- Define acceptance criteria for non-functional testing
- Establish service level objectives (SLOs) and agreements (SLAs)
- Inform infrastructure sizing and capacity planning
- Define operational monitoring and alerting thresholds
- Validate compliance with regulatory and security standards

### 1.2 Scope

This NFR specification covers the complete EDUTrack platform including:
- Web application (learner interface, admin console, dashboards)
- Backend APIs and microservices
- AI/ML components (Azure OpenAI integration, content generation)
- Data storage and processing (Azure SQL, Cosmos DB, Blob Storage)
- Integration services (SharePoint, Confluence, GitHub, Microsoft Learn)
- Authentication and authorization services
- Monitoring, logging, and observability infrastructure

**Geographic Scope:**
- Primary deployment: Corporate Azure tenant (East US, West Europe regions)
- User base: 10,000 employees globally
- Data residency: Within corporate Azure tenant per enterprise policy

### 1.3 Intended Audience

- **Solution Architects:** Architecture decisions and technology selection
- **Engineering Teams:** Implementation guidance and acceptance criteria
- **QA/Test Engineers:** Test planning, performance testing, security testing
- **DevOps/SRE:** Infrastructure provisioning, monitoring, capacity planning
- **Security Team:** Security controls validation and compliance verification
- **Compliance Officers:** Regulatory compliance and audit trail validation
- **Operations Team:** Production support and incident management
- **Product Owners:** Trade-off decisions and priority setting

### 1.4 Related Artefacts & Inputs

| Artefact | Location | Relevance |
|----------|----------|-----------|
| BRD | `docs/requirements/BRD.md` | Business objectives, KPIs, constraints, assumptions |
| PRD | `docs/requirements/PRD.md` | Product features, user journeys, personas |
| SRS | ` templates/SRS.md` | Functional requirements, interfaces, data models |
| RTM | ` templates/RTM.md` | Requirements traceability and coverage |
| HLD / LLD | `docs/design/` | Architecture decisions & component design |
| Business Case | `docs/inception/business-case.md` | ROI, financial justification |
| Stakeholder Register | `docs/inception/stakeholder-register.md` | Stakeholder expectations |

### 1.5 Quality Attribute Taxonomy

This NFR specification follows the **ISO/IEC 25010** Software Product Quality model, extended with OWASP Application Security Verification Standard (ASVS) and NIST Cybersecurity Framework principles.

**Quality Attributes Covered:**
1. **Security** - Authentication, authorization, data protection, API security
2. **Performance Efficiency** - Response time, throughput, resource utilization
3. **Reliability** - Availability, fault tolerance, recoverability
4. **Scalability** - Horizontal/vertical scaling, elasticity
5. **Usability** - Accessibility, learnability, user experience
6. **Maintainability** - Code quality, modularity, testability
7. **Portability** - Platform independence, cloud compatibility
8. **Compliance** - Regulatory, legal, audit requirements
9. **Observability** - Monitoring, logging, tracing, alerting
10. **Operability** - Deployment, backup/restore, disaster recovery

**Prioritisation Scheme (MoSCoW):**
- **Critical:** Must be met for go-live; regulatory/security requirement
- **High:** Significant business impact; user experience dependency
- **Medium:** Important but can be optimized post-launch
- **Low:** Nice-to-have; can be deferred to future releases

### 1.6 Compliance & Standards Baseline

EDUTrack must comply with the following regulatory, industry, and enterprise standards:

| Standard / Regulation | Scope | Applicability | Validation Method |
|----------------------|-------|---------------|-------------------|
| **GDPR (General Data Protection Regulation)** | Data privacy, right to erasure, consent | European employees (est. 2,000 users) | Privacy impact assessment, audit |
| **ISO 27001** | Information security management | Enterprise certification requirement | Annual certification audit |
| **OWASP ASVS Level 2** | Application security verification | Web application security baseline | Security testing, code review |
| **WCAG 2.1 Level AA** | Web accessibility | All user-facing interfaces | Accessibility audit, automated testing |
| **SOC 2 Type II** | Security, availability, confidentiality | Enterprise compliance | Annual SOC 2 audit |
| **Azure Well-Architected Framework** | Cloud architecture best practices | Azure deployment | Architecture review |
| **Enterprise Data Governance Policy** | Data classification, retention, residency | All corporate systems | Compliance review |

---

## 2. Governance & Measurement

### 2.1 Prioritisation & Ownership

| NFR Category | Primary Owner | Secondary Owner | Priority Guidance | Escalation Path |
|--------------|---------------|-----------------|-------------------|-----------------|
| Security | Security Architect | CISO | Critical - all security NFRs must be met | CISO → CTO |
| Performance | Solution Architect | DevOps Lead | High - targets based on user research | Product Owner → CTO |
| Availability | DevOps Lead | Operations Manager | Critical - 99.9% uptime required | Operations Manager → CTO |
| Scalability | Solution Architect | DevOps Lead | High - must support 10,000 users | Solution Architect → CTO |
| Usability | UX Lead | Product Owner | High - impacts adoption targets | Product Owner → CLO |
| Compliance | Compliance Officer | Legal Counsel | Critical - regulatory requirement | Compliance Officer → General Counsel |
| Observability | DevOps Lead | SRE Team | High - enables operational excellence | DevOps Lead → CTO |

### 2.2 Validation Strategy

**Testing Approach:**
- **Security Testing:** OWASP ZAP automated scans, manual penetration testing, dependency scanning
- **Performance Testing:** JMeter/k6 load tests, Azure Load Testing, synthetic monitoring
- **Accessibility Testing:** axe DevTools, WAVE, manual WCAG 2.1 validation
- **Compliance Testing:** Audit log validation, data residency verification, policy compliance checks
- **Integration Testing:** API contract testing, end-to-end workflow validation
- **Chaos Engineering:** Fault injection, failover testing, disaster recovery drills

**CI/CD Integration:**
- Security scans on every pull request (SAST, dependency check)
- Performance regression tests on staging environment
- Accessibility checks as part of UI test suite
- Compliance validation before production deployment

### 2.3 Monitoring & Reporting Framework

**Operational Metrics:**
- **Azure Application Insights:** Application performance monitoring, distributed tracing, user analytics
- **Azure Monitor:** Infrastructure metrics, resource utilization, alerts
- **Log Analytics:** Centralized logging, query-based analysis, compliance reporting
- **Power BI Dashboards:** Executive KPIs, SLA compliance, cost tracking

**Reporting Cadence:**
- **Daily:** Automated availability, performance, security alerts
- **Weekly:** SLO compliance summary, incident report
- **Monthly:** NFR compliance dashboard review with stakeholders
- **Quarterly:** Comprehensive NFR audit, capacity planning review

---

## 3. NFR Catalogue

### 3.1 Security

#### 3.1.1 Identity & Access Management

| ID | Requirement | Rationale | Metric / Target | Priority | Validation / Evidence |
|----|-------------|-----------|-----------------|----------|----------------------|
| SEC-IAM-001 | All user authentication must use Azure AD (Entra ID) single sign-on (SSO) with multi-factor authentication (MFA) support | Leverage existing enterprise identity; reduce credential sprawl | 100% of authentication via Azure AD SSO | Critical | Azure AD integration test, SSO login verification |
| SEC-IAM-002 | Role-based access control (RBAC) with minimum 4 roles: Admin, Content Reviewer, Manager, Learner | Principle of least privilege; segregation of duties | 100% of users assigned appropriate roles | Critical | Access control testing, role validation |
| SEC-IAM-003 | Admin actions require additional authentication or approval workflow | Prevent unauthorized privilege escalation | 100% of admin actions logged and auditable | Critical | Audit log review, admin action validation |
| SEC-IAM-004 | Access tokens must expire within 1 hour with automatic refresh capability | Reduce risk of token compromise | Token lifetime ≤ 60 minutes | High | Token expiration testing |
| SEC-IAM-005 | Failed login attempts must be logged and trigger account lockout after 5 consecutive failures | Prevent brute force attacks | Account lockout after 5 failed attempts within 15 min | High | Brute force testing, lockout validation |
| SEC-IAM-006 | Session management with automatic logout after 30 minutes of inactivity | Prevent unauthorized access from unattended sessions | Auto-logout after 30 min inactivity | Medium | Session timeout testing |

#### 3.1.2 Data Security & Privacy

| ID | Requirement | Data Classification | Metric / Target | Priority | Validation |
|----|-------------|---------------------|-----------------|----------|------------|
| SEC-DATA-001 | All data at rest must be encrypted using Azure Storage Service Encryption (SSE) with AES-256 | Protect confidential training content and PII | 100% of data encrypted at rest | Critical | Encryption configuration audit |
| SEC-DATA-002 | All data in transit must be encrypted using TLS 1.2 or higher | Prevent man-in-the-middle attacks | 100% HTTPS; no HTTP allowed | Critical | SSL/TLS scan, protocol verification |
| SEC-DATA-003 | Personally Identifiable Information (PII) must be detected and filtered before sending to Azure OpenAI | Prevent PII leakage to AI models | Zero PII leakage incidents | Critical | PII detection testing, AI prompt audit |
| SEC-DATA-004 | User passwords must never be stored; rely on Azure AD authentication only | Eliminate password storage risk | Zero password storage | Critical | Code review, data model audit |
| SEC-DATA-005 | Sensitive data (training records, assessment scores) must be classified as "Confidential - Internal" | Proper data handling and access controls | 100% of sensitive data properly classified | High | Data classification review |
| SEC-DATA-006 | GDPR right to erasure must be supported with complete data deletion within 30 days of request | GDPR Article 17 compliance | Data deletion within 30 days of request | Critical | GDPR compliance testing |
| SEC-DATA-007 | Database encryption at column level for sensitive fields (e.g., SSN if collected, assessment scores) | Additional protection for high-sensitivity data | 100% of PII fields encrypted | High | Database encryption verification |
| SEC-DATA-008 | Data residency must be within corporate Azure tenant with no cross-region replication to non-approved regions | Compliance with data sovereignty requirements | 100% data in approved regions (East US, West Europe) | Critical | Azure region configuration audit |

#### 3.1.3 Application & API Security

| ID | Requirement | Threat Reference | Control | Priority | Validation |
|----|-------------|------------------|---------|----------|------------|
| SEC-APP-001 | All user inputs must be validated and sanitized to prevent injection attacks (SQL, XSS, command injection) | OWASP A03:2021 Injection | Input validation, parameterized queries, output encoding | Critical | SAST, DAST, penetration testing |
| SEC-APP-002 | Cross-Site Request Forgery (CSRF) protection on all state-changing operations | OWASP A01:2021 Broken Access Control | Anti-CSRF tokens, SameSite cookie attribute | Critical | CSRF testing, security scan |
| SEC-APP-003 | Content Security Policy (CSP) headers to prevent XSS and clickjacking attacks | OWASP A03:2021 Injection | CSP headers with strict directives | High | Header analysis, XSS testing |
| SEC-APP-004 | API rate limiting to prevent denial-of-service (DoS) attacks | STRIDE: Denial of Service | 100 requests/minute per user; 1000/min per IP | High | Rate limiting testing, load testing |
| SEC-APP-005 | Secrets and API keys must be stored in Azure Key Vault, never in code or configuration files | OWASP A02:2021 Cryptographic Failures | Azure Key Vault integration | Critical | Code repository scan, configuration audit |
| SEC-APP-006 | Security headers (HSTS, X-Content-Type-Options, X-Frame-Options) must be present on all responses | Defense in depth | All security headers present | High | Header validation testing |
| SEC-APP-007 | Third-party dependencies must be scanned for known vulnerabilities weekly | OWASP A06:2021 Vulnerable Components | Zero high/critical CVEs in production | Critical | Dependency scanning (Dependabot, Snyk) |
| SEC-APP-008 | File uploads must be validated for type, size (<50MB), and scanned for malware | Prevent malicious file uploads | 100% of uploads validated and scanned | Critical | File upload testing, malware scan verification |

#### 3.1.4 AI Security & Governance

| ID | Requirement | Rationale | Metric / Target | Priority | Validation |
|----|-------------|-----------|-----------------|----------|------------|
| SEC-AI-001 | All prompts sent to Azure OpenAI must be logged with user ID, timestamp, and prompt content | Audit trail for AI usage | 100% of AI interactions logged | Critical | Audit log verification |
| SEC-AI-002 | AI-generated content must include hallucination detection scoring | Identify potentially inaccurate AI outputs | <10% false positive rate | High | Hallucination detection testing |
| SEC-AI-003 | PII detection must be applied to all user inputs before sending to Azure OpenAI | Prevent PII exposure to AI models | Zero PII sent to OpenAI | Critical | PII detection testing |
| SEC-AI-004 | AI-generated content must not be published to learners without SME approval | Human-in-the-loop validation | 100% of content reviewed before publication | Critical | Workflow testing, approval audit |
| SEC-AI-005 | Prompt injection attacks must be prevented through input filtering and validation | Prevent AI model manipulation | Zero successful prompt injection attacks | Critical | Prompt injection testing |
| SEC-AI-006 | Azure OpenAI API keys must be rotated every 90 days | Reduce risk of key compromise | API keys rotated quarterly | High | Key rotation audit |

### 3.2 Performance & Scalability

#### 3.2.1 Latency & Response Times

| ID | User Journey / API | P50 (median) | P95 | P99 | Priority | Measurement Point | Validation |
|----|-------------------|--------------|-----|-----|----------|-------------------|------------|
| PERF-LAT-001 | User login (Azure AD SSO) | <1s | <2s | <3s | High | Browser to complete authentication | Load testing, synthetic monitoring |
| PERF-LAT-002 | Home page / Dashboard load | <1s | <2s | <3s | High | Time to interactive (TTI) | Real user monitoring (RUM), Lighthouse |
| PERF-LAT-003 | Search query response | <200ms | <500ms | <1s | High | API response time | Load testing, APM |
| PERF-LAT-004 | Course content page load | <1s | <2s | <3s | High | Time to interactive (TTI) | RUM, performance testing |
| PERF-LAT-005 | AI content generation | <10s | <20s | <30s | High | API call to completion | Load testing, monitoring |
| PERF-LAT-006 | Assessment submission and scoring | <500ms | <1s | <2s | High | Submit to result display | Performance testing |
| PERF-LAT-007 | Analytics dashboard load (learner) | <1s | <2s | <3s | Medium | Page load time | Performance testing |
| PERF-LAT-008 | Analytics dashboard load (manager - team view) | <2s | <3s | <5s | Medium | Page load time | Performance testing |
| PERF-LAT-009 | Bulk user import (1,000 users) | N/A | <5 min | <10 min | Medium | API processing time | Batch processing test |
| PERF-LAT-010 | Document ingestion (SharePoint sync) | <30s | <60s | <120s | Medium | Per document processing | Integration testing |

#### 3.2.2 Throughput & Capacity

| ID | Metric | Target | Peak / Stress Target | Priority | Elasticity Strategy | Monitoring |
|----|--------|--------|----------------------|----------|---------------------|------------|
| PERF-TH-001 | Concurrent users supported | 10,000 | 15,000 (150% of baseline) | Critical | Auto-scaling based on CPU/memory | Application Insights, Azure Monitor |
| PERF-TH-002 | API requests per second (aggregate) | 1,000 RPS | 2,000 RPS | High | Horizontal scaling (App Service) | API Gateway metrics |
| PERF-TH-003 | AI content generation throughput | 10 concurrent generations | 20 concurrent generations | High | Queue-based processing with scaling | Queue depth monitoring |
| PERF-TH-004 | Search queries per second | 100 QPS | 200 QPS | High | Azure AI Search auto-scaling | Search service metrics |
| PERF-TH-005 | Database connections (Azure SQL) | 500 concurrent | 1,000 concurrent | High | Connection pooling, read replicas | SQL Database metrics |
| PERF-TH-006 | Document storage capacity | 1M documents | 2M documents | Medium | Blob Storage (virtually unlimited) | Storage metrics |
| PERF-TH-007 | Learning records (completion events) | 100,000 events/day | 200,000 events/day | Medium | Event-driven architecture, queues | Event Hub metrics |

#### 3.2.3 Resource Utilization

| ID | Resource | Target Utilization | Alert Threshold | Priority | Scaling Action | Monitoring |
|----|----------|-------------------|-----------------|----------|----------------|------------|
| PERF-RES-001 | App Service CPU | <70% average | >80% for 10 min | High | Scale out (add instances) | Azure Monitor |
| PERF-RES-002 | App Service Memory | <75% average | >85% for 10 min | High | Scale up (larger instance) | Azure Monitor |
| PERF-RES-003 | SQL Database DTU/vCore | <70% average | >80% for 15 min | High | Scale up database tier | SQL Database metrics |
| PERF-RES-004 | Cosmos DB RU/s | <80% provisioned | >90% for 5 min | High | Auto-scale RU/s | Cosmos DB metrics |
| PERF-RES-005 | Storage bandwidth | <50% limit | >75% for 10 min | Medium | Upgrade storage tier | Storage metrics |
| PERF-RES-006 | Azure OpenAI tokens/min | <80% quota | >90% of quota | Critical | Request quota increase | OpenAI usage metrics |

### 3.3 Availability, Reliability & Resilience

| ID | Requirement | Target (SLO/SLA) | Measurement Window | Priority | Failure Tolerance | Recovery Strategy |
|----|-------------|-------------------|--------------------|----------|-------------------|-------------------|
| AVAIL-001 | Platform availability (uptime) | 99.9% (43.8 min downtime/month) | Monthly | Critical | Single region failure | Multi-region deployment (East US, West Europe) |
| AVAIL-002 | Planned maintenance window | <4 hours/month | Monthly | High | N/A | Deploy during off-peak hours (weekends) |
| AVAIL-003 | Mean Time To Recover (MTTR) | <30 minutes | Per incident | High | Automated failover | Health checks, auto-restart, failover |
| AVAIL-004 | Mean Time Between Failures (MTBF) | >720 hours (30 days) | Quarterly | High | Redundancy | N+1 redundancy, health monitoring |
| AVAIL-005 | Azure AD authentication availability | 99.99% (dependency on Microsoft) | Monthly | Critical | Azure AD multi-region | Fallback error messaging |
| AVAIL-006 | Azure OpenAI service availability | 99.9% (dependency on Microsoft) | Monthly | High | Queue degraded requests | Retry logic, exponential backoff |
| AVAIL-007 | Database availability (Azure SQL) | 99.99% (Azure SLA) | Monthly | Critical | Zone-redundant deployment | Auto-failover, read replicas |
| AVAIL-008 | API endpoint availability | 99.95% | Monthly | High | Load balancer health checks | Auto-remove unhealthy instances |
| AVAIL-009 | Graceful degradation when AI service unavailable | Core platform remains functional | Real-time | High | Feature flags | Disable AI features, show maintenance message |
| AVAIL-010 | Data durability | 99.999999999% (11 nines) | Continuous | Critical | Geo-redundant storage | Azure GRS for blobs, automated backups |

### 3.4 Maintainability & Supportability

| ID | Requirement | Metric | Tooling / Process | Priority | Validation |
|----|-------------|--------|-------------------|----------|------------|
| MAINT-001 | Code quality standards with automated enforcement | Technical debt ratio <5% | SonarQube, code reviews | High | SonarQube analysis, PR reviews |
| MAINT-002 | Test coverage for critical business logic | >80% code coverage | Jest, pytest, xUnit | High | Coverage reports in CI/CD |
| MAINT-003 | API documentation with OpenAPI/Swagger specification | 100% of APIs documented | Swagger UI, API documentation | High | API documentation review |
| MAINT-004 | Deployment automation with zero manual steps | 100% automated deployments | Azure DevOps, GitHub Actions | Critical | Deployment audit |
| MAINT-005 | Database schema migrations with rollback capability | All schema changes versioned | Entity Framework Migrations, Flyway | High | Migration testing |
| MAINT-006 | Monitoring and alerting for all critical components | 100% of critical services monitored | Azure Monitor, Application Insights | Critical | Alert configuration audit |
| MAINT-007 | Incident runbooks for common failure scenarios | Runbooks for P0/P1 incidents | Confluence, Azure DevOps Wiki | High | Runbook review, DR drills |
| MAINT-008 | Modular architecture with clear separation of concerns | Low coupling, high cohesion | Microservices/modular monolith | High | Architecture review |
| MAINT-009 | Dependency updates with automated vulnerability scanning | Dependencies updated monthly | Dependabot, Snyk | High | Dependency audit |
| MAINT-010 | Configuration management with environment separation | Dev, Test, Staging, Prod environments | Azure App Configuration | High | Environment audit |

### 3.5 Observability & Operability

| ID | Requirement | Signal Type | Threshold / Target | Priority | Owner | Integration |
|----|-------------|-------------|-------------------|----------|-------|-------------|
| OBS-001 | Application performance monitoring (APM) for all API calls | Metrics, Traces | 100% of API calls traced | Critical | DevOps Lead | Application Insights |
| OBS-002 | Centralized logging with structured log format (JSON) | Logs | 100% of application logs centralized | Critical | DevOps Lead | Log Analytics |
| OBS-003 | Distributed tracing across microservices | Traces | 100% of requests traced end-to-end | High | DevOps Lead | Application Insights |
| OBS-004 | Real User Monitoring (RUM) for client-side performance | Metrics | 100% of page loads tracked | High | DevOps Lead | Application Insights |
| OBS-005 | Custom business metrics (content generated, paths completed, assessments taken) | Metrics | Real-time business KPIs | High | Product Owner | Application Insights, Power BI |
| OBS-006 | Error tracking with automatic grouping and alerting | Logs, Metrics | All errors logged and classified | Critical | DevOps Lead | Application Insights |
| OBS-007 | Infrastructure metrics (CPU, memory, disk, network) | Metrics | All infrastructure monitored | Critical | DevOps Lead | Azure Monitor |
| OBS-008 | Alerting for SLO violations with escalation | Alerts | Alerts within 5 min of threshold breach | Critical | DevOps Lead | Azure Monitor Alerts |
| OBS-009 | Log retention for compliance (7 years for training records) | Logs | 7-year retention for audit logs | Critical | Compliance Officer | Log Analytics Archive |
| OBS-010 | Synthetic monitoring for critical user journeys | Metrics | Synthetic tests every 5 min | High | DevOps Lead | Application Insights Availability Tests |

### 3.6 Usability & Accessibility

| ID | Requirement | Standard / Criterion | Target | Priority | Validation |
|----|-------------|----------------------|--------|----------|------------|
| ACCESS-001 | Web Content Accessibility Guidelines (WCAG) 2.1 Level AA compliance | WCAG 2.1 AA | 100% of user-facing pages compliant | Critical | axe DevTools, WAVE, manual audit |
| ACCESS-002 | Keyboard navigation for all interactive elements | WCAG 2.1 Guideline 2.1 | 100% keyboard accessible | Critical | Keyboard navigation testing |
| ACCESS-003 | Screen reader compatibility (JAWS, NVDA, VoiceOver) | WCAG 2.1 Guideline 1.3 | All content readable by screen readers | Critical | Screen reader testing |
| ACCESS-004 | Color contrast ratio of at least 4.5:1 for normal text, 3:1 for large text | WCAG 2.1 Guideline 1.4.3 | 100% of text meets contrast ratios | High | Automated contrast checker |
| ACCESS-005 | Alternative text for all images and non-text content | WCAG 2.1 Guideline 1.1.1 | 100% of images have alt text | High | Alt text audit |
| ACCESS-006 | Responsive design supporting viewport sizes from 320px to 2560px | Mobile-first design | All features functional on all screen sizes | High | Responsive design testing |
| ACCESS-007 | Page load time <3 seconds on standard corporate network | User experience | P95 page load <3s | High | Real User Monitoring |
| ACCESS-008 | Support for modern browsers (Chrome, Edge, Safari, Firefox - latest 2 versions) | Cross-browser compatibility | 100% feature parity across browsers | High | Cross-browser testing |
| ACCESS-009 | Error messages must be clear, actionable, and user-friendly | Usability heuristics | User comprehension >90% | Medium | Usability testing |
| ACCESS-010 | Consistent UI patterns and navigation across all pages | Design system adherence | 100% adherence to design system | Medium | Design review |

### 3.7 Compliance, Audit & Regulatory

| ID | Requirement | Regulation / Standard | Evidence Required | Priority | Owner | Audit Frequency |
|----|-------------|-----------------------|-------------------|----------|-------|-----------------|
| COMP-001 | GDPR compliance for European employees (data minimization, consent, right to erasure) | GDPR Articles 5, 7, 17 | Privacy impact assessment, data flow diagrams | Critical | Compliance Officer | Annual |
| COMP-002 | ISO 27001 information security controls | ISO 27001:2013 Annex A | Control implementation evidence | Critical | CISO | Annual |
| COMP-003 | Complete audit trail for all user actions (creation, modification, deletion of training records) | Enterprise policy | Audit logs with 7-year retention | Critical | Compliance Officer | Quarterly |
| COMP-004 | Audit trail for all AI interactions (prompts, outputs, approvals) | AI governance framework | AI interaction logs with full context | Critical | AI Governance Lead | Quarterly |
| COMP-005 | Training records retention for 7 years per enterprise policy | Enterprise data retention policy | Archived records with retrieval capability | Critical | L&D Manager | Annual |
| COMP-006 | Data residency within corporate Azure tenant (no data egress to public cloud) | Enterprise data governance | Azure region configuration, data flow audit | Critical | Solution Architect | Semi-annual |
| COMP-007 | Role-based access control audit trail | SOC 2 Control CC6.1 | Access control logs, role change audit | Critical | Security Team | Quarterly |
| COMP-008 | Encryption at rest and in transit compliance | ISO 27001 A.10.1.1, A.10.1.2 | Encryption configuration evidence | Critical | Security Team | Semi-annual |
| COMP-009 | Security vulnerability management with remediation SLA (Critical: 7 days, High: 30 days) | SOC 2 Control CC7.1 | Vulnerability scan reports, remediation tracking | Critical | Security Team | Monthly |
| COMP-010 | Business continuity and disaster recovery plan testing | ISO 22301 | DR test results, RTO/RPO validation | High | Operations Manager | Annual |

### 3.8 Disaster Recovery & Business Continuity

| ID | Requirement | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) | Priority | Failover Strategy | Validation |
|----|-------------|-------------------------------|--------------------------------|----------|-------------------|------------|
| DR-001 | Application tier disaster recovery | <1 hour | <15 minutes | Critical | Multi-region deployment with Traffic Manager | DR drill quarterly |
| DR-002 | Database disaster recovery (Azure SQL) | <30 minutes | <5 minutes | Critical | Active geo-replication with auto-failover | Failover testing quarterly |
| DR-003 | Blob storage disaster recovery | <1 hour | <15 minutes | High | Geo-redundant storage (GRS) with read access | DR drill semi-annual |
| DR-004 | Configuration and secrets recovery | <30 minutes | <1 hour | High | Azure Key Vault geo-replication | Configuration restore testing |
| DR-005 | Backup frequency for database | Daily full, hourly incremental | <1 hour | Critical | Automated Azure SQL backups | Backup verification daily |
| DR-006 | Backup retention period | 30 days short-term, 7 years long-term archive | N/A | Critical | Azure Backup with long-term retention | Retention policy audit |
| DR-007 | Point-in-time restore capability | Restore to any point within 7 days | N/A | High | Azure SQL point-in-time restore | Restore testing monthly |
| DR-008 | Disaster recovery runbook with step-by-step procedures | N/A | N/A | High | Documented runbooks, automated scripts | Runbook review quarterly |
| DR-009 | Disaster recovery communication plan | <15 minutes to notify stakeholders | N/A | High | Automated alerting, escalation matrix | Communication drill semi-annual |
| DR-010 | Data corruption recovery (accidental deletion, malicious activity) | <4 hours | <1 hour | High | Soft delete, backup restore | Recovery testing quarterly |

### 3.9 Additional Quality Attributes

#### 3.9.1 Portability & Platform Independence

| ID | Attribute | Requirement | Metric | Priority | Validation |
|----|-----------|-------------|--------|----------|------------|
| PORT-001 | Cloud portability | Architecture should minimize Azure-specific dependencies where possible | <30% of code tightly coupled to Azure | Medium | Architecture review |
| PORT-002 | Browser portability | Support Chrome, Edge, Safari, Firefox (latest 2 versions) | 100% feature parity | High | Cross-browser testing |
| PORT-003 | Data export capability | Users can export their learning data in standard formats (CSV, JSON) | 100% of user data exportable | High | Export functionality testing |
| PORT-004 | API versioning | APIs must support versioning to enable backward compatibility | API version strategy documented | High | API documentation review |

#### 3.9.2 Sustainability & Cost Optimization

| ID | Attribute | Requirement | Metric | Priority | Validation |
|----|-----------|-------------|--------|----------|------------|
| COST-001 | Azure cost monitoring | Real-time cost tracking with budget alerts | Alerts when >90% of monthly budget | High | Cost management review |
| COST-002 | Resource rightsizing | Infrastructure sized appropriately for workload | <20% over-provisioned resources | Medium | Resource utilization analysis |
| COST-003 | Auto-scaling policies | Scale down during off-peak hours (nights, weekends) | 30% cost reduction during off-peak | Medium | Scaling policy review |
| COST-004 | Azure OpenAI cost optimization | Token usage tracking and optimization | <$120K/year token costs | High | Token usage monitoring |

#### 3.9.3 Internationalization (Future)

| ID | Attribute | Requirement | Metric | Priority | Validation |
|----|-----------|-------------|--------|----------|------------|
| I18N-001 | Internationalization readiness | Code should be i18n-ready even if English-only in Phase 1 | String externalization >90% | Low | Code review |
| I18N-002 | UTF-8 character encoding | Support for international characters | 100% UTF-8 encoding | Medium | Character encoding testing |
| I18N-003 | Date/time localization | Display dates and times in user's local timezone | User timezone support | Low | Timezone testing |

---

## 4. Traceability Matrix Summary

This section provides a high-level summary of NFR traceability to business requirements, functional requirements, and test coverage. For detailed traceability, refer to `docs/requirements/RTM.md`.

| NFR Category | Count | Traced to BRD | Traced to PRD | Test Coverage | Status |
|--------------|-------|---------------|---------------|---------------|--------|
| Security (SEC) | 30 | BRD-OBJ-12, BRD-FR-037 to BRD-FR-043 | PRD-OBJ-04, F-021 to F-024 | Security test plan | ✅ Complete |
| Performance (PERF) | 23 | BRD-OBJ-01, BRD-OBJ-06, BRD-FR-045 to BRD-FR-050 | PRD-OBJ-03, F-001, F-002, F-012 | Performance test plan | ✅ Complete |
| Availability (AVAIL) | 10 | BRD-FR-045 (99.9% uptime) | F-001 to F-024 (all features) | Availability testing | ✅ Complete |
| Maintainability (MAINT) | 10 | BRD-OBJ-02 (enable scaling) | F-018 to F-020 (platform mgmt) | Code quality gates | ✅ Complete |
| Observability (OBS) | 10 | BRD-FR-038 (audit logging) | F-021 (audit logging) | Monitoring validation | ✅ Complete |
| Accessibility (ACCESS) | 10 | BRD-FR-023 (responsive design) | F-009 (course player) | Accessibility audit | ✅ Complete |
| Compliance (COMP) | 10 | BRD-OBJ-07, BRD-FR-052 to BRD-FR-056 | PRD-OBJ-04, F-021 | Compliance testing | ✅ Complete |
| DR/BC (DR) | 10 | BRD-FR-057 (data protection) | All features (continuity) | DR drills | ✅ Complete |
| Portability (PORT) | 4 | BRD-FR-023 (browser support) | F-009 (responsive design) | Cross-browser testing | ✅ Complete |
| Cost (COST) | 4 | BRD Budget ($1.07M), BRD-OBJ-08 | Cost efficiency | Cost monitoring | ✅ Complete |
| **Total** | **121 NFRs** | **100% traced** | **100% traced** | **Test plans defined** | **✅ Baseline** |

**Traceability Notes:**
- All NFRs trace to at least one business requirement in BRD
- All NFRs are testable with defined validation methods
- Test coverage includes automated testing where feasible
- Manual validation for compliance and accessibility
- Quarterly NFR compliance review process established

---

## 5. Risks, Issues & Technical Debt

| ID | Description | Impacted NFR | Probability | Impact | Mitigation / Action | Owner | Target Date |
|----|-------------|--------------|-------------|--------|---------------------|-------|-------------|
| RISK-001 | Azure OpenAI service outage or quota limitations impact content generation | PERF-LAT-005, AVAIL-006 | Medium | High | Queue-based architecture with retry logic; request quota increase proactively | Solution Architect | Q1 2026 |
| RISK-002 | GDPR compliance gaps due to incomplete data flow mapping | COMP-001 | Low | Critical | Conduct privacy impact assessment during design phase; engage DPO early | Compliance Officer | Q4 2025 |
| RISK-003 | Performance degradation at scale (10,000 concurrent users) | PERF-TH-001 | Medium | High | Comprehensive load testing in staging; phased rollout starting with 200 pilot users | DevOps Lead | Q2 2026 |
| RISK-004 | Accessibility compliance gaps delaying launch | ACCESS-001 to ACCESS-010 | Low | High | Accessibility review in every sprint; budget for accessibility audit | UX Lead | Q1 2026 |
| RISK-005 | Multi-region failover complexity and cost | DR-001 | Medium | Medium | Start with single region + backup; add active-active in Phase 2 if budget allows | DevOps Lead | Q3 2026 |
| RISK-006 | Third-party API rate limits (SharePoint, Confluence, GitHub) | PERF-TH-010 | Medium | Medium | Implement backoff and retry; cache API responses; negotiate higher limits | Integration Lead | Q1 2026 |
| RISK-007 | Security vulnerabilities in third-party dependencies | SEC-APP-007 | Medium | Critical | Automated dependency scanning in CI/CD; monthly vulnerability reviews | Security Team | Ongoing |
| RISK-008 | Cost overruns from Azure OpenAI token usage | COST-004 | High | Medium | Token usage monitoring with alerts at 80% budget; optimize prompts for efficiency | Product Owner | Ongoing |
| RISK-009 | Insufficient monitoring coverage leading to undetected issues | OBS-001 to OBS-010 | Low | High | Comprehensive monitoring implementation in Phase 1; synthetic monitoring for critical paths | DevOps Lead | Q1 2026 |
| RISK-010 | DR/BC testing reveals gaps in recovery procedures | DR-001 to DR-010 | Medium | High | Conduct tabletop DR exercise before go-live; quarterly DR drills post-launch | Operations Manager | Q2 2026 |

**Technical Debt:**
- **DEBT-001:** Deferred multi-language support (i18n infrastructure) - Impacts future scalability (Priority: Low, Target: Phase 3)
- **DEBT-002:** Deferred advanced analytics (predictive modeling) - Limits business insights (Priority: Medium, Target: Phase 3)
- **DEBT-003:** Basic keyword search in MVP vs. semantic search - Reduced user experience (Priority: High, Target: Phase 2)

---

## 6. Assumptions & Dependencies

| ID | Assumption / Dependency | Category | Owner | Validation Method | Due Date |
|----|-------------------------|----------|-------|-------------------|----------|
| ASM-001 | Azure OpenAI service remains available with <50% price fluctuation | Technology | CTO | Monitor Azure pricing; contractual agreement | Ongoing |
| ASM-002 | Corporate network infrastructure supports 10,000 concurrent HTTPS connections | Infrastructure | IT Operations | Network capacity testing | Q1 2026 |
| ASM-003 | Modern browsers (Chrome, Edge, Safari, Firefox - latest 2 versions) support required features | Technology | Engineering Lead | Browser compatibility testing | Q1 2026 |
| ASM-004 | Azure regional availability (East US, West Europe) remains consistent | Infrastructure | CTO | Azure service health monitoring | Ongoing |
| ASM-005 | Security and compliance teams can review deliverables within 2-week SLA | Process | CISO, Compliance | SLA agreement and tracking | Q4 2025 |
| DEP-001 | Azure OpenAI quota allocation approved | Technology | CTO | Quota request submitted and approved | Week 2 |
| DEP-002 | Azure subscription with sufficient credits provisioned | Budget | Finance/CTO | Subscription provisioning | Week 1 |
| DEP-003 | Security architecture review and approval | Security | CISO | Security review board approval | Week 8 |
| DEP-004 | AI governance framework approval | Compliance | Compliance Officer | Governance board approval | Week 6 |
| DEP-005 | SharePoint API permissions granted | Integration | IT Operations | API access testing | Week 3 |
| DEP-006 | Azure AD app registration for SSO | Security | Security Team | SSO testing | Week 3 |
| DEP-007 | Network capacity verification for 10,000 users | Infrastructure | IT Operations | Load testing in pre-prod | Month 3 |

---

## 7. Review & Change Management

### 7.1 Review Cadence

**NFR Review Schedule:**
- **Sprint Reviews (Bi-weekly):** Review NFR compliance for features delivered in sprint
- **Monthly NFR Dashboard Review:** Solution Architect, DevOps Lead, Security Team review SLO compliance, security posture, performance metrics
- **Quarterly Comprehensive Audit:** All stakeholders review complete NFR compliance, update priorities, address technical debt
- **Annual Certification Review:** Compliance Officer leads review for ISO 27001, SOC 2, GDPR compliance

**Required Participants:**
- Solution Architect (chair)
- DevOps Lead
- Security Architect
- QA Lead
- Compliance Officer
- Product Owner
- Engineering Lead

### 7.2 Change Log

| Version | Date | Change Description | Author | Approval |
|---------|------|--------------------|--------|----------|
| 0.1 | 2025-11-20 | Initial draft based on BRD and PRD requirements | Solution Architect | - |
| 1.0 | 2025-11-20 | Baseline version with all NFR categories | Solution Architect | Product Owner, QA Lead, Security Architect |

### 7.3 Exception Handling

**NFR Exception Process:**
1. **Request Submission:** Engineering Lead or Product Owner submits exception request with business justification, risk assessment, and remediation plan
2. **Risk Assessment:** Security Architect and Solution Architect assess technical and security risk
3. **Approval Authority:**
   - **Low Risk:** Solution Architect approval
   - **Medium Risk:** Product Owner + CISO approval
   - **High/Critical Risk:** Executive Sponsor (CTO) approval
4. **Time-Bound:** All exceptions must have expiry date (max 90 days)
5. **Tracking:** Exceptions tracked in RAID log with monthly review
6. **Remediation:** Remediation plan required for all exceptions; progress tracked in sprint backlogs

**Example Exception Scenarios:**
- Temporary relaxation of performance targets during pilot (acceptable if <200 users)
- Delayed DR implementation if single-region deployment acceptable for MVP
- Deferred accessibility compliance for admin-only features (not user-facing)

---

## 8. Appendices

### Appendix A – Glossary & Acronyms

| Term | Definition |
|------|------------|
| **API** | Application Programming Interface |
| **ASVS** | Application Security Verification Standard (OWASP) |
| **CSRF** | Cross-Site Request Forgery |
| **CSP** | Content Security Policy |
| **GDPR** | General Data Protection Regulation (EU) |
| **ISO 27001** | International Standard for Information Security Management |
| **MAU** | Monthly Active Users |
| **MTBF** | Mean Time Between Failures |
| **MTTR** | Mean Time To Recover |
| **NFR** | Non-Functional Requirement |
| **OWASP** | Open Web Application Security Project |
| **PII** | Personally Identifiable Information |
| **RBAC** | Role-Based Access Control |
| **RPO** | Recovery Point Objective (max acceptable data loss) |
| **RTO** | Recovery Time Objective (max acceptable downtime) |
| **RUM** | Real User Monitoring |
| **SLA** | Service Level Agreement |
| **SLO** | Service Level Objective |
| **SME** | Subject Matter Expert |
| **SOC 2** | Service Organization Control 2 (security audit framework) |
| **SSO** | Single Sign-On |
| **TLS** | Transport Layer Security |
| **WCAG** | Web Content Accessibility Guidelines |
| **XSS** | Cross-Site Scripting |

### Appendix B – Tooling & Automation

| Category | Tool | Purpose | Integration Point |
|----------|------|---------|------------------|
| **Security Testing** | OWASP ZAP | Dynamic application security testing | CI/CD pipeline |
| **Security Testing** | Snyk / Dependabot | Dependency vulnerability scanning | GitHub, CI/CD |
| **Performance Testing** | Apache JMeter / k6 | Load and performance testing | Staging environment |
| **Performance Testing** | Azure Load Testing | Cloud-based load testing | Azure DevOps |
| **Accessibility Testing** | axe DevTools | Automated accessibility scanning | CI/CD, browser extension |
| **Accessibility Testing** | WAVE | Web accessibility evaluation | Manual testing |
| **Monitoring** | Azure Application Insights | APM, RUM, distributed tracing | Application runtime |
| **Monitoring** | Azure Monitor | Infrastructure monitoring, alerts | Azure resources |
| **Logging** | Azure Log Analytics | Centralized logging, log queries | Application runtime |
| **Code Quality** | SonarQube | Static code analysis, code coverage | CI/CD pipeline |
| **Cost Management** | Azure Cost Management | Cost tracking, budget alerts | Azure portal |
| **Backup** | Azure Backup | Database and configuration backup | Azure SQL, Key Vault |

### Appendix C – Reference Checklists

#### Security Review Checklist
- [ ] All user inputs validated and sanitized
- [ ] Authentication via Azure AD SSO only
- [ ] RBAC implemented with least privilege
- [ ] All data encrypted at rest and in transit
- [ ] PII detection and filtering before AI processing
- [ ] Secrets stored in Azure Key Vault
- [ ] Security headers present on all responses
- [ ] CSRF protection on state-changing operations
- [ ] Third-party dependencies scanned for vulnerabilities
- [ ] Security audit logs enabled and retained for 7 years

#### Performance Review Checklist
- [ ] Page load time <3 seconds (P95)
- [ ] API response time meets SLO targets
- [ ] AI content generation <20 seconds
- [ ] Search query response <500ms (P95)
- [ ] Support for 10,000 concurrent users validated
- [ ] Auto-scaling policies configured and tested
- [ ] Resource utilization within targets (<70% CPU, <75% memory)
- [ ] Database queries optimized with indexes
- [ ] Caching strategy implemented
- [ ] CDN configured for static assets

#### Accessibility Review Checklist
- [ ] WCAG 2.1 Level AA compliance validated
- [ ] Keyboard navigation works for all interactive elements
- [ ] Screen reader compatibility tested (JAWS, NVDA)
- [ ] Color contrast ratios meet requirements (4.5:1 / 3:1)
- [ ] All images have alternative text
- [ ] Form labels and error messages are clear
- [ ] Responsive design tested (320px to 2560px)
- [ ] Focus indicators visible for all interactive elements
- [ ] Page structure uses semantic HTML
- [ ] No content flashing >3 times per second

#### Compliance Review Checklist
- [ ] GDPR right to erasure implemented
- [ ] 7-year training record retention configured
- [ ] Complete audit trail for all critical actions
- [ ] AI interaction logs captured with full context
- [ ] Data residency within approved Azure regions
- [ ] Encryption at rest and in transit validated
- [ ] Access control audit logs enabled
- [ ] Security vulnerability SLA compliance (7/30 days)
- [ ] DR testing completed successfully
- [ ] Privacy impact assessment documented

---

## Quality Checklist

- [x] All NFRs have measurable targets and defined validation methods
- [x] Security requirements address authentication, authorization, data protection, and monitoring (aligned to OWASP / NIST)
- [x] Performance targets cover response times, throughput, capacity, and elasticity
- [x] Availability, resilience, and DR requirements include RTO/RPO and failover strategies
- [x] Accessibility requirements comply with WCAG 2.1 Level AA and testing approach is documented
- [x] Compliance obligations and audit evidence are explicitly defined with owners
- [x] RTM links functional requirements to NFRs and downstream validation artefacts
- [x] Operational monitoring, alerting, and support requirements are captured with clear ownership
- [x] Risks, assumptions, and dependencies are recorded with mitigation or validation plans
- [x] Review cadence, change control, and exception handling processes are documented
- [x] All NFRs traced to business requirements (BRD) and product requirements (PRD)
- [x] 100% of NFRs are testable (confirmed by defined validation methods)
- [x] Prioritization scheme (MoSCoW) applied consistently
- [x] Ownership assigned for all NFR categories
- [x] Standards and compliance frameworks identified (GDPR, ISO 27001, WCAG 2.1, SOC 2, OWASP ASVS)

---

**Document Status:** ✅ Baselined  
**Last Updated:** 2025-11-20  
**Next Review:** 2026-01-20 (Monthly NFR Dashboard Review)
