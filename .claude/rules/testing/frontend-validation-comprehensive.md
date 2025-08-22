# Frontend Validation Comprehensive Rule

## 🎯 Purpose
Comprehensive validation of frontend changes through automated testing, design compliance checking, and acceptance criteria verification using Playwright MCP as primary tool with support for additional visual regression tools.

## 🚨 MANDATORY: Post-Frontend-Change Validation

### **Trigger Condition**
IMMEDIATELY after ANY frontend file modification:
- React components (`*.tsx`, `*.jsx`)
- Styles (`*.css`, `*.scss`, `*.module.css`)
- Pages/Routes (`routes/**/*`, `pages/**/*`)
- Layouts (`layouts/**/*`)
- Assets (`*.png`, `*.svg`, `*.jpg`)
- Config (`tailwind.config.js`, `next.config.js`)

### **Validation Workflow**
```yaml
MANDATORY_SEQUENCE:
  1_IDENTIFY_CHANGES:
    - Review modified components/pages using git diff
    - Map changes to affected URLs/routes
    - List all impacted user-facing views
    
  2_NAVIGATE_TO_PAGES:
    - Use mcp__playwright__browser_navigate for each affected URL
    - Ensure page loads completely (wait for network idle)
    - Verify no loading errors
    
  3_VERIFY_DESIGN_COMPLIANCE:
    - Compare against /context/design-principles.md
    - Validate against /context/style-guide.md
    - Check responsive behavior at key breakpoints
    
  4_VALIDATE_IMPLEMENTATION:
    - Confirm change fulfills user's specific request
    - Verify all acceptance criteria are met
    - Check feature works as intended
    
  5_CHECK_CONSOLE_ERRORS:
    - Run mcp__playwright__browser_console_messages
    - Ensure no JavaScript errors
    - Verify no failed network requests
    
  6_CAPTURE_EVIDENCE:
    - Take full page screenshot at 1440px width
    - Use mcp__playwright__browser_take_screenshot
    - Save with descriptive filename
    
  7_VISUAL_REGRESSION_CHECK:
    - Compare against baseline in ./screenshots/baseline/
    - Flag any unexpected visual changes
    - Document intentional changes
```

## 🔄 Two-Phase Testing Strategy

### **Phase 1: Affected URLs (Fast Feedback)**
```yaml
Immediate Execution:
  Duration: 30-60 seconds
  Scope: Only URLs detected from changed files
  Purpose: Fast feedback on direct impact
  
Process:
  1. Analyze changed files
  2. Map to affected URLs
  3. Run visual tests for those URLs only
  4. Report results immediately
  5. Block commit if regressions found
```

### **Phase 2: Comprehensive Coverage (Side Effects)**
```yaml
Background Execution:
  Duration: 5-15 minutes  
  Scope: ALL registered URLs
  Purpose: Catch unexpected side effects
  
Process:
  1. Run remaining URLs not tested in Phase 1
  2. Compare against baselines
  3. Report any unexpected changes
  4. Update commit status if new regressions found
```

## 🔍 Smart URL Detection Algorithm (Generic)

### **1. Component-to-URL Mapping**
```yaml
Detection Strategy:
  - Scan changed component files for usage patterns
  - Map components to pages that import them
  - Identify layout components that affect multiple pages
  - Detect shared components used across routes

Example Mappings:
  "src/components/Header.tsx": ["ALL_PAGES"]  # Layout component
  "src/components/Card.tsx": ["/dashboard", "/list"]
  "src/pages/dashboard.tsx": ["/dashboard"]
  "src/styles/globals.css": ["ALL_PAGES"]  # Global styles
```

### **2. Route Detection from File Paths**
```yaml
Path-Based Detection:
  - Framework-specific routing analysis (Next.js, React Router, etc.)
  - Dynamic route parameter injection
  - Layout component inheritance
  - Shared component usage tracking

Examples:
  "src/pages/dashboard.tsx" → ["/dashboard"]
  "src/pages/items/[id].tsx" → ["/items/1", "/items/2", "/items/3"]
  "src/layouts/MainLayout.tsx" → ["ALL_PAGES_USING_LAYOUT"]
```

### **3. Style Impact Analysis**
```yaml
CSS Change Detection:
  - Global style changes → Test ALL pages
  - Component-specific styles → Test pages using component
  - Utility class changes → Test pages using those classes
  - Theme/variable changes → Test ALL pages

Examples:
  "globals.css" → Test ALL pages
  "Component.module.css" → Test pages with Component
  "tailwind.config.js" → Test ALL pages
```

## 📊 Integration with Existing Systems

### **PostToolUse Hook Enhancement**
```bash
# Add to .claude/hooks/04-post-tool-01-test-runner.sh after line 98

# NEW: Mandatory frontend validation with Playwright
if [[ "$MODIFIED_FILE" =~ (components|pages|routes|layouts|styles) ]]; then
  echo "🎨 Running mandatory frontend validation..."
  
  # Execute validation workflow
  node .claude/scripts/frontend-validator.js "$MODIFIED_FILE" || {
    echo "❌ Frontend validation failed - fix issues before continuing"
    exit 1
  }
fi
```

## 📸 Baseline Management

### **Baseline Creation**
```yaml
New Baselines:
  - Created after successful validation
  - Stored in ./screenshots/baseline/ directory
  - Organized by viewport and test name
  - Versioned with git commit hash

Update Triggers:
  - Manual: npm run visual:update-baseline (if available)
  - Automatic: After approved changes
  - Forced: VISUAL_UPDATE_BASELINE=true flag
```

### **Baseline Comparison**
```yaml
Comparison Process:
  1. Load baseline screenshot for URL
  2. Take current screenshot
  3. Pixel-by-pixel comparison (when tool available)
  4. Generate diff image if changes detected
  5. Calculate change percentage
  6. Report if above threshold (default: 0.1%)

Threshold Configuration:
  Global: 0.1% pixel difference
  Per-URL: Configurable in project rules
  Critical Pages: 0.05% (stricter)
  Dynamic Content: 1.0% (more lenient)
```

## 🔧 Tool Integration

### **Primary: Playwright MCP**
- Always available in Claude Code
- Real browser testing
- Console error detection
- Screenshot capture
- Network monitoring

### **Secondary: Visual Regression Tools**
- Lost Pixel (project-specific)
- BackstopJS
- Percy
- Chromatic

The validator script automatically detects available tools and uses them when present.

## 📋 Validation Checklist

### **MUST CHECK (Blocking)**
- [ ] Page loads without errors
- [ ] No console errors
- [ ] Change matches user request
- [ ] Acceptance criteria met
- [ ] Screenshot captured

### **SHOULD CHECK (Warning)**
- [ ] Visual regression minimal (<0.1%)
- [ ] Performance not degraded
- [ ] Responsive design intact
- [ ] Accessibility maintained

### **NICE TO CHECK (Info)**
- [ ] Animation smooth
- [ ] Hover states work
- [ ] Focus management correct
- [ ] Print styles updated

## 🚨 Failure Handling

### **Critical Failures (Block Progress)**
```yaml
Console Errors:
  - JavaScript exceptions
  - Failed API calls
  - Missing resources
  Action: STOP and fix immediately

Page Not Loading:
  - 404/500 errors
  - Infinite loading
  - Blank page
  Action: STOP and debug

Feature Broken:
  - Core functionality fails
  - Data not displaying
  - Forms not submitting
  Action: STOP and repair
```

### **Warning Failures (Continue with Caution)**
```yaml
Visual Regressions:
  - Minor layout shifts
  - Color variations
  - Font rendering differences
  Action: Document and continue

Performance Issues:
  - Slower load times
  - Large bundle size
  - Memory leaks
  Action: Note for optimization
```

## 🔧 Configuration

### **Viewport Configurations**
```javascript
const viewports = {
  mobile: { width: 375, height: 667 },
  tablet: { width: 768, height: 1024 },
  desktop: { width: 1440, height: 900 },
  wide: { width: 1920, height: 1080 }
};
```

### **Validation Thresholds**
```javascript
const thresholds = {
  visualRegression: 0.001,  // 0.1% pixel difference
  loadTime: 3000,           // 3 seconds max
  consoleErrors: 0,         // Zero tolerance
  accessibility: 0.95       // 95% score minimum
};
```

### **Fallback Strategies**
When Playwright MCP is unavailable:
1. Use available testing tools (Jest, Vitest)
2. Static code analysis
3. TypeScript compilation check
4. Manual testing checklist generation

## 📋 Reporting Format

### **Success Report**
```
✅ Frontend Validation Complete

📍 Routes Tested: /dashboard, /items
🖼️ Screenshots: 2 captured
⏱️ Load Time: 1.2s average
🔍 Console: No errors
📊 Visual: No regressions

✅ All validation checks passed
```

### **Failure Report**
```
❌ Frontend Validation Failed

📍 Route: /dashboard
❌ Console Errors: 2 found
  - TypeError: Cannot read property 'id' of undefined
  - Failed to load resource: 404

🖼️ Screenshot: dashboard-error-1704123456.png
📊 Visual Regression: 2.3% change detected

🔧 Required Actions:
1. Fix JavaScript error in Dashboard.tsx:45
2. Restore missing API endpoint
3. Review visual changes in ./screenshots/diffs/
```

## 🎯 Success Criteria

### **Implementation Complete When:**
- ✅ Hook triggers on every frontend change
- ✅ Playwright MCP automatically navigates to affected pages
- ✅ Screenshots captured for all changes
- ✅ Console errors detected and reported
- ✅ Visual regressions flagged when tools available
- ✅ Clear pass/fail status provided

### **Integration Points:**
- ✅ Works with existing PostToolUse hook
- ✅ Compatible with various visual regression tools
- ✅ Uses existing baseline screenshots
- ✅ Integrates with test cache system
- ✅ Parallel execution for performance

## 🔄 Continuous Improvement

### **Metrics to Track:**
- Validation execution time
- False positive rate
- Caught regression count
- Screenshot storage usage
- Developer satisfaction

### **Future Enhancements:**
- AI-powered visual diff analysis
- Automatic baseline updates
- Cross-browser testing
- Performance profiling
- Accessibility scoring

This rule ensures every frontend change is thoroughly validated before proceeding, catching issues early and maintaining visual consistency across all projects.