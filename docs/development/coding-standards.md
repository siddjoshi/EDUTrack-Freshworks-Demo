# Coding Standards: EDUTrack Platform

## Document Control

| Version | Date | Author | Reviewer | Notes |
|---------|------|--------|----------|-------|
| 0.1     | 2025-11-21 | Engineering Lead | | Draft |
| 1.0     | 2025-11-21 | Engineering Lead | Solution Architect, QA Lead | Baseline |

## Approvals

| Name | Role | Signature | Date |
|------|------|-----------|------|
| TBD | Engineering Lead | | |
| TBD | Solution Architect | | |
| TBD | QA Lead | | |
| TBD | Security Architect | | |

---

## 1. Purpose & Scope

### 1.1 Purpose

This document defines the coding standards, development practices, and quality expectations for the EDUTrack AI-Powered Learning & Training Platform. It ensures:

- **Consistency:** Uniform code style across all teams and components
- **Quality:** Maintainable, testable, and secure codebase
- **Efficiency:** Clear guidelines reduce decision overhead and code review friction
- **Compliance:** Security, accessibility, and regulatory requirements embedded in standards
- **Onboarding:** New developers can quickly understand and contribute to the codebase

### 1.2 Scope

These standards apply to:
- All code developed for the EDUTrack platform (frontend, backend, infrastructure)
- All environments (development, testing, staging, production)
- All contributors (internal teams, contractors, third-party developers)

### 1.3 Governance

- **Ownership:** Engineering Lead maintains and updates this document
- **Review Cadence:** Quarterly review; updated as needed for new technologies or lessons learned
- **Exceptions:** Must be documented, justified, and approved by Engineering Lead + Solution Architect
- **Enforcement:** Automated checks in CI/CD pipeline; code review checklist validation

---

## 2. Technology Stack & Languages

### 2.1 Approved Technologies

| Layer | Technology | Version | Justification |
|-------|------------|---------|---------------|
| **Frontend** | React | 18.x | Modern UI framework; strong Azure integration; large talent pool |
| | TypeScript | 5.x | Type safety; improved developer experience; maintainability |
| | Vite | 5.x | Fast build times; modern tooling; HMR support |
| | TailwindCSS | 3.x | Utility-first CSS; rapid UI development; consistency |
| | React Query | 5.x | Server state management; caching; optimistic updates |
| | React Router | 6.x | Client-side routing; code splitting |
| | Axios | 1.x | HTTP client; interceptor support; cancellation |
| **Backend** | .NET | 8.0 (LTS) | Enterprise-grade; Azure native; C# type safety |
| | ASP.NET Core | 8.0 | RESTful APIs; middleware pipeline; dependency injection |
| | Entity Framework Core | 8.0 | ORM; migrations; LINQ; Azure SQL integration |
| | Azure Functions | v4 | Serverless compute; event-driven; cost-effective |
| **Data** | Azure SQL Database | Latest | Relational data; high availability; geo-replication |
| | Azure Cosmos DB | Latest | NoSQL; audit logs; analytics; global distribution |
| | Azure Blob Storage | Latest | File storage; encryption at rest; versioning |
| | Azure AI Search | Latest | Semantic search; AI-powered; vector search |
| **AI/ML** | Azure OpenAI | GPT-4 | Content generation; embeddings; managed service |
| | Azure AI Document Intelligence | Latest | Text extraction; OCR; form recognition |
| **DevOps** | Azure DevOps | Latest | CI/CD; boards; repos; test plans |
| | Bicep | Latest | Infrastructure as Code; Azure ARM templates |
| | Docker | 24.x | Containerization; consistent environments |
| **Observability** | Azure Application Insights | Latest | APM; distributed tracing; custom metrics |
| | Azure Monitor | Latest | Infrastructure monitoring; log analytics |
| | Azure Key Vault | Latest | Secrets management; certificate storage |

### 2.2 Language Standards

#### C# (.NET Backend)

- **Version:** C# 12.0 (with .NET 8.0)
- **Style Guide:** [Microsoft C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- **EditorConfig:** Enforce via `.editorconfig` in repository root
- **Nullable Reference Types:** Enabled for all projects (`<Nullable>enable</Nullable>`)
- **Async/Await:** Use `async`/`await` for all I/O operations; avoid `.Result` and `.Wait()`
- **LINQ:** Prefer LINQ query syntax for readability; method syntax for chaining

**Naming Conventions:**
```csharp
// PascalCase for classes, methods, properties, public members
public class ContentIngestionService { }
public async Task<Document> UploadDocumentAsync() { }

// camelCase for local variables, private fields with underscore prefix
private readonly ILogger<ContentIngestionService> _logger;
var documentId = Guid.NewGuid();

// Interfaces prefixed with 'I'
public interface IDocumentRepository { }

// Async methods suffixed with 'Async'
public async Task<bool> ValidateContentAsync() { }
```

#### TypeScript/JavaScript (Frontend)

- **Version:** TypeScript 5.x (strict mode enabled)
- **Style Guide:** [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript) with TypeScript extensions
- **Linter:** ESLint with TypeScript parser
- **Formatter:** Prettier (max line length: 100 characters)
- **Type Safety:** `strict: true` in `tsconfig.json`; avoid `any` type (use `unknown` or specific types)

**Naming Conventions:**
```typescript
// PascalCase for components, classes, types, interfaces
export const CoursePlayer: React.FC<CoursePlayerProps> = () => {};
interface UserProfile { }
type DocumentStatus = 'draft' | 'published' | 'archived';

// camelCase for variables, functions, properties
const userId = user.id;
const fetchDocuments = async () => {};

// UPPER_CASE for constants
const MAX_FILE_SIZE_MB = 50;
const API_BASE_URL = import.meta.env.VITE_API_URL;

// Prefix boolean variables with 'is', 'has', 'should'
const isLoading = true;
const hasPermission = checkPermission();
```

#### SQL (Database)

- **Naming:** snake_case for tables, columns; singular table names (e.g., `document`, not `documents`)
- **Primary Keys:** Always use `id` as primary key column (GUID or BIGINT)
- **Timestamps:** Include `created_at`, `updated_at` (UTC) for audit trail
- **Soft Delete:** Use `deleted_at` nullable column instead of hard deletes
- **Foreign Keys:** Explicit naming: `{referenced_table}_id` (e.g., `user_id`)

**Example:**
```sql
CREATE TABLE document (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    title NVARCHAR(500) NOT NULL,
    content_hash VARCHAR(64) NOT NULL, -- SHA-256
    uploaded_by_user_id UNIQUEIDENTIFIER NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    deleted_at DATETIME2 NULL,
    CONSTRAINT fk_document_user FOREIGN KEY (uploaded_by_user_id) REFERENCES [user](id)
);
```

#### Infrastructure as Code (Bicep)

- **Module Organization:** Separate modules for each Azure resource type
- **Parameters:** Use parameter files for environment-specific values
- **Naming:** kebab-case for files; camelCase for parameters/variables
- **Outputs:** Always output resource IDs and connection strings for downstream dependencies

---

## 3. Code Organization & Architecture

### 3.1 Repository Structure

```
EDUTrack-Demo/
├── src/
│   ├── frontend/               # React SPA
│   │   ├── src/
│   │   │   ├── components/     # Reusable UI components
│   │   │   ├── pages/          # Route-level components
│   │   │   ├── hooks/          # Custom React hooks
│   │   │   ├── services/       # API client services
│   │   │   ├── utils/          # Helper functions
│   │   │   ├── types/          # TypeScript type definitions
│   │   │   └── App.tsx         # Root component
│   │   ├── public/             # Static assets
│   │   └── package.json
│   ├── backend/                # .NET Web API
│   │   ├── EDUTrack.API/       # API project
│   │   ├── EDUTrack.Core/      # Domain models, interfaces
│   │   ├── EDUTrack.Infrastructure/ # Data access, external services
│   │   ├── EDUTrack.Application/    # Business logic, use cases
│   │   └── EDUTrack.Tests/     # Unit and integration tests
│   ├── functions/              # Azure Functions
│   │   ├── ContentIngestion/   # Serverless ingestion jobs
│   │   ├── AIGeneration/       # AI content generation workers
│   │   └── Analytics/          # Analytics aggregation
│   └── infrastructure/         # Bicep IaC templates
│       ├── modules/            # Reusable Bicep modules
│       ├── environments/       # Environment-specific parameters
│       └── main.bicep          # Main deployment template
├── docs/                       # Documentation
├── backlog/                    # Product backlog artifacts
├── .github/                    # GitHub Actions workflows
└── README.md
```

### 3.2 Backend Architecture (Clean Architecture)

**Layers (Dependency Rule: Inner layers never depend on outer layers):**

1. **Core Layer (`EDUTrack.Core`):**
   - Domain entities, value objects, enums
   - Domain interfaces (repository, service contracts)
   - No dependencies on external frameworks
   - Example: `Document.cs`, `IDocumentRepository.cs`

2. **Application Layer (`EDUTrack.Application`):**
   - Use cases (commands, queries) using CQRS pattern
   - DTOs for API requests/responses
   - Business logic orchestration
   - Depends only on Core layer
   - Example: `UploadDocumentCommand.cs`, `UploadDocumentCommandHandler.cs`

3. **Infrastructure Layer (`EDUTrack.Infrastructure`):**
   - Data access (Entity Framework repositories)
   - External service integrations (Azure OpenAI, SharePoint)
   - Logging, caching, messaging implementations
   - Depends on Core and Application layers
   - Example: `DocumentRepository.cs`, `SharePointService.cs`

4. **API Layer (`EDUTrack.API`):**
   - ASP.NET Core controllers
   - Middleware (authentication, error handling, logging)
   - Dependency injection configuration
   - Depends on all inner layers
   - Example: `DocumentsController.cs`

**Example Directory Structure:**
```
EDUTrack.Core/
├── Entities/
│   ├── Document.cs
│   ├── User.cs
│   └── Module.cs
├── Interfaces/
│   ├── IDocumentRepository.cs
│   └── IAIGenerationService.cs
└── ValueObjects/
    └── ContentHash.cs

EDUTrack.Application/
├── Commands/
│   ├── UploadDocumentCommand.cs
│   └── UploadDocumentCommandHandler.cs
├── Queries/
│   ├── GetDocumentQuery.cs
│   └── GetDocumentQueryHandler.cs
└── DTOs/
    ├── DocumentUploadDto.cs
    └── DocumentResponseDto.cs
```

### 3.3 Frontend Architecture (Feature-Based)

**Component Organization:**
- **Pages:** Route-level components (e.g., `CoursePlayerPage.tsx`)
- **Components:** Reusable UI components organized by feature (e.g., `components/document/DocumentCard.tsx`)
- **Hooks:** Custom hooks for state and side effects (e.g., `hooks/useDocuments.ts`)
- **Services:** API client wrappers (e.g., `services/documentService.ts`)

**State Management:**
- **Server State:** React Query for API data fetching, caching, synchronization
- **Client State:** React Context for global app state (authentication, theme)
- **Form State:** React Hook Form for form handling and validation

---

## 4. Coding Best Practices

### 4.1 General Principles

1. **SOLID Principles:** Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
2. **DRY (Don't Repeat Yourself):** Extract reusable logic into functions, classes, or components
3. **YAGNI (You Aren't Gonna Need It):** Implement only what's required now; avoid over-engineering
4. **KISS (Keep It Simple, Stupid):** Prefer simple, readable solutions over clever complexity
5. **Boy Scout Rule:** Leave code cleaner than you found it

### 4.2 Code Readability

**Functions/Methods:**
- **Single Responsibility:** Each function should do one thing well
- **Length:** Keep functions under 50 lines; extract helper functions if longer
- **Parameters:** Maximum 4 parameters; use objects/DTOs for more
- **Naming:** Descriptive verb-noun pairs (e.g., `validateDocument`, `getUserProfile`)

**Comments:**
- **When to Comment:** 
  - Complex business logic or algorithms
  - Non-obvious workarounds or limitations
  - Public API documentation (XML comments in C#, JSDoc in TypeScript)
- **When NOT to Comment:** 
  - Obvious code (e.g., `// increment counter` before `counter++`)
  - Redundant explanations of what code does (code should be self-documenting)

**Example (C#):**
```csharp
/// <summary>
/// Validates uploaded document meets security and format requirements.
/// </summary>
/// <param name="file">The uploaded file stream</param>
/// <param name="metadata">Document metadata including filename and content type</param>
/// <returns>ValidationResult with success status and error messages if invalid</returns>
/// <exception cref="ArgumentNullException">Thrown when file or metadata is null</exception>
public async Task<ValidationResult> ValidateDocumentAsync(Stream file, DocumentMetadata metadata)
{
    ArgumentNullException.ThrowIfNull(file);
    ArgumentNullException.ThrowIfNull(metadata);

    // Check file size limit (SEC-APP-008)
    if (file.Length > MaxFileSizeBytes)
    {
        return ValidationResult.Failure($"File size exceeds {MaxFileSizeMB}MB limit");
    }

    // Validate file extension against whitelist
    if (!AllowedExtensions.Contains(metadata.Extension))
    {
        return ValidationResult.Failure($"Unsupported file type: {metadata.Extension}");
    }

    // Scan for malware using Azure Defender (async operation)
    var scanResult = await _malwareScanService.ScanAsync(file);
    if (!scanResult.IsClean)
    {
        _logger.LogWarning("Malware detected in uploaded file: {Filename}", metadata.Filename);
        return ValidationResult.Failure("File failed security scan");
    }

    return ValidationResult.Success();
}
```

### 4.3 Error Handling

**Backend (C#):**
- Use **exceptions** for exceptional conditions only (not control flow)
- Throw **specific exceptions** (e.g., `ArgumentNullException`, `InvalidOperationException`, custom domain exceptions)
- **Catch exceptions** at appropriate boundaries (controller, middleware)
- **Log all exceptions** with context (correlation ID, user ID, operation)
- Return **standardized error responses** to client (HTTP problem details RFC 7807)

**Frontend (TypeScript):**
- Use **try/catch** for async operations
- Display **user-friendly error messages** (never expose technical details)
- Implement **error boundaries** for React component failures
- **Log errors** to Application Insights with context

**Example Error Response (API):**
```json
{
  "type": "https://edutrack.example.com/errors/validation-error",
  "title": "Document Validation Failed",
  "status": 400,
  "detail": "The uploaded file exceeds the maximum size limit of 50MB.",
  "instance": "/api/documents/upload",
  "traceId": "00-4bf92f3577b34da6a3ce929d0e0e4736-00"
}
```

### 4.4 Asynchronous Programming

**C# (.NET):**
- Use `async`/`await` for all I/O-bound operations (database, HTTP, file system)
- Avoid blocking calls (`.Result`, `.Wait()`, `.GetAwaiter().GetResult()`)
- Use `ConfigureAwait(false)` in library code to avoid deadlocks
- Prefer `Task.WhenAll` for parallel operations
- Use `CancellationToken` for long-running operations

**TypeScript:**
- Use `async`/`await` for promises (avoid `.then()` chaining)
- Handle promise rejections with try/catch
- Use `Promise.all()` for concurrent operations
- Implement request cancellation with AbortController

---

## 5. Security Standards

### 5.1 Secure Coding Practices

**Input Validation (SEC-APP-001):**
- **Whitelist validation:** Accept only known-good inputs; reject all others
- **Sanitize inputs:** Escape HTML, SQL, JavaScript before processing or display
- **Validate on server:** Never trust client-side validation alone
- **Use parameterized queries:** Prevent SQL injection (Entity Framework does this by default)
- **Validate file uploads:** Check MIME type, extension, size, content (malware scan)

**Example (C# - Input Validation):**
```csharp
public class UploadDocumentDto
{
    [Required]
    [StringLength(500, MinimumLength = 1)]
    [RegularExpression(@"^[a-zA-Z0-9\s\-_\.]+$", ErrorMessage = "Title contains invalid characters")]
    public string Title { get; set; }

    [StringLength(2000)]
    public string? Description { get; set; }

    [Required]
    [Range(1, 52428800)] // Max 50MB
    public long FileSize { get; set; }

    [Required]
    [RegularExpression(@"^\.(pdf|docx|pptx|md|html)$", ErrorMessage = "Unsupported file type")]
    public string FileExtension { get; set; }
}
```

**Authentication & Authorization:**
- **Never store passwords:** Use Azure AD SSO; delegate authentication (SEC-IAM-001)
- **Use HTTPS only:** All API calls over TLS 1.2+ (SEC-DATA-002)
- **Implement RBAC:** Check user roles/permissions at controller and service layer (SEC-IAM-002)
- **Token expiration:** Access tokens expire in 1 hour (SEC-IAM-004)
- **Session timeout:** Idle timeout after 30 minutes (SEC-IAM-006)

**Secrets Management (SEC-APP-005):**
- **Azure Key Vault:** All secrets, connection strings, API keys stored in Key Vault
- **No hardcoded secrets:** Never commit secrets to source control
- **Environment variables:** Reference Key Vault secrets via Azure App Service configuration
- **Rotate secrets:** API keys rotated every 90 days (SEC-AI-006)

**Example (C# - Key Vault Integration):**
```csharp
// Startup configuration
builder.Configuration.AddAzureKeyVault(
    new Uri($"https://{builder.Configuration["KeyVaultName"]}.vault.azure.net/"),
    new DefaultAzureCredential());

// Service usage
private readonly string _openAiApiKey = _configuration["OpenAI-ApiKey"];
```

### 5.2 Data Protection

**Encryption (SEC-DATA-001, SEC-DATA-002):**
- **At Rest:** Azure SQL TDE enabled; Blob Storage encryption enabled by default
- **In Transit:** TLS 1.2+ for all API communication
- **PII Encryption:** Column-level encryption for sensitive fields (SEC-DATA-007)

**PII Detection (SEC-DATA-003, SEC-AI-003):**
- **Pre-processing:** Detect and redact PII before sending to Azure OpenAI
- **Patterns:** Email, phone, SSN, credit card, names (using regex and Azure AI)
- **Zero leakage target:** Log PII detection events; alert on failures

**Example (C# - PII Detection):**
```csharp
public async Task<string> SanitizeContentForAIAsync(string content)
{
    // Use Azure AI Text Analytics for PII detection
    var piiEntities = await _textAnalyticsClient.RecognizePiiEntitiesAsync(content);

    var sanitizedContent = content;
    foreach (var entity in piiEntities.Entities)
    {
        // Redact PII with placeholder
        sanitizedContent = sanitizedContent.Replace(
            entity.Text, 
            $"[{entity.Category.ToString().ToUpper()}]"
        );
        
        // Log PII detection event (without actual PII value)
        _logger.LogWarning(
            "PII detected: Category={Category}, Offset={Offset}, Length={Length}",
            entity.Category, entity.Offset, entity.Length
        );
    }

    return sanitizedContent;
}
```

### 5.3 Security Headers (SEC-APP-003, SEC-APP-006)

**Required HTTP Headers (Applied in Middleware):**
```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Add("X-Frame-Options", "DENY");
    context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
    context.Response.Headers.Add("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
    context.Response.Headers.Add("Content-Security-Policy", 
        "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;");
    
    await next();
});
```

---

## 6. Testing Standards

### 6.1 Test Coverage Requirements

| Code Type | Minimum Coverage | Target Coverage | Measurement Tool |
|-----------|-----------------|-----------------|------------------|
| Backend (C#) | 80% | 90% | Coverlet + ReportGenerator |
| Frontend (TypeScript) | 70% | 80% | Vitest + Istanbul |
| Critical Paths (auth, payment) | 95% | 100% | Manual verification |
| Integration Tests | N/A | All API endpoints | xUnit + WebApplicationFactory |

### 6.2 Test Pyramid Strategy

**Distribution:**
- **70% Unit Tests:** Fast, isolated, focused on single function/class
- **20% Integration Tests:** Test component interactions (API + database, service + external API)
- **10% End-to-End Tests:** Full user workflows (Playwright)

### 6.3 Testing Best Practices

**Unit Tests (xUnit for C#, Vitest for TypeScript):**
- **Naming:** `MethodName_Scenario_ExpectedBehavior` (e.g., `UploadDocument_ExceedsSizeLimit_ReturnsValidationError`)
- **AAA Pattern:** Arrange, Act, Assert
- **Isolation:** Mock external dependencies (repositories, HTTP clients, time)
- **Fast:** Each test runs in milliseconds
- **Deterministic:** No flaky tests; same input = same output

**Example (C# - Unit Test):**
```csharp
[Fact]
public async Task ValidateDocumentAsync_ExceedsSizeLimit_ReturnsFailure()
{
    // Arrange
    var validator = new DocumentValidator(maxSizeMb: 50);
    var largeFile = new MemoryStream(new byte[60 * 1024 * 1024]); // 60MB
    var metadata = new DocumentMetadata { Filename = "large.pdf", Extension = ".pdf" };

    // Act
    var result = await validator.ValidateDocumentAsync(largeFile, metadata);

    // Assert
    Assert.False(result.IsSuccess);
    Assert.Contains("exceeds 50MB limit", result.ErrorMessage);
}
```

**Integration Tests:**
- Use `WebApplicationFactory` for API testing
- Use in-memory database or test containers for isolation
- Clean up data after each test
- Test happy path and error scenarios

**Example (C# - Integration Test):**
```csharp
public class DocumentsControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public DocumentsControllerTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task UploadDocument_ValidFile_ReturnsCreated()
    {
        // Arrange
        var content = new MultipartFormDataContent();
        content.Add(new StringContent("Test Document"), "title");
        content.Add(new ByteArrayContent(new byte[1024]), "file", "test.pdf");

        // Act
        var response = await _client.PostAsync("/api/documents/upload", content);

        // Assert
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var document = await response.Content.ReadFromJsonAsync<DocumentResponseDto>();
        Assert.NotNull(document);
        Assert.Equal("Test Document", document.Title);
    }
}
```

**End-to-End Tests (Playwright):**
- Test critical user journeys (login, upload document, take assessment)
- Run in CI/CD pipeline before deployment
- Use page object pattern for maintainability

---

## 7. Code Review Process

### 7.1 Pull Request Guidelines

**Before Creating PR:**
- [ ] All tests pass locally (`dotnet test`, `npm test`)
- [ ] Code builds without warnings
- [ ] Linters pass (ESLint, StyleCop)
- [ ] No merge conflicts with target branch
- [ ] Commit messages follow convention (see 7.4)

**PR Description Template:**
```markdown
## Summary
Brief description of changes (1-2 sentences)

## Related Work Items
- Fixes #123: User Story Title
- Related to #456: Bug Title

## Changes Made
- Added X functionality
- Refactored Y component
- Fixed Z bug

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if UI changes)
[Attach screenshots or video]

## Checklist
- [ ] Code follows coding standards
- [ ] Documentation updated (if needed)
- [ ] No hardcoded secrets or credentials
- [ ] Error handling implemented
- [ ] Logging added for key operations
```

### 7.2 Code Review Checklist

**Reviewers Must Verify:**

**Functionality:**
- [ ] Code implements the requirements correctly
- [ ] Edge cases and error scenarios handled
- [ ] No obvious bugs or logical errors

**Code Quality:**
- [ ] Code follows naming conventions and style guide
- [ ] Functions are single-purpose and reasonably sized
- [ ] No code duplication (DRY principle)
- [ ] Comments explain "why," not "what"
- [ ] Magic numbers/strings extracted to constants

**Testing:**
- [ ] Adequate test coverage (meets minimum thresholds)
- [ ] Tests are meaningful and test the right things
- [ ] Tests are not brittle or flaky

**Security:**
- [ ] No hardcoded secrets or credentials
- [ ] Input validation implemented
- [ ] Authentication/authorization checks in place
- [ ] No SQL injection, XSS, or other vulnerabilities
- [ ] PII handling follows data protection standards

**Performance:**
- [ ] No obvious performance issues (e.g., N+1 queries)
- [ ] Appropriate use of async/await
- [ ] Caching considered where applicable
- [ ] Database queries optimized (indexes, projections)

**Documentation:**
- [ ] Public APIs documented (XML comments, JSDoc)
- [ ] README updated if setup/deployment changes
- [ ] Architecture Decision Records (ADRs) created for significant design choices

### 7.3 Approval Requirements

- **Minimum Approvals:** 2 reviewers (1 senior developer + 1 peer)
- **Required Approvers:** Engineering Lead for architecture changes; Security Architect for security-sensitive code
- **Merge Criteria:** All CI checks pass + required approvals + no unresolved comments

### 7.4 Branching Strategy (GitFlow)

**Branches:**
- `main`: Production-ready code; always deployable
- `develop`: Integration branch for next release
- `feature/*`: New features (e.g., `feature/content-ingestion`)
- `bugfix/*`: Bug fixes for current release
- `hotfix/*`: Urgent production fixes
- `release/*`: Release preparation (e.g., `release/v1.0.0`)

**Workflow:**
1. Create feature branch from `develop`: `git checkout -b feature/my-feature develop`
2. Commit changes with meaningful messages (see below)
3. Push branch and create pull request to `develop`
4. Code review and CI checks
5. Merge to `develop` after approval
6. Release branch created from `develop` for deployment
7. Release branch merged to `main` and tagged with version

**Commit Message Convention (Conventional Commits):**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

**Examples:**
```
feat(ingestion): add SharePoint document upload API

Implements SRS-FUNC-001 for SharePoint Online integration using Microsoft Graph API.
Includes file validation, deduplication, and metadata extraction.

Closes #123
```

```
fix(auth): resolve token expiration handling

Fixes issue where expired tokens caused unhandled exceptions instead of redirecting to login.
Added token refresh logic and improved error messaging.

Fixes #456
```

---

## 8. Documentation Standards

### 8.1 Code Documentation

**C# XML Comments (Required for Public APIs):**
```csharp
/// <summary>
/// Uploads a document to the content repository.
/// </summary>
/// <param name="file">The file stream to upload</param>
/// <param name="metadata">Document metadata including title and description</param>
/// <param name="cancellationToken">Cancellation token for async operation</param>
/// <returns>The created document with assigned ID and upload timestamp</returns>
/// <exception cref="ValidationException">Thrown when file validation fails</exception>
/// <exception cref="StorageException">Thrown when file upload to blob storage fails</exception>
public async Task<Document> UploadDocumentAsync(
    Stream file, 
    DocumentMetadata metadata, 
    CancellationToken cancellationToken = default)
{
    // Implementation
}
```

**TypeScript JSDoc (Required for Exported Functions/Components):**
```typescript
/**
 * Fetches document details by ID from the API.
 * 
 * @param documentId - The unique identifier of the document
 * @param options - Optional fetch options including signal for cancellation
 * @returns Promise resolving to the document object
 * @throws {NotFoundError} When document does not exist
 * @throws {UnauthorizedError} When user lacks permission
 * 
 * @example
 * const document = await getDocument('123e4567-e89b-12d3-a456-426614174000');
 */
export async function getDocument(
  documentId: string, 
  options?: RequestOptions
): Promise<Document> {
  // Implementation
}
```

### 8.2 README Files

**Repository Root README:**
- Project overview and purpose
- Technology stack summary
- Prerequisites and setup instructions
- Build and run commands
- Testing instructions
- Deployment overview
- Contributing guidelines
- License and contact information

**Component/Module README:**
- Purpose and responsibility
- Architecture overview (diagrams if applicable)
- Configuration and environment variables
- API documentation or usage examples
- Known issues or limitations

### 8.3 API Documentation

- **OpenAPI/Swagger:** Auto-generated from ASP.NET Core controllers (Swashbuckle)
- **Endpoint Documentation:** Include description, request/response schemas, example payloads, error codes
- **Authentication:** Document required authentication and authorization
- **Published Location:** `/swagger` endpoint in non-production environments; static docs for production

### 8.4 Architecture Decision Records (ADRs)

**When to Create ADR:**
- Significant technology choice (e.g., choosing React over Angular)
- Architectural pattern adoption (e.g., CQRS, event sourcing)
- Trade-off decisions with lasting impact

**ADR Template:**
```markdown
# ADR-001: Use React for Frontend Framework

## Status
Accepted

## Context
We need a modern JavaScript framework for building the EDUTrack web application.

## Decision
We will use React 18.x with TypeScript for the frontend.

## Consequences
**Positive:**
- Large ecosystem and community support
- Strong Azure integration (Microsoft backing)
- Component reusability and composition
- TypeScript for type safety

**Negative:**
- Steeper learning curve than simpler frameworks
- Requires build tooling setup
- Frequent version updates

## Alternatives Considered
- Angular: More opinionated, steeper learning curve
- Vue: Smaller ecosystem, less enterprise adoption
```

---

## 9. Static Analysis & Linting

### 9.1 C# (.NET Backend)

**Tools:**
- **StyleCop.Analyzers:** Code style enforcement (installed as NuGet package)
- **Roslyn Analyzers:** Built-in code analysis (enabled in `.csproj`)
- **SonarQube:** Continuous code quality inspection (CI/CD integration)

**Configuration:**
```xml
<!-- .csproj -->
<PropertyGroup>
  <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  <EnableNETAnalyzers>true</EnableNETAnalyzers>
  <AnalysisLevel>latest</AnalysisLevel>
</PropertyGroup>

<ItemGroup>
  <PackageReference Include="StyleCop.Analyzers" Version="1.2.0-beta.556" />
</ItemGroup>
```

**Ruleset Exceptions:**
- SA1633: File must have header - Disabled (use in open source projects only)
- SA1200: Using directives placement - Disabled (prefer inside namespace)

### 9.2 TypeScript/JavaScript (Frontend)

**Tools:**
- **ESLint:** Linting with TypeScript parser
- **Prettier:** Code formatting
- **SonarQube:** Continuous code quality inspection

**Configuration (`eslint.config.js`):**
```javascript
import js from '@eslint/js';
import typescript from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';

export default [
  js.configs.recommended,
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: { jsx: true }
      }
    },
    plugins: {
      '@typescript-eslint': typescript,
      'react': react,
      'react-hooks': reactHooks
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/explicit-function-return-type': 'warn',
      'react/prop-types': 'off', // Using TypeScript instead
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn'
    }
  }
];
```

**Prettier Configuration (`.prettierrc`):**
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "always"
}
```

### 9.3 SQL Linting

- **Tool:** SQLFluff (Python-based)
- **Rules:** Enforce naming conventions, formatting, anti-patterns
- **Integration:** Pre-commit hook or CI/CD pipeline

---

## 10. Performance & Optimization

### 10.1 Backend Performance

**Database Optimization:**
- **Indexing:** Create indexes for frequently queried columns (foreign keys, search fields)
- **Query Optimization:** Use `.Select()` projections; avoid `SELECT *`; use `.AsNoTracking()` for read-only queries
- **Connection Pooling:** Enabled by default in Entity Framework; monitor pool size
- **Pagination:** Always paginate large result sets (default page size: 20-50)

**Example (Optimized Query):**
```csharp
// BAD: Loads all columns and tracks entities unnecessarily
var documents = await _context.Documents.ToListAsync();

// GOOD: Projects only needed columns, no tracking
var documents = await _context.Documents
    .AsNoTracking()
    .Where(d => d.DeletedAt == null)
    .Select(d => new DocumentListDto
    {
        Id = d.Id,
        Title = d.Title,
        CreatedAt = d.CreatedAt
    })
    .Skip((pageNumber - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

**Caching:**
- **Distributed Cache:** Azure Cache for Redis for session state, frequently accessed data
- **In-Memory Cache:** `IMemoryCache` for application-level caching (configuration, lookup data)
- **Response Caching:** HTTP response caching for static or slow-changing API responses

**Async/Await:**
- All I/O operations must be async (database, HTTP, file system)
- Use `ConfigureAwait(false)` in library code
- Avoid blocking calls (`.Result`, `.Wait()`)

### 10.2 Frontend Performance

**Code Splitting:**
- Route-based code splitting with React Router
- Lazy load components with `React.lazy()` and `Suspense`
- Dynamic imports for large libraries

**Example:**
```typescript
const CoursePlayer = React.lazy(() => import('./pages/CoursePlayerPage'));

<Suspense fallback={<LoadingSpinner />}>
  <CoursePlayer />
</Suspense>
```

**Bundle Optimization:**
- Use Vite's automatic code splitting
- Analyze bundle size with `vite-bundle-visualizer`
- Tree-shake unused code (automatic with ES modules)

**Image Optimization:**
- Use WebP format with fallback to PNG/JPEG
- Implement lazy loading for images (`loading="lazy"`)
- Serve responsive images with `srcset`

**API Calls:**
- Debounce/throttle search inputs
- Implement request cancellation for abandoned requests
- Use React Query for automatic caching and deduplication

---

## 11. Accessibility Standards (WCAG 2.1 Level AA)

### 11.1 Semantic HTML

- Use semantic HTML5 elements (`<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`)
- Use `<button>` for actions, `<a>` for navigation
- Proper heading hierarchy (`<h1>` → `<h2>` → `<h3>` without skipping levels)

### 11.2 ARIA Attributes

- Add `aria-label` for icon buttons without text
- Use `aria-describedby` for input hints/errors
- Implement `role` attributes where semantic HTML isn't sufficient
- Mark live regions with `aria-live` for dynamic content updates

**Example:**
```tsx
<button 
  aria-label="Upload document" 
  onClick={handleUpload}
>
  <UploadIcon />
</button>

<input
  type="text"
  aria-describedby="email-hint email-error"
  aria-invalid={hasError}
/>
<span id="email-hint">Enter your work email address</span>
{hasError && <span id="email-error" role="alert">Invalid email format</span>}
```

### 11.3 Keyboard Navigation

- All interactive elements must be keyboard accessible (Tab, Enter, Space, Arrow keys)
- Logical tab order (follows visual flow)
- Visible focus indicators (outline or custom styling)
- Skip navigation links for keyboard users

### 11.4 Color & Contrast

- Text contrast ratio: 4.5:1 for normal text, 3:1 for large text (WCAG AA)
- Don't rely on color alone to convey information (use icons, text, patterns)
- Test with browser DevTools accessibility checker

### 11.5 Testing

- **Automated:** Lighthouse accessibility audit (CI/CD pipeline)
- **Manual:** Screen reader testing (NVDA, JAWS, VoiceOver)
- **Keyboard-only:** Navigate entire application using only keyboard

---

## 12. Observability & Logging

### 12.1 Logging Standards

**Log Levels:**
- **Trace:** Very detailed, typically only enabled in troubleshooting
- **Debug:** Detailed information for development/debugging
- **Information:** General informational messages (startup, configuration, key operations)
- **Warning:** Unexpected but recoverable situations (retries, fallbacks, deprecated usage)
- **Error:** Error events that allow application to continue (handled exceptions)
- **Critical:** Severe errors causing application failure (unhandled exceptions, service outages)

**What to Log:**
- Application startup/shutdown events
- API requests/responses (summary, not full payload for security)
- Database operations (query execution time, errors)
- External service calls (duration, success/failure)
- Business events (user login, document upload, module completion)
- Errors and exceptions (full stack trace, context)
- Security events (authentication failures, authorization denials, PII access)

**What NOT to Log:**
- Passwords, tokens, API keys (mask or exclude entirely)
- PII (personal identifiable information) unless required for audit (then encrypt/hash)
- Full request/response payloads (log summary only)
- Sensitive business data (trade secrets, confidential information)

**Example (C# - Structured Logging with Serilog):**
```csharp
_logger.LogInformation(
    "Document uploaded successfully: DocumentId={DocumentId}, UserId={UserId}, FileSize={FileSize}, Duration={Duration}ms",
    document.Id, userId, fileSize, duration
);

try
{
    await _aiService.GenerateModuleAsync(documentId);
}
catch (Exception ex)
{
    _logger.LogError(
        ex, 
        "AI module generation failed: DocumentId={DocumentId}, ErrorType={ErrorType}",
        documentId, ex.GetType().Name
    );
    throw;
}
```

### 12.2 Application Insights Integration

**Telemetry Types:**
- **Requests:** HTTP request duration, response code, endpoint
- **Dependencies:** External calls (database, HTTP, Azure services)
- **Exceptions:** Unhandled exceptions with stack trace
- **Custom Events:** Business events (user actions, milestones)
- **Custom Metrics:** Business metrics (modules generated, assessments completed)
- **Traces:** Log messages (linked to requests via correlation ID)

**Example (C# - Custom Telemetry):**
```csharp
_telemetryClient.TrackEvent("ModuleGenerated", new Dictionary<string, string>
{
    { "DocumentId", documentId.ToString() },
    { "ModuleType", moduleType },
    { "GenerationTimeSeconds", duration.TotalSeconds.ToString() }
});

_telemetryClient.TrackMetric("AI_TokensUsed", tokensUsed, new Dictionary<string, string>
{
    { "Model", "gpt-4" },
    { "OperationType", "content-generation" }
});
```

### 12.3 Distributed Tracing

- Enable Application Insights distributed tracing (automatic with SDK)
- Propagate correlation IDs across service boundaries
- Include correlation ID in error responses for customer support

---

## 13. CI/CD Integration

### 13.1 Pipeline Quality Gates

**Build Stage:**
- [ ] Code compiles without errors or warnings (`TreatWarningsAsErrors=true`)
- [ ] Linters pass (ESLint, StyleCop, SQLFluff)
- [ ] Unit tests pass with minimum coverage (80% backend, 70% frontend)

**Test Stage:**
- [ ] Integration tests pass
- [ ] End-to-end tests pass (critical paths)
- [ ] Security scan passes (dependency vulnerabilities, SAST)

**Deploy Stage:**
- [ ] Infrastructure deployment succeeds (Bicep templates)
- [ ] Database migrations applied successfully
- [ ] Smoke tests pass in target environment
- [ ] Application Insights availability tests pass

### 13.2 Automated Checks

**Pre-Commit (Local):**
- Linters (ESLint, Prettier, StyleCop)
- Unit tests (fast subset)

**Pull Request (CI):**
- Full build and test suite
- Code coverage report
- SonarQube code quality scan
- Dependency vulnerability scan (Dependabot, Snyk)
- Accessibility audit (Lighthouse)

**Pre-Deployment:**
- Integration tests
- End-to-end tests
- Performance tests (load testing for critical endpoints)
- Security scan (SAST, DAST)

---

## 14. Definition of Done (DoD)

A user story, task, or feature is considered "Done" when ALL of the following criteria are met:

### 14.1 Development
- [ ] Code is written and follows coding standards (this document)
- [ ] Code compiles without errors or warnings
- [ ] Linters pass (ESLint, StyleCop)
- [ ] All acceptance criteria met (verified by developer)
- [ ] Edge cases and error scenarios handled
- [ ] Security requirements implemented (input validation, authorization, PII handling)

### 14.2 Testing
- [ ] Unit tests written with minimum coverage (80% backend, 70% frontend)
- [ ] Integration tests written for API endpoints
- [ ] All tests pass locally and in CI/CD pipeline
- [ ] Manual testing completed (developer self-test)
- [ ] Accessibility tested (keyboard navigation, screen reader, contrast)

### 14.3 Code Review
- [ ] Pull request created with complete description
- [ ] Code reviewed and approved by 2+ reviewers
- [ ] All review comments addressed
- [ ] No merge conflicts

### 14.4 Documentation
- [ ] Public APIs documented (XML comments, JSDoc)
- [ ] README updated (if setup/usage changes)
- [ ] API documentation updated (Swagger)
- [ ] Architecture Decision Record created (if applicable)

### 14.5 Deployment
- [ ] Merged to `develop` branch
- [ ] Deployed to development environment
- [ ] Smoke tests pass in development environment
- [ ] Product Owner acceptance (demo/review)

### 14.6 Quality Assurance
- [ ] QA testing completed (functional, regression, integration)
- [ ] Security scan passed (no critical vulnerabilities)
- [ ] Performance testing completed (if applicable)
- [ ] Accessibility audit passed (WCAG 2.1 AA)

### 14.7 Release Readiness
- [ ] Merged to `main` branch (via release branch)
- [ ] Deployed to staging environment
- [ ] User acceptance testing (UAT) completed
- [ ] Release notes updated
- [ ] Production deployment approved by Product Owner

---

## 15. Continuous Improvement

### 15.1 Metrics & Monitoring

**Code Quality Metrics:**
- **Technical Debt Ratio:** <5% (SonarQube)
- **Code Coverage:** ≥80% backend, ≥70% frontend
- **Code Duplication:** <3%
- **Maintainability Index:** >70 (Visual Studio metric)

**Process Metrics:**
- **Lead Time:** Time from story start to production deployment
- **Cycle Time:** Time from development start to code review approval
- **Code Review Turnaround:** <24 hours
- **Build Success Rate:** >95%
- **Deployment Frequency:** Daily to development, weekly to staging, bi-weekly to production

### 15.2 Retrospectives

- **Frequency:** After each sprint (bi-weekly)
- **Focus:** What went well, what didn't, action items for improvement
- **Ownership:** Engineering Lead facilitates; team owns action items
- **Follow-up:** Review action item progress in next retrospective

### 15.3 Standards Review

- **Frequency:** Quarterly
- **Participants:** Engineering Lead, Solution Architect, senior developers
- **Agenda:** Review metrics, gather feedback, identify pain points, propose updates
- **Output:** Updated coding standards document with version increment

---

## 16. Exceptions & Escalation

### 16.1 Exception Process

**When to Request Exception:**
- Technical constraint prevents adherence to standard
- Alternative approach provides significant benefit
- Time-sensitive delivery requires temporary deviation

**Exception Request Template:**
```markdown
## Exception Request: [Brief Title]

**Requested By:** [Name, Role]  
**Date:** [YYYY-MM-DD]  
**Standard/Rule:** [Specific standard or rule requiring exception]

**Reason for Exception:**
[Detailed explanation of why exception is needed]

**Proposed Alternative:**
[What will be done instead]

**Impact Assessment:**
- Security: [Impact on security posture]
- Maintainability: [Impact on code maintainability]
- Technical Debt: [Debt incurred; plan to address]

**Duration:** [Temporary (with remediation plan) or Permanent]

**Approval Required:** Engineering Lead + Solution Architect (+ Security Architect if security-related)
```

### 16.2 Escalation Path

1. **Developer → Team Lead:** Technical questions, clarifications
2. **Team Lead → Engineering Lead:** Standard interpretation, exception requests
3. **Engineering Lead → Solution Architect:** Architecture decisions, significant exceptions
4. **Solution Architect → CTO:** Strategic technology decisions, major deviations

---

## 17. References & Resources

### 17.1 External Style Guides

- [Microsoft C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
- [React Documentation](https://react.dev/)
- [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

### 17.2 Internal Documentation

- Requirements Traceability Matrix: `docs/requirements/RTM.md`
- High-Level Design: `docs/design/HLD.md`
- Threat Model: `docs/design/threat-model.md`
- Data Architecture: `docs/design/data-architecture.md`
- API Specifications: `docs/design/api-specs/`

### 17.3 Tools & Platforms

- Azure DevOps: [https://dev.azure.com/edutrack](https://dev.azure.com/edutrack)
- SonarQube: [https://sonarqube.edutrack.internal](https://sonarqube.edutrack.internal)
- Application Insights: [Azure Portal](https://portal.azure.com)

---

## 18. Document Change Log

| Version | Date | Author | Changes | Approved By |
|---------|------|--------|---------|-------------|
| 0.1 | 2025-11-21 | Engineering Lead | Initial draft | - |
| 1.0 | 2025-11-21 | Engineering Lead | Baseline version for Phase 4.1 | Pending |

---

**Document Status:** ✅ Baseline  
**Next Review:** 2026-02-21 (Quarterly)  
**Feedback:** engineering-lead@edutrack.internal
