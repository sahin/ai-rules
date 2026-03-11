# Performance Guide

Use this guide when optimizing application performance, setting budgets, or running load tests.

## Response Time Targets

| Endpoint Type | P50 | P95 | P99 |
|---------------|-----|-----|-----|
| Health check | < 5ms | < 10ms | < 50ms |
| Simple CRUD | < 50ms | < 200ms | < 500ms |
| List/search | < 100ms | < 500ms | < 1s |
| Complex query | < 200ms | < 1s | < 2s |
| File upload | < 500ms | < 2s | < 5s |
| Report generation | < 1s | < 5s | < 10s |

## Frontend Performance Budgets

### Core Web Vitals
| Metric | Good | Needs Improvement | Poor |
|--------|------|--------------------|------|
| LCP | < 2.5s | 2.5s - 4s | > 4s |
| INP | < 200ms | 200ms - 500ms | > 500ms |
| CLS | < 0.1 | 0.1 - 0.25 | > 0.25 |

### Bundle Budgets
| Asset | Budget (gzipped) |
|-------|-------------------|
| Initial JS | < 200KB |
| Per-route chunk | < 50KB |
| Total CSS | < 50KB |
| Hero image | < 100KB |
| Total page weight | < 1MB |

### Rendering Performance
- First paint: < 1s
- Time to Interactive: < 3s
- DOM nodes: < 1500
- Layout shifts: 0 after initial load
- Long tasks (> 50ms): minimize, never > 200ms

## Backend Performance Budgets

### Database
- Simple query (indexed): < 10ms
- Join query: < 100ms
- Complex aggregation: < 500ms
- Connection pool utilization: < 80%
- Slow query log threshold: 100ms

### API
- Throughput: handle 100 req/s per instance minimum
- Error rate: < 0.1% under normal load
- Timeout: 30s max (abort and return error)
- Payload size: < 1MB per response
- Pagination: max 100 items per page

## Caching Strategies

### Cache Layers
```
Client (browser) -> CDN -> Application Cache -> Database
```

### Browser Cache Headers
```typescript
// Static assets (JS, CSS, images): cache forever, bust with hash
res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');

// API responses: short cache with revalidation
res.setHeader('Cache-Control', 'private, max-age=60, stale-while-revalidate=300');

// Dynamic HTML: no cache
res.setHeader('Cache-Control', 'no-store');
```

### Application Cache (Redis)
```typescript
// Cache-aside pattern
async function getUser(id: string): Promise<User> {
  const cacheKey = `user:${id}`;

  // Check cache first
  const cached = await redis.get(cacheKey);
  if (cached) return JSON.parse(cached);

  // Cache miss: fetch from database
  const user = await db.users.findById(id);

  // Store in cache with TTL
  await redis.set(cacheKey, JSON.stringify(user), 'EX', 300); // 5 min

  return user;
}

// Invalidate on write
async function updateUser(id: string, data: Partial<User>): Promise<User> {
  const user = await db.users.update(id, data);
  await redis.del(`user:${id}`);
  return user;
}
```

### Cache TTL Guidelines
| Data Type | TTL | Notes |
|-----------|-----|-------|
| Static config | 1 hour | Rarely changes |
| User profile | 5 minutes | Moderate change frequency |
| List/search results | 1 minute | Frequently changing |
| Session data | 24 hours | Until expiry |
| Rate limit counters | Window size | Match rate limit window |

## Load Testing with k6

### Basic Load Test
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Ramp up
    { duration: '5m', target: 50 },   // Steady state
    { duration: '2m', target: 100 },  // Peak load
    { duration: '5m', target: 100 },  // Sustained peak
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('https://api.example.com/users');

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

### Stress Test
```javascript
export const options = {
  stages: [
    { duration: '5m', target: 200 },  // Ramp to breaking point
    { duration: '10m', target: 200 }, // Hold at breaking point
    { duration: '5m', target: 0 },    // Recovery
  ],
};
```

### Spike Test
```javascript
export const options = {
  stages: [
    { duration: '1m', target: 10 },   // Normal load
    { duration: '10s', target: 500 },  // Spike!
    { duration: '3m', target: 500 },   // Hold spike
    { duration: '10s', target: 10 },   // Drop back
    { duration: '3m', target: 10 },    // Recovery
  ],
};
```

## Common Performance Optimizations

### Database
- Add missing indexes (check slow query log)
- Replace N+1 queries with JOINs or batch loading
- Use cursor-based pagination instead of OFFSET
- Add connection pooling (PgBouncer or application-level)
- Use read replicas for read-heavy workloads
- Materialize frequently-computed aggregations

### API
- Compress responses (gzip/brotli)
- Use pagination for all list endpoints
- Implement field selection (`?fields=id,name`)
- Add ETag/If-None-Match for conditional requests
- Use streaming for large payloads
- Implement request coalescing for duplicate concurrent requests

### Frontend
- Code split routes with `lazy()`
- Tree-shake unused code
- Optimize images (WebP, proper sizing, lazy loading)
- Use `will-change` sparingly for animation hints
- Debounce/throttle expensive event handlers
- Use virtual scrolling for lists > 100 items
- Preload critical resources (`<link rel="preload">`)
- Avoid layout thrashing (batch DOM reads/writes)

## Performance Monitoring

### Key Metrics to Track
```
# Backend
- Request rate (req/s) by endpoint
- Error rate (%) by status code
- Response time (p50, p95, p99) by endpoint
- Database query time (p50, p95, p99)
- Cache hit ratio (%)
- Active database connections

# Frontend
- Core Web Vitals (LCP, INP, CLS)
- Time to First Byte (TTFB)
- Bundle size over time
- JavaScript errors per session
```

### Performance Regression Prevention
- Run load tests in CI on PRs that change critical paths
- Track bundle size in CI (fail if > budget)
- Monitor Core Web Vitals in production (RUM)
- Set up alerts for p95 latency regressions
- Review slow query log weekly
