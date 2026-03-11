# Testing Guide

Comprehensive testing reference. Invoke with `/test`.

## Test Pyramid

```
    /  E2E  \     10% - User journeys (Playwright)
   /----------\
  / Integration \  30% - API, services, database
 /----------------\
/      Unit        \ 60% - Components, functions
```

## Coverage Targets
| Area | Target |
|------|--------|
| API endpoints | 100% |
| UI components | 80% |
| Critical logic | 90% |
| Utilities | 90% |
| Overall | 80% |

## AAA Pattern (Arrange-Act-Assert)
```typescript
it('should calculate total with tax', () => {
  // Arrange
  const items = [{ price: 10 }, { price: 20 }];
  const taxRate = 0.1;

  // Act
  const total = calculateTotal(items, taxRate);

  // Assert
  expect(total).toBe(33);
});
```

## Test Naming
- `should calculate total when items provided`
- `should throw error when input is invalid`
- `when user is admin, then show delete button`

## Unit Testing

### Component Testing
```typescript
describe('UserForm', () => {
  it('should submit with valid data', async () => {
    const onSubmit = jest.fn();
    render(<UserForm onSubmit={onSubmit} />);

    await userEvent.type(screen.getByLabelText('Name'), 'John');
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

    expect(onSubmit).toHaveBeenCalledWith({ name: 'John' });
  });
});
```

### Parameterized Tests
```typescript
it.each([
  [100, 10, 90],
  [50, 50, 25],
  [0, 10, 0],
])('price %i with %i%% discount = %i', (price, discount, expected) => {
  expect(calculateDiscount(price, discount)).toBe(expected);
});
```

### Mocking
```typescript
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;
mockedAxios.get.mockResolvedValue({ data: { users: [] } });

const spy = jest.spyOn(service, 'fetchData');
const stub = jest.fn().mockResolvedValue({ success: true });
```

## Integration Testing

### Database Tests
```typescript
describe('UserRepository', () => {
  beforeEach(async () => {
    await db.migrate.latest();
    await db.seed.run();
  });

  afterEach(async () => {
    await db.migrate.rollback();
  });

  it('should create and retrieve user', async () => {
    const user = await UserRepository.create({ name: 'Test', email: 'test@example.com' });
    const retrieved = await UserRepository.findById(user.id);
    expect(retrieved.name).toBe('Test');
  });
});
```

### API Testing (100% coverage required)
```typescript
describe('POST /api/users', () => {
  it('should create user (201)', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'Jane', email: 'jane@example.com' })
      .expect(201);

    expect(response.body).toMatchObject({ id: expect.any(Number), name: 'Jane' });
  });

  it('should validate required fields (400)', async () => {
    await request(app).post('/api/users').send({}).expect(400);
  });

  it('should require authentication (401)', async () => {
    await request(app).post('/api/users').send({ name: 'Jane' }).expect(401);
  });
});
```

Required scenarios for every endpoint:
- Happy path (200/201)
- Validation errors (400/422)
- Auth errors (401/403)
- Not found (404)
- Edge cases and boundary conditions

## E2E Testing with Playwright

### Configuration
```typescript
// playwright.config.ts
export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
  ],
});
```

### Page Object Model (required)
```typescript
export class LoginPage {
  constructor(private page: Page) {}

  private emailInput = () => this.page.getByLabel('Email');
  private passwordInput = () => this.page.getByLabel('Password');
  private loginButton = () => this.page.getByRole('button', { name: 'Log in' });

  async login(email: string, password: string) {
    await this.emailInput().fill(email);
    await this.passwordInput().fill(password);
    await this.loginButton().click();
  }
}
```

### Selectors Priority
1. `data-testid` - most reliable
2. Role selectors - `getByRole('button')`
3. Label - `getByLabel('Email')`
4. Text - `getByText('Submit')`
5. Never: CSS classes, IDs, nth-child

### User Journey Test
```typescript
test('complete purchase flow', async ({ page }) => {
  await page.goto('/products');
  await page.getByPlaceholder('Search').fill('laptop');
  await page.getByRole('button', { name: 'Search' }).click();
  await page.getByRole('article').first().getByRole('button', { name: 'Add to Cart' }).click();
  await page.getByRole('link', { name: 'Cart' }).click();
  await page.getByRole('button', { name: 'Checkout' }).click();
  await expect(page.getByText('Order Confirmed')).toBeVisible();
});
```

### Responsive Testing
```typescript
const viewports = [
  { name: 'mobile', width: 375, height: 667 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1920, height: 1080 },
];

viewports.forEach(({ name, width, height }) => {
  test(`dashboard on ${name}`, async ({ page }) => {
    await page.setViewportSize({ width, height });
    await page.goto('/dashboard');
    await page.screenshot({ path: `screenshots/${name}-dashboard.png`, fullPage: true });
  });
});
```

### Network Failure Testing
```typescript
test('handle API failure gracefully', async ({ page, context }) => {
  await context.route('**/api/**', route => route.abort());
  await page.goto('/data-page');
  await expect(page.getByText('Failed to load data')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Retry' })).toBeVisible();
});
```

### Accessibility Testing
```typescript
import { injectAxe, checkA11y } from 'axe-playwright';

test('accessibility compliance', async ({ page }) => {
  await page.goto('/');
  await injectAxe(page);
  await checkA11y(page, undefined, { detailedReport: true });
});
```

### Visual Regression
```typescript
test('visual consistency', async ({ page }) => {
  await page.goto('/components');
  await expect(page).toHaveScreenshot('components.png', {
    maxDiffPixels: 100,
    threshold: 0.2,
  });
});
```

## Smart Testing Commands
```bash
npm run test:smart       # Run only affected tests
npm run test:smart:dry   # Preview what would run
npm run test:smart:unit  # Only affected unit tests
npm run test:smart:e2e   # Only affected E2E tests
npm test                 # Watch mode
npm run test:coverage    # Coverage report
npm run test:ci          # CI pipeline mode
```

## Test File Organization
```
src/
  components/
    Button.tsx
    Button.test.tsx      # Unit tests co-located
  api/
    users.ts
    users.test.ts        # Integration tests co-located
e2e/
  auth/                  # E2E by feature
  features/
  pages/                 # Page Object Models
  helpers/               # Shared utilities
```

## CI/CD Pipeline
1. Pre-commit: unit tests for changed files
2. Pull request: full test suite
3. Main branch: all tests including E2E
4. Pre-deploy: performance and security
5. Post-deploy: production smoke tests
