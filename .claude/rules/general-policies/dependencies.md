# Dependency Management Standards

## 📦 DEPENDENCY ADDITION REQUIREMENTS (MANDATORY)

### **Pre-Addition Evaluation**
Before adding any new dependency, you MUST evaluate:

#### **Justification Criteria (MANDATORY)**
```markdown
# Dependency Addition Request Template

## Dependency Information
- **Name**: package-name
- **Version**: 1.2.3
- **License**: MIT/Apache-2.0/BSD/etc.
- **Repository**: https://github.com/owner/repo
- **NPM/Package Manager**: https://npmjs.com/package/package-name

## Justification
- **Problem Solved**: What specific problem does this solve?
- **Why Not Custom Solution**: Why not implement in-house?
- **Alternatives Considered**: What other packages were evaluated?
- **Size Impact**: Bundle size increase (KB gzipped)

## Evaluation Checklist
- [ ] Package actively maintained (updated within 6 months)
- [ ] Compatible license (check license compatibility matrix)
- [ ] No security vulnerabilities in audit
- [ ] Reasonable bundle size impact (<50KB for utilities, <200KB for frameworks)
- [ ] Good documentation and examples
- [ ] Strong community adoption (>1000 weekly downloads)
- [ ] TypeScript support (if applicable)
- [ ] No conflicts with existing dependencies

## Risk Assessment
- **Security Risk**: Low/Medium/High
- **Maintenance Risk**: Low/Medium/High  
- **Performance Impact**: Low/Medium/High
- **Breaking Change Risk**: Low/Medium/High

## Approval
- [ ] Technical Lead Approval
- [ ] Security Review (for high-risk dependencies)
- [ ] Architecture Review (for major dependencies)
```

#### **License Compatibility Matrix**
```typescript
// Allowed licenses for dependencies
const APPROVED_LICENSES = [
  'MIT',
  'Apache-2.0', 
  'BSD-2-Clause',
  'BSD-3-Clause',
  'ISC',
  'CC0-1.0'
];

// Licenses requiring legal review
const REVIEW_REQUIRED_LICENSES = [
  'GPL-3.0',
  'LGPL-2.1',
  'MPL-2.0',
  'CDDL-1.0'
];

// Prohibited licenses
const PROHIBITED_LICENSES = [
  'GPL-2.0',
  'AGPL-3.0',
  'SSPL-1.0',
  'Commons Clause',
  'Unlicense'  // Security risk - no warranty
];
```

### **Security Review Process (MANDATORY)**
```bash
# Before adding any dependency, run security audit
npm audit
yarn audit  
pnpm audit

# Check for known vulnerabilities
npm audit --audit-level moderate

# Review dependency tree
npm ls --depth=0
npm ls package-name --depth=1

# Check for suspicious patterns
npm info package-name
npm info package-name maintainers
npm info package-name repository
```

### **Bundle Size Impact Assessment**
```bash
# Analyze bundle size impact before adding
npx bundlephobia package-name@version

# Check current bundle size
npm run build
ls -la dist/ # Note current sizes

# After adding dependency
npm install package-name
npm run build  
ls -la dist/ # Compare size increase

# Tool for detailed analysis
npx webpack-bundle-analyzer dist/
```

---

## 🔍 DEPENDENCY AUDIT PROCESS (MANDATORY)

### **Weekly Dependency Audit**
Every project must run weekly dependency audits:

```bash
#!/bin/bash
# weekly-audit.sh

echo "🔍 Running Weekly Dependency Audit..."

# Security vulnerabilities
echo "📊 Security Audit:"
npm audit --audit-level moderate

# Outdated packages  
echo "📦 Outdated Packages:"
npm outdated

# License compliance
echo "📄 License Check:"
npx license-checker --onlyAllow 'MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC'

# Unused dependencies
echo "🗑️ Unused Dependencies:"
npx depcheck

# Bundle size analysis
echo "📈 Bundle Size:"
npx bundlephobia list

echo "✅ Audit Complete"
```

### **Automated Security Monitoring**
```yaml
# .github/workflows/dependency-audit.yml
name: Dependency Audit

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM
  push:
    paths:
      - 'package.json'
      - 'package-lock.json'
      - 'yarn.lock'
      - 'pnpm-lock.yaml'

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Security Audit
        run: |
          npm audit --audit-level moderate
          if [ $? -ne 0 ]; then
            echo "🚨 Security vulnerabilities found!"
            exit 1
          fi
      
      - name: License Check
        run: |
          npx license-checker --failOn 'GPL-2.0;AGPL-3.0'
      
      - name: Bundle Size Check
        run: |
          npm run build
          BUNDLE_SIZE=$(stat -c%s "dist/main.js")
          if [ $BUNDLE_SIZE -gt 1048576 ]; then  # 1MB limit
            echo "🚨 Bundle size too large: ${BUNDLE_SIZE} bytes"
            exit 1
          fi
```

---

## 🔄 DEPENDENCY UPDATE STRATEGY (MANDATORY)

### **Update Categories**

#### **Patch Updates (Automatic)**
```bash
# Safe to update automatically - bug fixes only
# 1.2.3 -> 1.2.4
npm update --depth 0

# Configure automated patch updates
echo '{
  "extends": ["config:base", ":automergeMinor"],
  "packageRules": [
    {
      "updateTypes": ["patch"],
      "automerge": true
    }
  ]
}' > renovate.json
```

#### **Minor Updates (Review Required)**
```bash
# Review required - new features, potential breaking changes
# 1.2.3 -> 1.3.0

# Update specific package
npm install package@^1.3.0

# Test thoroughly
npm test
npm run e2e
npm run build

# Monitor for issues
npm run start
# Manual testing of affected features
```

#### **Major Updates (Extensive Review)**
```bash
# Major version updates require migration planning
# 1.2.3 -> 2.0.0

# Research breaking changes
npm info package@2.0.0 --json | jq '.changelog'
# Read CHANGELOG.md, migration guides

# Create migration branch
git checkout -b upgrade/package-v2

# Update with exact version
npm install package@2.0.0

# Fix breaking changes
# Update imports, API calls, etc.

# Comprehensive testing
npm test
npm run e2e  
npm run performance-test
npm run security-test

# Create detailed PR with migration notes
```

### **Update Testing Requirements**
```typescript
// Package update testing checklist
interface UpdateTestPlan {
  packageName: string;
  oldVersion: string;
  newVersion: string;
  updateType: 'patch' | 'minor' | 'major';
  testingRequired: TestType[];
  rollbackPlan: string[];
}

const updateTestPlan: UpdateTestPlan = {
  packageName: 'react',
  oldVersion: '17.0.2',
  newVersion: '18.0.0', 
  updateType: 'major',
  testingRequired: [
    'unit-tests',
    'integration-tests',
    'e2e-tests',
    'performance-tests',
    'visual-regression-tests',
    'accessibility-tests'
  ],
  rollbackPlan: [
    '1. npm install react@17.0.2',
    '2. Revert code changes',
    '3. Run test suite',
    '4. Deploy if tests pass'
  ]
};
```

---

## 🚫 DEPENDENCY RED FLAGS (MANDATORY CHECKS)

### **Security Red Flags**
```bash
# Check for suspicious packages
npm info package-name | grep -E "(created|modified|maintainers)"

# Red flags to watch for:
# - Package created very recently (< 30 days ago)
# - No repository link or private repository
# - Maintainers with suspicious names or no previous packages
# - Very few downloads despite being available for months
# - Package name similar to popular packages (typosquatting)
```

### **Maintenance Red Flags**
```typescript
interface DependencyRedFlags {
  noUpdatesInMonths: number;      // > 24 months is concerning
  weeklyDownloads: number;        // < 100 is concerning  
  openIssuesCount: number;        // > 100 unresolved issues
  openSecurityIssues: number;     // > 0 is critical
  hasTests: boolean;              // false is concerning
  hasDocumentation: boolean;      // false is concerning  
  maintainerCount: number;        // < 2 is risky
  hasCommercialSupport: boolean;  // affects risk assessment
}

// Automated red flag detection
async function assessDependencyRisk(packageName: string): Promise<DependencyRedFlags> {
  const packageInfo = await npm.info(packageName);
  const githubInfo = await github.getRepoInfo(packageInfo.repository.url);
  
  return {
    noUpdatesInMonths: monthsSince(packageInfo.time.modified),
    weeklyDownloads: packageInfo.downloads.weekly,
    openIssuesCount: githubInfo.open_issues_count,
    openSecurityIssues: await getSecurityIssueCount(packageName),
    hasTests: await hasTestDirectory(packageInfo.repository.url),
    hasDocumentation: await hasReadme(packageInfo.repository.url),
    maintainerCount: packageInfo.maintainers.length,
    hasCommercialSupport: await checkCommercialSupport(packageName)
  };
}
```

### **Performance Red Flags**
```bash
# Bundle size analysis
npx bundlephobia package@version

# Red flags:
# - Minified size > 100KB for utilities
# - Minified + Gzipped size > 50KB for simple functions  
# - Large number of dependencies (> 10 for utilities)
# - Tree-shaking not supported
# - No ES modules (only CommonJS)
```

---

## 📊 DEPENDENCY METRICS TRACKING (RECOMMENDED)

### **Track These Metrics**
```typescript
interface DependencyMetrics {
  totalDependencies: number;
  productionDependencies: number;
  devDependencies: number;
  vulnerabilitiesHigh: number;
  vulnerabilitiesMedium: number;
  vulnerabilitiesLow: number;
  outdatedPackages: number;
  bundleSize: {
    total: number;
    vendor: number;
    application: number;
  };
  licenseCompliance: {
    approved: number;
    needsReview: number; 
    prohibited: number;
  };
}

// Generate monthly dependency report
async function generateDependencyReport(): Promise<DependencyMetrics> {
  const packageJson = require('./package.json');
  const auditResult = await runNpmAudit();
  const outdatedResult = await runNpmOutdated();
  const bundleAnalysis = await analyzeBundleSize();
  
  return {
    totalDependencies: Object.keys({
      ...packageJson.dependencies,
      ...packageJson.devDependencies
    }).length,
    productionDependencies: Object.keys(packageJson.dependencies || {}).length,
    devDependencies: Object.keys(packageJson.devDependencies || {}).length,
    vulnerabilitiesHigh: auditResult.high || 0,
    vulnerabilitiesMedium: auditResult.moderate || 0, 
    vulnerabilitiesLow: auditResult.low || 0,
    outdatedPackages: Object.keys(outdatedResult).length,
    bundleSize: bundleAnalysis,
    licenseCompliance: await analyzeLicenseCompliance()
  };
}
```

---

## 🛡️ DEPENDENCY SECURITY BEST PRACTICES

### **Lock File Management**
```bash
# Always commit lock files
git add package-lock.json  # npm
git add yarn.lock          # yarn  
git add pnpm-lock.yaml     # pnpm

# Keep lock files updated
npm ci                     # Use in CI/CD
npm install --package-lock-only  # Update lock without node_modules
```

### **Dependency Scanning Integration**
```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Snyk Security Scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=medium
      
      - name: Run NPM Audit
        run: npm audit --audit-level moderate
      
      - name: OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'project-name'
          path: '.'
          format: 'HTML'
```

### **Private Package Registry**
```bash
# Configure private registry for internal packages
npm config set @company:registry https://npm.company.com/

# .npmrc file
@company:registry=https://npm.company.com/
//npm.company.com/:_authToken=${NPM_TOKEN}

# Always prefer internal packages over public alternatives
npm install @company/utils instead-of third-party-utils
```

---

## 🔧 DEPENDENCY MANAGEMENT TOOLS

### **Recommended Tools**
```json
{
  "devDependencies": {
    "depcheck": "^1.4.3",           // Find unused dependencies
    "license-checker": "^25.0.1",   // License compliance
    "bundlephobia-cli": "^0.1.4",   // Bundle size analysis  
    "npm-check-updates": "^16.6.2", // Update checker
    "audit-ci": "^6.6.1",          // CI security auditing
    "renovate": "^34.24.0"          // Automated dependency updates
  }
}
```

### **Package.json Configuration**
```json
{
  "scripts": {
    "deps:check": "depcheck",
    "deps:audit": "audit-ci --moderate",
    "deps:outdated": "ncu --target minor",
    "deps:update": "ncu -u && npm install",
    "deps:licenses": "license-checker --onlyAllow 'MIT;Apache-2.0;BSD-3-Clause'",
    "deps:size": "bundlephobia list"
  },
  "renovate": {
    "extends": ["config:base"],
    "packageRules": [
      {
        "updateTypes": ["patch"],
        "automerge": true
      },
      {
        "updateTypes": ["minor"],
        "reviewers": ["team:developers"]
      },
      {
        "updateTypes": ["major"],
        "reviewers": ["team:senior-developers", "team:architects"]
      }
    ]
  }
}
```

---

## 📋 DEPENDENCY MANAGEMENT CHECKLIST

### **Before Adding Dependencies**
- [ ] Business justification documented
- [ ] Alternative solutions evaluated
- [ ] License compatibility verified
- [ ] Security audit passed
- [ ] Bundle size impact assessed
- [ ] Maintenance status reviewed
- [ ] Required approvals obtained

### **Weekly Maintenance**
- [ ] Security audit run (`npm audit`)
- [ ] Outdated packages reviewed (`npm outdated`)
- [ ] License compliance checked
- [ ] Unused dependencies removed (`depcheck`)
- [ ] Bundle size monitored
- [ ] Update candidates prioritized

### **Monthly Review**
- [ ] Dependency metrics report generated
- [ ] High-risk dependencies identified  
- [ ] Update roadmap planned
- [ ] Team training on new critical dependencies
- [ ] Documentation updated

### **Quarterly Audit**
- [ ] Complete dependency tree review
- [ ] License compliance audit
- [ ] Security posture assessment
- [ ] Performance impact analysis
- [ ] Sunset plan for EOL dependencies

---

## 🚨 DEPENDENCY VIOLATIONS

### **Zero Tolerance Violations**
- [ ] Adding dependencies without justification
- [ ] Using packages with prohibited licenses
- [ ] Ignoring high/critical security vulnerabilities
- [ ] Committing secrets in dependency configurations
- [ ] Installing packages from untrusted sources

### **Review Required Violations** 
- [ ] Bundle size increase > 100KB without approval
- [ ] Adding major version updates without migration plan
- [ ] Bypassing security scan requirements
- [ ] Using deprecated or unmaintained packages
- [ ] Multiple packages solving the same problem

---

## 🎯 DEPENDENCY HEALTH TARGETS

### **Security Targets**
- **Zero high/critical vulnerabilities** in production
- **All medium vulnerabilities** addressed within 30 days
- **Security scans** run on every deployment
- **100% license compliance** with approved licenses

### **Maintenance Targets**
- **<5% outdated dependencies** older than 6 months
- **Monthly update cycles** for patch versions
- **Quarterly review** of all major dependencies  
- **90% test coverage** for dependency integration code

### **Performance Targets**
- **Bundle size growth** <10% per quarter
- **Load time impact** <100ms per new dependency
- **Tree-shaking effectiveness** >80% for utility libraries
- **First-party code ratio** >70% of total bundle

---

**Related Rules**: See `general-policies/ops/git-workflow.md` for dependency update PR requirements and `core-standards/coding-standards.md` for import organization standards.