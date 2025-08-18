# Universal Backend Security Patterns

This document provides security patterns and best practices applicable to all backend systems. For project-specific implementation details, refer to your project's security documentation.

## 🔒 AUTHENTICATION & AUTHORIZATION PATTERNS

### Authentication Standards
- **Password Requirements**: Minimum 12 characters with complexity
- **Multi-Factor Authentication**: Required for production access
- **Session Management**: Secure tokens with proper timeout
- **Password Storage**: Use bcrypt, scrypt, or Argon2
- **Brute Force Protection**: Implement account lockout

### Authorization Patterns
- **Least Privilege**: Grant minimum required permissions
- **Role-Based Access Control (RBAC)**: Define clear role hierarchies
- **Resource-Level Security**: Implement fine-grained controls
- **Permission Auditing**: Regular access reviews

### Implementation Example
```typescript
// Authentication pattern
interface AuthenticationService {
  authenticate(credentials: Credentials): Promise<AuthToken>;
  validateToken(token: string): Promise<TokenPayload>;
  refreshToken(refreshToken: string): Promise<AuthToken>;
  logout(token: string): Promise<void>;
}

// Authorization pattern
interface AuthorizationService {
  hasPermission(user: User, resource: string, action: string): boolean;
  hasRole(user: User, role: string): boolean;
  enforcePermission(user: User, permission: string): void;
}
```

## 🛡️ INPUT VALIDATION PATTERNS (MANDATORY)

### Never Trust User Input - Comprehensive Validation
Every application input MUST be validated at the boundary before processing.

#### **Validation Strategy (MANDATORY)**
1. **Never trust client input** - Always validate server-side regardless of client-side validation
2. **Whitelist approach** - Define what's allowed, reject everything else (no blacklisting)
3. **Type safety** - Enforce strict types and schemas
4. **Length limits** - Prevent buffer overflows and DoS attacks
5. **Encoding** - Proper output encoding to prevent injection attacks
6. **Sanitization** - Clean data before database operations
7. **Parametrization** - Use parameterized queries only, never string concatenation

#### **Input Validation Requirements (MANDATORY)**
All inputs must validate:
- **Type**: Correct data type (string, number, email, etc.)
- **Length**: Minimum and maximum constraints
- **Format**: Regex patterns for structured data
- **Range**: Numerical bounds and allowed values
- **Encoding**: Character set and encoding standards
- **Business Rules**: Domain-specific constraints

### Common Validation Patterns
```typescript
// Email validation
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MAX_EMAIL_LENGTH = 254;

// SQL injection prevention
// Always use parameterized queries
const safeQuery = 'SELECT * FROM users WHERE id = $1';

// XSS prevention
function escapeHtml(unsafe: string): string {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
```

## 🔐 DATA PROTECTION PATTERNS

### Encryption Standards
- **At Rest**: AES-256 for stored data
- **In Transit**: TLS 1.2+ for all communications
- **Key Management**: Separate key storage from data
- **Rotation**: Regular key rotation schedule

### Data Classification
1. **Public**: No restrictions
2. **Internal**: Company use only
3. **Confidential**: Restricted access
4. **Restricted**: Highest security level

## 🌐 API SECURITY PATTERNS

### Core API Security
- **HTTPS Only**: No HTTP in production
- **Rate Limiting**: Prevent abuse
- **CORS Configuration**: Restrict origins
- **API Versioning**: Maintain compatibility
- **Request Signing**: For sensitive operations

### Security Headers
```typescript
const securityHeaders = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Content-Security-Policy': "default-src 'self'",
  'Referrer-Policy': 'no-referrer'
};
```

## 🔍 SECURITY TESTING PATTERNS

### Testing Approaches
1. **Static Analysis (SAST)**
   - Integration: CI/CD pipeline
   - Focus: Code vulnerabilities, hardcoded secrets
   - Tools: SonarQube, Semgrep, Bandit

2. **Dynamic Testing (DAST)**
   - Integration: Pre-production
   - Focus: Runtime vulnerabilities
   - Tools: OWASP ZAP, Burp Suite

3. **Dependency Scanning**
   - Integration: Build process
   - Focus: Third-party vulnerabilities
   - Tools: Snyk, npm audit, safety

4. **Penetration Testing**
   - Frequency: Regular schedule
   - Focus: Real-world attack scenarios
   - Approach: Both automated and manual

## 📋 SECURITY CHECKLIST FOR EVERY FEATURE (MANDATORY)

### **Feature Development Security Checklist**
Every new feature and change MUST complete this checklist:

#### **Input Validation (MANDATORY)**
- [ ] All user inputs validated at server boundary
- [ ] Type validation implemented (string, number, email, etc.)
- [ ] Length restrictions enforced (prevent DoS)
- [ ] Format validation applied (regex patterns)
- [ ] Range validation for numerical inputs
- [ ] File upload validation (type, size, content)
- [ ] JSON/XML schema validation for APIs
- [ ] SQL injection prevention (parameterized queries only)
- [ ] XSS prevention (output encoding/escaping)
- [ ] CSRF protection implemented where needed

#### **Output Encoding (MANDATORY)**
- [ ] HTML encoding for web output
- [ ] JSON encoding for API responses
- [ ] URL encoding for redirects
- [ ] SQL encoding for database queries
- [ ] Context-appropriate encoding applied

#### **Authentication & Authorization (MANDATORY)**
- [ ] Authentication required for protected endpoints
- [ ] Authorization checks implemented at function level
- [ ] Permission boundaries clearly defined
- [ ] Session management secure (timeout, invalidation)
- [ ] Token validation implemented
- [ ] Role-based access control enforced

#### **Rate Limiting & DoS Protection (MANDATORY)**
- [ ] API rate limiting configured
- [ ] Resource consumption limits set
- [ ] Request size limits enforced
- [ ] Timeout mechanisms implemented
- [ ] Concurrent request limits applied

#### **Audit Logging (MANDATORY)**
- [ ] Security events logged (auth attempts, failures)
- [ ] User actions audited (creation, modification, deletion)
- [ ] Access attempts recorded
- [ ] Error conditions logged (without sensitive data)
- [ ] Log integrity protected (append-only, signed)

#### **Data Protection (MANDATORY)**
- [ ] Sensitive data encrypted in transit (HTTPS/TLS)
- [ ] Sensitive data encrypted at rest
- [ ] Secrets not hardcoded (environment variables)
- [ ] Database connections secured
- [ ] Backup data protected
- [ ] Data retention policies followed

#### **Error Handling & Information Disclosure**
- [ ] Generic error messages to users (no system details)
- [ ] Detailed errors logged securely
- [ ] Stack traces not exposed to users
- [ ] Database errors not leaked
- [ ] System information not disclosed

#### **Dependencies & Configuration**
- [ ] Third-party dependencies scanned for vulnerabilities
- [ ] Security patches applied
- [ ] Secure configuration implemented
- [ ] Default credentials changed
- [ ] Unnecessary services disabled

### **Pre-Deployment Security Review (MANDATORY)**
- [ ] Static code analysis completed (SAST)
- [ ] Dependency vulnerability scan passed
- [ ] Security unit tests written and passing
- [ ] Integration security tests completed
- [ ] Manual security review conducted
- [ ] Penetration testing completed (for major features)
- [ ] Security documentation updated
- [ ] Incident response plan updated if needed

### **Production Security Monitoring**
- [ ] Security monitoring alerts configured
- [ ] Anomaly detection enabled
- [ ] Log analysis setup
- [ ] Security metrics tracked
- [ ] Incident response procedures tested

### **Ongoing Security Tasks**
- [ ] Regular dependency updates
- [ ] Security patch management
- [ ] Access review audits
- [ ] Security training completion
- [ ] Incident response drills
- [ ] Vulnerability assessments
- [ ] Security policy updates

## 🚨 INCIDENT RESPONSE FRAMEWORK

### Response Process
1. **Detect**: Identify security events
2. **Analyze**: Assess impact and scope
3. **Contain**: Limit damage spread
4. **Eradicate**: Remove threat
5. **Recover**: Restore operations
6. **Learn**: Improve defenses

### Key Metrics
- Mean Time to Detect (MTTD)
- Mean Time to Respond (MTTR)
- Vulnerability remediation time
- Security training coverage

## 🎯 SECURITY PRINCIPLES

### Core Principles
1. **Defense in Depth**: Multiple security layers
2. **Fail Secure**: Default to secure state
3. **Zero Trust**: Verify everything
4. **Least Privilege**: Minimal access rights
5. **Separation of Duties**: Divide critical functions

### Security by Design
- Consider security from project start
- Threat modeling for new features
- Security reviews in development
- Regular security assessments
- Continuous security improvement

---

**Note**: This document provides universal patterns. For specific implementation requirements, compliance needs, or technology-specific guidance, consult your project's security documentation.