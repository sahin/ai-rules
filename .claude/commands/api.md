# API Development Guide

Comprehensive API design and implementation reference. Invoke with `/api`.

## RESTful Design

### URL Patterns
```
GET    /api/v1/users           List users
POST   /api/v1/users           Create user
GET    /api/v1/users/{id}      Get user
PUT    /api/v1/users/{id}      Replace user
PATCH  /api/v1/users/{id}      Partial update
DELETE /api/v1/users/{id}      Delete user
GET    /api/v1/users/{id}/posts Nested resource
```

### Response Format (mandatory)
```json
{
  "success": true,
  "data": { "id": 123, "name": "John" },
  "metadata": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "v1",
    "requestId": "req_123456789",
    "pagination": {
      "page": 1, "limit": 20, "total": 100,
      "totalPages": 5, "hasNext": true, "hasPrev": false
    }
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": { "field": "email", "value": "invalid" },
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "trace_987654321"
  }
}
```

## Request Validation

### Schema Validation (Zod example)
```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(2).max(100),
  age: z.number().int().min(0).max(150).optional(),
  role: z.enum(['user', 'admin', 'moderator']),
});

// Middleware
function validate(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return res.status(422).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', details: result.error.issues }
      });
    }
    req.body = result.data;
    next();
  };
}
```

## Pagination
```typescript
// Query params: ?page=1&limit=20&sort=name&order=asc
interface PaginationParams {
  page: number;       // Default: 1
  limit: number;      // Default: 20, max: 100
  sort?: string;
  order?: 'asc' | 'desc';
}

// Implementation
async function listUsers(params: PaginationParams) {
  const offset = (params.page - 1) * params.limit;
  const [users, total] = await Promise.all([
    db.users.findMany({ skip: offset, take: params.limit, orderBy: { [params.sort]: params.order } }),
    db.users.count(),
  ]);
  return {
    data: users,
    pagination: {
      page: params.page, limit: params.limit, total,
      totalPages: Math.ceil(total / params.limit),
      hasNext: params.page * params.limit < total,
      hasPrev: params.page > 1,
    }
  };
}
```

## Authentication Middleware
```typescript
async function authenticate(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ success: false, error: { code: 'MISSING_TOKEN' } });

  const user = await verifyToken(token);
  if (!user) return res.status(401).json({ success: false, error: { code: 'INVALID_TOKEN' } });

  const hasAccess = await checkPermissions(user, req.path, req.method);
  if (!hasAccess) return res.status(403).json({ success: false, error: { code: 'FORBIDDEN' } });

  req.user = user;
  next();
}
```

## API Versioning
- URL versioning recommended: `/api/v1/resource`
- Support previous version for 12 months after new version
- Additive changes (new fields) don't require version bump
- Breaking changes require new version with migration guide
- Deprecation headers: `X-API-Deprecated: true`, `X-API-Sunset-Date: 2025-12-31`

## Rate Limiting
```typescript
import rateLimit from 'express-rate-limit';

const apiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 1000,                 // per user
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      error: { code: 'RATE_LIMIT_EXCEEDED', message: 'Too many requests' }
    });
  },
});
```

## Performance Targets
| Metric | Target |
|--------|--------|
| Simple GET | < 100ms (p95) |
| Complex GET | < 500ms (p95) |
| POST/PUT | < 300ms (p95) |
| Authentication | < 100ms |
| Availability | 99.9% |
| Error rate | < 1% |

## API Monitoring
```typescript
// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info('API request', {
      method: req.method, path: req.path,
      status: res.statusCode, duration,
      requestId: req.get('X-Request-ID'),
    });
    if (duration > 1000) {
      logger.warn('Slow request', { method: req.method, path: req.path, duration });
    }
  });
  next();
});
```

## OpenAPI Documentation
- Document every endpoint with request/response schemas
- Include authentication requirements
- Provide example requests and responses
- Document error codes and their meanings
- Keep docs in sync with implementation

## Checklist Before Deployment
- [ ] RESTful URL design
- [ ] Consistent response format
- [ ] Input validation on all endpoints
- [ ] Authentication and authorization
- [ ] Rate limiting configured
- [ ] Error handling standardized
- [ ] API versioning in place
- [ ] Security headers set
- [ ] OpenAPI docs complete
- [ ] 100% test coverage
