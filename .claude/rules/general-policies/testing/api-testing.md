# API Testing

## 100% Coverage Requirement
**MANDATORY**: ALL API endpoints MUST have 100% test coverage

## API Test Pattern
```typescript
describe('POST /api/users', () => {
  it('should create user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'Jane', email: 'jane@example.com' })
      .expect(201);

    expect(response.body).toMatchObject({
      id: expect.any(Number),
      name: 'Jane'
    });
  });

  it('should validate fields', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com' })
      .expect(400);

    expect(response.body.errors).toContainEqual(
      expect.objectContaining({ field: 'name' })
    );
  });
});
```

## Authentication Testing
```typescript
it('should protect routes', async () => {
  await request(app).get('/api/protected').expect(401);
  
  await request(app)
    .get('/api/protected')
    .set('Authorization', 'Bearer token')
    .expect(200);
});
```

## Response Validation
- Status codes correct
- Response structure matches spec
- Error format consistent
- Headers properly set