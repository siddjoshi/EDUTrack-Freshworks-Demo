# Authentication API Specification
## EDUTrack Platform

---

## Document Control
| Version | Date | Author | Status |
|---------|------|--------|--------|
| 1.0 | 2025-11-21 | Security Architect | Baseline |

---

## 1. Overview

### 1.1 Purpose
This document specifies the Authentication API for the EDUTrack platform, including Azure AD SSO integration, token management, session handling, and security controls.

### 1.2 Base URL
- **Production:** `https://api.edutrack.company.com/auth`
- **Staging:** `https://api-staging.edutrack.company.com/auth`
- **Development:** `https://api-dev.edutrack.company.com/auth`

### 1.3 Authentication Method
- **OAuth 2.0 / OpenID Connect** via Azure AD (Entra ID)
- **Bearer Token** authentication for API requests

---

## 2. Endpoints

### 2.1 Initiate SSO Login

**Endpoint:** `GET /login`

**Description:** Redirects user to Azure AD login page for authentication.

**Request:**
```http
GET /auth/login HTTP/1.1
Host: api.edutrack.company.com
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `redirect_uri` | string | No | URL to redirect after successful login (default: `/dashboard`) |
| `state` | string | No | Opaque value for CSRF protection |

**Response:**
```http
HTTP/1.1 302 Found
Location: https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize?...
```

**Success:** Redirects to Azure AD login page
**Error Handling:**
- 400 Bad Request: Invalid redirect_uri
- 500 Internal Server Error: Azure AD configuration error

---

### 2.2 OAuth Callback

**Endpoint:** `GET /callback`

**Description:** Handles Azure AD OAuth callback after successful authentication.

**Request:**
```http
GET /auth/callback?code={authorization_code}&state={state} HTTP/1.1
Host: api.edutrack.company.com
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `code` | string | Yes | Authorization code from Azure AD |
| `state` | string | Yes | State parameter for CSRF validation |

**Response:**
```http
HTTP/1.1 302 Found
Location: {redirect_uri}
Set-Cookie: session_token={JWT}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600
```

**Success Cookies:**
- `session_token`: JWT with 1-hour expiration
- `refresh_token`: Long-lived refresh token (7 days)

**Error Handling:**
- 400 Bad Request: Missing or invalid code
- 403 Forbidden: State mismatch (CSRF attack)
- 401 Unauthorized: Azure AD authorization failed

---

### 2.3 Get Current User Profile

**Endpoint:** `GET /me`

**Description:** Retrieves authenticated user's profile information.

**Request:**
```http
GET /auth/me HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "john.doe@company.com",
  "first_name": "John",
  "last_name": "Doe",
  "job_title": "Senior Software Engineer",
  "department": "Engineering",
  "manager_id": "660e8400-e29b-41d4-a716-446655440001",
  "role": "Learner",
  "created_at": "2025-11-01T00:00:00Z",
  "last_login": "2025-11-21T08:30:00Z"
}
```

**Status Codes:**
- 200 OK: Profile retrieved successfully
- 401 Unauthorized: Invalid or expired token
- 404 Not Found: User profile not found

---

### 2.4 Refresh Access Token

**Endpoint:** `POST /refresh`

**Description:** Exchanges refresh token for new access token.

**Request:**
```http
POST /auth/refresh HTTP/1.1
Host: api.edutrack.company.com
Content-Type: application/json

{
  "refresh_token": "{refresh_token}"
}
```

**Response:**
```json
{
  "access_token": "{new_access_token}",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "{new_refresh_token}"
}
```

**Status Codes:**
- 200 OK: Token refreshed successfully
- 401 Unauthorized: Invalid or expired refresh token
- 429 Too Many Requests: Rate limit exceeded

---

### 2.5 Logout

**Endpoint:** `POST /logout`

**Description:** Invalidates session token and logs out user.

**Request:**
```http
POST /auth/logout HTTP/1.1
Host: api.edutrack.company.com
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "message": "Logout successful"
}
```

**Status Codes:**
- 200 OK: Logout successful
- 401 Unauthorized: Invalid token

**Cookie Clearing:**
Response clears `session_token` and `refresh_token` cookies.

---

## 3. Data Models

### 3.1 JWT Payload

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",  // user_id
  "email": "john.doe@company.com",
  "name": "John Doe",
  "role": "Learner",
  "iat": 1700000000,  // Issued at (Unix timestamp)
  "exp": 1700003600,  // Expiration (1 hour later)
  "iss": "https://edutrack.company.com",
  "aud": "edutrack-api"
}
```

---

## 4. Security Controls

### 4.1 Rate Limiting
- **Login Endpoint:** 10 requests per minute per IP
- **Refresh Endpoint:** 30 requests per hour per user
- **Account Lockout:** 5 failed login attempts within 15 minutes

**Reference:** SEC-IAM-005 (NFR)

### 4.2 Token Security
- **Access Token Expiration:** 1 hour (SEC-IAM-004)
- **Refresh Token Expiration:** 7 days
- **Token Storage:** HttpOnly, Secure cookies
- **CSRF Protection:** State parameter validation

### 4.3 Session Management
- **Session Timeout:** 30 minutes of inactivity (SEC-IAM-006)
- **Concurrent Sessions:** Maximum 3 active sessions per user
- **Session Revocation:** On logout or password change

---

## 5. Error Responses

### 5.1 Standard Error Format

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Access token has expired",
    "details": "Please refresh your token or log in again"
  },
  "timestamp": "2025-11-21T10:30:00Z",
  "request_id": "req-123456789"
}
```

### 5.2 Error Codes

| Code | HTTP Status | Description | User Action |
|------|-------------|-------------|-------------|
| `INVALID_CREDENTIALS` | 401 | Invalid username or password | Re-enter credentials |
| `TOKEN_EXPIRED` | 401 | Access token has expired | Refresh token or re-login |
| `TOKEN_INVALID` | 401 | Malformed or tampered token | Clear cookies and re-login |
| `ACCOUNT_LOCKED` | 403 | Too many failed login attempts | Wait 15 minutes or contact IT |
| `INSUFFICIENT_PRIVILEGES` | 403 | User lacks required role | Contact admin for role assignment |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests | Wait and retry |

---

## 6. Integration Testing

### 6.1 Test Scenarios

| Test Case | Expected Outcome |
|-----------|------------------|
| Valid Azure AD login | 302 redirect to callback with authorization code |
| Invalid credentials | 401 Unauthorized from Azure AD |
| CSRF attack (state mismatch) | 403 Forbidden |
| Expired access token | 401 Unauthorized; prompt for refresh |
| Valid refresh token | New access token issued |
| Account lockout (5 failures) | 403 Forbidden for 15 minutes |
| Logout | Session token invalidated; cookies cleared |

---

## 7. Observability

### 7.1 Logging
- **Event:** `authentication.login.success`, `authentication.login.failure`
- **Fields:** user_id, email, IP address, timestamp, user agent
- **Retention:** 7 years (audit compliance)

### 7.2 Metrics
- **Login Success Rate:** Target >98%
- **Token Refresh Latency:** <500ms P95
- **Failed Login Rate:** Alert if >2%

---

## 8. References
- **NFR:** SEC-IAM-001 (Azure AD SSO), SEC-IAM-004 (Token expiration), SEC-IAM-005 (Account lockout)
- **Threat Model:** SPOOF-001, SPOOF-002, PRIV-007
- **SRS:** Section 2.1 (User Roles & Access)

---

**Document Status:** ✅ Baseline  
**Owner:** Security Architect (STK-027)  
**Last Updated:** 2025-11-21
