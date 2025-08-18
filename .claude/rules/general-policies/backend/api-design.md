# Universal API Design Rules

This document outlines universal standards for API design, RESTful services, GraphQL APIs, and API management practices that must be followed across all software development projects.

## 🚨 CRITICAL: API Testing 100% Coverage Rule

### Core Principles
1. **NO API ENDPOINT WITHOUT TESTS** - Every single API endpoint MUST have comprehensive test coverage
2. **100% COVERAGE REQUIRED** - All API routes must maintain 100% test coverage
3. **TEST-FIRST DEVELOPMENT** - Write or update tests BEFORE marking any task as complete
4. **CONTINUOUS VALIDATION** - Run tests after EVERY change to API code

### Enforcement Rules
- ❌ Complete a task without 100% API test coverage
- ❌ Show task as "done" if tests are failing
- ❌ Implement new features without test coverage
- ❌ Modify existing APIs without updating tests
- ❌ Skip test execution after changes

✅ Required test scenarios for EVERY endpoint:
- Happy path scenarios (200/201)
- Error handling (400, 401, 403, 404, 500)
- Edge cases
- Data validation
- Authentication/authorization
- Query parameters and filters
- Request body validation
- Response format validation

## 🚀 CRITICAL API DESIGN REQUIREMENTS

### 1. **RESTful API Standards (MANDATORY)**

#### **Resource-Based URL Design:**
```typescript
// ✅ Good: RESTful resource design
const apiRoutes = {
  // Resource collections
  'GET    /api/v1/users':           'List all users',
  'POST   /api/v1/users':           'Create new user',
  
  // Specific resources
  'GET    /api/v1/users/{id}':      'Get specific user',
  'PUT    /api/v1/users/{id}':      'Update entire user',
  'PATCH  /api/v1/users/{id}':      'Partial user update',
  'DELETE /api/v1/users/{id}':      'Delete user',
  
  // Nested resources
  'GET    /api/v1/users/{id}/posts': 'Get user posts',
  'POST   /api/v1/users/{id}/posts': 'Create post for user'
};

// ❌ Bad: Non-RESTful design
const badRoutes = {
  'GET /api/getUser?id=123':        'RPC-style endpoint',
  'POST /api/updateUser':           'Verb in URL',
  'GET /api/user-posts':            'Unclear resource hierarchy'
};
```

#### **HTTP Status Code Standards:**
```typescript
interface HTTPStatusCodes {
  success: {
    200: 'OK - Request successful';
    201: 'Created - Resource created';
    202: 'Accepted - Async processing started';
    204: 'No Content - Successful, no body';
  };
  
  clientError: {
    400: 'Bad Request - Invalid request syntax';
    401: 'Unauthorized - Authentication required';
    403: 'Forbidden - Access denied';
    404: 'Not Found - Resource not found';
    409: 'Conflict - Resource conflict';
    422: 'Unprocessable Entity - Validation failed';
    429: 'Too Many Requests - Rate limit exceeded';
  };
  
  serverError: {
    500: 'Internal Server Error - Server error';
    502: 'Bad Gateway - Upstream server error';
    503: 'Service Unavailable - Service temporarily down';
    504: 'Gateway Timeout - Upstream timeout';
  };
}
```

### 2. **Request/Response Standards (CRITICAL)**

#### **Request Format Standards:**
```typescript
// MANDATORY: Consistent request structure
interface APIRequest {
  // Headers
  headers: {
    'Content-Type': 'application/json';
    'Accept': 'application/json';
    'Authorization': 'Bearer <token>';
    'X-Request-ID': string;         // For tracing
    'X-API-Version': string;        // API versioning
  };
  
  // Query parameters (for GET requests)
  queryParams?: {
    page?: number;                  // Pagination
    limit?: number;                 // Page size (max 100)
    sort?: string;                  // Sort field
    order?: 'asc' | 'desc';        // Sort order
    filter?: Record<string, any>;   // Filtering
  };
  
  // Body (for POST/PUT/PATCH)
  body?: {
    data: any;                      // Main payload
    metadata?: Record<string, any>; // Additional metadata
  };
}

// MANDATORY: Request validation
interface RequestValidation {
  required: string[];               // Required fields
  types: Record<string, string>;    // Field type validation
  constraints: Record<string, any>; // Field constraints
  sanitization: boolean;            // Input sanitization
}
```

#### **Response Format Standards:**
```typescript
// MANDATORY: Consistent response structure
interface APIResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    code: string;                   // Error code
    message: string;                // Human-readable message
    details?: any;                  // Additional error details
    timestamp: string;              // Error timestamp
    traceId: string;               // Request trace ID
  };
  metadata?: {
    timestamp: string;              // Response timestamp
    version: string;                // API version
    requestId: string;              // Request tracking ID
    pagination?: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
      hasNext: boolean;
      hasPrev: boolean;
    };
  };
}

// ✅ Good: Consistent success response
{
  "success": true,
  "data": {
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "metadata": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "v1",
    "requestId": "req_123456789"
  }
}

// ✅ Good: Consistent error response
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": {
      "field": "email",
      "value": "invalid-email"
    },
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "trace_987654321"
  }
}
```

### 3. **API Versioning (MANDATORY)**

#### **Version Strategy:**
```typescript
// MANDATORY: API versioning approaches
interface APIVersioning {
  // URL versioning (recommended)
  urlVersioning: {
    pattern: '/api/v{version}/{resource}';
    example: '/api/v1/users';
    deprecation: 'Support v1 for 12 months after v2 release';
  };
  
  // Header versioning (alternative)
  headerVersioning: {
    header: 'X-API-Version';
    example: 'X-API-Version: v1';
    fallback: 'Default to latest stable version';
  };
  
  // Backward compatibility
  compatibility: {
    additive: 'New fields can be added without version bump';
    breaking: 'Breaking changes require new version';
    deprecation: 'Deprecated endpoints marked clearly';
    sunset: 'Sunset timeline communicated in advance';
  };
}

// MANDATORY: Version deprecation handling
interface APIDeprecation {
  headers: {
    'X-API-Deprecated': 'true';
    'X-API-Sunset-Date': '2024-12-31';
    'X-API-Replacement': '/api/v2/users';
  };
  
  response: {
    warnings: string[];             // Deprecation warnings
    migrationGuide: string;         // Migration instructions
    supportEndDate: string;         // Support end date
  };
}
```

### 4. **Authentication & Authorization (CRITICAL)**

#### **Authentication Standards:**
```typescript
// MANDATORY: Authentication patterns
interface APIAuthentication {
  bearer: {
    header: 'Authorization: Bearer <token>';
    tokenType: 'JWT' | 'Opaque';
    expiration: number;             // Token expiration time
    refreshable: boolean;           // Refresh token support
  };
  
  apiKey: {
    header: 'X-API-Key: <key>';
    usage: 'Service-to-service authentication';
    rotation: 'Quarterly rotation required';
    scoping: 'Scoped to specific resources/actions';
  };
  
  oauth2: {
    grantTypes: ['authorization_code', 'client_credentials'];
    scopes: string[];               // Permission scopes
    tokenEndpoint: string;          // Token endpoint URL
    introspection: boolean;         // Token introspection support
  };
}

// MANDATORY: Authorization middleware
async function authorizationMiddleware(
  req: Request, 
  res: Response, 
  next: NextFunction
) {
  try {
    // Validate authentication token
    const token = extractToken(req);
    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'MISSING_TOKEN',
          message: 'Authentication token required'
        }
      });
    }
    
    // Verify token and extract user
    const user = await verifyToken(token);
    if (!user) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'INVALID_TOKEN',
          message: 'Invalid or expired token'
        }
      });
    }
    
    // Check authorization for resource
    const hasAccess = await checkPermissions(user, req.path, req.method);
    if (!hasAccess) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'INSUFFICIENT_PERMISSIONS',
          message: 'Access denied for this resource'
        }
      });
    }
    
    req.user = user;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: {
        code: 'AUTH_ERROR',
        message: 'Authentication service error'
      }
    });
  }
}
```

### 5. **Input Validation & Sanitization (MANDATORY)**

#### **Request Validation:**
```typescript
// MANDATORY: Input validation schema
interface ValidationSchema {
  type: 'object';
  required: string[];
  properties: Record<string, {
    type: string;
    format?: string;
    minLength?: number;
    maxLength?: number;
    minimum?: number;
    maximum?: number;
    pattern?: string;
    enum?: any[];
  }>;
  additionalProperties: false;
}

// Example validation schema
const userValidationSchema: ValidationSchema = {
  type: 'object',
  required: ['email', 'name'],
  properties: {
    email: {
      type: 'string',
      format: 'email',
      maxLength: 255
    },
    name: {
      type: 'string',
      minLength: 2,
      maxLength: 100
    },
    age: {
      type: 'integer',
      minimum: 0,
      maximum: 150
    },
    role: {
      type: 'string',
      enum: ['user', 'admin', 'moderator']
    }
  },
  additionalProperties: false
};

// MANDATORY: Validation middleware
function validateRequest(schema: ValidationSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const validation = validateSchema(req.body, schema);
    
    if (!validation.valid) {
      return res.status(422).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Request validation failed',
          details: validation.errors
        }
      });
    }
    
    // Sanitize input
    req.body = sanitizeInput(req.body);
    next();
  };
}
```

## 📊 API PERFORMANCE & MONITORING

### **Performance Requirements:**
```typescript
interface APIPerformanceStandards {
  responseTime: {
    simple: 100;                    // ms - Simple queries
    complex: 500;                   // ms - Complex operations
    bulk: 2000;                     // ms - Bulk operations
    upload: 30000;                  // ms - File uploads
  };
  
  throughput: {
    reads: 1000;                    // requests per second
    writes: 200;                    // requests per second
    concurrent: 100;                // concurrent connections
    bulkOperations: 50;             // bulk operations per minute
  };
  
  reliability: {
    uptime: 99.9;                   // percentage
    errorRate: 1.0;                 // percentage
    latencyP95: 500;                // ms - 95th percentile
    latencyP99: 1000;               // ms - 99th percentile
  };
}
```

### **API Monitoring:**
```typescript
// MANDATORY: API monitoring implementation
class APIMonitor {
  static trackRequest(req: Request, res: Response, startTime: number) {
    const duration = Date.now() - startTime;
    const route = `${req.method} ${req.route?.path || req.path}`;
    
    // Log performance metrics
    logger.info('API Request', {
      route,
      statusCode: res.statusCode,
      duration,
      userAgent: req.get('User-Agent'),
      ip: req.ip,
      requestId: req.get('X-Request-ID')
    });
    
    // Track slow requests
    if (duration > 1000) {
      logger.warn('Slow API Request', {
        route,
        duration,
        requestId: req.get('X-Request-ID')
      });
    }
    
    // Update metrics
    this.updateMetrics(route, res.statusCode, duration);
  }
  
  static updateMetrics(route: string, statusCode: number, duration: number) {
    // Implementation depends on monitoring service
    // Examples: Prometheus, DataDog, New Relic
  }
}
```

## 🔒 API Security Standards

### **Security Requirements:**
```typescript
interface APISecurityStandards {
  https: {
    required: true;                 // HTTPS required for all APIs
    hsts: true;                     // HTTP Strict Transport Security
    certificateValidation: true;    // Valid SSL certificates
  };
  
  headers: {
    contentType: 'application/json';
    cors: {
      origin: string[];             // Allowed origins
      methods: string[];            // Allowed methods
      credentials: boolean;         // Include credentials
    };
    security: {
      'X-Content-Type-Options': 'nosniff';
      'X-Frame-Options': 'DENY';
      'X-XSS-Protection': '1; mode=block';
      'Strict-Transport-Security': 'max-age=31536000';
    };
  };
  
  rateLimiting: {
    requests: 1000;                 // per hour per user
    burst: 10;                      // per minute
    windowSize: 3600;               // seconds
    punishment: 300;                // block duration in seconds
  };
  
  inputValidation: {
    sqlInjection: true;             // SQL injection protection
    xss: true;                      // XSS protection
    pathTraversal: true;            // Path traversal protection
    maxRequestSize: 10485760;       // 10MB max request size
  };
}
```

## 🧪 Validators and Schemas (Adjacent)

- For each route/controller file, create adjacent validators/schemas (e.g., Zod/Yup).
- Naming: `auth.validators.ts`, `user.schema.ts`.
- Keep handlers thin; move business logic into services.

## 📚 API Documentation Standards

### **Documentation Requirements:**
```typescript
// MANDATORY: OpenAPI specification
interface APIDocumentation {
  openapi: '3.0.0';
  info: {
    title: string;
    version: string;
    description: string;
    contact: {
      name: string;
      email: string;
      url: string;
    };
    license: {
      name: string;
      url: string;
    };
  };
  
  servers: Array<{
    url: string;
    description: string;
  }>;
  
  paths: Record<string, any>;       // API endpoints
  components: {
    schemas: Record<string, any>;   // Data models
    securitySchemes: Record<string, any>; // Auth schemes
  };
}

// MANDATORY: Example documentation
const userEndpointDoc = {
  '/api/v1/users': {
    get: {
      summary: 'List users',
      description: 'Retrieve a paginated list of users',
      parameters: [
        {
          name: 'page',
          in: 'query',
          schema: { type: 'integer', default: 1 },
          description: 'Page number'
        },
        {
          name: 'limit',
          in: 'query',
          schema: { type: 'integer', default: 20, maximum: 100 },
          description: 'Items per page'
        }
      ],
      responses: {
        200: {
          description: 'Success',
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  success: { type: 'boolean' },
                  data: {
                    type: 'array',
                    items: { $ref: '#/components/schemas/User' }
                  },
                  metadata: { $ref: '#/components/schemas/PaginationMetadata' }
                }
              }
            }
          }
        },
        400: { $ref: '#/components/responses/BadRequest' },
        401: { $ref: '#/components/responses/Unauthorized' },
        500: { $ref: '#/components/responses/InternalServerError' }
      }
    }
  }
};
```

## 🚨 API VIOLATIONS - ZERO TOLERANCE

### **Critical API Design Violations:**
- ❌ Non-RESTful URL design (verbs in URLs)
- ❌ Inconsistent response formats across endpoints
- ❌ Missing input validation and sanitization
- ❌ Exposing internal system details in errors
- ❌ No authentication/authorization on protected resources
- ❌ Missing rate limiting on public endpoints
- ❌ Inconsistent HTTP status code usage
- ❌ No API versioning strategy

### **Security Violations:**
- ❌ Sensitive data in query parameters
- ❌ Missing HTTPS enforcement
- ❌ SQL injection vulnerabilities
- ❌ XSS vulnerabilities in responses
- ❌ Missing CORS configuration
- ❌ Exposing stack traces to clients
- ❌ No request size limits
- ❌ Missing authentication on protected endpoints

## 📋 API DESIGN CHECKLIST

### **Before API Deployment:**
- [ ] RESTful URL design implemented
- [ ] Consistent request/response formats
- [ ] Input validation and sanitization implemented
- [ ] Authentication and authorization configured
- [ ] Rate limiting implemented
- [ ] Error handling standardized
- [ ] API versioning strategy in place
- [ ] Security headers configured
- [ ] OpenAPI documentation complete
- [ ] Performance requirements met

### **Production API Health:**
- [ ] All endpoints responding within performance targets
- [ ] Error rates below acceptable thresholds
- [ ] Security scanning completed with no critical issues
- [ ] Rate limiting functioning correctly
- [ ] Monitoring and alerting configured
- [ ] Documentation up to date
- [ ] Backward compatibility maintained
- [ ] Deprecation timeline communicated

## 🎯 API QUALITY METRICS

### **Required API KPIs:**
- **Response Time**: P95 < 500ms
- **Availability**: 99.9% uptime
- **Error Rate**: < 1% of all requests
- **Throughput**: > 1000 RPS capability
- **Security**: Zero critical vulnerabilities
- **Documentation**: 100% endpoint coverage
- **Consistency**: 100% adherence to standards
- **Version Compliance**: All APIs properly versioned