# SBOM Strategy
## EDUTrack - Internal AI Learning & Training Platform

---

## Document Control
| Version | Date | Author | Reviewer | Notes |
|---------|------|--------|----------|-------|
| 0.1     | 2025-11-21 | DevOps Lead | | Draft |
| 1.0     | 2025-11-21 | DevOps Lead | Security Architect, Compliance Officer, Engineering Lead | Baseline |

## Approvals
| Name | Role | Signature | Date |
|------|------|-----------|------|
| TBD | DevOps Lead | | |
| TBD | Security Architect | | |
| TBD | Compliance Officer | | |
| TBD | Engineering Lead | | |
| TBD | Legal Counsel | | |

---

## 1. Executive Summary

### 1.1 Purpose

This Software Bill of Materials (SBOM) Strategy defines the comprehensive approach for generating, validating, storing, and reporting software component inventory throughout the EDUTrack platform lifecycle. It ensures supply chain transparency, license compliance, vulnerability management, and regulatory alignment.

**Intended Audience:**
- DevOps Engineers: SBOM generation and automation
- Security Team: Vulnerability tracking and supply chain risk management
- Compliance Officers: License compliance and regulatory reporting
- Engineering Teams: Dependency management and security awareness
- Legal Counsel: License compliance and intellectual property protection
- Procurement Team: Vendor risk assessment and third-party software governance

### 1.2 Scope

This strategy covers:
- SBOM generation tooling and automation
- SBOM formats and standards (SPDX, CycloneDX)
- Integration with CI/CD pipeline
- Vulnerability correlation and tracking
- License compliance validation and reporting
- SBOM storage, versioning, and retrieval
- Attestation and provenance (SLSA framework)
- Supply chain security and transparency
- Regulatory compliance (Executive Order 14028, NTIA guidelines)

**Out of Scope:**
- Detailed vulnerability remediation procedures (covered in Security Operations)
- License negotiation and procurement (covered by Legal and Procurement)
- Third-party software evaluation (covered in Architecture Decision Records)

### 1.3 SBOM Strategy Principles

1. **Transparency:** Complete visibility into software components and dependencies
2. **Automation:** Automated SBOM generation on every build; no manual intervention
3. **Standardization:** Use industry-standard formats (SPDX, CycloneDX)
4. **Immutability:** SBOM artifacts are immutable; versioned with software releases
5. **Traceability:** Link SBOM to specific builds, commits, and releases
6. **Security-First:** Correlate SBOM with vulnerability databases (NVD, OSV)
7. **Compliance-Ready:** Support license compliance, regulatory audits, and supply chain transparency
8. **Provenance:** Cryptographic attestation of build integrity (SLSA provenance)

---

## 2. SBOM Standards & Formats

### 2.1 Supported SBOM Formats

**Primary Format:** **CycloneDX 1.5** (JSON)

**Rationale:**
- Modern, lightweight, security-focused SBOM standard
- Native vulnerability correlation (VEX support)
- Extensive tooling support (.NET, npm, Docker)
- Growing industry adoption (OWASP project)
- Comprehensive metadata (licenses, hashes, dependencies, external references)

**Secondary Format:** **SPDX 2.3** (JSON)

**Rationale:**
- ISO/IEC 5962:2021 standard
- Regulatory compliance (NTIA, Executive Order 14028)
- Legal use case focus (license compliance)
- Generated for long-term archival and regulatory reporting

### 2.2 SBOM Content Requirements

**Minimum Fields (NTIA Baseline):**
- Supplier name (component publisher)
- Component name (package name, library name)
- Version of the component (SemVer)
- Other unique identifiers (Package URL, CPE)
- Dependency relationships (component graph)
- Author of SBOM data (EDUTrack DevOps Team)
- Timestamp (ISO 8601 format)

**Enhanced Metadata (EDUTrack Requirements):**
- License (SPDX license identifier)
- Cryptographic hashes (SHA-256 for all components)
- Download location (repository URL)
- External references (documentation, issue tracker, security advisories)
- Known vulnerabilities (CVE IDs, severity scores)
- Build provenance (Git commit SHA, build timestamp, CI/CD pipeline ID)

**NFR Traceability:** COMP-LICENSE-001 (License compliance), SEC-APP-007 (Dependency tracking)

### 2.3 SBOM Granularity

**SBOM Scope by Artifact:**

| Artifact Type | SBOM Scope | Tool |
|---------------|------------|------|
| **Backend (.NET)** | All NuGet packages (direct + transitive dependencies) | CycloneDX .NET Tool |
| **Frontend (React)** | All npm packages (direct + transitive dependencies) | CycloneDX npm Tool |
| **Docker Images** | OS packages + application dependencies | Syft + CycloneDX export |
| **Infrastructure (Bicep)** | Bicep modules, Azure resource providers | Custom script (manual) |

**Dependency Depth:** Transitive dependencies included (full dependency tree)

**NFR Traceability:** COMP-SBOM-001 (SBOM generation for all artifacts)

---

## 3. SBOM Generation Tooling

### 3.1 Tool Selection

| Ecosystem | Tool | Version | Output Format | Integration |
|-----------|------|---------|---------------|-------------|
| **.NET (Backend)** | CycloneDX .NET Tool | Latest | CycloneDX 1.5 JSON | Azure Pipelines task |
| **npm (Frontend)** | CycloneDX npm Tool (`@cyclonedx/cyclonedx-npm`) | Latest | CycloneDX 1.5 JSON | Azure Pipelines task |
| **Docker** | Syft | Latest | CycloneDX 1.5 JSON | Azure Pipelines task |
| **SPDX Conversion** | CycloneDX CLI | Latest | SPDX 2.3 JSON | Post-processing step |
| **SBOM Merging** | CycloneDX CLI | Latest | Merged CycloneDX JSON | Aggregate backend + frontend + container |

**Tooling Validation:**
- Tools verified against CycloneDX/SPDX specification test suites
- Regular updates to support latest specification versions
- Community support and active development

**NFR Traceability:** MAINT-TOOL-001 (Approved tooling)

### 3.2 Installation & Configuration

**Azure Pipelines Integration:**

```yaml
# Install CycloneDX .NET Tool
- task: DotNetCoreCLI@2
  displayName: 'Install CycloneDX .NET Tool'
  inputs:
    command: 'custom'
    custom: 'tool'
    arguments: 'install --global CycloneDX'

# Install CycloneDX npm Tool
- task: Npm@1
  displayName: 'Install CycloneDX npm Tool'
  inputs:
    command: 'custom'
    customCommand: 'install -g @cyclonedx/cyclonedx-npm'

# Install Syft for Docker image scanning
- script: |
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
  displayName: 'Install Syft'
```

**Tool Configuration:**
- CycloneDX .NET: Default configuration (scan all projects in solution)
- CycloneDX npm: Default configuration (include dev dependencies: `--include-dev`)
- Syft: CycloneDX output format (`-o cyclonedx-json`)

---

## 4. SBOM Generation Workflow

### 4.1 CI/CD Pipeline Integration

**Trigger Points:**

| Pipeline Stage | SBOM Activity | Frequency |
|----------------|---------------|-----------|
| **Build (Backend)** | Generate SBOM for .NET solution | Every CI build |
| **Build (Frontend)** | Generate SBOM for React app | Every CI build |
| **Build (Docker)** | Generate SBOM for Docker image | Every image build |
| **Artifact Publish** | Merge SBOMs, attach to artifact | Every artifact publish |
| **Deployment** | Store SBOM reference in deployment metadata | Every deployment |
| **Compliance** | Generate SPDX format for archival | Weekly (scheduled) |

**NFR Traceability:** COMP-SBOM-001 (SBOM generation), MAINT-BUILD-001 (CI/CD integration)

### 4.2 SBOM Generation Steps

#### 4.2.1 Backend (.NET) SBOM

**Azure Pipelines Task:**

```yaml
- task: PowerShell@2
  displayName: 'Generate SBOM for .NET Solution'
  inputs:
    targetType: 'inline'
    script: |
      dotnet CycloneDX EDUTrack.sln -o ./sbom -f backend-sbom.json --json
      if ($LASTEXITCODE -ne 0) { throw "SBOM generation failed" }
```

**Output:**
- File: `backend-sbom.json` (CycloneDX 1.5)
- Location: Build artifact staging directory
- Metadata: Includes solution name, version, Git SHA, build timestamp

**Validation:**
- Validate JSON schema compliance
- Check minimum required fields (component name, version, licenses)
- Verify dependency count >0

**NFR Traceability:** COMP-SBOM-001

#### 4.2.2 Frontend (React) SBOM

**Azure Pipelines Task:**

```yaml
- script: |
    npx @cyclonedx/cyclonedx-npm --output-file ./sbom/frontend-sbom.json --output-format JSON
  displayName: 'Generate SBOM for React App'
```

**Output:**
- File: `frontend-sbom.json` (CycloneDX 1.5)
- Location: Build artifact staging directory
- Metadata: Includes package.json metadata, Git SHA, build timestamp

**Validation:**
- Validate JSON schema compliance
- Check minimum required fields
- Verify npm dependencies detected

**NFR Traceability:** COMP-SBOM-001

#### 4.2.3 Docker Image SBOM

**Azure Pipelines Task:**

```yaml
- script: |
    syft packages docker:edutrack-web:$(Build.BuildId) -o cyclonedx-json=./sbom/docker-sbom.json
  displayName: 'Generate SBOM for Docker Image'
```

**Output:**
- File: `docker-sbom.json` (CycloneDX 1.5)
- Location: Build artifact staging directory
- Metadata: Includes OS packages, application layers, image digest

**Validation:**
- Validate JSON schema compliance
- Verify both OS and application dependencies detected
- Check image digest matches built image

**NFR Traceability:** COMP-SBOM-001

#### 4.2.4 SBOM Merging & Aggregation

**Azure Pipelines Task:**

```yaml
- script: |
    cyclonedx merge --input-files ./sbom/backend-sbom.json ./sbom/frontend-sbom.json ./sbom/docker-sbom.json --output-file ./sbom/edutrack-sbom.json
  displayName: 'Merge SBOMs into Unified Artifact'
```

**Output:**
- File: `edutrack-sbom.json` (CycloneDX 1.5, merged)
- Location: Build artifact staging directory
- Metadata: Composite SBOM representing entire application stack

**NFR Traceability:** COMP-SBOM-002 (Unified SBOM per release)

### 4.3 SBOM Enrichment

**Post-Generation Processing:**

1. **Add Build Metadata:**
   - Git commit SHA
   - Build pipeline ID and run number
   - Build timestamp (ISO 8601)
   - Author (CI/CD service account)

2. **License Normalization:**
   - Map detected licenses to SPDX identifiers
   - Flag non-standard or proprietary licenses

3. **Vulnerability Correlation:**
   - Cross-reference components with NVD, GitHub Advisory, OSV
   - Embed known CVEs in SBOM (CycloneDX VEX extension)

4. **Cryptographic Hashing:**
   - Generate SHA-256 hash for each component (if not already present)
   - Generate SHA-256 hash of SBOM file itself

**NFR Traceability:** COMP-SBOM-003 (SBOM enrichment)

---

## 5. SBOM Storage & Versioning

### 5.1 Storage Architecture

**Primary Storage:** Azure Artifacts (NuGet feed for SBOM files)

**Storage Strategy:**

| Artifact Type | Storage Location | Retention Policy | Access Control |
|---------------|------------------|------------------|----------------|
| **Build SBOM** | Azure Artifacts (Universal Packages) | 90 days (non-release), indefinite (release) | DevOps team, Security team, Compliance team |
| **Release SBOM** | Azure Artifacts (Universal Packages) | Indefinite (tagged with release version) | Public read (internal employees), write (DevOps) |
| **SPDX Archive** | Azure Blob Storage (Compliance container) | 7 years (compliance requirement) | Compliance Officer, Legal, Auditors |
| **SBOM Attestation** | Azure Artifacts (alongside SBOM) | Same as SBOM | DevOps team, Security team |

**NFR Traceability:** COMP-SBOM-004 (SBOM storage and retention)

### 5.2 Versioning & Naming Conventions

**SBOM File Naming:**

Format: `{artifact-name}-{version}-sbom-{format}.{extension}`

Examples:
- `edutrack-backend-1.2.3-sbom-cyclonedx.json`
- `edutrack-frontend-1.2.3-sbom-cyclonedx.json`
- `edutrack-unified-1.2.3-sbom-cyclonedx.json`
- `edutrack-unified-1.2.3-sbom-spdx.json`

**Versioning Strategy:**
- SBOM version matches software artifact version (SemVer)
- SBOM specification version embedded in SBOM metadata (e.g., CycloneDX 1.5)
- Immutable: Once published, SBOM cannot be modified (re-publish with new version)

**NFR Traceability:** COMP-SBOM-005 (SBOM versioning)

### 5.3 SBOM Retrieval & Access

**Access Methods:**

1. **Azure Artifacts Web UI:**
   - Browse Universal Packages
   - Download SBOM JSON files
   - View metadata (version, publish date, dependencies)

2. **Azure CLI:**
   ```bash
   az artifacts universal download \
     --organization https://dev.azure.com/edutrack \
     --feed edutrack-sbom \
     --name edutrack-unified \
     --version 1.2.3 \
     --path ./downloads
   ```

3. **REST API:**
   - Azure Artifacts REST API for programmatic access
   - Automation, compliance reporting, vulnerability scanning

**Access Control:**
- Read: All internal employees (corporate Azure AD)
- Write: DevOps team, CI/CD service principal
- Admin: DevOps Lead, Compliance Officer

**NFR Traceability:** COMP-SBOM-006 (SBOM access control)

---

## 6. License Compliance

### 6.1 License Detection & Validation

**License Detection Sources:**

1. **Package Metadata:**
   - NuGet: `<license>` element in `.nuspec`
   - npm: `license` field in `package.json`
   - OS packages: License files in `/usr/share/doc`

2. **License Scanning Tools:**
   - FOSSA (primary): Automated license detection and compliance reporting
   - WhiteSource Bolt (secondary): Backup license scanning
   - Manual review: For ambiguous or missing licenses

**License Normalization:**
- Map detected licenses to SPDX identifiers (e.g., `MIT`, `Apache-2.0`, `GPL-3.0`)
- Flag non-standard licenses for legal review

**NFR Traceability:** COMP-LICENSE-001 (License compliance)

### 6.2 Approved & Restricted Licenses

**Approved Licenses (Permissive):**
- MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause
- ISC, CC0-1.0, Unlicense
- Microsoft .NET Library License (for .NET components)

**Conditional Licenses (Requires Review):**
- LGPL-2.1, LGPL-3.0 (dynamic linking acceptable)
- MPL-2.0, EPL-2.0 (file-level copyleft acceptable)
- CC-BY-4.0, CC-BY-SA-4.0 (for documentation/content only)

**Restricted Licenses (Prohibited):**
- GPL-2.0, GPL-3.0 (copyleft incompatible with proprietary code)
- AGPL-3.0 (network copyleft)
- SSPL, Commons Clause (non-open source)
- Proprietary licenses (requires legal approval)

**NFR Traceability:** COMP-LICENSE-002 (License approval policy)

### 6.3 License Compliance Workflow

**Automated Checks (CI/CD Pipeline):**

1. **License Scanning:**
   - FOSSA CLI scans all dependencies
   - Fail build if restricted license detected
   - Warn if conditional license detected

2. **License Reporting:**
   - Generate license summary report (CSV, JSON)
   - Attach to SBOM artifact
   - Store in Azure Artifacts

3. **License Approval Process:**
   - Conditional licenses: Engineering Lead review (documented in ADR)
   - Restricted licenses: Legal Counsel approval required (escalate to Legal team)
   - Proprietary licenses: Procurement + Legal approval (vendor contract review)

**Manual Review Triggers:**
- Unknown/missing license
- Conflicting licenses (component A: MIT, component B: GPL)
- License change in dependency update

**NFR Traceability:** COMP-LICENSE-003 (License compliance workflow)

### 6.4 License Compliance Reporting

**Reports Generated:**

| Report | Frequency | Recipients | Format |
|--------|-----------|------------|--------|
| **License Summary** | Per build | DevOps team | JSON (embedded in SBOM) |
| **License Compliance Dashboard** | Real-time | Engineering Lead, Legal | FOSSA Web UI |
| **License Audit Report** | Quarterly | Legal, Compliance, Audit | PDF (detailed component list, license text) |
| **License Change Report** | Per dependency update | Engineering Lead | Email notification |

**NFR Traceability:** COMP-LICENSE-004 (License reporting)

---

## 7. Vulnerability Management

### 7.1 Vulnerability Correlation

**SBOM-to-Vulnerability Mapping:**

1. **Generate SBOM:** CycloneDX format with Package URLs (PURL)
2. **Scan SBOM:** Cross-reference components with vulnerability databases
3. **Enrich SBOM:** Embed CVE IDs, CVSS scores, VEX statements (CycloneDX extension)
4. **Alert:** Notify security team of Critical/High vulnerabilities

**Vulnerability Databases:**

| Database | Coverage | Integration |
|----------|----------|-------------|
| **NVD (National Vulnerability Database)** | CVE-based, broad coverage | Trivy, WhiteSource, Dependabot |
| **GitHub Advisory Database** | GitHub-hosted packages (npm, NuGet) | Dependabot, WhiteSource |
| **OSV (Open Source Vulnerabilities)** | Multi-ecosystem (npm, PyPI, Go) | Trivy, custom scripts |
| **Checkmarx SCA** | Commercial vulnerability database | Checkmarx CLI |

**NFR Traceability:** SEC-APP-007 (Dependency vulnerability scanning)

### 7.2 Vulnerability Scanning Workflow

**Pipeline Integration:**

```yaml
- script: |
    trivy sbom ./sbom/edutrack-sbom.json --severity CRITICAL,HIGH --exit-code 1
  displayName: 'Scan SBOM for Vulnerabilities'
```

**Scanning Cadence:**

| Scan Type | Frequency | Tool | Action |
|-----------|-----------|------|--------|
| **Build-time** | Every CI build | Trivy SBOM scan | Fail pipeline if Critical/High found |
| **Post-deployment** | After deployment to DEV/TEST/STAGING | WhiteSource Bolt | Alert security team |
| **Scheduled** | Weekly | Dependabot + Trivy | Auto-create PR for dependency updates |
| **On-demand** | New CVE published | Automated GitHub webhook | Re-scan all SBOMs |

**NFR Traceability:** SEC-APP-007 (Dependency vulnerability scanning)

### 7.3 Vulnerability Remediation

**Remediation SLA:**

| Severity | SLA | Action | Owner |
|----------|-----|--------|-------|
| **Critical** | 7 days | Immediate patching, emergency release | Security Architect + Engineering Lead |
| **High** | 30 days | Patching in next sprint, backlog prioritization | Engineering Lead |
| **Medium** | 90 days | Planned remediation, tracked in backlog | Engineering Team |
| **Low** | Best effort | Remediate when convenient, no SLA | Engineering Team |

**Remediation Workflow:**

1. **Vulnerability Detected:** Automated scan flags CVE
2. **Triage:** Security team reviews severity, exploitability, applicability
3. **Create Work Item:** Azure DevOps work item created (Bug, Security issue)
4. **Assign Owner:** Engineering Lead assigns to developer
5. **Remediation:** Update dependency, rebuild, re-scan SBOM
6. **Validation:** Confirm CVE no longer present in SBOM
7. **Deploy:** Deploy patched version via CI/CD pipeline
8. **Close:** Mark work item as resolved, document in release notes

**NFR Traceability:** SEC-APP-007 (Vulnerability remediation)

### 7.4 Vulnerability Reporting

**Reports Generated:**

| Report | Frequency | Recipients | Format |
|--------|-----------|------------|--------|
| **Vulnerability Summary** | Per build | DevOps team | Console output (CI/CD logs) |
| **Vulnerability Dashboard** | Real-time | Security team, Engineering Lead | WhiteSource Web UI |
| **Vulnerability Trend Report** | Weekly | Security Architect, CISO | Email (charts, metrics) |
| **Critical Vulnerability Alert** | Immediate | Security team, Engineering Lead, CISO | Teams notification + email |

**NFR Traceability:** SEC-APP-007 (Vulnerability tracking)

---

## 8. SBOM Attestation & Provenance

### 8.1 Build Provenance (SLSA Framework)

**SLSA Level Target:** SLSA Level 2 (MVP), SLSA Level 3 (future)

**Provenance Metadata:**

| Field | Description | Source |
|-------|-------------|--------|
| **Build ID** | Unique build identifier | Azure Pipelines run ID |
| **Build Timestamp** | ISO 8601 timestamp | Azure Pipelines |
| **Build Environment** | OS, tooling versions | Azure Pipelines agent metadata |
| **Source Repository** | Git repo URL | Azure DevOps Repos |
| **Commit SHA** | Git commit hash (full SHA-1) | `git rev-parse HEAD` |
| **Branch** | Git branch name | `git rev-parse --abbrev-ref HEAD` |
| **Builder** | CI/CD service account | Azure Pipelines service principal |
| **Build Steps** | Compilation, testing, SBOM generation | Azure Pipelines YAML |

**Provenance Format:** SLSA Provenance v0.2 (JSON)

**NFR Traceability:** COMP-SBOM-007 (Build provenance)

### 8.2 Cryptographic Attestation

**Signing Mechanism:**

1. **Generate SBOM:** CycloneDX JSON file
2. **Hash SBOM:** SHA-256 hash of SBOM file
3. **Sign Hash:** Sign hash with code signing certificate (Azure Key Vault)
4. **Store Signature:** Attach signature file alongside SBOM in Azure Artifacts

**Signature Format:** PKCS#7 detached signature (`.sig` file)

**Verification Workflow:**

```bash
# Download SBOM and signature
az artifacts universal download --name edutrack-unified --version 1.2.3

# Verify signature
openssl cms -verify -in edutrack-unified-1.2.3-sbom-cyclonedx.json.sig \
  -content edutrack-unified-1.2.3-sbom-cyclonedx.json \
  -CAfile edutrack-ca.pem
```

**NFR Traceability:** COMP-SBOM-008 (Cryptographic attestation)

### 8.3 Provenance Integration with CI/CD

**Azure Pipelines Task:**

```yaml
- task: PowerShell@2
  displayName: 'Generate SLSA Provenance'
  inputs:
    targetType: 'inline'
    script: |
      $provenance = @{
        "_type" = "https://in-toto.io/Statement/v0.1"
        "subject" = @(@{
          "name" = "edutrack-unified"
          "digest" = @{
            "sha256" = (Get-FileHash -Path ./sbom/edutrack-sbom.json -Algorithm SHA256).Hash.ToLower()
          }
        })
        "predicateType" = "https://slsa.dev/provenance/v0.2"
        "predicate" = @{
          "buildType" = "https://dev.azure.com/build"
          "builder" = @{ "id" = "$(System.DefinitionId)" }
          "metadata" = @{
            "buildInvocationId" = "$(Build.BuildId)"
            "completeness" = @{ "parameters" = $true; "environment" = $true; "materials" = $true }
          }
          "materials" = @(@{
            "uri" = "https://dev.azure.com/edutrack/_git/edutrack"
            "digest" = @{ "sha1" = "$(Build.SourceVersion)" }
          })
        }
      }
      $provenance | ConvertTo-Json -Depth 10 | Out-File ./sbom/edutrack-provenance.json
```

**Output:** `edutrack-provenance.json` (SLSA provenance v0.2)

**NFR Traceability:** COMP-SBOM-007 (Build provenance)

---

## 9. Compliance & Regulatory Alignment

### 9.1 Regulatory Requirements

**Executive Order 14028 (Improving the Nation's Cybersecurity):**
- **Requirement:** Federal agencies procuring software must require SBOM from vendors
- **EDUTrack Alignment:** Generate SBOM for all releases; provide upon request
- **NTIA Minimum Elements:** All minimum fields included in CycloneDX SBOM

**ISO/IEC 5962:2021 (SPDX Specification):**
- **Requirement:** International standard for software package data exchange
- **EDUTrack Alignment:** Generate SPDX 2.3 format for long-term archival
- **Compliance:** Quarterly SPDX exports for compliance archive

**Corporate IT Policy:**
- **Requirement:** Track all third-party software dependencies for risk management
- **EDUTrack Alignment:** SBOM generation mandatory for all builds; stored 2 years
- **Audit:** Annual audit of SBOM completeness and accuracy

**NFR Traceability:** COMP-SBOM-009 (Regulatory compliance)

### 9.2 Audit & Reporting

**Audit Artifacts:**

| Artifact | Purpose | Storage | Retention |
|----------|---------|---------|-----------|
| **SBOM (CycloneDX)** | Component inventory, vulnerability tracking | Azure Artifacts | Indefinite (releases), 90 days (builds) |
| **SBOM (SPDX)** | Regulatory compliance, legal review | Azure Blob (Compliance) | 7 years |
| **License Report** | License compliance audit | Azure Artifacts | 7 years |
| **Vulnerability Report** | Security audit, risk assessment | Azure Blob (Security) | 2 years |
| **Provenance** | Build integrity, supply chain audit | Azure Artifacts | Indefinite (releases) |

**Audit Cadence:**

| Audit Type | Frequency | Auditor | Scope |
|------------|-----------|---------|-------|
| **SBOM Completeness** | Quarterly | DevOps Lead | Verify SBOM generated for all releases |
| **License Compliance** | Quarterly | Legal Counsel | Review restricted/conditional licenses |
| **Vulnerability Status** | Monthly | Security Architect | Review open CVEs, remediation progress |
| **Regulatory Compliance** | Annually | External Auditor | NTIA compliance, ISO 5962 alignment |

**NFR Traceability:** COMP-AUDIT-001 (Audit trail), COMP-SBOM-010 (Audit reporting)

---

## 10. SBOM Distribution & Transparency

### 10.1 Internal Distribution

**Distribution Channels:**

| Stakeholder | Access Method | Use Case |
|-------------|---------------|----------|
| **Engineering Teams** | Azure Artifacts Web UI / CLI | Dependency review, troubleshooting |
| **Security Team** | WhiteSource Dashboard, Azure Artifacts | Vulnerability tracking, risk assessment |
| **Compliance Team** | Azure Blob (Compliance container) | Regulatory reporting, audit preparation |
| **Legal Team** | FOSSA Dashboard, SPDX exports | License compliance, IP review |
| **Operations Team** | Azure Artifacts (production releases) | Incident response, root cause analysis |

**NFR Traceability:** COMP-SBOM-011 (SBOM distribution)

### 10.2 External Distribution

**Customer/Partner Requests:**

- **Process:** Submit request via IT support ticket
- **Approval:** DevOps Lead + Legal Counsel
- **Format:** SPDX 2.3 JSON (regulatory standard)
- **Delivery:** Secure file transfer (encrypted email, Azure File Share)
- **Restrictions:** Non-disclosure agreement (NDA) required

**Public Transparency (Future Consideration):**

- **Pilot:** Publish SBOM for open-source components only
- **Platform:** GitHub Releases (for public-facing projects)
- **Scope:** Frontend libraries, non-proprietary components
- **Approval:** Legal + CISO approval required

**NFR Traceability:** COMP-SBOM-012 (External SBOM distribution)

---

## 11. SBOM Maintenance & Updates

### 11.1 SBOM Regeneration Triggers

**Automatic Regeneration:**

| Trigger | Frequency | Rationale |
|---------|-----------|-----------|
| **Code commit** | Continuous | New build may include dependency updates |
| **Dependency update** | Per Dependabot PR | Reflect updated component versions |
| **Security patch** | Immediate | Emergency vulnerability remediation |
| **Scheduled build** | Nightly | Ensure SBOM reflects latest dependencies |

**Manual Regeneration:**

- On-demand SBOM generation for specific commits (via Azure Pipelines UI)
- Historical SBOM recreation (for forensics, audit, compliance)

**NFR Traceability:** COMP-SBOM-013 (SBOM maintenance)

### 11.2 Dependency Update Workflow

**Automated Dependency Updates (Dependabot):**

1. **Detect Update:** Dependabot scans for newer dependency versions
2. **Security Check:** Validate update resolves known vulnerabilities
3. **Create PR:** Auto-generate pull request with updated dependency
4. **CI/CD Validation:** Run full CI pipeline (build, test, SBOM generation)
5. **SBOM Comparison:** Compare old vs. new SBOM (dependency diff)
6. **Review & Merge:** Developer reviews changes, merges PR
7. **Deploy:** Deploy updated version with new SBOM

**Manual Dependency Updates:**

- Developer updates `package.json` or `.csproj` files
- CI pipeline regenerates SBOM automatically
- No manual SBOM update required

**NFR Traceability:** SEC-APP-007 (Dependency updates)

### 11.3 SBOM Diff & Change Tracking

**SBOM Comparison Tool:**

- **Tool:** CycloneDX CLI (`cyclonedx diff`)
- **Usage:** Compare SBOMs between releases
- **Output:** JSON report highlighting added/removed/updated components

**Change Tracking:**

| Change Type | Notification | Approval Required |
|-------------|--------------|-------------------|
| **Patch update** (1.2.3 → 1.2.4) | None (automatic) | No |
| **Minor update** (1.2.3 → 1.3.0) | DevOps team (email) | No (reviewed in PR) |
| **Major update** (1.2.3 → 2.0.0) | Engineering Lead (email) | Yes (ADR required) |
| **New dependency** | Engineering Lead (PR review) | Yes (PR approval) |
| **License change** | Legal (email alert) | Yes (Legal review) |
| **Vulnerability introduced** | Security team (alert) | Yes (Security review) |

**NFR Traceability:** COMP-SBOM-014 (SBOM change tracking)

---

## 12. Integration with Security Tools

### 12.1 SBOM-Driven Security Scanning

**Tool Integration:**

| Tool | Input | Output | Use Case |
|------|-------|--------|----------|
| **Trivy** | CycloneDX SBOM | Vulnerability report (JSON, table) | Build-time vulnerability scanning |
| **WhiteSource Bolt** | SBOM + source code | Vulnerability + license report | Continuous security monitoring |
| **Dependabot** | SBOM (via GitHub integration) | Auto-generated PRs | Automated dependency updates |
| **FOSSA** | SBOM + source code | License compliance report | License compliance validation |
| **Checkmarx SCA** | SBOM | Vulnerability + license report | Comprehensive SCA analysis |

**NFR Traceability:** SEC-APP-007 (Security tool integration)

### 12.2 VEX (Vulnerability Exploitability eXchange)

**VEX Purpose:** Document vulnerability status and exploitability

**VEX Statements:**

| VEX Status | Definition | Example |
|------------|------------|---------|
| **Not Affected** | Component not vulnerable | CVE applies to different OS version |
| **Affected** | Component vulnerable, no remediation | Awaiting upstream patch |
| **Fixed** | Vulnerability patched | Component updated to patched version |
| **Under Investigation** | Status unknown, investigating | Recently disclosed CVE |

**VEX Embedding:**

- CycloneDX 1.5 supports VEX extension
- VEX statements embedded in SBOM (no separate file)
- Automated VEX updates (when vulnerabilities resolved)

**NFR Traceability:** SEC-APP-007 (Vulnerability tracking)

---

## 13. Training & Awareness

### 13.1 Developer Training

**Training Topics:**

- SBOM fundamentals (purpose, formats, benefits)
- Dependency management best practices
- License compliance awareness
- Vulnerability remediation workflow
- SBOM generation tools (CycloneDX, Syft)

**Training Delivery:**

- Onboarding session (1 hour, interactive)
- Self-paced e-learning module (30 minutes)
- Monthly security awareness newsletter

**NFR Traceability:** MAINT-DOC-001 (Training and documentation)

### 13.2 Security Team Training

**Training Topics:**

- SBOM analysis and vulnerability correlation
- VEX statement creation and management
- License compliance enforcement
- Supply chain risk assessment
- SLSA provenance verification

**Training Delivery:**

- Quarterly security workshop (2 hours, hands-on)
- Conference attendance (SBOM-focused events)
- Tool vendor training (WhiteSource, Checkmarx)

---

## 14. Metrics & KPIs

### 14.1 SBOM Generation Metrics

| Metric | Target | Current | Measurement |
|--------|--------|---------|-------------|
| **SBOM Coverage** | 100% of releases | TBD | (Releases with SBOM) / (Total releases) |
| **SBOM Generation Time** | <2 minutes | TBD | Average time to generate SBOM in CI pipeline |
| **SBOM Completeness** | 100% NTIA fields | TBD | Automated validation script |
| **SBOM Format Compliance** | 100% valid JSON | TBD | JSON schema validation pass rate |

### 14.2 Vulnerability Metrics

| Metric | Target | Current | Measurement |
|--------|--------|---------|-------------|
| **Critical CVE Remediation** | <7 days | TBD | Time from detection to deployment |
| **High CVE Remediation** | <30 days | TBD | Time from detection to deployment |
| **Vulnerability Detection Rate** | 100% of known CVEs | TBD | (Detected CVEs) / (Total CVEs in NVD) |
| **False Positive Rate** | <10% | TBD | (False positives) / (Total alerts) |

### 14.3 License Compliance Metrics

| Metric | Target | Current | Measurement |
|--------|--------|---------|-------------|
| **Approved License Coverage** | 100% | TBD | (Approved licenses) / (Total licenses) |
| **License Detection Rate** | >95% | TBD | (Detected licenses) / (Total components) |
| **Restricted License Violations** | 0 | TBD | Count of restricted licenses in production |
| **License Review Cycle Time** | <5 days | TBD | Time from detection to legal approval |

**NFR Traceability:** COMP-SBOM-015 (SBOM metrics)

---

## 15. Risks & Mitigation

### 15.1 SBOM Risk Register

| Risk ID | Risk Description | Impact | Likelihood | Mitigation Strategy | Owner |
|---------|------------------|--------|------------|---------------------|-------|
| SBOM-R01 | SBOM generation tool failure | High | Low | Multiple tool fallbacks (CycloneDX, Syft); manual generation procedure documented | DevOps Lead |
| SBOM-R02 | Incomplete or inaccurate SBOM | High | Medium | Automated validation; quarterly manual audits; multiple tool cross-check | DevOps Lead |
| SBOM-R03 | Vulnerability database lag (new CVEs not detected) | High | Medium | Subscribe to multiple databases (NVD, OSV, GitHub Advisory); weekly scans | Security Architect |
| SBOM-R04 | License compliance violation | Medium | Low | Automated license scanning; legal review for conditional licenses; restricted license blocking | Legal Counsel |
| SBOM-R05 | SBOM storage/retrieval failure | Medium | Low | Geo-redundant Azure Artifacts; backup to Azure Blob; documented recovery procedure | DevOps Lead |
| SBOM-R06 | False positive vulnerabilities causing alert fatigue | Medium | Medium | VEX statements for false positives; tuning detection rules; triage process | Security Architect |
| SBOM-R07 | SBOM format obsolescence (specification updates) | Low | Medium | Monitor CycloneDX/SPDX roadmaps; update tools quarterly; backward compatibility | DevOps Lead |
| SBOM-R08 | Transitive dependency not detected | High | Low | Enable transitive dependency scanning; validate dependency tree depth | DevOps Lead |
| SBOM-R09 | SBOM tampering or unauthorized modification | High | Low | Cryptographic signing; access control (write-once storage); audit logs | Security Architect |
| SBOM-R10 | Regulatory compliance failure (missing NTIA fields) | Medium | Low | Automated NTIA compliance validation; quarterly audits; provenance metadata | Compliance Officer |

---

## 16. Action Items & Next Steps

### 16.1 Immediate Actions (Sprint 0)

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| Install CycloneDX .NET Tool in CI/CD | DevOps Team | Week 1 | 🔲 Not Started |
| Install CycloneDX npm Tool in CI/CD | DevOps Team | Week 1 | 🔲 Not Started |
| Install Syft for Docker scanning | DevOps Team | Week 1 | 🔲 Not Started |
| Configure Azure Artifacts feed for SBOM storage | DevOps Lead | Week 1 | 🔲 Not Started |
| Setup FOSSA account and integration | Security Architect | Week 2 | 🔲 Not Started |
| Document SBOM generation procedures | DevOps Lead | Week 2 | 🔲 Not Started |

### 16.2 Sprint 1-2 Actions

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| Implement SBOM generation in CI pipeline | DevOps Team | Sprint 1 | 🔲 Not Started |
| Integrate Trivy SBOM scanning | DevOps Team | Sprint 1 | 🔲 Not Started |
| Configure Dependabot for auto-updates | DevOps Team | Sprint 1 | 🔲 Not Started |
| Generate baseline SBOM for existing code | DevOps Team | Sprint 1 | 🔲 Not Started |
| Create SBOM validation script | DevOps Team | Sprint 2 | 🔲 Not Started |
| Conduct SBOM training for developers | DevOps Lead | Sprint 2 | 🔲 Not Started |

### 16.3 Pre-Production Actions

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| Implement SLSA provenance generation | DevOps Team | Sprint 6 | 🔲 Not Started |
| Setup cryptographic signing for SBOMs | DevOps Team | Sprint 6 | 🔲 Not Started |
| Generate SPDX format for compliance | DevOps Team | Sprint 7 | 🔲 Not Started |
| Conduct license compliance audit | Legal Counsel | Sprint 8 | 🔲 Not Started |
| Validate NTIA minimum elements compliance | Compliance Officer | Sprint 8 | 🔲 Not Started |
| Test SBOM retrieval and distribution procedures | DevOps Lead | Sprint 9 | 🔲 Not Started |

---

## 17. References

### 17.1 Internal References

| Document | Location | Relevance |
|----------|----------|-----------|
| CI/CD Specification | `docs/development/cicd-spec.md` | Pipeline integration, quality gates |
| Environment Matrix | `docs/development/environment-matrix.md` | Deployment tracking, compliance |
| Coding Standards | `docs/development/coding-standards.md` | Dependency management, tech stack |
| NFR Catalogue | `docs/requirements/NFR.md` | Compliance, security requirements |
| Threat Model | `docs/design/threat-model.md` | Supply chain security, vulnerability management |

### 17.2 External References

1. **NTIA SBOM Minimum Elements:** https://www.ntia.gov/files/ntia/publications/sbom_minimum_elements_report.pdf
2. **CycloneDX Specification:** https://cyclonedx.org/specification/overview/
3. **SPDX Specification (ISO/IEC 5962:2021):** https://spdx.dev/specifications/
4. **SLSA Framework:** https://slsa.dev/
5. **Executive Order 14028:** https://www.whitehouse.gov/briefing-room/presidential-actions/2021/05/12/executive-order-on-improving-the-nations-cybersecurity/
6. **OWASP Dependency-Check:** https://owasp.org/www-project-dependency-check/
7. **CISA SBOM Resources:** https://www.cisa.gov/sbom

---

## Document Approval

This SBOM Strategy has been reviewed and approved by:

| Name | Role | Signature | Date |
|------|------|-----------|------|
| TBD | DevOps Lead | | |
| TBD | Security Architect | | |
| TBD | Compliance Officer | | |
| TBD | Engineering Lead | | |
| TBD | Legal Counsel | | |

---

**Document Status:** ✅ Baseline  
**Last Updated:** 2025-11-21  
**Next Review:** 2026-02-21 (Quarterly)
