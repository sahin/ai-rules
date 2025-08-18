# E2E Testing with Playwright - Essential Guide

Universal standards for end-to-end testing with Playwright, focusing on visual documentation, cross-browser testing, and user journey validation.

## 🎭 CORE PLAYWRIGHT CONFIGURATION

### **Essential Configuration:**
```typescript
// playwright.config.ts
export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['json', { outputFile: 'test-results/results.json' }]],
  
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },
  
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 12'] } },
  ],
  
  webServer: {
    command: 'npm run dev',
    port: 3000,
    reuseExistingServer: !process.env.CI,
  },
});
```

## 📋 TEST STRUCTURE & PATTERNS

### **Page Object Model (MANDATORY):**
```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}
  
  private emailInput = () => this.page.getByLabel('Email');
  private passwordInput = () => this.page.getByLabel('Password');
  private loginButton = () => this.page.getByRole('button', { name: 'Log in' });
  private errorMessage = () => this.page.getByRole('alert');
  
  async login(email: string, password: string) {
    await this.emailInput().fill(email);
    await this.passwordInput().fill(password);
    await this.loginButton().click();
  }
  
  async expectError(message: string) {
    await expect(this.errorMessage()).toContainText(message);
  }
}
```

### **Test Organization:**
```typescript
// e2e/auth/login.spec.ts
test.describe('Authentication Flow', () => {
  let loginPage: LoginPage;
  
  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await page.goto('/login');
  });
  
  test('should login with valid credentials', async ({ page }) => {
    await loginPage.login('user@example.com', 'ValidPassword123!');
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('Welcome back')).toBeVisible();
  });
});
```

## 📸 VISUAL DOCUMENTATION (MANDATORY)

### **Screenshot Documentation:**
```typescript
test.describe('Feature: Dashboard', () => {
  test('document dashboard states', async ({ page }, testInfo) => {
    await page.goto('/dashboard');
    
    // Initial state
    await page.screenshot({
      path: `test-results/dashboard/${testInfo.project.name}/01-initial.png`,
      fullPage: true,
    });
    
    // Loading state
    await page.getByRole('button', { name: 'Refresh' }).click();
    await page.screenshot({
      path: `test-results/dashboard/${testInfo.project.name}/02-loading.png`,
    });
    
    // Data loaded
    await page.waitForSelector('[data-testid="data-grid"]');
    await page.screenshot({
      path: `test-results/dashboard/${testInfo.project.name}/03-loaded.png`,
      fullPage: true,
    });
  });
});
```

### **Responsive Testing:**
```typescript
test.describe('Mobile Responsive', () => {
  const viewports = [
    { name: 'iPhone-12', width: 390, height: 844 },
    { name: 'iPad', width: 768, height: 1024 },
    { name: 'Desktop', width: 1920, height: 1080 },
  ];
  
  viewports.forEach(({ name, width, height }) => {
    test(`dashboard on ${name}`, async ({ page }) => {
      await page.setViewportSize({ width, height });
      await page.goto('/dashboard');
      
      await page.screenshot({
        path: `test-results/responsive/${name}-dashboard.png`,
        fullPage: true,
      });
      
      if (width < 768) {
        await page.getByRole('button', { name: 'Menu' }).click();
        await expect(page.getByRole('navigation')).toBeVisible();
      }
    });
  });
});
```

## 🎯 USER JOURNEY TESTING

### **Complete Flow Testing:**
```typescript
test('complete purchase journey', async ({ page }) => {
  // 1. Browse products
  await page.goto('/products');
  await page.getByPlaceholder('Search').fill('laptop');
  await page.getByRole('button', { name: 'Search' }).click();
  
  // 2. Add to cart
  await page.getByRole('article').first().getByRole('button', { name: 'Add to Cart' }).click();
  
  // 3. Checkout
  await page.getByRole('link', { name: 'Cart' }).click();
  await page.getByRole('button', { name: 'Checkout' }).click();
  
  // 4. Fill details
  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Email').fill('john@example.com');
  await page.getByLabel('Card Number').fill('4242424242424242');
  
  // 5. Complete order
  await page.getByRole('button', { name: 'Place Order' }).click();
  await expect(page.getByText('Order Confirmed')).toBeVisible();
  
  // Document success
  await page.screenshot({ path: 'test-results/purchase-complete.png', fullPage: true });
});
```

## ⚡ PERFORMANCE TESTING

### **Performance Metrics:**
```typescript
test('measure page performance', async ({ page }) => {
  await page.goto('/');
  
  const metrics = await page.evaluate(() => {
    const nav = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
    return {
      domContentLoaded: nav.domContentLoadedEventEnd - nav.domContentLoadedEventStart,
      firstContentfulPaint: performance.getEntriesByName('first-contentful-paint')[0]?.startTime,
    };
  });
  
  expect(metrics.firstContentfulPaint).toBeLessThan(2000); // Under 2s
  expect(metrics.domContentLoaded).toBeLessThan(3000); // Under 3s
});
```

## ♿ ACCESSIBILITY TESTING

### **Automated A11y Checks:**
```typescript
import { injectAxe, checkA11y } from 'axe-playwright';

test('accessibility compliance', async ({ page }) => {
  await page.goto('/');
  await injectAxe(page);
  await checkA11y(page, undefined, { detailedReport: true });
});

test('keyboard navigation', async ({ page }) => {
  await page.goto('/contact');
  
  await page.keyboard.press('Tab');
  await expect(page.getByLabel('Name')).toBeFocused();
  
  await page.keyboard.press('Tab');
  await expect(page.getByLabel('Email')).toBeFocused();
});
```

## 🚨 ERROR STATE TESTING

### **Network Failure Simulation:**
```typescript
test('handle network failures', async ({ page, context }) => {
  // Simulate network failure
  await context.route('**/api/**', route => route.abort());
  
  await page.goto('/data-page');
  await page.getByRole('button', { name: 'Load Data' }).click();
  
  // Should show error state
  await expect(page.getByText('Failed to load data')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Retry' })).toBeVisible();
  
  // Restore and retry
  await context.unroute('**/api/**');
  await page.getByRole('button', { name: 'Retry' }).click();
  await expect(page.getByTestId('data-grid')).toBeVisible();
});
```

## 👁️ VISUAL REGRESSION TESTING

### **Screenshot Comparison:**
```typescript
test('visual regression checks', async ({ page }) => {
  await page.goto('/components');
  
  // Compare against baseline
  await expect(page).toHaveScreenshot('components.png', {
    maxDiffPixels: 100,
    threshold: 0.2,
  });
  
  // Test interactive states
  await page.hover('[data-testid="button"]');
  await expect(page.locator('[data-testid="button"]')).toHaveScreenshot('button-hover.png');
});
```

## 🛠️ TESTING UTILITIES

### **Helper Functions:**
```typescript
// e2e/helpers/auth.ts
export async function loginAs(page: Page, role: 'admin' | 'user') {
  const credentials = {
    admin: { email: 'admin@test.com', password: 'AdminPass123!' },
    user: { email: 'user@test.com', password: 'UserPass123!' },
  };
  
  await page.goto('/login');
  await page.getByLabel('Email').fill(credentials[role].email);
  await page.getByLabel('Password').fill(credentials[role].password);
  await page.getByRole('button', { name: 'Log in' }).click();
  await page.waitForURL('/dashboard');
}

// e2e/helpers/data.ts
export async function seedTestData(page: Page) {
  await page.request.post('/api/test/seed', {
    data: { users: 10, products: 50, orders: 100 },
  });
}
```

## 📁 FOLDER STRUCTURE

```
e2e/
├── auth/           # Authentication tests
├── features/       # Feature-specific tests
├── journeys/       # End-to-end user flows
├── visual/         # Visual regression tests
├── pages/          # Page Object Models
├── helpers/        # Utility functions
└── fixtures/       # Test data
```

## ✅ E2E TESTING CHECKLIST

- [ ] Critical user journeys tested
- [ ] Visual documentation created
- [ ] Cross-browser testing passes
- [ ] Mobile responsive views tested
- [ ] Accessibility standards met
- [ ] Performance benchmarks achieved
- [ ] Error states handled gracefully
- [ ] Network failures tested
- [ ] Authentication flows verified
- [ ] Visual regression baselines established

## 🚀 E2E-SPECIFIC BEST PRACTICES

1. **Use Page Object Model** for maintainability
2. **Document with screenshots** for visual features
3. **Test across browsers and devices**
4. **Use test data factories** for consistency
5. **Run tests in parallel** for speed

---

## 📚 Related Testing Documentation

- **[core-standards.md](./core-standards.md)**: Core testing principles and coverage requirements
- **[playwright-first.md](./playwright-first.md)**: User-first testing philosophy
- **[implementation-guide.md](./implementation-guide.md)**: Unit and integration testing patterns