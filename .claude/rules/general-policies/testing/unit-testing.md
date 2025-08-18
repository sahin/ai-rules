# Unit Testing

## Component Testing
```typescript
describe('UserForm', () => {
  it('should submit with valid data', async () => {
    const onSubmit = jest.fn();
    render(<UserForm onSubmit={onSubmit} />);
    
    await userEvent.type(screen.getByLabelText('Name'), 'John');
    await userEvent.click(screen.getByRole('button'));
    
    expect(onSubmit).toHaveBeenCalledWith({ name: 'John' });
  });
});
```

## Function Testing
```typescript
describe('calculateDiscount', () => {
  it.each([
    [100, 10, 90],
    [50, 50, 25],
    [0, 10, 0],
  ])('price %i with %i%% = %i', (price, discount, expected) => {
    expect(calculateDiscount(price, discount)).toBe(expected);
  });
});
```

## Mocking Strategies
```typescript
// Mock external dependencies
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

// Spy on methods
const loggerSpy = jest.spyOn(console, 'log');

// Stub responses
const stub = jest.fn().mockResolvedValue({ success: true });
```

## Test Utilities
- Custom render with providers
- Test data builders
- Mock factories
- Wait helpers