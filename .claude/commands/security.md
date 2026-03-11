# Security Checklist

Use this guide when implementing security features, reviewing code for vulnerabilities, or responding to security incidents.

## Feature Security Checklist

Run through this checklist for every feature that handles user data or external input.

### Input Validation
- [ ] All user input validated server-side (never trust client-only validation)
- [ ] Whitelist approach: define what's allowed, reject everything else
- [ ] Validate: type, length, format, range on every input
- [ ] File uploads: validate type, size, scan for malware
- [ ] Reject unexpected fields (no mass assignment)

### Output Encoding
- [ ] HTML output: escape with context-aware encoding
- [ ] JSON responses: properly serialized (no raw string injection)
- [ ] URLs: encode user-provided values in query parameters
- [ ] SQL: parameterized queries only (never string concatenation)
- [ ] Shell commands: avoid user input; if necessary, strict whitelist

### Authentication
- [ ] Passwords: bcrypt/argon2 with cost factor >= 12
- [ ] Tokens: cryptographically random, sufficient length (>= 256 bits)
- [ ] Sessions: rotate ID after login, expire after inactivity
- [ ] MFA: enforced for admin accounts, available for all users
- [ ] Brute force: account lockout after 5 failed attempts (with backoff)

### Authorization
- [ ] Every endpoint checks permissions (no "security by obscurity")
- [ ] Least privilege: users get minimum required access
- [ ] IDOR prevention: verify resource ownership before access
- [ ] Admin functions: separate middleware with explicit role check
- [ ] API keys: scoped to minimum required permissions

### Rate Limiting
- [ ] Login endpoint: strict limits (5/min per IP, 10/min per account)
- [ ] API endpoints: per-user and per-IP limits
- [ ] File upload: size and frequency limits
- [ ] Password reset: rate limited to prevent enumeration
- [ ] Return 429 with Retry-After header

### Data Protection
- [ ] Encryption at rest: AES-256 for sensitive data
- [ ] Encryption in transit: TLS 1.2+ (no TLS 1.0/1.1)
- [ ] PII: minimize collection, define retention policy
- [ ] Backups: encrypted, access-controlled, tested recovery
- [ ] Secrets: environment variables only (never in code or config files)

### Error Handling
- [ ] No stack traces in production responses
- [ ] No internal details leaked (database names, file paths, versions)
- [ ] Generic error messages for auth failures (prevent enumeration)
- [ ] Errors logged server-side with full context for debugging
- [ ] Custom error pages for 4xx/5xx (no framework defaults)

### Headers & Configuration
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 0  (rely on CSP instead)
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

### Dependencies
- [ ] `npm audit` clean (no critical/high vulnerabilities)
- [ ] Dependencies pinned to exact versions in lockfile
- [ ] No packages with known vulnerabilities
- [ ] Automated dependency scanning in CI (Dependabot/Snyk)
- [ ] Review new dependencies before adding (check maintenance, license)

## OWASP Top 10 Quick Reference

### 1. Injection (SQL, NoSQL, OS, LDAP)
```typescript
// BAD: SQL injection
db.query(`SELECT * FROM users WHERE email = '${email}'`);

// GOOD: Parameterized query
db.query('SELECT * FROM users WHERE email = $1', [email]);
```

### 2. Broken Authentication
```typescript
// Password hashing
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(password, 12);
const valid = await bcrypt.compare(password, hash);

// Session management
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { secure: true, httpOnly: true, sameSite: 'strict', maxAge: 3600000 },
}));
```

### 3. Sensitive Data Exposure
```typescript
// Never log sensitive data
logger.info('User login', { userId: user.id }); // GOOD
logger.info('User login', { email, password });  // BAD

// Never return sensitive fields
const { password, resetToken, ...safeUser } = user;
res.json(safeUser);
```

### 4. XSS (Cross-Site Scripting)
```typescript
// React auto-escapes JSX (safe by default)
<p>{userInput}</p>  // Safe

// DANGEROUS: bypasses escaping
<div dangerouslySetInnerHTML={{ __html: userInput }} />  // Avoid!

// If you must render HTML, sanitize first
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

### 5. Broken Access Control
```typescript
// Always verify resource ownership
app.get('/api/orders/:id', auth, async (req, res) => {
  const order = await db.orders.findById(req.params.id);
  if (!order) return res.status(404).json({ error: 'Not found' });

  // CRITICAL: verify ownership
  if (order.userId !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }

  res.json(order);
});
```

### 6. Security Misconfiguration
```typescript
// Disable unnecessary features
app.disable('x-powered-by');

// Production settings
if (process.env.NODE_ENV === 'production') {
  app.set('trust proxy', 1);
  // No detailed error messages
  app.use((err, req, res, next) => {
    logger.error('Unhandled error', { error: err.message, requestId: req.id });
    res.status(500).json({ error: 'Internal server error' });
  });
}
```

## Incident Response Framework

### Severity Levels
| Level | Description | Response Time | Examples |
|-------|-------------|---------------|----------|
| P1 Critical | Active exploitation, data breach | < 1 hour | SQL injection in prod, leaked credentials |
| P2 High | Exploitable vulnerability found | < 4 hours | Auth bypass, privilege escalation |
| P3 Medium | Potential vulnerability | < 24 hours | Missing rate limiting, weak CSP |
| P4 Low | Best practice violation | Next sprint | Missing security header, verbose errors |

### Incident Response Steps
1. **Detect**: Alert triggered or vulnerability reported
2. **Contain**: Isolate affected systems (block IPs, disable features)
3. **Assess**: Determine scope and impact
4. **Fix**: Develop and deploy patch
5. **Recover**: Restore normal operations
6. **Review**: Post-mortem, update procedures, communicate to affected users

### Immediate Actions for P1/P2
```bash
# Rotate compromised credentials immediately
# Revoke affected tokens/sessions
# Block suspicious IPs at WAF/load balancer
# Enable enhanced logging for affected endpoints
# Notify security team and stakeholders
```

## Security Testing Integration

### SAST (Static Analysis)
```yaml
# Run in CI pipeline
- name: Security scan
  run: |
    npx eslint --config .eslintrc.security.js src/
    npm audit --audit-level=high
    npx snyk test
```

### DAST (Dynamic Analysis)
```bash
# Run against staging environment
# OWASP ZAP baseline scan
docker run -t owasp/zap2docker-stable zap-baseline.py -t https://staging.example.com

# API security scan
docker run -t owasp/zap2docker-stable zap-api-scan.py -t https://staging.example.com/api/openapi.json
```

### Dependency Scanning
```bash
# Check for known vulnerabilities
npm audit

# Fix automatically where possible
npm audit fix

# For manual fixes (breaking changes)
npm audit fix --force  # Review changes carefully!

# Continuous monitoring
# Set up Dependabot or Snyk for automated PRs
```

## Secrets Management

### Rules
- Never commit secrets to git (use `.gitignore` and pre-commit hooks)
- Never hardcode secrets in source code
- Use environment variables for all secrets
- Rotate secrets regularly (90 days for production)
- Use different secrets per environment

### Pre-Commit Hook for Secret Detection
```bash
# .husky/pre-commit
npx secretlint "**/*"
```

### Environment Variable Checklist
```bash
# Required for every environment
DATABASE_URL=          # Connection string (never log this)
SESSION_SECRET=        # Random, >= 32 characters
JWT_SECRET=            # Random, >= 64 characters
API_KEYS=              # External service keys

# Production-only
SENTRY_DSN=            # Error tracking
SMTP_PASSWORD=         # Email service
AWS_ACCESS_KEY_ID=     # Cloud credentials
```