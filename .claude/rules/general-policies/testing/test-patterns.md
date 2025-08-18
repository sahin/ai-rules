# Test Patterns

## AAA Pattern (Arrange-Act-Assert)
```javascript
it('should calculate total', () => {
  // Arrange
  const input = { value: 10 };
  
  // Act
  const result = calculateTotal(input);
  
  // Assert
  expect(result).toBe(10);
});
```

## Naming Conventions
- Start with "should" or "when/then"
- Be specific: `should_calculate_total_with_tax_when_rate_provided`
- Focus on behavior, not implementation

## Test Organization
```
src/
  components/
    Button.tsx
    Button.test.tsx    // Unit tests
  api/
    users.ts
    users.test.ts      // Integration tests
tests/
  e2e/
    user-flow.test.ts  // E2E tests
```

## What to Test
- **Always**: Public APIs, edge cases, errors
- **Never**: Implementation details, private methods
- **Focus**: Business logic, state changes, boundaries