# Visual Regression Testing Verification Rule

## 🎯 MANDATORY: Visual Testing After Every Frontend Change

### **WHEN TO APPLY THIS RULE**
- After ANY frontend component change
- After CSS/styling modifications
- After layout adjustments
- After adding new features
- After fixing UI bugs

## 📸 VISUAL REGRESSION WORKFLOW

### **1. MAKE THE CHANGE**
```bash
# Example: Fix a button color issue in login page
# Modify the component/CSS
```

### **2. CAPTURE CURRENT STATE WITH PLAYWRIGHT MCP**
```javascript
// Use Playwright MCP to capture the page
await mcp__playwright__browser_navigate({ url: '/login' });
await mcp__playwright__browser_take_screenshot({ 
  filename: 'login-current.png',
  fullPage: true 
});
```

### **3. COMPARE WITH BASELINE**
```bash
# Run visual comparison
node scripts/visual-compare.mjs
```

### **4. REPORT FORMAT FOR FIXES**

#### ✅ **SUCCESS FORMAT (No Visual Changes)**
```
VISUAL REGRESSION TEST: ✅ PASSED
Feature: Fixed login button hover state
URL: /login
Files:
  - Baseline: login-baseline.png
  - Current: login-current.png
  - Diff: login-diff.png
  - Changes: 0% (No visual changes detected)
Status: Fix successful - No unintended visual changes
```

#### ❌ **FAILURE FORMAT (Unexpected Changes)**
```
VISUAL REGRESSION TEST: ⚠️ CHANGES DETECTED
Feature: Fixed login button hover state
URL: /login
Files:
  - Baseline: login-baseline.png
  - Current: login-current.png
  - Diff: login-diff.png
  - Changes: 2.3% (234 pixels different)
Status: Review needed - Unexpected visual changes
```

## 🆕 NEW FEATURE VERIFICATION

### **REPORT FORMAT FOR NEW FEATURES**
```
VISUAL REGRESSION TEST: 🆕 NEW FEATURE
Feature: Added password strength indicator
URL: /register
Files:
  - Component: apps/frontend/src/components/auth/RegisterForm.tsx
  - Baseline: tests/e2e/visual/screenshots/baseline/register.png
  - Current: tests/e2e/visual/screenshots/current/register-with-indicator.png
  - Diff: 15.2% (Expected changes for new feature)

Visual Changes:
  ✅ Password strength bar added below password field
  ✅ Color indicators (red/yellow/green) for strength
  ✅ Text feedback for password requirements
```

## 🔄 AUTOMATED VERIFICATION STEPS

### **Step 1: Capture Before State (if needed)**
```javascript
// For new features, capture baseline first
await captureBaseline('/path-to-page');
```

### **Step 2: Make Changes**
```typescript
// Implement the fix or feature
```

### **Step 3: Capture After State**
```javascript
// Use Playwright MCP to capture current state
await mcp__playwright__browser_navigate({ url: targetUrl });
await mcp__playwright__browser_take_screenshot({ 
  filename: `${urlToFilename(targetUrl)}-current.png`,
  fullPage: true 
});
```

### **Step 4: Run Comparison**
```javascript
// Automated comparison script
const result = await compareImages(baseline, current);
```

### **Step 5: Generate Report**
```javascript
// Output in required format
console.log(`
Feature: ${featureName}
URL: ${url}
Files:
  - Baseline: ${baselinePath}
  - Current: ${currentPath}
  - Diff: ${result.diffPercentage}%
`);
```

## 📊 DIFF THRESHOLDS

### **Acceptable Diff Percentages**
- **0%**: Perfect match (ideal for fixes)
- **< 0.1%**: Anti-aliasing differences (acceptable)
- **< 1%**: Minor rendering differences (review)
- **> 1%**: Significant changes (investigation required)
- **> 5%**: Major changes (likely intentional or broken)

## 🚀 QUICK COMMANDS

### **Test Single Route**
```bash
# Compare specific route (generates diff automatically)
node scripts/visual-compare.mjs login
node scripts/visual-compare.mjs dashboard
node scripts/visual-compare.mjs component-showcase
```

### **Update Baseline**
```bash
# Update baseline when changes are approved
cp tests/e2e/visual/screenshots/login-current.png tests/e2e/visual/screenshots/login-baseline.png
```

### **View Diff Image**
```bash
# Open diff image to see visual changes
open tests/e2e/visual/screenshots/login-diff.png
```

### **Batch Testing**
```bash
# Test multiple routes
for route in login dashboard settings; do
  node scripts/visual-compare.mjs $route
done
```

## 📝 CHECKLIST FOR EVERY CHANGE

- [ ] Make the frontend change
- [ ] Run visual regression test
- [ ] Check diff percentage
- [ ] If diff > 0%, verify changes are intentional
- [ ] Document visual changes in commit message
- [ ] Update baseline if new design is approved

## 🎯 SMART FILE NAMING

The system uses a unified screenshots directory with descriptive naming:
- **Directory**: `tests/e2e/visual/screenshots/`
- **Baseline**: `<route>-baseline.png`
- **Current**: `<route>-current.png`
- **Diff**: `<route>-diff.png` (always generated)

Examples:
- `/login` → `login-baseline.png`, `login-current.png`, `login-diff.png`
- `/dashboard` → `dashboard-baseline.png`, `dashboard-current.png`, `dashboard-diff.png`
- `/component-showcase` → `component-showcase-baseline.png`, etc.

This ensures automatic baseline matching without configuration.

## ⚠️ IMPORTANT NOTES

1. **Always test at 1920x1080 resolution**
2. **Wait for animations to complete before capturing**
3. **Clear any notifications/toasts before capturing**
4. **Test in consistent environment (same browser, OS)**
5. **Document any intentional visual changes**

## 🌐 AUTOMATIC REPORT VIEWING

### **WHEN DIFFERENCES ARE DETECTED**

When visual regression tests detect differences > 1%, the system **AUTOMATICALLY**:

1. **Opens Browser** to Playwright HTML reporter
2. **Navigates to Failed Tests** with precise testId URLs  
3. **Shows Visual Differences** side-by-side comparison
4. **Enables Quick Review** without manual navigation

### **URL FORMAT**
```
http://playwright.main.clarosfarm.localhost/#?testId=b0d67a64cf44dd8a563c-0f5ecabede19038e6584
```

**Smart Port System Integration:**
- URLs automatically use worktree-based subdomains: `playwright.{worktree}.clarosfarm.localhost`
- Ports are deterministically calculated using the same algorithm as the smart port system
- For worktree `main`: Port `8223`, URL: `http://playwright.main.clarosfarm.localhost`
- For worktree `feature-auth`: Port `8052`, URL: `http://playwright.feature-auth.clarosfarm.localhost`

### **AUTOMATIC OPENING TRIGGERS**

#### ✅ **Auto-Open Scenarios**
- `npm run visual:compare` detects failures
- Visual tests run with differences > 1%
- Manual trigger: `npm run visual:open`
- Server start: `npm run visual:serve`

#### 🔍 **Available Commands**
```bash
# Open failed visual tests automatically
npm run visual:open

# Start HTML server and open failures  
npm run visual:serve

# Check for failures without opening
npm run visual:check

# Compare and auto-open on differences
npm run visual:compare
```

### **CONFIGURATION OPTIONS**

#### **Environment Variables**
```bash
# Disable auto-opening
export PLAYWRIGHT_AUTO_OPEN=false

# Override smart port (otherwise auto-calculated)
export PLAYWRIGHT_REPORT_PORT=9324

# Override smart URL (otherwise auto-generated)
export PLAYWRIGHT_REPORT_URL=http://custom-host:9323
```

#### **Command Options**
```bash
# Custom threshold (default: 1.0%)
npm run visual:open -- --threshold 0.5

# Custom port
npm run visual:serve -- --port 9324

# Disable auto-opening
npm run visual:open -- --no-auto
```

### **TROUBLESHOOTING**

#### **Reporter Not Opening**
```bash
# Check if HTML server is running
curl http://localhost:9323

# Start server manually
npx playwright show-report --port 9323

# View available URLs
npm run visual:check
```

#### **Custom Browser Command**
```bash
# macOS with Chrome
npm run visual:open -- --browser "open -a 'Google Chrome'"

# Linux with Firefox  
npm run visual:open -- --browser "firefox"

# Windows
npm run visual:open -- --browser "start chrome"
```

## 🔥 EXAMPLE WORKFLOW

```javascript
// 1. Fix button color issue
await editFile('Button.tsx', { color: '#007bff' });

// 2. Capture current state
await mcp__playwright__browser_navigate({ url: '/login' });
await mcp__playwright__browser_take_screenshot({ 
  filename: 'login-current.png',
  fullPage: true 
});

// 3. Compare (auto-opens browser on differences)
const diff = await compareWithBaseline('login');

// 4. Report
if (diff === 0) {
  console.log('✅ Fix successful - No visual regression');
} else {
  console.log(`⚠️ ${diff}% difference detected - Review needed`);
  // 🌐 Browser automatically opens to: 
  // http://localhost:9323/#?testId=abc123...
}
```

---

**This rule ensures visual consistency and prevents unintended UI changes through automated baseline comparison with instant visual feedback.**