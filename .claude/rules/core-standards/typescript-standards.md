# TypeScript Standards

TypeScript-specific coding standards and best practices.

## Type Safety Policy (MANDATORY)
- **New Code**: Must be properly typed (no exceptions)
- **Legacy Code**: Gradual improvement encouraged
- **Error Trend**: Must show decreasing error count
- **Critical Errors**: Security/runtime issues fixed immediately

## Type Annotations

### Always Type These
- Function parameters
- Function return types
- Class properties
- Module exports

### Examples
```typescript
// ✅ GOOD
export function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ❌ BAD
export function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

## Null/Undefined Handling
```typescript
// ✅ Use optional chaining and nullish coalescing
const value = data?.property ?? defaultValue;

// ❌ Avoid verbose checks
const value = data && data.property ? data.property : defaultValue;
```

## Type Guards Over Assertions
```typescript
// ✅ Type guard
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && obj !== null && 'id' in obj;
}

// ❌ Type assertion
const user = obj as User;
```

## Framework-Specific Types

### Express Routes
```typescript
import { Request, Response } from 'express';

app.get('/api/users', (req: Request, res: Response) => {
  // Always type route handlers
});
```

### React Components
```typescript
// Function component with FC
const MyComponent: React.FC<Props> = ({ name }) => {
  return <div>{name}</div>;
};

// Or with explicit return type
function MyComponent({ name }: Props): JSX.Element {
  return <div>{name}</div>;
}
```

## Strict Mode Settings
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitThis": true
  }
}
```