# Testing Implementation Guide

> Supports `./core-standards.md` (canonical principles) and `./playwright-first.md` (strategy). Project-specific deltas live in `../../../current-code/testing/clarosfarm-tests.md`.

This guide provides practical testing patterns and examples for unit, integration, and API testing. For E2E testing, see `e2e-playwright.md`.

## 🧩 UNIT TESTING PATTERNS

### Component Testing (React)
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('UserForm', () => {
  it('should submit form with valid data', async () => {
    const onSubmit = jest.fn();
    render(<UserForm onSubmit={onSubmit} />);
    
    // Use userEvent for realistic interactions
    await userEvent.type(screen.getByLabelText('Name'), 'John Doe');
    await userEvent.type(screen.getByLabelText('Email'), 'john@example.com');
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));
    
    expect(onSubmit).toHaveBeenCalledWith({
      name: 'John Doe',
      email: 'john@example.com'
    });
  });

  it('should show validation errors', async () => {
    render(<UserForm />);
    
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));
    
    expect(screen.getByText('Name is required')).toBeInTheDocument();
    expect(screen.getByText('Email is required')).toBeInTheDocument();
  });
});
```

### Function Testing
```typescript
describe('calculateDiscount', () => {
  it.each([
    { price: 100, discount: 10, expected: 90 },
    { price: 50, discount: 50, expected: 25 },
    { price: 0, discount: 10, expected: 0 },
  ])('should calculate $expected for price $price with $discount% discount', 
    ({ price, discount, expected }) => {
      expect(calculateDiscount(price, discount)).toBe(expected);
    }
  );

  it('should throw for invalid inputs', () => {
    expect(() => calculateDiscount(-10, 20)).toThrow('Invalid price');
    expect(() => calculateDiscount(100, 101)).toThrow('Invalid discount');
  });
});
```

### Async Testing
```typescript
describe('fetchUserData', () => {
  it('should return user data', async () => {
    const mockUser = { id: 1, name: 'John' };
    jest.spyOn(api, 'get').mockResolvedValue({ data: mockUser });
    
    const result = await fetchUserData(1);
    
    expect(api.get).toHaveBeenCalledWith('/users/1');
    expect(result).toEqual(mockUser);
  });

  it('should handle errors', async () => {
    jest.spyOn(api, 'get').mockRejectedValue(new Error('Network error'));
    
    await expect(fetchUserData(1)).rejects.toThrow('Failed to fetch user');
  });
});
```

## 🔌 API TESTING PATTERNS

### Express/Node.js API Testing
```typescript
import request from 'supertest';
import app from '../app';

describe('POST /api/users', () => {
  it('should create a new user', async () => {
    const newUser = {
      name: 'Jane Doe',
      email: 'jane@example.com',
      password: 'SecurePass123!'
    };

    const response = await request(app)
      .post('/api/users')
      .send(newUser)
      .expect(201);

    expect(response.body).toMatchObject({
      id: expect.any(Number),
      name: newUser.name,
      email: newUser.email
    });
    expect(response.body.password).toBeUndefined();
  });

  it('should validate required fields', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com' })
      .expect(400);

    expect(response.body.errors).toContainEqual(
      expect.objectContaining({
        field: 'name',
        message: 'Name is required'
      })
    );
  });
});
```

### FastAPI Testing (Python)
```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_user():
    response = client.post(
        "/api/users",
        json={"name": "Jane", "email": "jane@example.com"}
    )
    assert response.status_code == 201
    assert response.json()["email"] == "jane@example.com"

def test_get_user():
    response = client.get("/api/users/1")
    assert response.status_code == 200
    assert "id" in response.json()
```

## 🧪 INTEGRATION TESTING

### Database Integration
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
    const user = await UserRepository.create({
      name: 'Test User',
      email: 'test@example.com'
    });

    expect(user.id).toBeDefined();

    const retrieved = await UserRepository.findById(user.id);
    expect(retrieved).toMatchObject({
      name: 'Test User',
      email: 'test@example.com'
    });
  });

  it('should handle concurrent updates', async () => {
    const user = await UserRepository.create({ name: 'Initial' });
    
    // Simulate concurrent updates
    await Promise.all([
      UserRepository.update(user.id, { name: 'Update 1' }),
      UserRepository.update(user.id, { name: 'Update 2' })
    ]);

    const final = await UserRepository.findById(user.id);
    expect(['Update 1', 'Update 2']).toContain(final.name);
  });
});
```

### Service Integration
```typescript
describe('EmailService', () => {
  let mockTransporter: jest.Mocked<Transporter>;

  beforeEach(() => {
    mockTransporter = createMockTransporter();
    EmailService.initialize(mockTransporter);
  });

  it('should send welcome email', async () => {
    await EmailService.sendWelcomeEmail('user@example.com', 'John');

    expect(mockTransporter.sendMail).toHaveBeenCalledWith(
      expect.objectContaining({
        to: 'user@example.com',
        subject: 'Welcome to Our App',
        html: expect.stringContaining('Hello John')
      })
    );
  });

  it('should retry on failure', async () => {
    mockTransporter.sendMail
      .mockRejectedValueOnce(new Error('Network error'))
      .mockResolvedValueOnce({ messageId: '123' });

    await EmailService.sendWelcomeEmail('user@example.com', 'John');

    expect(mockTransporter.sendMail).toHaveBeenCalledTimes(2);
  });
});
```

## 🎭 MOCKING STRATEGIES

### Mock External Services
```typescript
// Mock HTTP requests
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

beforeEach(() => {
  mockedAxios.get.mockResolvedValue({ data: { status: 'ok' } });
});

// Mock database
jest.mock('../db');
const mockDb = db as jest.Mocked<typeof db>;

mockDb.query.mockResolvedValue({
  rows: [{ id: 1, name: 'Test' }]
});

// Mock timers
jest.useFakeTimers();
setTimeout(() => {}, 1000);
jest.runAllTimers();
```

### Test Doubles
```typescript
// Stub - Provides predefined responses
const paymentStub = {
  processPayment: jest.fn().mockResolvedValue({ success: true, id: '123' })
};

// Spy - Records how it was called
const loggerSpy = jest.spyOn(console, 'log');
expect(loggerSpy).toHaveBeenCalledWith('Payment processed');

// Mock - Programmable test double
const emailMock = {
  send: jest.fn().mockImplementation((to, subject) => {
    if (!to.includes('@')) throw new Error('Invalid email');
    return Promise.resolve({ sent: true });
  })
};
```

## 🧪 TESTING PATTERNS

### Parameterized Testing
```typescript
describe.each([
  ['admin', true],
  ['user', false],
  ['guest', false],
])('User role %s', (role, canDelete) => {
  it(`should ${canDelete ? '' : 'not '}allow deletion`, () => {
    const user = { role };
    expect(permissions.canDelete(user)).toBe(canDelete);
  });
});
```

### Snapshot Testing
```typescript
it('should render correctly', () => {
  const component = render(<UserProfile user={mockUser} />);
  expect(component).toMatchSnapshot();
});

// For dynamic content
it('should match snapshot with date', () => {
  const component = render(<TimeDisplay />);
  expect(component).toMatchInlineSnapshot(
    { createdAt: expect.any(String) },
    `<div>Created: {createdAt}</div>`
  );
});
```

### Error Boundary Testing
```typescript
it('should catch errors and display fallback', () => {
  const ThrowError = () => {
    throw new Error('Test error');
  };

  render(
    <ErrorBoundary fallback={<div>Error occurred</div>}>
      <ThrowError />
    </ErrorBoundary>
  );

  expect(screen.getByText('Error occurred')).toBeInTheDocument();
});
```

## 📊 TESTING UTILITIES

### Custom Test Helpers
```typescript
// Custom render with providers
export const renderWithProviders = (ui: React.ReactElement) => {
  return render(
    <QueryClient>
      <AuthProvider>
        <ThemeProvider>
          {ui}
        </ThemeProvider>
      </AuthProvider>
    </QueryClient>
  );
};

// Wait for async updates
export const waitForLoadingToFinish = () => 
  waitForElementToBeRemoved(() => screen.queryAllByTestId(/loading/i));

// Generate test data
export const createMockUser = (overrides = {}) => ({
  id: faker.datatype.uuid(),
  name: faker.name.fullName(),
  email: faker.internet.email(),
  ...overrides
});
```

### Test Data Builders
```typescript
class UserBuilder {
  private user = {
    id: 1,
    name: 'Default User',
    email: 'user@example.com',
    role: 'user'
  };

  withAdmin() {
    this.user.role = 'admin';
    return this;
  }

  withEmail(email: string) {
    this.user.email = email;
    return this;
  }

  build() {
    return { ...this.user };
  }
}

// Usage
const adminUser = new UserBuilder().withAdmin().build();
```

## 🚀 PERFORMANCE TESTING

### Load Testing Pattern
```javascript
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
  },
};

export default function() {
  let response = http.get('https://api.example.com/users');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

## 🎯 COMMON TESTING SCENARIOS

### Authentication Testing
```typescript
describe('Authentication', () => {
  it('should login with valid credentials', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({ email: 'user@example.com', password: 'password123' });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('accessToken');
    expect(response.body).toHaveProperty('refreshToken');
  });

  it('should protect routes', async () => {
    await request(app)
      .get('/api/protected')
      .expect(401);

    await request(app)
      .get('/api/protected')
      .set('Authorization', 'Bearer valid-token')
      .expect(200);
  });
});
```

### Form Validation Testing
```typescript
describe('Form Validation', () => {
  it('should validate email format', async () => {
    render(<ContactForm />);
    
    await userEvent.type(screen.getByLabelText('Email'), 'invalid-email');
    await userEvent.tab();
    
    expect(screen.getByText('Invalid email format')).toBeInTheDocument();
  });

  it('should validate required fields', async () => {
    render(<ContactForm />);
    
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));
    
    expect(screen.getByText('Name is required')).toBeInTheDocument();
    expect(screen.getByText('Email is required')).toBeInTheDocument();
  });
});
```

---

**Related**: See `core-standards.md` for testing principles and `e2e-playwright.md` for end-to-end testing.