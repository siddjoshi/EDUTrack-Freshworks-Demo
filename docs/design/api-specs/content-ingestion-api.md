# Content Ingestion API Specification
## EDUTrack Platform

---

## Document Control
| Version | Date | Author | Status |
|---------|------|--------|--------|
| 1.0 | 2025-11-21 | Solution Architect | Baseline |

---

## 1. Overview

### 1.1 Purpose
This document specifies the Content Ingestion API for uploading, processing, and managing training documents in the EDUTrack platform.

### 1.2 Base URL
- **Production:** `https://api.edutrack.company.com/v1/content`
- **Staging:** `https://api-staging.edutrack.company.com/v1/content`

### 1.3 Authentication
- **Method:** Bearer token (OAuth 2.0)
- **Required Role:** ContentUploader, ContentManager, L&DAdmin, Admin

---

## 2. Endpoints

### 2.1 Upload Document

**Endpoint:** `POST /documents/upload`

**Description:** Uploads a training document for processing.

**Request:**
```http
POST /v1/content/documents/upload HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="file"; filename="training-guide.pdf"
Content-Type: application/pdf

{binary file content}
--boundary
Content-Disposition: form-data; name="metadata"
Content-Type: application/json

{
  "title": "Azure OpenAI Integration Guide",
  "description": "Comprehensive guide for integrating Azure OpenAI",
  "tags": ["AI", "Azure", "OpenAI", "Integration"],
  "source_type": "LocalUpload"
}
--boundary--
```

**Request Fields:**
| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `file` | binary | Yes | Document file | PDF, DOCX, PPTX, MD, HTML; max 50MB |
| `metadata.title` | string | Yes | Document title | Max 500 characters |
| `metadata.description` | string | No | Document description | Max 2000 characters |
| `metadata.tags` | array[string] | No | Content tags | Max 10 tags |
| `metadata.source_type` | string | Yes | Upload source | Must be "LocalUpload" |

**Response:**
```json
{
  "document_id": "880e8400-e29b-41d4-a716-446655440003",
  "title": "Azure OpenAI Integration Guide",
  "file_size": 2457600,
  "file_hash": "5f4dcc3b5aa765d61d8327deb882cf99",
  "status": "Ingested",
  "blob_url": "https://edutrack.blob.core.windows.net/documents/880e8400.pdf?{SAS}",
  "created_at": "2025-11-21T10:00:00Z"
}
```

**Status Codes:**
- 201 Created: Document uploaded successfully
- 400 Bad Request: Invalid file format or size
- 401 Unauthorized: Missing or invalid token
- 403 Forbidden: User lacks ContentUploader role
- 413 Payload Too Large: File exceeds 50MB
- 429 Too Many Requests: Rate limit exceeded (10 uploads/hour)

**Reference:** SRS-FUNC-004, SEC-APP-008

---

### 2.2 Get Document Status

**Endpoint:** `GET /documents/{document_id}`

**Description:** Retrieves document metadata and processing status.

**Request:**
```http
GET /v1/content/documents/880e8400-e29b-41d4-a716-446655440003 HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "document_id": "880e8400-e29b-41d4-a716-446655440003",
  "title": "Azure OpenAI Integration Guide",
  "description": "Comprehensive guide for integrating Azure OpenAI",
  "source_type": "LocalUpload",
  "file_type": "PDF",
  "file_size": 2457600,
  "file_hash": "5f4dcc3b5aa765d61d8327deb882cf99",
  "status": "Processed",
  "ingestion_date": "2025-11-21T10:00:00Z",
  "processing_completed_at": "2025-11-21T10:00:45Z",
  "created_by": "550e8400-e29b-41d4-a716-446655440000",
  "tags": ["AI", "Azure", "OpenAI", "Integration"],
  "extraction_accuracy": 97.5,
  "word_count": 5420
}
```

**Status Codes:**
- 200 OK: Document retrieved successfully
- 401 Unauthorized: Invalid token
- 403 Forbidden: User lacks permission to view document
- 404 Not Found: Document ID not found

---

### 2.3 List Documents

**Endpoint:** `GET /documents`

**Description:** Retrieves paginated list of documents.

**Request:**
```http
GET /v1/content/documents?page=1&per_page=20&status=Processed&source_type=LocalUpload HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number (min 1) |
| `per_page` | integer | 20 | Results per page (min 1, max 100) |
| `status` | string | All | Filter by status (Ingested, Processed, Error, Archived) |
| `source_type` | string | All | Filter by source (SharePoint, Confluence, GitHub, LocalUpload) |
| `tags` | string | None | Comma-separated tags to filter |
| `sort_by` | string | ingestion_date | Sort field (title, ingestion_date, file_size) |
| `sort_order` | string | desc | Sort order (asc, desc) |

**Response:**
```json
{
  "documents": [
    {
      "document_id": "880e8400-e29b-41d4-a716-446655440003",
      "title": "Azure OpenAI Integration Guide",
      "file_type": "PDF",
      "file_size": 2457600,
      "status": "Processed",
      "ingestion_date": "2025-11-21T10:00:00Z",
      "tags": ["AI", "Azure", "OpenAI"]
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 94
  }
}
```

**Status Codes:**
- 200 OK: Documents retrieved successfully
- 400 Bad Request: Invalid query parameters
- 401 Unauthorized: Invalid token

**Reference:** SRS-FUNC-012

---

### 2.4 Archive Document

**Endpoint:** `POST /documents/{document_id}/archive`

**Description:** Archives a document (soft delete with 30-day recovery).

**Request:**
```http
POST /v1/content/documents/880e8400-e29b-41d4-a716-446655440003/archive HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "reason": "Content outdated and no longer relevant"
}
```

**Response:**
```json
{
  "document_id": "880e8400-e29b-41d4-a716-446655440003",
  "status": "Archived",
  "archived_at": "2025-11-21T11:00:00Z",
  "recovery_until": "2025-12-21T11:00:00Z"
}
```

**Status Codes:**
- 200 OK: Document archived successfully
- 401 Unauthorized: Invalid token
- 403 Forbidden: User lacks ContentManager role
- 404 Not Found: Document ID not found

**Reference:** SRS-FUNC-013, BR-INGEST-005

---

## 3. Data Models

### 3.1 Document Status Enum
- `Ingested`: File uploaded, awaiting text extraction
- `Processed`: Text extracted successfully
- `Error`: Extraction or processing failed
- `Archived`: Soft-deleted (30-day recovery period)
- `Deleted`: Permanently deleted

### 3.2 Source Type Enum
- `SharePoint`: Microsoft SharePoint Online
- `Confluence`: Atlassian Confluence Cloud
- `GitHub`: GitHub repository
- `LocalUpload`: Manual file upload

---

## 4. Security Controls

### 4.1 File Validation
- **Allowed Formats:** PDF, DOCX, PPTX, MD, HTML (SEC-APP-008)
- **Max File Size:** 50MB (SRS-FUNC-004, BR-INGEST-001)
- **Malware Scanning:** All uploads scanned before storage
- **File Hash:** SHA-256 for deduplication (SRS-FUNC-007)

### 4.2 Rate Limiting
- **Upload:** 10 files per hour per user
- **List:** 100 requests per hour per user
- **Archive:** 50 requests per hour per user

### 4.3 Access Control
- **Upload:** ContentUploader role required
- **View:** Learner can view published documents only
- **Archive/Delete:** ContentManager or Admin role required

**Reference:** SEC-IAM-002, SRS Section 3.1 (RBAC)

---

## 5. Error Handling

### 5.1 Error Response Format
```json
{
  "error": {
    "code": "FILE_TOO_LARGE",
    "message": "File exceeds 50MB limit",
    "details": "Please compress or split the document"
  },
  "timestamp": "2025-11-21T10:30:00Z",
  "request_id": "req-upload-123456"
}
```

### 5.2 Error Codes
| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNSUPPORTED_FORMAT` | 400 | File format not in whitelist |
| `FILE_TOO_LARGE` | 413 | File exceeds 50MB |
| `DUPLICATE_DOCUMENT` | 409 | Document with same hash already exists |
| `EXTRACTION_FAILED` | 500 | Text extraction failed |
| `MALWARE_DETECTED` | 400 | Malicious content detected |

**Reference:** SRS Section 3.1 (Error Handling & Notifications)

---

## 6. Observability

### 6.1 Logging
- **Event:** `content.document.uploaded`, `content.document.processed`, `content.document.archived`
- **Fields:** document_id, user_id, file_size, status, timestamp
- **Retention:** 7 years

### 6.2 Metrics
- **Upload Success Rate:** Target >95%
- **Extraction Accuracy:** Target >95%
- **Processing Time:** <60s P95 (SRS-FUNC-001)
- **Duplicate Rate:** Monitor <1%

**Reference:** PERF-LAT-010 (NFR)

---

## 7. Integration Points

### 7.1 Downstream Services
- **Text Extraction Service:** Triggered on `Ingested` status
- **AI Generation Service:** Triggered on `Processed` status
- **Search Indexer:** Updates index on `Published` module

### 7.2 Event Publishing
```json
{
  "event_type": "document.processed",
  "document_id": "880e8400-e29b-41d4-a716-446655440003",
  "timestamp": "2025-11-21T10:00:45Z",
  "metadata": {
    "word_count": 5420,
    "extraction_accuracy": 97.5
  }
}
```

---

## 8. References
- **SRS:** Section 3.1 (Content Ingestion & Management)
- **NFR:** PERF-LAT-010, SEC-APP-008
- **Threat Model:** TAMP-004, TAMP-007
- **Backlog:** Feature FE-0001, User Story US-0001

---

**Document Status:** ✅ Baseline  
**Owner:** Solution Architect (STK-014)  
**Last Updated:** 2025-11-21
