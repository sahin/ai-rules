# Universal Performance Rules

This document outlines universal performance standards, benchmarks, and optimization requirements that must be followed across all software development projects.

## 📚 Related Documentation
- **[observability.md](./observability.md)** - Performance monitoring and metrics tracking
- **[deployment.md](./deployment.md)** - Performance gates in deployment pipeline
- **[idempotency.md](./idempotency.md)** - Performance-safe operation patterns
- **[code-review.md](./code-review.md)** - Performance review checklist

## ⚡ PERFORMANCE FUNDAMENTALS

### 1. **Response Time Standards**

#### **General API Response Targets:**
- **Simple queries**: < 100ms (95th percentile)
- **Complex queries**: < 500ms (95th percentile)
- **Database operations**: < 200ms (95th percentile)
- **File operations**: < 300ms for small files (< 1MB)
- **Authentication**: < 100ms for token validation

#### **Frontend Performance Targets:**
- **Page load time**: < 2 seconds (First Contentful Paint)
- **Time to Interactive**: < 3 seconds
- **Route transitions**: < 100ms for client-side navigation
- **Form submissions**: < 200ms for simple forms
- **Search/filter operations**: < 150ms for local data

### 2. **Throughput Standards**

#### **General Scalability Requirements:**
- **Concurrent users**: Support appropriate user load for application scale
- **Database connections**: Efficient connection pooling
- **Memory usage**: < 80% of available system memory
- **Request handling**: Implement proper pagination and batching

```typescript
// MANDATORY: Implement proper pagination
interface PaginationParams {
  page: number;
  limit: number; // Max 100 items per page
  offset?: number;
}

// MANDATORY: Basic caching pattern
class CacheManager {
  private cache = new Map();
  
  async get<T>(key: string, fetchFn: () => Promise<T>, ttl = 300000): Promise<T> {
    if (this.cache.has(key)) {
      const { data, timestamp } = this.cache.get(key);
      if (Date.now() - timestamp < ttl) {
        return data;
      }
    }
    
    const data = await fetchFn();
    this.cache.set(key, { data, timestamp: Date.now() });
    return data;
  }
}
```

### 3. **Resource Management**

#### **CPU and Memory Standards:**
- **Normal operations**: < 70% CPU utilization
- **Peak load**: < 90% CPU utilization
- **Memory monitoring**: Alert on 85% memory usage
- **Memory leaks**: Zero tolerance for memory leaks
- **Resource cleanup**: Proper disposal of resources

### 4. **Database Performance**

#### **Query Optimization Principles:**
```sql
-- MANDATORY: Analyze query performance
EXPLAIN ANALYZE SELECT * FROM table WHERE condition = $1;

-- MANDATORY: Monitor slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC;
```

#### **Database Best Practices:**
- **Connection pooling**: Implement appropriate pool sizing
- **Query optimization**: Use proper indexes for query patterns
- **Transaction management**: Keep transactions short and focused
- **Bulk operations**: Use batch processing for large operations
- **Read/Write separation**: Consider read replicas for heavy read workloads

### 5. **Frontend Performance**

#### **Asset Optimization Patterns:**
```typescript
// Code splitting for large applications
const LazyComponent = React.lazy(() => import('./HeavyComponent'));

// Image optimization
const OptimizedImage = ({ src, alt, width, height }) => (
  <img 
    src={src}
    alt={alt}
    width={width}
    height={height}
    loading="lazy"
    decoding="async"
  />
);

// Memoization for expensive calculations
const ExpensiveComponent = React.memo(({ data }) => {
  const result = useMemo(() => expensiveCalculation(data), [data]);
  return <div>{result}</div>;
});
```

#### **Bundle Optimization:**
- **Initial bundle**: Target < 200KB gzipped
- **Code splitting**: Implement route-based splitting
- **Tree shaking**: Eliminate unused code
- **Asset compression**: Enable gzip/brotli compression

## 📊 PERFORMANCE MONITORING

### **Core Monitoring Approach:**
```typescript
// Performance monitoring framework
class PerformanceMonitor {
  static trackOperation(operation: string, duration: number, threshold: number = 500) {
    if (duration > threshold) {
      console.warn(`Slow operation: ${operation} took ${duration}ms`);
      this.reportMetric(operation, duration);
    }
  }
  
  static trackPagePerformance(page: string, metrics: PerformanceMetrics) {
    if (metrics.loadTime > 2000) {
      console.warn(`Slow page load: ${page}`);
    }
    this.reportPageMetrics(page, metrics);
  }
  
  static trackResourceUsage() {
    if (performance.memory) {
      const usage = performance.memory.usedJSHeapSize / 1024 / 1024;
      this.reportMemoryUsage(usage);
    }
  }
}
```

### **Alerting Strategy:**
- **Response time**: Alert when exceeding defined thresholds
- **Error rates**: Monitor and alert on error rate increases
- **Resource usage**: Track CPU, memory, and network utilization
- **Availability**: Monitor service uptime and responsiveness

## 🔧 CACHING STRATEGIES

### **Multi-Level Caching:**
```typescript
interface CacheConfig {
  ttl: number;           // Time to live in milliseconds
  maxSize: number;       // Maximum cache size
  strategy: 'LRU' | 'FIFO'; // Eviction strategy
}

class PerformanceCache {
  private cache = new Map();
  private config: CacheConfig;
  
  constructor(config: CacheConfig) {
    this.config = config;
  }
  
  async get<T>(key: string, fetchFn: () => Promise<T>): Promise<T> {
    if (this.cache.has(key)) {
      const { data, timestamp } = this.cache.get(key);
      if (Date.now() - timestamp < this.config.ttl) {
        return data;
      }
    }
    
    const data = await fetchFn();
    this.set(key, data);
    return data;
  }
  
  private set(key: string, data: any) {
    if (this.cache.size >= this.config.maxSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    
    this.cache.set(key, { data, timestamp: Date.now() });
  }
}
```

### **Caching Layers:**
- **Application cache**: In-memory caching for frequently accessed data
- **Database cache**: Query result caching and connection pooling
- **CDN/Edge cache**: Static asset caching and distribution
- **Browser cache**: Client-side caching strategies

## 🚨 DATABASE OPTIMIZATION

### **Query Optimization Techniques:**
- **Index analysis**: Regular review of query patterns and index usage
- **Query planning**: Use EXPLAIN ANALYZE for query optimization
- **Connection management**: Proper connection pooling and lifecycle
- **Data partitioning**: Partition large tables for better performance
- **Read/Write optimization**: Separate read-heavy from write-heavy operations

### **Common Database Anti-Patterns:**
- ❌ Unindexed queries on large tables
- ❌ N+1 query problems
- ❌ Missing LIMIT clauses on large result sets
- ❌ Inefficient JOINs and subqueries
- ❌ Blocking transactions and deadlocks

## 🎯 PERFORMANCE BENCHMARKING

### **Benchmarking Methodology:**
- **Baseline establishment**: Define performance baselines for key operations
- **Load testing**: Test performance under various load conditions
- **Stress testing**: Determine breaking points and failure modes
- **Endurance testing**: Verify performance stability over time
- **Regression testing**: Prevent performance degradation in releases

## 📈 PERFORMANCE TESTING

### **Load Testing Framework:**
```javascript
// Load testing example with k6
import { check, sleep } from 'k6';
import http from 'k6/http';

export let options = {
  stages: [
    { duration: '2m', target: 10 },   // Ramp up
    { duration: '5m', target: 100 },  // Sustained load
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.1'],
  },
};

export default function() {
  const response = http.get('https://api.example.com/endpoint');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time acceptable': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

### **Testing Schedule:**
- **Pre-release**: Load testing with expected traffic patterns
- **Regular intervals**: Stress testing to identify limits
- **Performance regression**: Testing after major changes
- **Optimization validation**: Testing after performance improvements

## 📋 GENERAL PERFORMANCE CHECKLIST

### **Pre-Deployment:**
- [ ] Load testing completed with passing thresholds
- [ ] Database queries optimized and indexed
- [ ] Caching strategy implemented for expensive operations
- [ ] Frontend assets optimized and compressed
- [ ] Memory usage profiled for leaks
- [ ] Response time targets validated
- [ ] Resource utilization within limits
- [ ] Monitoring and alerting configured

### **Production Health:**
- [ ] API endpoints meeting response time targets
- [ ] Database queries using appropriate indexes
- [ ] Cache performance at expected levels
- [ ] Memory usage stable over time
- [ ] Error rates within acceptable thresholds
- [ ] Resource utilization optimized
- [ ] Performance monitoring active

## 💰 PERFORMANCE BUDGETS (MANDATORY)

### **Frontend Performance Budgets**

#### **Core Web Vitals Budgets**
```typescript
// Strict performance budgets for user experience
interface WebVitalsBudgets {
  firstContentfulPaint: number;    // < 1.5s (target: 1.2s)
  largestContentfulPaint: number;  // < 2.5s (target: 2.0s)
  timeToInteractive: number;       // < 3.5s (target: 3.0s)
  cumulativeLayoutShift: number;   // < 0.1 (target: 0.05)
  firstInputDelay: number;         // < 100ms (target: 50ms)
}

const PERFORMANCE_BUDGETS: WebVitalsBudgets = {
  firstContentfulPaint: 1500,      // 1.5 seconds
  largestContentfulPaint: 2500,    // 2.5 seconds  
  timeToInteractive: 3500,         // 3.5 seconds
  cumulativeLayoutShift: 0.1,      // Layout shift score
  firstInputDelay: 100             // 100 milliseconds
};
```

#### **Bundle Size Budgets**
```typescript
interface BundleBudgets {
  initialBundle: number;           // Main bundle size limit
  totalJavaScript: number;         // Total JS across all chunks
  totalCSS: number;               // Total CSS size
  images: number;                 // Total image assets per page
  fonts: number;                  // Total font files
  thirdParty: number;             // Third-party dependencies
}

// Budgets in KB (gzipped)
const BUNDLE_BUDGETS: BundleBudgets = {
  initialBundle: 200,             // 200KB initial bundle
  totalJavaScript: 500,           // 500KB total JavaScript
  totalCSS: 50,                   // 50KB total CSS
  images: 500,                    // 500KB images per page
  fonts: 100,                     // 100KB fonts
  thirdParty: 150                 // 150KB third-party code
};

// Budget enforcement in build process
function enforceBundleBudgets(stats: WebpackStats): void {
  const assets = stats.assets;
  const jsSize = assets.filter(a => a.name.endsWith('.js'))
    .reduce((sum, asset) => sum + asset.size, 0);
  
  const cssSize = assets.filter(a => a.name.endsWith('.css'))
    .reduce((sum, asset) => sum + asset.size, 0);
  
  if (jsSize > BUNDLE_BUDGETS.totalJavaScript * 1024) {
    throw new Error(`JavaScript budget exceeded: ${jsSize} > ${BUNDLE_BUDGETS.totalJavaScript}KB`);
  }
  
  if (cssSize > BUNDLE_BUDGETS.totalCSS * 1024) {
    throw new Error(`CSS budget exceeded: ${cssSize} > ${BUNDLE_BUDGETS.totalCSS}KB`);
  }
}
```

#### **Network Performance Budgets**
```typescript
interface NetworkBudgets {
  totalPageWeight: number;        // Total page weight
  httpRequests: number;           // Number of HTTP requests
  slowConnectionLoad: number;     // Load time on slow connection (3G)
  slowConnectionInteractive: number; // Interactive time on slow connection
}

const NETWORK_BUDGETS: NetworkBudgets = {
  totalPageWeight: 1024,          // 1MB total page weight
  httpRequests: 50,               // Max 50 HTTP requests
  slowConnectionLoad: 5000,       // 5s on slow 3G
  slowConnectionInteractive: 8000  // 8s interactive on slow 3G
};
```

### **Backend Performance Budgets**

#### **API Response Time Budgets**
```typescript
interface APIBudgets {
  simpleGET: number;              // Simple data retrieval
  complexGET: number;             // Complex queries with joins
  simplePOST: number;             // Simple data creation
  complexPOST: number;            // Complex data processing
  simpleUPDATE: number;           // Simple data updates
  complexUPDATE: number;          // Complex batch updates
  DELETE: number;                 // Data deletion
  authentication: number;          // Auth token validation
  search: number;                 // Search operations
}

// Response time budgets in milliseconds (P95)
const API_BUDGETS: APIBudgets = {
  simpleGET: 200,                 // 200ms for simple GET
  complexGET: 500,                // 500ms for complex GET
  simplePOST: 300,                // 300ms for simple POST
  complexPOST: 800,               // 800ms for complex POST
  simpleUPDATE: 300,              // 300ms for simple UPDATE
  complexUPDATE: 600,             // 600ms for complex UPDATE
  DELETE: 200,                    // 200ms for DELETE
  authentication: 100,            // 100ms for auth validation
  search: 400                     // 400ms for search
};

// Middleware to enforce API budgets
function enforceAPIBudgets(req: Request, res: Response, next: NextFunction) {
  const startTime = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const budget = getAPIBudget(req.method, req.path);
    
    if (duration > budget) {
      logger.warn('API budget exceeded', {
        method: req.method,
        path: req.path,
        duration,
        budget,
        exceedBy: duration - budget
      });
      
      // Alert if significantly over budget
      if (duration > budget * 1.5) {
        alerting.sendAlert('API_BUDGET_EXCEEDED', {
          endpoint: `${req.method} ${req.path}`,
          duration,
          budget
        });
      }
    }
  });
  
  next();
}
```

#### **Database Performance Budgets**
```typescript
interface DatabaseBudgets {
  simpleQuery: number;            // Simple SELECT queries
  complexQuery: number;           // Complex JOINs and aggregations
  indexedQuery: number;           // Queries using proper indexes
  fullTableScan: number;          // Full table scans (should be rare)
  insertSingle: number;           // Single row INSERT
  insertBatch: number;            // Batch INSERT operations
  updateSingle: number;           // Single row UPDATE
  updateBatch: number;            // Batch UPDATE operations
  deleteSingle: number;           // Single row DELETE
  connection: number;             // Connection establishment
}

// Database budgets in milliseconds
const DATABASE_BUDGETS: DatabaseBudgets = {
  simpleQuery: 50,                // 50ms for simple queries
  complexQuery: 200,              // 200ms for complex queries
  indexedQuery: 30,               // 30ms for indexed queries
  fullTableScan: 1000,            // 1s for full table scan (avoid)
  insertSingle: 20,               // 20ms for single INSERT
  insertBatch: 100,               // 100ms for batch INSERT
  updateSingle: 30,               // 30ms for single UPDATE
  updateBatch: 200,               // 200ms for batch UPDATE
  deleteSingle: 20,               // 20ms for single DELETE
  connection: 10                  // 10ms for connection
};
```

#### **Resource Usage Budgets**
```typescript
interface ResourceBudgets {
  cpuUsageNormal: number;         // Normal CPU usage %
  cpuUsagePeak: number;           // Peak CPU usage %
  memoryUsageNormal: number;      // Normal memory usage %
  memoryUsagePeak: number;        // Peak memory usage %
  diskUsage: number;              // Disk usage %
  networkBandwidth: number;       // Network bandwidth MB/s
  concurrentConnections: number;   // Max concurrent connections
  requestsPerSecond: number;      // Max RPS per instance
}

const RESOURCE_BUDGETS: ResourceBudgets = {
  cpuUsageNormal: 70,             // 70% CPU normal
  cpuUsagePeak: 90,               // 90% CPU peak
  memoryUsageNormal: 80,          // 80% memory normal
  memoryUsagePeak: 95,            // 95% memory peak
  diskUsage: 85,                  // 85% disk usage
  networkBandwidth: 100,          // 100MB/s network
  concurrentConnections: 1000,    // 1000 concurrent connections
  requestsPerSecond: 500          // 500 RPS per instance
};
```

### **Budget Monitoring & Alerting**

#### **Automated Budget Enforcement**
```typescript
class PerformanceBudgetMonitor {
  static checkWebVitals(metrics: WebVitalsBudgets): void {
    const violations: string[] = [];
    
    if (metrics.firstContentfulPaint > PERFORMANCE_BUDGETS.firstContentfulPaint) {
      violations.push(`FCP: ${metrics.firstContentfulPaint}ms > ${PERFORMANCE_BUDGETS.firstContentfulPaint}ms`);
    }
    
    if (metrics.largestContentfulPaint > PERFORMANCE_BUDGETS.largestContentfulPaint) {
      violations.push(`LCP: ${metrics.largestContentfulPaint}ms > ${PERFORMANCE_BUDGETS.largestContentfulPaint}ms`);
    }
    
    if (violations.length > 0) {
      throw new PerformanceBudgetViolationError(violations);
    }
  }
  
  static monitorAPIBudgets(endpoint: string, duration: number): void {
    const budget = getAPIBudget(endpoint);
    
    if (duration > budget) {
      this.recordBudgetViolation('API', endpoint, duration, budget);
      
      if (duration > budget * 2) {
        this.triggerCriticalAlert('API', endpoint, duration, budget);
      }
    }
  }
  
  static trackBundleSize(stats: BundleStats): void {
    if (stats.initialBundle > BUNDLE_BUDGETS.initialBundle * 1024) {
      this.recordBudgetViolation('BUNDLE', 'initial', stats.initialBundle, BUNDLE_BUDGETS.initialBundle * 1024);
    }
  }
}
```

#### **Performance Budget Dashboard**
```typescript
interface BudgetReport {
  timestamp: Date;
  budgetType: 'frontend' | 'backend' | 'database';
  metric: string;
  currentValue: number;
  budgetValue: number;
  utilizationPercentage: number;
  status: 'ok' | 'warning' | 'critical';
  trend: 'improving' | 'stable' | 'degrading';
}

// Generate performance budget reports
async function generateBudgetReport(): Promise<BudgetReport[]> {
  const reports: BudgetReport[] = [];
  
  // Frontend budget checks
  const webVitals = await getWebVitalsMetrics();
  reports.push({
    timestamp: new Date(),
    budgetType: 'frontend',
    metric: 'FirstContentfulPaint',
    currentValue: webVitals.fcp,
    budgetValue: PERFORMANCE_BUDGETS.firstContentfulPaint,
    utilizationPercentage: (webVitals.fcp / PERFORMANCE_BUDGETS.firstContentfulPaint) * 100,
    status: webVitals.fcp > PERFORMANCE_BUDGETS.firstContentfulPaint ? 'critical' : 'ok',
    trend: calculateTrend('fcp', webVitals.fcp)
  });
  
  // API budget checks
  const apiMetrics = await getAPIMetrics();
  for (const [endpoint, duration] of Object.entries(apiMetrics)) {
    const budget = getAPIBudget(endpoint);
    reports.push({
      timestamp: new Date(),
      budgetType: 'backend',
      metric: endpoint,
      currentValue: duration,
      budgetValue: budget,
      utilizationPercentage: (duration / budget) * 100,
      status: duration > budget ? 'warning' : 'ok',
      trend: calculateTrend(endpoint, duration)
    });
  }
  
  return reports;
}
```

### **Budget Violation Actions**

#### **Immediate Actions for Budget Violations**
```yaml
# Performance budget violation response plan
budget_violations:
  critical:
    # >150% of budget
    actions:
      - "Stop deployment immediately"
      - "Alert on-call engineer"
      - "Create incident in tracking system"
      - "Begin performance investigation"
    
  warning:
    # >100% but <150% of budget  
    actions:
      - "Create performance improvement ticket"
      - "Schedule performance review"
      - "Monitor trend closely"
      - "Consider optimization sprint"
    
  trending:
    # Approaching budget limits
    actions:
      - "Schedule proactive optimization"
      - "Review recent changes"
      - "Update performance monitoring"
      - "Consider infrastructure scaling"
```

#### **Budget Enforcement in CI/CD**
```yaml
# .github/workflows/performance-budget.yml
name: Performance Budget Check

on: [push, pull_request]

jobs:
  performance-budget:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Application
        run: npm run build
      
      - name: Check Bundle Size Budget
        run: |
          npm run bundle-analyzer -- --budget
          if [ $? -ne 0 ]; then
            echo "❌ Bundle size budget exceeded"
            exit 1
          fi
      
      - name: Run Lighthouse CI
        uses: treosh/lighthouse-ci-action@v9
        with:
          budgetPath: './lighthouse-budget.json'
          uploadArtifacts: true
          temporaryPublicStorage: true
      
      - name: Performance Test
        run: |
          npm run test:performance
          if [ $? -ne 0 ]; then
            echo "❌ Performance budget violated"
            exit 1
          fi
```

## 🎯 PERFORMANCE METRICS & TRACKING

### **Key Performance Indicators:**
- **Availability**: Target 99.9% uptime
- **Response Time**: P95 within defined budgets
- **Throughput**: Adequate RPS for expected load  
- **Error Rate**: < 1% of all requests
- **Resource Utilization**: Within budget constraints
- **User Experience**: Meet Core Web Vitals budgets

### **Budget Utilization Tracking**
```typescript
// Track budget utilization over time
interface BudgetUtilization {
  metric: string;
  budget: number;
  current: number;
  utilization: number;
  trend: 'up' | 'down' | 'stable';
  lastViolation?: Date;
  violationCount: number;
}

// Monthly budget review
async function generateBudgetUtilizationReport(): Promise<BudgetUtilization[]> {
  const utilizations: BudgetUtilization[] = [];
  
  // Calculate utilization for each budget metric
  const metrics = await getCurrentPerformanceMetrics();
  
  for (const [metric, current] of Object.entries(metrics)) {
    const budget = getBudgetForMetric(metric);
    utilizations.push({
      metric,
      budget,
      current,
      utilization: (current / budget) * 100,
      trend: calculateTrend(metric, current),
      violationCount: await getViolationCount(metric, 30) // Last 30 days
    });
  }
  
  return utilizations;
}
```

### **Budget Review Process**
- **Weekly**: Review budget violations and trends
- **Monthly**: Comprehensive budget utilization analysis  
- **Quarterly**: Budget adjustment based on business needs
- **Release**: Pre/post-release budget validation
- **Incident**: Budget review after performance incidents

### **Monitoring Best Practices:**
- Track performance metrics over time
- Identify trends and regression patterns  
- Correlate performance with deployments
- Monitor resource usage growth
- Analyze user experience impact
- Alert on budget violations immediately
- Review budgets quarterly for relevance