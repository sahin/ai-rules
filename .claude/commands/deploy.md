# Deployment Guide

Use this guide when setting up CI/CD pipelines, deployment strategies, health checks, or observability.

## CI/CD Pipeline Stages

```yaml
# Standard pipeline stages
stages:
  - lint        # ESLint, Prettier, type checking
  - test        # Unit, integration, E2E tests
  - build       # Compile, bundle, optimize
  - security    # Dependency audit, SAST scanning
  - deploy-stg  # Deploy to staging
  - smoke-test  # Verify staging deployment
  - deploy-prod # Deploy to production (manual gate)
  - verify      # Post-deployment health checks
```

### Stage Requirements
| Stage | Blocking? | Notes |
|-------|-----------|-------|
| lint | Yes | Zero errors allowed |
| test | Yes | All tests must pass |
| build | Yes | Zero warnings in production build |
| security | Yes | No critical/high vulnerabilities |
| deploy-stg | Yes | Must succeed before prod |
| smoke-test | Yes | Critical paths verified |
| deploy-prod | Manual gate | Requires approval |
| verify | Alerting | Auto-rollback on failure |

## Deployment Strategies

### Blue-Green Deployment
```
1. Deploy new version to "green" environment
2. Run smoke tests against green
3. Switch load balancer from blue to green
4. Keep blue running for quick rollback
5. Tear down blue after verification period (15-30 min)
```

### Canary Deployment
```
1. Deploy new version to canary (5% of traffic)
2. Monitor error rates, latency, business metrics
3. Gradually increase: 5% -> 25% -> 50% -> 100%
4. Each stage: minimum 10 minutes observation
5. Auto-rollback if error rate > baseline + 1%
```

### Rolling Deployment
```
1. Update instances one at a time (or in small batches)
2. Each instance: drain connections, update, health check
3. Proceed to next batch only if health checks pass
4. Minimum 2 healthy instances at all times
```

## Health Check Implementation

```typescript
// Basic health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Deep health check with dependency verification
app.get('/health/ready', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    externalApi: await checkExternalApi(),
  };

  const allHealthy = Object.values(checks).every(c => c.status === 'ok');

  res.status(allHealthy ? 200 : 503).json({
    status: allHealthy ? 'ok' : 'degraded',
    checks,
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION,
  });
});

async function checkDatabase(): Promise<HealthCheck> {
  try {
    const start = Date.now();
    await db.query('SELECT 1');
    return { status: 'ok', latencyMs: Date.now() - start };
  } catch (error) {
    return { status: 'error', message: error.message };
  }
}
```

### Health Check Configuration
```yaml
healthCheck:
  path: /health/ready
  initialDelaySeconds: 10
  periodSeconds: 15
  timeoutSeconds: 5
  failureThreshold: 3
  successThreshold: 1
```

## Rollback Procedures

### Automated Rollback Triggers
- Error rate exceeds 5% (or 2x baseline)
- P99 latency exceeds 2x baseline
- Health check failures for > 30 seconds
- Memory/CPU usage exceeds 90%

### Manual Rollback Steps
```bash
# 1. Identify the last known good version
git log --oneline -10

# 2. Deploy previous version
# Option A: Revert commit and redeploy
git revert HEAD
git push origin main

# Option B: Deploy specific version tag
./deploy.sh --version v1.2.3

# 3. Verify rollback
curl -s https://app.example.com/health/ready | jq .

# 4. Post-mortem
# Document: what failed, why, how to prevent
```

## Structured Logging

```typescript
// Use structured JSON logging
import { logger } from './lib/logger';

// Standard log format
logger.info('Order created', {
  orderId: order.id,
  userId: user.id,
  total: order.total,
  itemCount: order.items.length,
  duration: Date.now() - startTime,
});

// Error logging with context
logger.error('Payment processing failed', {
  orderId: order.id,
  provider: 'stripe',
  errorCode: error.code,
  errorMessage: error.message,
  requestId: req.id,
});

// Log levels
// error: system failures requiring immediate attention
// warn: unexpected but handled situations
// info: significant business events
// debug: development diagnostics (disabled in production)
```

### Logging Standards
- Always include: `timestamp`, `level`, `message`, `requestId`
- Include context: relevant IDs, operation name, duration
- Never log: passwords, tokens, credit cards, PII
- Use correlation IDs across service boundaries
- Structured JSON format (not string concatenation)

## Metrics and Monitoring

### Key Metrics (RED Method)
```
Rate:   requests per second (by endpoint, status code)
Errors: error rate percentage (4xx, 5xx)
Duration: response time percentiles (p50, p95, p99)
```

### Application Metrics
```typescript
// Track key business and system metrics
const metrics = {
  httpRequestDuration: new Histogram({
    name: 'http_request_duration_seconds',
    help: 'HTTP request duration',
    labelNames: ['method', 'route', 'status'],
    buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5],
  }),

  activeConnections: new Gauge({
    name: 'db_active_connections',
    help: 'Number of active database connections',
  }),

  ordersCreated: new Counter({
    name: 'orders_created_total',
    help: 'Total orders created',
    labelNames: ['payment_method'],
  }),
};
```

### Alerting Rules
| Metric | Warning | Critical |
|--------|---------|----------|
| Error rate (5xx) | > 1% for 5 min | > 5% for 2 min |
| P99 latency | > 2s for 5 min | > 5s for 2 min |
| CPU usage | > 70% for 10 min | > 90% for 5 min |
| Memory usage | > 75% for 10 min | > 90% for 5 min |
| Disk usage | > 80% | > 90% |
| Health check | 1 failure | 3 consecutive failures |

## Idempotency Patterns

```typescript
// Use idempotency keys for non-idempotent operations
app.post('/api/v1/orders', async (req, res) => {
  const idempotencyKey = req.headers['idempotency-key'];

  if (idempotencyKey) {
    const existing = await cache.get(`idempotency:${idempotencyKey}`);
    if (existing) {
      return res.status(200).json(JSON.parse(existing));
    }
  }

  const order = await createOrder(req.body);

  if (idempotencyKey) {
    await cache.set(`idempotency:${idempotencyKey}`, JSON.stringify(order), 'EX', 86400);
  }

  res.status(201).json(order);
});
```

### Database-Level Idempotency
```sql
-- Use unique constraints to prevent duplicates
INSERT INTO payments (order_id, amount, idempotency_key)
VALUES ($1, $2, $3)
ON CONFLICT (idempotency_key) DO NOTHING
RETURNING *;
```

## Pre-Deployment Checklist

- [ ] All tests passing (unit, integration, E2E)
- [ ] Build succeeds without warnings
- [ ] Security scan clean (no critical/high vulnerabilities)
- [ ] Database migrations tested on staging
- [ ] Environment variables configured for target environment
- [ ] Health check endpoints responding
- [ ] Rollback plan documented and tested
- [ ] Monitoring and alerts configured
- [ ] Team notified of deployment window
- [ ] Feature flags configured (if applicable)
