# Playwright-First Testing Standards

> Strategy document. Canonical requirements live in `./core-standards.md`. Project-specific test deltas live in `../../../current-code/testing/clarosfarm-tests.md`.

## 🎯 Purpose
Test from user perspective first, building features that actually work for real users through end-to-end testing.

## 🎭 Playwright-First Philosophy

### Core Principle
```markdown
USER STORY → E2E TEST → IMPLEMENTATION → VERIFICATION

Build tests that represent real user behavior, not implementation details.
If a user can't complete their task, the feature isn't done.
```

### Testing Hierarchy
```markdown
PRIORITY ORDER:
1. 🎭 E2E Tests (User flows) - PRIMARY
2. 🧩 Integration Tests (API + UI) - SECONDARY  
3. 🔧 Unit Tests (Logic only) - SUPPORTING

Focus 70% effort on E2E tests that validate user stories.
```

## 🚀 Implementation Strategy

### Test-First Development
```markdown
FOR EACH FEATURE:
1. Write user story
2. Create E2E test (failing)
3. Build minimum code to pass test
4. Verify user flow works
5. Refactor if needed
6. Mark feature complete

NEVER mark feature complete without E2E test passing.
```

### User Story to Test Translation
```markdown
USER STORY:
"As a farmer, I want to view tank levels so I can prevent overflows"

E2E TEST:
1. Login as farmer user
2. Navigate to dashboard
3. Verify tank level widgets visible
4. Check level data displays correctly
5. Confirm alerts show when levels high
6. Verify user can take action

CODE TO BUILD:
- Dashboard route
- Tank level API
- Tank widget component
- Alert system
- User actions
```

## 🎯 Test Writing Standards

### Good E2E Test Structure
```javascript
// ✅ GOOD - Tests user behavior
test('farmer can monitor tank levels and receive alerts', async ({ page }) => {
  // Setup: Login as farmer
  await page.goto('/login');
  await page.fill('[data-testid=email]', 'farmer@test.com');
  await page.fill('[data-testid=password]', 'password123');
  await page.click('[data-testid=login-button]');
  
  // Navigate to monitoring
  await page.click('[data-testid=dashboard-link]');
  
  // Verify tank levels visible
  await expect(page.locator('[data-testid=tank-level-widget]')).toBeVisible();
  await expect(page.locator('[data-testid=tank-1-level]')).toContainText('75%');
  
  // Check alert functionality
  await expect(page.locator('[data-testid=high-level-alert]')).toBeVisible();
  
  // Verify user can act on alert
  await page.click('[data-testid=alert-action-button]');
  await expect(page.locator('[data-testid=action-confirmation]')).toBeVisible();
});
```

### Bad E2E Test Examples
```javascript
// ❌ BAD - Tests implementation details
test('tank level component renders correct props', async ({ page }) => {
  // This tests implementation, not user value
  await page.goto('/components/tank-level');
  await expect(page.locator('.tank-level-component')).toHaveClass('rendered');
});

// ❌ BAD - Too granular for E2E
test('tank level API returns JSON', async ({ page }) => {
  // This should be an integration test, not E2E
  const response = await page.request.get('/api/tanks');
  expect(response.status()).toBe(200);
});
```

## 📝 Test Planning Framework

### User Flow Mapping
```markdown
IDENTIFY USER JOURNEYS:
1. Critical Path: Must work or app is broken
2. Happy Path: Normal user behavior
3. Error Path: What happens when things go wrong
4. Edge Cases: Unusual but possible scenarios

EXAMPLE MAPPING:
Feature: User Authentication
- Critical: Login → Access Dashboard
- Happy: Register → Verify Email → Login
- Error: Wrong password → Show error → Retry
- Edge: Account locked → Show message → Contact support
```

### Test Coverage Strategy
```markdown
E2E TEST COVERAGE RULES:
✅ Every user-facing feature
✅ All critical user journeys
✅ Error scenarios users see
✅ Cross-browser compatibility
✅ Mobile responsive behavior

❌ Internal API logic (use integration tests)
❌ Pure utility functions (use unit tests)
❌ Implementation details
❌ Third-party library behavior
```

## 🛠️ Playwright Best Practices

### Selector Strategy
```markdown
PREFERRED SELECTORS (in order):
1. data-testid attributes (most reliable)
2. Accessible labels/roles (semantic)
3. Text content (user-visible)
4. CSS selectors (last resort)

AVOID:
❌ Xpath selectors (brittle)
❌ Complex CSS paths (fragile)
❌ Index-based selectors (unreliable)
```

### Test Data Management
```javascript
// ✅ GOOD - Isolated test data
test.beforeEach(async ({ page }) => {
  // Create fresh test data for each test
  await page.request.post('/api/test/setup', {
    data: {
      user: { email: 'test@example.com', role: 'farmer' },
      tanks: [
        { id: 1, name: 'Tank A', level: 75 },
        { id: 2, name: 'Tank B', level: 45 }
      ]
    }
  });
});

test.afterEach(async ({ page }) => {
  // Clean up test data
  await page.request.delete('/api/test/cleanup');
});
```

### Page Object Pattern
```javascript
// ✅ GOOD - Reusable page objects
class DashboardPage {
  constructor(page) {
    this.page = page;
    this.tankWidget = page.locator('[data-testid=tank-level-widget]');
    this.alertPanel = page.locator('[data-testid=alerts-panel]');
  }
  
  async navigateTo() {
    await this.page.goto('/dashboard');
  }
  
  async getTankLevel(tankId) {
    return await this.page.locator(`[data-testid=tank-${tankId}-level]`).textContent();
  }
  
  async clickAlert(alertId) {
    await this.page.click(`[data-testid=alert-${alertId}-button]`);
  }
}
```

## 🔍 Testing User Flows

### Authentication Flow
```javascript
test.describe('User Authentication Flow', () => {
  test('user can register, verify email, and login', async ({ page }) => {
    // Registration
    await page.goto('/register');
    await page.fill('[data-testid=name]', 'John Farmer');
    await page.fill('[data-testid=email]', 'john@farm.com');
    await page.fill('[data-testid=password]', 'securepass123');
    await page.click('[data-testid=register-button]');
    
    // Email verification (mock)
    await expect(page.locator('[data-testid=verify-email-message]')).toBeVisible();
    
    // Login
    await page.goto('/login');
    await page.fill('[data-testid=email]', 'john@farm.com');
    await page.fill('[data-testid=password]', 'securepass123');
    await page.click('[data-testid=login-button]');
    
    // Verify success
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid=user-welcome]')).toContainText('John Farmer');
  });
});
```

### Data Management Flow
```javascript
test.describe('Tank Management Flow', () => {
  test('farmer can add new tank and monitor levels', async ({ page }) => {
    // Login first
    await loginAsFarmer(page);
    
    // Add new tank
    await page.click('[data-testid=add-tank-button]');
    await page.fill('[data-testid=tank-name]', 'New Water Tank');
    await page.fill('[data-testid=tank-capacity]', '1000');
    await page.click('[data-testid=save-tank-button]');
    
    // Verify tank appears in list
    await expect(page.locator('[data-testid=tank-list]')).toContainText('New Water Tank');
    
    // Monitor tank level
    await page.click('[data-testid=tank-monitor-button]');
    await expect(page.locator('[data-testid=tank-level-chart]')).toBeVisible();
    await expect(page.locator('[data-testid=current-level]')).toBeVisible();
  });
});
```

### Error Handling Flow
```javascript
test.describe('Error Scenarios', () => {
  test('user sees helpful error when server is down', async ({ page }) => {
    // Mock server error
    await page.route('/api/**', route => route.abort());
    
    await page.goto('/dashboard');
    
    // Verify error handling
    await expect(page.locator('[data-testid=error-message]')).toBeVisible();
    await expect(page.locator('[data-testid=error-message]')).toContainText('Connection problem');
    await expect(page.locator('[data-testid=retry-button]')).toBeVisible();
    
    // Test retry functionality
    await page.unroute('/api/**');
    await page.click('[data-testid=retry-button]');
    
    await expect(page.locator('[data-testid=tank-level-widget]')).toBeVisible();
  });
});
```

## 🎯 Feature-Driven Testing

### Test Planning Template
```markdown
## Feature: [Feature Name]

### User Stories:
1. As a [user type], I want [goal] so I can [benefit]
2. As a [user type], I want [goal] so I can [benefit]

### Critical User Flows:
1. [Flow name] - [User path through app]
2. [Flow name] - [User path through app]

### E2E Test Cases:
1. Happy Path: [Normal usage scenario]
2. Error Path: [Error handling scenario] 
3. Edge Cases: [Unusual but valid scenarios]

### Success Criteria:
- [ ] All user stories testable with E2E tests
- [ ] All critical flows have E2E coverage
- [ ] Error scenarios handled gracefully
- [ ] Tests pass on multiple browsers
- [ ] Mobile responsive tests pass
```

### Test Implementation Checklist
```markdown
FOR EACH FEATURE:
- [ ] User story defined
- [ ] E2E test written (failing)
- [ ] Test data setup/cleanup
- [ ] Page objects created (if reusable)
- [ ] Implementation built to pass test
- [ ] Test passes consistently
- [ ] Cross-browser testing completed
- [ ] Mobile testing completed
- [ ] Error scenarios tested
- [ ] Performance acceptable
```

## 🚨 Common Testing Pitfalls

### Anti-Patterns to Avoid
```markdown
❌ Testing Implementation Details
- Don't test internal state
- Don't test component props directly
- Don't test CSS classes or IDs
- Focus on user-visible behavior

❌ Brittle Selectors
- Don't use complex CSS paths
- Don't rely on element positioning
- Don't use auto-generated IDs
- Use stable data-testid attributes

❌ Flaky Tests
- Don't use hard-coded waits
- Don't assume timing
- Don't depend on external services
- Use proper waiting strategies

❌ Over-Mocking
- Don't mock user interactions
- Don't mock critical dependencies
- Do mock external services
- Mock only what you must
```

### Flaky Test Prevention
```javascript
// ✅ GOOD - Proper waiting
await expect(page.locator('[data-testid=loading-spinner]')).not.toBeVisible();
await expect(page.locator('[data-testid=data-table]')).toBeVisible();

// ❌ BAD - Hard-coded waits
await page.waitForTimeout(5000); // Flaky!

// ✅ GOOD - Wait for network
await page.waitForResponse('/api/data');
await expect(page.locator('[data-testid=data-loaded]')).toBeVisible();
```

## 📊 Test Organization

### File Structure
```
tests/
├── e2e/
│   ├── auth/
│   │   ├── login.spec.js
│   │   ├── register.spec.js
│   │   └── logout.spec.js
│   ├── dashboard/
│   │   ├── tank-monitoring.spec.js
│   │   ├── alerts.spec.js
│   │   └── weather.spec.js
│   └── settings/
│       ├── user-profile.spec.js
│       └── preferences.spec.js
├── fixtures/
│   ├── users.js
│   ├── tank-data.js
│   └── test-helpers.js
└── page-objects/
    ├── dashboard-page.js
    ├── login-page.js
    └── settings-page.js
```

### Test Configuration
```javascript
// playwright.config.js
export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
});
```

## 🎯 Integration with Todo Workflow

### Todo Task Testing Requirements
```markdown
EVERY TODO TASK MUST INCLUDE:
- User story definition
- E2E test specification
- Acceptance criteria
- Browser compatibility targets

TODO TASK COMPLETION CRITERIA:
- [ ] E2E test written and failing
- [ ] Implementation passes E2E test
- [ ] Cross-browser testing passed
- [ ] Error scenarios tested
- [ ] User can complete intended flow
```

### Testing in High-ROI Context
```markdown
HIGH ROI TESTING:
✅ Test critical user journeys
✅ Focus on frequently used features
✅ Test error scenarios users encounter
✅ Automate repetitive user actions

LOW ROI TESTING:
❌ Test every edge case
❌ Test admin-only features extensively
❌ Test implementation details
❌ Over-test rarely used features
```

## 🔧 Debugging E2E Tests

### Debug Tools
```javascript
// Visual debugging
await page.pause(); // Interactive debugging
await page.screenshot({ path: 'debug.png' });
await page.locator('[data-testid=element]').screenshot({ path: 'element.png' });

// Console debugging
page.on('console', msg => console.log(msg.text()));
page.on('pageerror', err => console.log(err.message));

// Network debugging
page.on('response', response => {
  if (response.status() >= 400) {
    console.log(`${response.status()} ${response.url()}`);
  }
});
```

### Test Troubleshooting
```markdown
WHEN TESTS FAIL:
1. Run test in headed mode: `npx playwright test --headed`
2. Use debug mode: `npx playwright test --debug`
3. Check network tab for API errors
4. Verify test data setup/cleanup
5. Check for timing issues
6. Validate selectors still exist
7. Review recent code changes
```

## 📚 Quick Reference

### Essential Commands
```bash
# Run all E2E tests
npm run test:e2e

# Run specific test file
npm run test:e2e tests/e2e/auth/login.spec.js

# Run in headed mode (see browser)
npm run test:e2e -- --headed

# Debug mode (step through)
npm run test:e2e -- --debug

# Generate test report
npm run test:e2e -- --reporter=html
```

### Test Quality Checklist
```markdown
HIGH QUALITY E2E TEST:
✅ Tests real user behavior
✅ Uses stable selectors (data-testid)
✅ Has proper setup/cleanup
✅ Waits appropriately (no hard waits)
✅ Tests error scenarios
✅ Works across browsers
✅ Has clear assertions
✅ Follows page object pattern
✅ Is maintainable and readable
✅ Runs consistently without flaking
```

---

## 🎯 Remember: Test what users do, not how code works

E2E tests should validate that users can accomplish their goals, not that your implementation works correctly. If a user can't complete their task, the feature isn't done, regardless of how well the code is written.