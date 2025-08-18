# Integration Testing

## Database Integration
```typescript
describe('UserRepository', () => {
  beforeEach(async () => {
    await db.migrate.latest();
    await db.seed.run();
  });

  afterEach(async () => {
    await db.migrate.rollback();
  });

  it('should create and retrieve', async () => {
    const user = await UserRepository.create({
      name: 'Test User',
      email: 'test@example.com'
    });

    const retrieved = await UserRepository.findById(user.id);
    expect(retrieved.name).toBe('Test User');
  });
});
```

## Service Integration
```typescript
describe('EmailService', () => {
  it('should send welcome email', async () => {
    const mockTransporter = createMockTransporter();
    EmailService.initialize(mockTransporter);

    await EmailService.sendWelcomeEmail('user@example.com');

    expect(mockTransporter.sendMail).toHaveBeenCalledWith(
      expect.objectContaining({ to: 'user@example.com' })
    );
  });
});
```

## Test Data Management
- Use migrations for schema
- Seed test data before tests
- Rollback after each test
- Isolate test databases

## Concurrent Testing
- Handle race conditions
- Test transaction isolation
- Verify data consistency