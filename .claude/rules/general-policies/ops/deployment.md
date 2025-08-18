# Universal Deployment & DevOps Rules

This document outlines universal standards for deployment, CI/CD, infrastructure management, and DevOps practices that must be followed across all projects.

## 📚 Related Documentation
- **[observability.md](./observability.md)** - Monitoring, metrics, alerting, and health checks
- **[performance.md](./performance.md)** - Performance budgets and optimization
- **[git-workflow.md](./git-workflow.md)** - Git branching and CI/CD integration
- **[idempotency.md](./idempotency.md)** - Safe deployment patterns

## 🚀 CRITICAL DEPLOYMENT REQUIREMENTS

### 1. **CI/CD Pipeline Standards (MANDATORY)**

#### **Pipeline Structure:**
- **Source control integration**: All code changes trigger pipeline
- **Automated testing**: Full test suite must pass before deployment
- **Security scanning**: Automated vulnerability and secret detection
- **Build validation**: Successful build required for all environments
- **Deployment gates**: Manual approval required for production

#### **Required Pipeline Stages:**
```yaml
# Mandatory CI/CD stages
stages:
  - test          # Unit, integration, security tests
  - build         # Compile, package, container build
  - security      # Vulnerability scan, secret detection
  - staging       # Deploy to staging environment
  - approval      # Manual approval gate for production
  - production    # Production deployment
  - monitoring    # Post-deployment health checks
```

### 2. **Environment Management (CRITICAL)**

#### **Environment Standards:**
- **Environment parity**: Development, staging, production must be identical
- **Configuration management**: Environment-specific configs without code changes
- **Secret management**: No secrets in code, use secure secret stores
- **Resource isolation**: Each environment completely isolated
- **Data protection**: Production data never in non-production environments

#### **Environment Requirements:**
```bash
# MANDATORY environment variables
NODE_ENV=production|staging|development
LOG_LEVEL=error|warn|info|debug
DATABASE_URL=<encrypted-connection-string>
SECRET_KEY=<256-bit-random-key>
API_VERSION=v1
HEALTH_CHECK_INTERVAL=30
```

### 3. **Deployment Safety (MANDATORY)**

#### **Deployment Strategies:**
- **Blue-green deployment**: Zero-downtime deployments required
- **Rollback capability**: One-click rollback to previous version
- **Health checks**: See [`observability.md`](./observability.md#health-check-implementation) for implementation
- **Canary deployments**: Gradual rollout for high-risk changes
- **Feature flags**: Runtime feature toggling capability

#### **Pre-deployment Checklist:**
- [ ] All tests passing (unit, integration, e2e)
- [ ] Security scans completed with no critical issues
- [ ] Database migrations tested and reversible
- [ ] Rollback plan documented and tested
- [ ] Monitoring and alerting configured
- [ ] Performance benchmarks met
- [ ] Stakeholder approval obtained

### 4. **Infrastructure as Code (CRITICAL)**

#### **IaC Requirements:**
- **Version control**: All infrastructure defined in code
- **Declarative configuration**: Infrastructure state clearly defined
- **Automated provisioning**: No manual infrastructure changes
- **Change tracking**: All infrastructure changes auditable
- **Environment consistency**: Same IaC for all environments

#### **Infrastructure Standards:**
```yaml
# Required infrastructure components
infrastructure:
  compute:
    - auto_scaling: true
    - health_checks: enabled
    - security_groups: restrictive
  
  storage:
    - encryption_at_rest: true
    - backup_automated: true
    - retention_policy: defined
  
  networking:
    - vpc_isolation: true
    - ssl_termination: required
    - ddos_protection: enabled
  
  monitoring:
    - logging: centralized
    - metrics: comprehensive
    - alerting: configured
```

### 5. **Monitoring & Observability (MANDATORY)**

> For comprehensive monitoring, metrics, alerting, and health check requirements, see [`observability.md`](./observability.md)

## 🔧 DEPLOYMENT AUTOMATION

### **Automated Deployment Requirements:**
```bash
# Required deployment automation
deploy_automation:
  triggers:
    - git_push_to_main
    - scheduled_releases
    - manual_approval
  
  validations:
    - test_suite_pass
    - security_scan_pass
    - performance_benchmark_met
  
  deployment:
    - zero_downtime_strategy
    - health_check_validation
    - automatic_rollback_on_failure
  
  post_deployment:
    - smoke_tests
    - monitoring_validation
    - stakeholder_notification
```

### **Deployment Rollback:**
- **Automatic rollback triggers**: Health check failures, error rate spikes
- **Manual rollback capability**: One-click rollback from dashboard
- **Database rollback**: Schema migration reversibility
- **File rollback**: Asset and configuration file reversion
- **Validation after rollback**: Confirm system stability

## 🏗️ BUILD STANDARDS

### **Build Requirements:**
- **Reproducible builds**: Same input produces identical output
- **Build caching**: Optimize build times with intelligent caching
- **Artifact storage**: Secure storage of build artifacts
- **Build versioning**: Semantic versioning for all releases
- **Build signing**: Cryptographic signatures for security

### **Container Standards (if applicable):**
```dockerfile
# Required container practices
FROM node:18-alpine  # Use official, minimal base images
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production  # Reproducible installs
COPY . .
RUN npm run build
EXPOSE 3000
USER node  # Non-root user
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
CMD ["npm", "start"]
```

## 📊 DEPLOYMENT METRICS

> For comprehensive metrics tracking, performance targets, and monitoring requirements, see [`observability.md`](./observability.md#metrics-to-track) and [`performance.md`](./performance.md#performance-metrics--tracking)

### **Key Deployment Metrics:**
- **Deployment frequency**: How often deployments occur
- **Lead time**: Time from commit to production  
- **Mean time to recovery**: Time to recover from failures
- **Change failure rate**: Percentage of deployments causing issues

## 🚨 DEPLOYMENT FAILURE PROCEDURES

### **Incident Response:**
1. **Immediate assessment**: Determine severity and impact
2. **Communication**: Alert stakeholders and users if necessary
3. **Mitigation**: Rollback or hotfix deployment
4. **Investigation**: Root cause analysis
5. **Prevention**: Implement measures to prevent recurrence

### **Rollback Triggers:**
- Critical application errors
- Performance degradation > 20%
- Security vulnerability exposure
- Data integrity issues
- User authentication failures

## 📋 DEPLOYMENT CHECKLIST

### **Pre-deployment Validation:**
- [ ] All automated tests passing
- [ ] Security scans completed successfully
- [ ] Performance benchmarks met
- [ ] Database migrations tested
- [ ] Rollback procedure documented
- [ ] Monitoring configured for new features
- [ ] Stakeholder approval obtained
- [ ] Communication plan in place

### **Post-deployment Validation:**
- [ ] Health checks passing
- [ ] Performance metrics within normal range
- [ ] Error rates at acceptable levels
- [ ] User functionality working as expected
- [ ] Monitoring data flowing correctly
- [ ] Documentation updated
- [ ] Team notified of successful deployment

## 🎯 DEVOPS CULTURE

### **Team Practices:**
- **Shared responsibility**: Development and operations collaborate
- **Continuous improvement**: Regular retrospectives and process refinement
- **Blameless post-mortems**: Focus on system improvement, not blame
- **Knowledge sharing**: Documentation and cross-training
- **Automation first**: Automate repetitive tasks

### **Quality Gates:**
- No deployment without passing all **critical** tests
- **TypeScript Policy**: Follow Pragmatic TypeScript Policy (< 500 errors acceptable)
- No manual configuration changes in production
- All infrastructure changes through code
- Security considerations in every deployment
- Performance impact assessment for all changes
- **Build success for functionality** (TypeScript warnings acceptable)