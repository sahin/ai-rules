# Testing Implementation Guide

> Practical patterns and examples for all test types

## Implementation Files

### Core Testing
- **[api-testing.md](./api-testing.md)** - API endpoints, auth, 100% coverage
- **[unit-testing.md](./unit-testing.md)** - Components, functions, mocking
- **[integration-testing.md](./integration-testing.md)** - Database, services, data management

### Testing Standards
- **[test-requirements.md](./test-requirements.md)** - Coverage requirements
- **[test-patterns.md](./test-patterns.md)** - AAA pattern, naming
- **[test-automation.md](./test-automation.md)** - CI/CD, smart detection

### Specialized Testing
- **[playwright-strategy.md](./playwright-strategy.md)** - E2E philosophy
- **[playwright-patterns.md](./playwright-patterns.md)** - E2E patterns

## Quick Patterns

### Mocking
```typescript
jest.mock('axios');
const spy = jest.spyOn(console, 'log');
const stub = jest.fn().mockResolvedValue(data);
```

### Test Data
```typescript
const user = new UserBuilder().withAdmin().build();
const mockUser = createMockUser({ role: 'admin' });
```

### Assertions
```typescript
expect(result).toMatchObject({ name: 'John' });
expect(fn).toHaveBeenCalledWith(expected);
expect(screen.getByText('Error')).toBeInTheDocument();
```