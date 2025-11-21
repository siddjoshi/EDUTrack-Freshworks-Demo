# AI Content Generation API Specification
## EDUTrack Platform

---

## Document Control
| Version | Date | Author | Status |
|---------|------|--------|--------|
| 1.0 | 2025-11-21 | Solution Architect | Baseline |

---

## 1. Overview

### 1.1 Purpose
This document specifies the AI Content Generation API that transforms ingested documents into structured training modules using Azure OpenAI (GPT-4).

### 1.2 Base URL
- **Production:** `https://api.edutrack.company.com/v1/ai`
- **Staging:** `https://api-staging.edutrack.company.com/v1/ai`

### 1.3 Authentication
- **Method:** Bearer token (OAuth 2.0)
- **Required Role:** ContentManager, L&DAdmin, Admin

---

## 2. Endpoints

### 2.1 Generate Training Module

**Endpoint:** `POST /generate/module`

**Description:** Generates a training module from a source document using AI.

**Request:**
```http
POST /v1/ai/generate/module HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "document_id": "880e8400-e29b-41d4-a716-446655440003",
  "generation_options": {
    "include_assessments": true,
    "min_objectives": 3,
    "max_objectives": 7,
    "difficulty_level": "Intermediate",
    "target_duration_minutes": 60
  }
}
```

**Request Fields:**
| Field | Type | Required | Description | Default |
|-------|------|----------|-------------|---------|
| `document_id` | UUID | Yes | Source document identifier | - |
| `generation_options.include_assessments` | boolean | No | Generate quiz questions | true |
| `generation_options.min_objectives` | integer | No | Minimum learning objectives | 3 |
| `generation_options.max_objectives` | integer | No | Maximum learning objectives | 7 |
| `generation_options.difficulty_level` | string | No | Target difficulty | Intermediate |
| `generation_options.target_duration_minutes` | integer | No | Estimated completion time | 45 |

**Response:**
```json
{
  "module_id": "770e8400-e29b-41d4-a716-446655440002",
  "document_id": "880e8400-e29b-41d4-a716-446655440003",
  "status": "Generated",
  "generation_time_seconds": 15.3,
  "hallucination_score": 12.5,
  "tokens_used": 3542,
  "cost_usd": 0.1062,
  "content_preview": {
    "title": "Introduction to Azure OpenAI",
    "summary": "Learn how to integrate Azure OpenAI...",
    "objectives_count": 5,
    "concepts_count": 12,
    "assessment_count": 13
  },
  "created_at": "2025-11-21T10:05:15Z"
}
```

**Status Codes:**
- 201 Created: Module generated successfully
- 400 Bad Request: Invalid request parameters
- 401 Unauthorized: Invalid token
- 403 Forbidden: User lacks ContentManager role
- 404 Not Found: Document ID not found
- 429 Too Many Requests: AI quota exhausted
- 500 Internal Server Error: AI generation failed

**SLA:** <20 seconds P95 (PERF-LAT-005)

**Reference:** SRS-FUNC-031, BRD-FR-008

---

### 2.2 Get Module Details

**Endpoint:** `GET /modules/{module_id}`

**Description:** Retrieves full AI-generated module content.

**Request:**
```http
GET /v1/ai/modules/770e8400-e29b-41d4-a716-446655440002 HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "module_id": "770e8400-e29b-41d4-a716-446655440002",
  "document_id": "880e8400-e29b-41d4-a716-446655440003",
  "title": "Introduction to Azure OpenAI",
  "summary": "Learn how to integrate Azure OpenAI into applications...",
  "detailed_explanation": "Azure OpenAI Service provides REST API access...",
  "learning_objectives": [
    "Understand Azure OpenAI service capabilities",
    "Set up Azure OpenAI resource and API keys",
    "Make API calls for text generation and embeddings",
    "Implement best practices for prompt engineering",
    "Monitor token usage and costs"
  ],
  "key_concepts": [
    {
      "concept": "Azure OpenAI Service",
      "definition": "Enterprise-grade AI service providing access to GPT models with enhanced security"
    },
    {
      "concept": "Embeddings",
      "definition": "Numerical vector representations of text for semantic search and similarity"
    }
  ],
  "instructions": "Step 1: Create Azure OpenAI resource...",
  "duration_minutes": 60,
  "difficulty": "Intermediate",
  "generated_at": "2025-11-21T10:05:15Z",
  "hallucination_score": 12.5,
  "status": "UnderReview",
  "metadata": {
    "model": "gpt-4",
    "tokens_used": 3542,
    "cost_usd": 0.1062
  }
}
```

**Status Codes:**
- 200 OK: Module retrieved successfully
- 401 Unauthorized: Invalid token
- 403 Forbidden: User lacks permission to view module
- 404 Not Found: Module ID not found

**Reference:** SRS-FUNC-032 to SRS-FUNC-036

---

### 2.3 Get Module Assessments

**Endpoint:** `GET /modules/{module_id}/assessments`

**Description:** Retrieves AI-generated quiz questions for a module.

**Response:**
```json
{
  "module_id": "770e8400-e29b-41d4-a716-446655440002",
  "assessments": [
    {
      "assessment_id": "aa0e8400-e29b-41d4-a716-446655440010",
      "question_type": "MCQ",
      "question_text": "What is the primary benefit of using Azure OpenAI Service over OpenAI's public API?",
      "answer_choices": [
        "Lower cost",
        "Enterprise security and compliance",
        "Faster response times",
        "More AI models available"
      ],
      "correct_answer": "Enterprise security and compliance",
      "explanation": "Azure OpenAI Service provides enterprise-grade security, data residency, and compliance features...",
      "difficulty": "Medium",
      "order": 1,
      "points": 10
    },
    {
      "assessment_id": "bb0e8400-e29b-41d4-a716-446655440011",
      "question_type": "Scenario",
      "question_text": "Your application needs to analyze customer feedback sentiment. Which Azure OpenAI capability would you use?",
      "answer_choices": [
        "Text generation",
        "Text classification (sentiment analysis)",
        "Image generation",
        "Speech recognition"
      ],
      "correct_answer": "Text classification (sentiment analysis)",
      "explanation": "Sentiment analysis falls under text classification using GPT models...",
      "difficulty": "Medium",
      "order": 2,
      "points": 15
    }
  ],
  "total_assessments": 13,
  "total_points": 150
}
```

**Status Codes:**
- 200 OK: Assessments retrieved successfully
- 404 Not Found: Module ID not found

**Reference:** SRS-FUNC-037, SRS-FUNC-038

---

### 2.4 Regenerate Module

**Endpoint:** `POST /modules/{module_id}/regenerate`

**Description:** Regenerates module content using updated options or after SME feedback.

**Request:**
```http
POST /v1/ai/modules/770e8400-e29b-41d4-a716-446655440002/regenerate HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "regeneration_reason": "SME feedback: Add more code examples",
  "generation_options": {
    "include_code_examples": true,
    "difficulty_level": "Advanced"
  }
}
```

**Response:**
```json
{
  "module_id": "770e8400-e29b-41d4-a716-446655440002",
  "version": 2,
  "status": "Generated",
  "regenerated_at": "2025-11-21T11:00:00Z",
  "hallucination_score": 10.2
}
```

**Status Codes:**
- 200 OK: Module regenerated successfully
- 403 Forbidden: Module already approved (cannot regenerate)
- 429 Too Many Requests: AI quota exhausted

---

## 3. Security Controls

### 3.1 PII Detection
- **Pre-Processing:** All document text scanned for PII before OpenAI API call
- **Detection Methods:** Regex patterns + NLP entity recognition
- **Action:** Block generation if PII detected; notify user

**Reference:** SEC-DATA-003, SEC-AI-003

### 3.2 Prompt Injection Prevention
- **Input Validation:** Sanitize user inputs to prevent prompt manipulation
- **Output Validation:** Check AI responses for unexpected patterns
- **Monitoring:** Log all prompts and responses for security audit

**Reference:** SEC-AI-005, TAMP-003

### 3.3 AI Quota Management
- **Token Quota:** 100K tokens per minute (Azure OpenAI limit)
- **Cost Tracking:** Log token usage and cost per generation
- **Throttling:** Queue requests if quota <90% utilization

**Reference:** PERF-RES-006, COST-004

---

## 4. Hallucination Detection

### 4.1 Scoring Algorithm
- **Range:** 0.00 (no hallucination risk) to 100.00 (high risk)
- **Threshold:** >30% flagged for SME attention
- **Factors:** Factual consistency, source attribution, confidence level

**Reference:** SRS-FUNC-042, SEC-AI-002

### 4.2 Flagging Rules
| Score Range | Risk Level | Action |
|-------------|------------|--------|
| 0-10 | Low | Auto-approve for review |
| 10-30 | Medium | Normal SME review |
| 30-60 | High | Flag for detailed SME review |
| 60-100 | Critical | Block publish; manual intervention |

---

## 5. Error Handling

### 5.1 Error Codes
| Code | HTTP Status | Description | Remediation |
|------|-------------|-------------|-------------|
| `PII_DETECTED` | 400 | PII found in document | Redact PII and retry |
| `QUOTA_EXCEEDED` | 429 | AI token quota exhausted | Wait or request quota increase |
| `GENERATION_TIMEOUT` | 504 | AI generation exceeded 30s timeout | Retry with smaller document |
| `HALLUCINATION_CRITICAL` | 400 | Hallucination score >60% | Review source document quality |
| `MODEL_ERROR` | 500 | Azure OpenAI service error | Retry or contact support |

---

## 6. Observability

### 6.1 Logging
- **Event:** `ai.generation.started`, `ai.generation.completed`, `ai.generation.failed`
- **Fields:** module_id, document_id, tokens_used, cost_usd, hallucination_score, generation_time_seconds
- **Retention:** 7 years (AI governance requirement)

**Reference:** SEC-AI-001, SRS-FUNC-045

### 6.2 Metrics
- **Generation Success Rate:** Target >95%
- **Generation Time:** <20s P95
- **Hallucination Rate:** <10% of modules flagged (score >30%)
- **Token Cost per Module:** Monitor average cost

---

## 7. Integration Points

### 7.1 Upstream Dependencies
- **Document Service:** Provides source text for generation
- **PII Detection Service:** Pre-processes text before AI call

### 7.2 Downstream Services
- **Review Workflow:** Routes generated modules to SME reviewers
- **Search Index:** Indexes approved modules for discovery

---

## 8. References
- **SRS:** Section 3.2 (AI Content Generation)
- **NFR:** PERF-LAT-005, PERF-RES-006, SEC-AI-001 to SEC-AI-006
- **Threat Model:** TAMP-003, INFO-001, PRIV-006
- **Backlog:** Feature FE-0002

---

**Document Status:** ✅ Baseline  
**Owner:** Solution Architect (STK-014)  
**Last Updated:** 2025-11-21
