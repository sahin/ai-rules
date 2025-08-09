# Universal Coding Standards

This document outlines universal coding conventions, patterns, and best practices that must be followed in all software development projects, regardless of technology stack or domain.

## 🚀 CRITICAL CODING REQUIREMENTS

### 1. **Code Quality Standards (MANDATORY)**

#### **Code Consistency:**
- **Consistent formatting**: Use automated formatters (Prettier, ESLint, etc.)
- **Naming conventions**: Clear, descriptive names for variables, functions, classes
- **Code organization**: Logical file and folder structure
- **Comment standards**: Document complex logic and business rules
- **Version control**: Meaningful commit messages, proper branching

#### **Error Handling:**
- **Explicit error handling**: Never ignore or suppress errors silently
- **Proper logging**: Log errors with context and stack traces
- **User-friendly messages**: Display appropriate messages to users
- **Recovery mechanisms**: Implement fallback behaviors where possible
- **Error boundaries**: Catch and handle errors at appropriate levels

### 2. **TypeScript Standards (MANDATORY)**

#### **Type Safety Policy:**
- **New Code**: Must be properly typed (no exceptions)
- **Legacy Code**: Gradual improvement encouraged
- **Error Trend**: Must show decreasing error count over time
- **Critical Errors**: Security and runtime issues must be fixed (no tolerance)

#### **Type Annotations Best Practices:**
Always provide explicit types for:
- Function parameters
- Function return types
- Class properties
- Module exports

```typescript
// Good
export function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Bad
export function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

#### **Null/Undefined Handling:**
Use optional chaining and nullish coalescing:
```typescript
// Good
const value = data?.property ?? defaultValue;

// Bad
const value = data && data.property ? data.property : defaultValue;
```

#### **Express Route Types:**
Always type Express route handlers:
```typescript
import { Request, Response } from 'express';

// Good
app.get('/api/users', (req: Request, res: Response) => {
  // ...
});

// Bad
app.get('/api/users', (req, res) => {
  // ...
});
```

#### **React Component Types:**
Use proper React FC types or explicit return types:
```typescript
// Good
const MyComponent: React.FC<Props> = ({ name }) => {
  return <div>{name}</div>;
};

// Also good
function MyComponent({ name }: Props): JSX.Element {
  return <div>{name}</div>;
}
```

#### **Avoid Type Assertions:**
Prefer type guards over type assertions:
```typescript
// Good
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && obj !== null && 'id' in obj;
}

// Bad
const user = obj as User;
```

### 2.5. **Naming Conventions (Cross-Stack)**

- Use kebab-case for file names in TS/JS; PascalCase for React components; snake_case for Python.
- Prefer `<domain>.<role>.<ext>` (e.g., `auth.service.ts`, `billing.webhook.handler.ts`).
- Avoid generic names (`utils.ts`, `helpers.ts`, `index.ts`) unless the folder is uniquely named and the entrypoint is obvious.
- Keep filenames under ~60 characters; use folders to convey specificity.
- Common suffixes: `.routes`, `.controller`, `.service`, `.repo`, `.types`, `.validators`, `.schema`, `.hook`, `.utils`, `.test`.

### 3. **React Best Practices (MANDATORY)**

#### **Component Standards:**
- **Functional components**: Use functional components with hooks
- **Component organization**: Place components in appropriate domain folders
- **Export patterns**: Use default exports for components
- **Naming conventions**: Use descriptive component names in PascalCase
- **Props typing**: Always type component props explicitly

#### **Hook Usage:**
```typescript
// Good - Custom hook with proper typing
function useApiData<T>(url: string): { data: T | null; loading: boolean; error: Error | null } {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    // Implementation
  }, [url]);
  
  return { data, loading, error };
}
```

### 3.5. **SRP and File Size Targets**

- Single Responsibility Principle: one reason to change per file.
- Soft limits to keep files readable:
  - React component: 50–200 LOC
  - Route/handler: 50–150 LOC
  - Service/module: 150–300 LOC
  - Test files: ≤300 LOC
- Split when a file spans multiple domains, adds a third reusable helper, or its description needs “and/also”.

### 4. **File Organization Standards (MANDATORY)**

#### **File Naming Conventions:**
- **Components**: `PascalCase.tsx` (e.g., `UserProfile.tsx`)
- **Utilities**: `camelCase.ts` (e.g., `apiRequest.ts`)
- **Types**: `types.ts` or `PascalCase.types.ts`
- **API files**: `camelCaseApi.ts` (e.g., `userApi.ts`)
- **Constants**: `UPPER_SNAKE_CASE.ts` or `constants.ts`

#### **Import Organization:**
```typescript
// 1. External library imports
import React, { useState, useEffect } from 'react';
import { Router } from 'express';

// 2. Internal library imports (if using monorepo)
import { Button } from '@company/ui';
import { apiClient } from '@company/shared';

// 3. Relative imports
import { UserService } from '../services/UserService';
import type { User } from './types';
```

### 4.5. **Tests Colocation and Mirrored Names**

- Place tests next to the source with mirrored names:
  - `foo.service.ts` -> `foo.service.test.ts`
  - `LoginForm.tsx` -> `LoginForm.test.tsx`
- Keep fixtures/factories in a `__fixtures__` or `testutils` sibling folder.

### 5. **Documentation & Comment Standards (MANDATORY)**

#### **When to Comment - MUST Comment:**
- **Complex algorithms** (> 10 lines or non-obvious logic)
- **Business logic decisions** (why this approach was chosen)
- **Workarounds** with issue links and explanations
- **API contracts and expectations** (input/output specifications)
- **Security considerations** (authentication, validation, authorization)
- **Performance-critical sections** (optimization explanations)
- **External integrations** (third-party API usage)

#### **When NOT to Comment - AVOID Comments For:**
- **Self-documenting code** (clear variable and function names)
- **Simple getters/setters** (obvious functionality)
- **Obvious implementations** (standard patterns)
- **Temporary code** (fix the code instead)
- **Outdated information** (remove or update immediately)

#### **Comment Format Standards:**

**JSDoc Function Comments:**
```typescript
/**
 * Calculate compound interest with daily compounding
 * @param principal - Initial amount in cents to avoid floating point issues
 * @param rate - Annual interest rate as decimal (0.05 = 5%)
 * @param days - Number of days to compound
 * @returns Total amount in cents after compounding
 * @throws {InvalidRateError} If rate is negative or > 1
 * @example
 * calculateInterest(100000, 0.05, 365) // Returns 105127 (5.127% actual)
 * @see https://docs.company.com/financial-calculations
 */
export function calculateCompoundInterest(
  principal: number, 
  rate: number, 
  days: number
): number {
  if (rate < 0 || rate > 1) {
    throw new InvalidRateError('Rate must be between 0 and 1');
  }
  
  // Using daily compounding formula: A = P(1 + r/365)^(365*t)
  // where t = days/365 for partial years
  const dailyRate = rate / 365;
  const periods = days;
  
  return Math.round(principal * Math.pow(1 + dailyRate, periods));
}
```

**Inline Comments for Complex Logic:**
```typescript
export function processPayment(amount: number, paymentMethod: PaymentMethod) {
  // SECURITY: Validate amount to prevent negative transactions
  // See: https://github.com/company/security-guidelines/issues/42
  if (amount <= 0) {
    throw new InvalidAmountError('Payment amount must be positive');
  }
  
  // BUSINESS LOGIC: Apply processing fee based on payment method
  // Credit cards: 2.9% + $0.30, ACH: $0.50 flat fee
  // Updated per finance team requirements (2024-Q4)
  const processingFee = paymentMethod === 'credit_card' 
    ? Math.round(amount * 0.029 + 30)  // 2.9% + $0.30 in cents
    : 50; // $0.50 in cents for ACH
    
  // PERFORMANCE: Batch multiple small payments to reduce API calls
  // Only for amounts under $10 to optimize transaction costs
  if (amount < 1000) { // $10.00 in cents
    return batchSmallPayment(amount, processingFee, paymentMethod);
  }
  
  return processImmediatePayment(amount, processingFee, paymentMethod);
}
```

**Component Documentation:**
```typescript
interface UserProfileProps {
  /** Unique identifier for the user to display */
  userId: string;
  /** 
   * Optional callback when user clicks edit button
   * @param user - The updated user object after edit
   */
  onEdit?: (user: User) => void;
  /** Whether edit functionality is enabled (default: false) */
  isEditable?: boolean;
  /** 
   * Display mode for the profile
   * - 'compact': Shows only essential info
   * - 'detailed': Shows full profile with all fields  
   * - 'card': Optimized for card layouts
   */
  displayMode?: 'compact' | 'detailed' | 'card';
}

/**
 * User profile display component with responsive layout
 * 
 * Handles loading states, error boundaries, and accessibility.
 * Automatically fetches user data based on userId prop.
 * 
 * @example
 * // Basic usage
 * <UserProfile userId="123" />
 * 
 * @example  
 * // With edit callback
 * <UserProfile 
 *   userId="123" 
 *   isEditable={true}
 *   onEdit={(user) => console.log('User updated:', user)}
 * />
 * 
 * @see UserEditModal for editing functionality
 * @see UserList for bulk user operations
 */
export const UserProfile: React.FC<UserProfileProps> = ({ 
  userId, 
  onEdit, 
  isEditable = false,
  displayMode = 'detailed' 
}) => {
  // Implementation...
};
```

**API Endpoint Documentation:**
```typescript
/**
 * Create a new user account
 * 
 * SECURITY: Requires admin privileges or valid invitation token
 * RATE_LIMIT: 10 requests per minute per IP
 * 
 * @route POST /api/users
 * @param {CreateUserRequest} body - User creation data
 * @returns {User} The created user object (passwords excluded)
 * @throws {ValidationError} 400 - Invalid input data
 * @throws {DuplicateEmailError} 409 - Email already exists
 * @throws {UnauthorizedError} 401 - Invalid or missing auth token
 * @throws {ForbiddenError} 403 - Insufficient privileges
 * 
 * @example
 * POST /api/users
 * {
 *   "email": "user@example.com",
 *   "password": "securePassword123",
 *   "firstName": "John",
 *   "lastName": "Doe",
 *   "invitationToken": "abc123"
 * }
 * 
 * @example Response
 * {
 *   "id": "user_123",
 *   "email": "user@example.com",
 *   "firstName": "John",
 *   "lastName": "Doe", 
 *   "createdAt": "2024-01-15T10:30:00Z",
 *   "status": "active"
 * }
 */
export const createUser = async (req: Request, res: Response) => {
  // Implementation...
};
```

#### **Code Documentation:**
- **Function documentation**: Document complex functions with JSDoc
- **Component documentation**: Document props and usage examples  
- **API documentation**: Document all endpoints and parameters
- **README files**: Maintain up-to-date setup and usage instructions
- **Change documentation**: Update CHANGELOG.md for all changes

#### **Documentation Examples:**

**Good Function Documentation:**
```typescript
/**
 * Calculates the total price of items with tax
 * @param items - Array of items with price property
 * @param taxRate - Tax rate as decimal (e.g., 0.08 for 8%)
 * @returns Total price including tax
 */
export function calculateTotalWithTax(items: Item[], taxRate: number): number {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  return subtotal * (1 + taxRate);
}
```

**Good Component Documentation:**
```typescript
interface UserProfileProps {
  userId: string;
  onEdit?: (user: User) => void;
  isEditable?: boolean;
}

/**
 * User profile display component
 * @param userId - Unique identifier for the user
 * @param onEdit - Optional callback when user clicks edit
 * @param isEditable - Whether edit functionality is enabled
 */
const UserProfile: React.FC<UserProfileProps> = ({ userId, onEdit, isEditable = false }) => {
  // Implementation
};
```

## 🚨 CODING VIOLATIONS - ZERO TOLERANCE

### **Critical Violations:**
- ❌ Hardcoded sensitive information (passwords, API keys, secrets)
- ❌ Unhandled promise rejections
- ❌ SQL injection vulnerabilities
- ❌ XSS vulnerabilities in user input handling
- ❌ Memory leaks from uncleaned event listeners
- ❌ Infinite loops or recursion without exit conditions
- ❌ Direct manipulation of production data in code
- ❌ Committing temporary debug code or console.logs

### **Code Quality Violations:**
- ❌ Functions longer than 50 lines without clear justification
- ❌ Deeply nested code (more than 4 levels of indentation)
- ❌ Magic numbers or strings without explanation
- ❌ Duplicate code that should be abstracted
- ❌ Unused imports, variables, or functions
- ❌ Missing error handling for async operations
- ❌ Inconsistent naming conventions

## 📋 CODE QUALITY CHECKLIST

### **Before Code Submission:**
- [ ] All TypeScript errors resolved
- [ ] Code properly formatted with automated tools
- [ ] All functions and components properly typed
- [ ] Error handling implemented for all async operations
- [ ] No hardcoded values (use constants or environment variables)
- [ ] All imports used and properly organized
- [ ] Console.log statements removed
- [ ] Comments added for complex logic
- [ ] Tests written for new functionality

### **Code Review Standards:**
- [ ] Code follows established patterns and conventions
- [ ] Performance implications considered
- [ ] Security vulnerabilities addressed
- [ ] Documentation updated where necessary
- [ ] Breaking changes properly communicated
- [ ] Backward compatibility maintained where possible

## 🎯 UNIVERSAL TYPE SAFETY CHECKLIST

- [ ] All function parameters have explicit types
- [ ] All function return types are explicit
- [ ] No `any` types (use `unknown` if type is truly unknown)
- [ ] All nullable values are properly handled
- [ ] Class properties are initialized or marked optional
- [ ] No unused variables or parameters
- [ ] All imports are used
- [ ] Proper error types in catch blocks

---

Add a short header comment to each new/edited source file summarizing purpose, tags, inputs/outputs, and see-also references.

Template:
```
/**
 * Purpose: <one-sentence scope>
 * Tags: <comma-separated keywords>
 * Inputs: <API signatures, props, or function inputs>
 * Outputs: <returns/thrown errors/side effects>
 * See also: <relative paths to closely related files>
 */
```

**Note**: For project-specific coding standards and examples, see `project-coding-standards.md` 