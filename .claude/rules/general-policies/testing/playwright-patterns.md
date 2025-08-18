# Playwright Testing Patterns

Common patterns and best practices for Playwright tests.

## Test Structure

### Good Test Example
```javascript
test('user can monitor system and receive alerts', async ({ page }) => {
  // Setup: Login
  await page.goto('/login');
  await page.fill('[data-testid=email]', 'user@test.com');
  await page.fill('[data-testid=password]', 'password');
  await page.click('[data-testid=login-button]');
  
  // Navigate
  await page.click('[data-testid=dashboard-link]');
  
  // Verify
  await expect(page.locator('[data-testid=status-widget]')).toBeVisible();
  await expect(page.locator('[data-testid=alert]')).toBeVisible();
  
  // Act
  await page.click('[data-testid=alert-action]');
  await expect(page.locator('[data-testid=success]')).toBeVisible();
});
```

## Selectors Best Practices

### Use Data Test IDs
```javascript
// ✅ GOOD - Stable selector
await page.click('[data-testid=submit-button]');

// ❌ BAD - Brittle selector
await page.click('.btn.btn-primary:nth-child(2)');
```

### Selector Priority
1. `data-testid` - Most reliable
2. Role selectors - `getByRole('button')`
3. Text content - `getByText('Submit')`
4. Never use: classes, IDs, CSS paths

## Test Data Management

### Isolated Test Data
```javascript
test.beforeEach(async ({ page }) => {
  // Create fresh test data
  await page.request.post('/api/test/setup', {
    data: {
      user: { email: 'test@example.com' },
      items: [{ id: 1, name: 'Test Item' }]
    }
  });
});

test.afterEach(async ({ page }) => {
  // Cleanup
  await page.request.post('/api/test/cleanup');
});
```

## Common Patterns

### Wait for Loading
```javascript
// Wait for specific element
await page.waitForSelector('[data-testid=loaded]');

// Wait for network idle
await page.waitForLoadState('networkidle');

// Custom wait
await page.waitForFunction(() => {
  return document.querySelector('[data-testid=count]')?.textContent === '10';
});
```

### Handle Popups
```javascript
// Dismiss dialogs
page.on('dialog', dialog => dialog.dismiss());

// Accept confirmation
const [dialog] = await Promise.all([
  page.waitForEvent('dialog'),
  page.click('[data-testid=delete]')
]);
await dialog.accept();
```

### File Uploads
```javascript
const fileInput = page.locator('input[type=file]');
await fileInput.setInputFiles('path/to/file.pdf');
```