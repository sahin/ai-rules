# Observability Standards

## 📚 Related Documentation
- **[deployment.md](./deployment.md)** - Deployment processes and CI/CD
- **[performance.md](./performance.md)** - Performance optimization and budgets
- **[idempotency.md](./idempotency.md)** - Error handling and recovery patterns
- **[git-workflow.md](./git-workflow.md)** - Version control and release management

## 📊 OBSERVABILITY FOUNDATION

### **Definition**
Observability is the ability to measure the internal state of a system by examining its outputs. It consists of three pillars: **Logging**, **Metrics**, and **Tracing**.

### **Why Observability Matters**
- **Faster incident resolution**: Reduce MTTR (Mean Time To Repair)
- **Proactive issue detection**: Find problems before users do
- **Performance optimization**: Identify bottlenecks and inefficiencies
- **Business insights**: Track user behavior and system usage
- **Compliance**: Meet audit and regulatory requirements

---

## 📝 LOGGING REQUIREMENTS (MANDATORY)

### **Structured Logging Standards**
All applications MUST use structured logging (JSON format):

```typescript
// ❌ BAD - Unstructured logging
console.log('User john@example.com logged in from 192.168.1.1');

// ✅ GOOD - Structured logging
logger.info('User login successful', {
  event: 'user_login',
  userId: 'user_123',
  email: 'john@example.com',
  sourceIP: '192.168.1.1',
  userAgent: 'Mozilla/5.0...',
  timestamp: new Date().toISOString(),
  sessionId: 'session_456',
  correlationId: 'req_789'
});
```

### **Required Log Levels**
```typescript
enum LogLevel {
  ERROR = 'error',   // System errors, exceptions
  WARN = 'warn',     // Warning conditions, deprecated usage
  INFO = 'info',     // General information, business events
  DEBUG = 'debug',   // Detailed debugging information
  TRACE = 'trace'    // Very detailed tracing information
}

// Production log level: INFO
// Development log level: DEBUG  
// Troubleshooting log level: TRACE
```

### **Mandatory Logging Events**

#### **API Endpoint Logging (MANDATORY)**
Every API endpoint must log entry and exit:

```typescript
// API middleware for automatic logging
app.use((req: Request, res: Response, next: NextFunction) => {
  const startTime = Date.now();
  const correlationId = req.headers['x-correlation-id'] || generateId();
  
  // Log request entry
  logger.info('API request started', {
    event: 'api_request_start',
    method: req.method,
    url: req.url,
    correlationId,
    userAgent: req.headers['user-agent'],
    sourceIP: req.ip,
    userId: req.user?.id
  });
  
  // Capture response
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    
    logger.info('API request completed', {
      event: 'api_request_end',
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration,
      correlationId,
      userId: req.user?.id
    });
  });
  
  next();
});
```

#### **Error Logging (MANDATORY)**
All errors must be logged with full context:

```typescript
// Error logging with context
function handleError(error: Error, context: Record<string, unknown>): void {
  logger.error('Application error occurred', {
    event: 'application_error',
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
      code: (error as any).code
    },
    context,
    timestamp: new Date().toISOString(),
    correlationId: context.correlationId
  });
}

// Usage example
try {
  await processPayment(paymentData);
} catch (error) {
  handleError(error, {
    operation: 'processPayment',
    userId: paymentData.userId,
    amount: paymentData.amount,
    paymentMethod: paymentData.method,
    correlationId: req.correlationId
  });
  throw error;
}
```

#### **Business Event Logging (MANDATORY)**
Important business events must be logged:

```typescript
// Business event logging
const businessEvents = {
  userRegistration: (userId: string, email: string) => {
    logger.info('User registered', {
      event: 'user_registered',
      userId,
      email,
      timestamp: new Date().toISOString(),
      source: 'web_app'
    });
  },
  
  orderPlaced: (orderId: string, userId: string, amount: number) => {
    logger.info('Order placed', {
      event: 'order_placed',
      orderId,
      userId,
      amount,
      timestamp: new Date().toISOString(),
      currency: 'USD'
    });
  },
  
  paymentProcessed: (paymentId: string, amount: number, status: string) => {
    logger.info('Payment processed', {
      event: 'payment_processed',
      paymentId,
      amount,
      status,
      timestamp: new Date().toISOString()
    });
  }
};
```

### **Security Logging (MANDATORY)**
Security events must be logged for audit:

```typescript
const securityEvents = {
  loginAttempt: (email: string, success: boolean, sourceIP: string) => {
    logger.info('Login attempt', {
      event: 'login_attempt',
      email,
      success,
      sourceIP,
      timestamp: new Date().toISOString(),
      severity: success ? 'info' : 'warn'
    });
  },
  
  authorizationFailure: (userId: string, resource: string, action: string) => {
    logger.warn('Authorization denied', {
      event: 'authorization_denied',
      userId,
      resource,
      action,
      timestamp: new Date().toISOString(),
      severity: 'warn'
    });
  },
  
  suspiciousActivity: (userId: string, activity: string, details: Record<string, unknown>) => {
    logger.warn('Suspicious activity detected', {
      event: 'suspicious_activity',
      userId,
      activity,
      details,
      timestamp: new Date().toISOString(),
      severity: 'high'
    });
  }
};
```

### **Correlation IDs (MANDATORY)**
All logs must include correlation IDs for request tracing:

```typescript
// Correlation ID middleware
import { v4 as uuidv4 } from 'uuid';

app.use((req: Request, res: Response, next: NextFunction) => {
  // Use existing correlation ID or generate new one
  req.correlationId = req.headers['x-correlation-id'] as string || uuidv4();
  
  // Add to response headers
  res.setHeader('X-Correlation-ID', req.correlationId);
  
  next();
});

// Use correlation ID in all logs
logger.info('Processing request', {
  correlationId: req.correlationId,
  // ... other fields
});
```

### **Sensitive Data Protection (MANDATORY)**
Never log sensitive information:

```typescript
// ❌ NEVER LOG THESE
const sensitiveFields = [
  'password',
  'creditCard',
  'ssn', 
  'token',
  'apiKey',
  'secret',
  'authorization'
];

// ✅ GOOD - Redact sensitive data
function sanitizeForLogging(data: Record<string, unknown>): Record<string, unknown> {
  const sanitized = { ...data };
  
  for (const field of sensitiveFields) {
    if (sanitized[field]) {
      sanitized[field] = '***REDACTED***';
    }
  }
  
  return sanitized;
}

// Usage
logger.info('User data processed', sanitizeForLogging({
  userId: '123',
  email: 'user@example.com',
  password: 'secret123' // Will be redacted
}));
```

---

## 📈 METRICS TO TRACK (MANDATORY)

### **Application Performance Metrics**

#### **Response Time Metrics**
```typescript
// Track response times with percentiles
const responseTimeHistogram = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10] // seconds
});

// Middleware to track metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    responseTimeHistogram
      .labels(req.method, req.route?.path || req.path, res.statusCode.toString())
      .observe(duration);
  });
  
  next();
});
```

#### **Error Rate Metrics**
```typescript
// Track error rates by endpoint
const errorCounter = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Track business logic errors
const businessErrorCounter = new promClient.Counter({
  name: 'business_errors_total',
  help: 'Total number of business logic errors',
  labelNames: ['error_type', 'operation']
});
```

#### **Database Performance Metrics**
```typescript
// Database query performance
const dbQueryDuration = new promClient.Histogram({
  name: 'database_query_duration_seconds',
  help: 'Duration of database queries',
  labelNames: ['operation', 'table'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5]
});

// Database connection pool metrics
const dbConnectionsGauge = new promClient.Gauge({
  name: 'database_connections_active',
  help: 'Number of active database connections'
});
```

### **Business Metrics**
```typescript
// Track business-specific metrics
const userRegistrations = new promClient.Counter({
  name: 'user_registrations_total',
  help: 'Total number of user registrations',
  labelNames: ['source', 'plan_type']
});

const ordersValue = new promClient.Histogram({
  name: 'orders_value_dollars',
  help: 'Value of orders in dollars',
  buckets: [1, 5, 10, 25, 50, 100, 250, 500, 1000]
});

const activeUsers = new promClient.Gauge({
  name: 'active_users_current',
  help: 'Number of currently active users'
});
```

### **Infrastructure Metrics**
```typescript
// System resource usage
const memoryUsage = new promClient.Gauge({
  name: 'process_memory_usage_bytes',
  help: 'Memory usage in bytes'
});

const cpuUsage = new promClient.Gauge({
  name: 'process_cpu_usage_percent',
  help: 'CPU usage percentage'
});

// Cache metrics
const cacheHits = new promClient.Counter({
  name: 'cache_hits_total',
  help: 'Total cache hits',
  labelNames: ['cache_name']
});

const cacheMisses = new promClient.Counter({
  name: 'cache_misses_total', 
  help: 'Total cache misses',
  labelNames: ['cache_name']
});
```

---

## 🩺 HEALTH CHECKS (MANDATORY)

### **Health Check Endpoint Requirements**
Every service must expose `/health` endpoint:

```typescript
interface HealthCheckResult {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  version: string;
  uptime: number;
  dependencies: Record<string, DependencyHealth>;
}

interface DependencyHealth {
  status: 'healthy' | 'unhealthy';
  responseTime?: number;
  error?: string;
  lastChecked: string;
}

// Health check implementation
app.get('/health', async (req, res) => {
  const startTime = Date.now();
  const dependencies: Record<string, DependencyHealth> = {};
  
  // Check database
  try {
    const dbStart = Date.now();
    await db.query('SELECT 1');
    dependencies.database = {
      status: 'healthy',
      responseTime: Date.now() - dbStart,
      lastChecked: new Date().toISOString()
    };
  } catch (error) {
    dependencies.database = {
      status: 'unhealthy',
      error: error.message,
      lastChecked: new Date().toISOString()
    };
  }
  
  // Check Redis cache
  try {
    const cacheStart = Date.now();
    await redis.ping();
    dependencies.cache = {
      status: 'healthy',
      responseTime: Date.now() - cacheStart,
      lastChecked: new Date().toISOString()
    };
  } catch (error) {
    dependencies.cache = {
      status: 'unhealthy',
      error: error.message,
      lastChecked: new Date().toISOString()
    };
  }
  
  // Determine overall status
  const unhealthyDeps = Object.values(dependencies).filter(d => d.status === 'unhealthy');
  const status = unhealthyDeps.length === 0 ? 'healthy' : 
                unhealthyDeps.length < Object.keys(dependencies).length ? 'degraded' : 
                'unhealthy';
  
  const result: HealthCheckResult = {
    status,
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0',
    uptime: process.uptime(),
    dependencies
  };
  
  // Set appropriate status code
  const statusCode = status === 'healthy' ? 200 : 
                    status === 'degraded' ? 200 : 
                    503;
  
  res.status(statusCode).json(result);
});
```

### **Deep Health Checks**
For more detailed health information:

```typescript
// Deep health check endpoint
app.get('/health/deep', async (req, res) => {
  const checks = {
    // Database connectivity and performance
    database: await checkDatabaseHealth(),
    
    // External service availability
    paymentGateway: await checkPaymentGatewayHealth(),
    emailService: await checkEmailServiceHealth(),
    
    // Resource availability
    diskSpace: await checkDiskSpace(),
    memory: checkMemoryUsage(),
    
    // Business logic health
    criticalFeatures: await checkCriticalFeatures()
  };
  
  res.json({
    status: determineOverallHealth(checks),
    timestamp: new Date().toISOString(),
    checks
  });
});

async function checkDatabaseHealth(): Promise<HealthCheck> {
  try {
    const start = Date.now();
    
    // Test basic connectivity
    await db.query('SELECT 1');
    
    // Test write capability
    await db.query('INSERT INTO health_checks (timestamp) VALUES (NOW())');
    
    // Check connection pool
    const poolStats = db.getPoolStats();
    
    return {
      status: 'healthy',
      responseTime: Date.now() - start,
      metadata: {
        activeConnections: poolStats.active,
        idleConnections: poolStats.idle,
        waitingRequests: poolStats.waiting
      }
    };
  } catch (error) {
    return {
      status: 'unhealthy',
      error: error.message
    };
  }
}
```

---

## 🔍 DISTRIBUTED TRACING (MANDATORY)

### **Trace Context Propagation**
```typescript
import { trace, context } from '@opentelemetry/api';

// Create spans for important operations
async function processOrder(orderData: OrderData): Promise<Order> {
  const span = trace.getActiveSpan() || trace.getTracer('order-service').startSpan('processOrder');
  
  try {
    // Add attributes to span
    span.setAttributes({
      'order.id': orderData.id,
      'order.userId': orderData.userId,
      'order.amount': orderData.amount,
      'order.itemCount': orderData.items.length
    });
    
    // Child spans for sub-operations
    const inventory = await context.with(trace.setSpan(context.active(), span), async () => {
      const childSpan = trace.getTracer('order-service').startSpan('checkInventory');
      try {
        return await checkInventory(orderData.items);
      } finally {
        childSpan.end();
      }
    });
    
    const payment = await context.with(trace.setSpan(context.active(), span), async () => {
      const childSpan = trace.getTracer('order-service').startSpan('processPayment');
      try {
        return await processPayment(orderData.payment);
      } finally {
        childSpan.end();
      }
    });
    
    const order = await createOrder({ ...orderData, inventory, payment });
    
    span.setStatus({ code: trace.SpanStatusCode.OK });
    return order;
    
  } catch (error) {
    span.recordException(error);
    span.setStatus({ 
      code: trace.SpanStatusCode.ERROR,
      message: error.message 
    });
    throw error;
  } finally {
    span.end();
  }
}
```

---

## 🚨 ALERTING RULES (MANDATORY)

### **Critical Alerts (Immediate Response Required)**
```yaml
# Alert configuration example
alerts:
  - name: HighErrorRate
    condition: error_rate > 5%
    duration: 2m
    severity: critical
    notification: pager
    
  - name: HighResponseTime
    condition: p95_response_time > 2s
    duration: 5m
    severity: critical
    notification: pager
    
  - name: ServiceDown
    condition: health_check_failed
    duration: 1m
    severity: critical
    notification: pager
```

### **Warning Alerts (Investigation Required)**
```yaml
  - name: MediumErrorRate
    condition: error_rate > 2%
    duration: 5m
    severity: warning
    notification: slack
    
  - name: HighMemoryUsage
    condition: memory_usage > 80%
    duration: 10m
    severity: warning
    notification: slack
    
  - name: DatabaseSlowQueries
    condition: db_query_p95 > 500ms
    duration: 5m
    severity: warning
    notification: slack
```

---

## 📊 OBSERVABILITY IMPLEMENTATION CHECKLIST

### **Logging Implementation (MANDATORY)**
- [ ] Structured JSON logging implemented
- [ ] All API endpoints log entry/exit
- [ ] All errors logged with full context
- [ ] Correlation IDs included in all logs
- [ ] Sensitive data redacted from logs
- [ ] Log levels configured per environment
- [ ] Log rotation and retention configured

### **Metrics Implementation (MANDATORY)**
- [ ] Response time histograms implemented
- [ ] Error rate counters implemented
- [ ] Business metrics tracked
- [ ] Database performance metrics tracked
- [ ] Cache hit/miss rates tracked
- [ ] Resource usage metrics tracked
- [ ] Custom dashboards created

### **Health Checks Implementation (MANDATORY)**
- [ ] Basic /health endpoint implemented
- [ ] Deep health checks for all dependencies
- [ ] Health check response includes dependency status
- [ ] Health checks integrated with load balancer
- [ ] Health check alerts configured

### **Tracing Implementation (RECOMMENDED)**
- [ ] Distributed tracing configured
- [ ] Trace context propagated across services
- [ ] Critical operations instrumented
- [ ] Trace data retention configured
- [ ] Trace analysis dashboards created

### **Alerting Implementation (MANDATORY)**
- [ ] Critical alerts defined and tested
- [ ] Warning alerts configured
- [ ] Alert routing configured (PagerDuty, Slack, etc.)
- [ ] Alert escalation policies defined
- [ ] Alert runbooks created

---

## 🎯 PERFORMANCE TARGETS

> For detailed performance budgets, optimization strategies, and comprehensive targets, see [`performance.md`](./performance.md#performance-budgets-mandatory)

### **Quick Reference - Key Targets**
- **API Response**: p95 < 200ms, p99 < 500ms
- **Service Uptime**: 99.9% (8.76 hours downtime/year)
- **Error Rate**: < 0.1% for successful responses
- **Resource Usage**: < 80% memory, < 70% CPU average

---

**Related Rules**: See `general-policies/ops/idempotency.md` for rollback monitoring and `core-standards/core-workflow.md` for development observability requirements.