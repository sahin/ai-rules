# API & Security Standards

## RESTful URL Design
- Resource-based: `/api/v1/users/{id}/posts` not `/api/getUser`
- No verbs in URLs - use HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Plural nouns for collections: `/users`, `/orders`
- Nested resources for relationships: `/users/{id}/posts`

## HTTP Status Codes
- 200 OK, 201 Created, 204 No Content
- 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found
- 409 Conflict, 422 Unprocessable Entity, 429 Too Many Requests
- 500 Internal Server Error, 503 Service Unavailable

## Response Format
```json
{
  "success": true,
  "data": {},
  "error": { "code": "VALIDATION_ERROR", "message": "..." },
  "metadata": { "timestamp": "...", "requestId": "...", "pagination": {} }
}
```

## Input Validation
- Validate all inputs server-side regardless of client validation
- Whitelist approach: define what's allowed, reject everything else
- Validate type, length, format, range on every input
- Use parameterized queries only - never string concatenation for SQL
- Sanitize output: HTML encoding, JSON encoding, URL encoding as appropriate

## Authentication & Authorization
- Bearer tokens in Authorization header
- Least privilege: grant minimum required permissions
- RBAC: define clear role hierarchies
- Validate tokens on every request
- Implement session timeout and token refresh

## Security Headers
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'
Referrer-Policy: no-referrer
```

## Rate Limiting
- Apply to all public endpoints
- Return 429 with Retry-After header
- Implement per-user and per-IP limits

## OWASP Top 10 Awareness
- SQL injection: parameterized queries only
- XSS: escape all user-generated content on output
- CSRF: implement token-based protection
- Broken auth: enforce strong passwords, MFA for production
- Security misconfiguration: no default credentials, disable unnecessary services
- Sensitive data exposure: encrypt at rest (AES-256) and in transit (TLS 1.2+)
- Never log passwords, tokens, credit cards, or PII
- Never hardcode secrets - use environment variables
