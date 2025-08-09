# TypeScript Strict Mode Guide

This document provides strict TypeScript configuration and coding patterns to ensure your code passes all type checks, linting, and build processes without errors.

## 🎯 GOAL: ZERO ERRORS POLICY

Your TypeScript code must pass:
- ✅ `npm run type-check` - TypeScript type checking (noEmit)
- ✅ `npm test:types` - Type safety tests
- ✅ `npm run build` - Production build (includes type-check)
- ✅ `npm run lint` - ESLint check (max 50 warnings allowed)

## 🔧 STRICT TYPESCRIPT CONFIGURATION

### **Recommended `tsconfig.json` for New Projects:**
```json
{
  "compilerOptions": {
    // STRICT MODE - ALL FLAGS ENABLED
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    
    // ADDITIONAL SAFETY CHECKS
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    
    // BUILD OPTIONS
    "noEmit": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "esModuleInterop": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true
  }
}
```

## 📝 STRICT CODING PATTERNS

### **1. No Implicit Any - Type Everything**
```typescript
// ❌ BAD - Implicit any
function processData(data) {
  return data.map(item => item.value);
}

// ✅ GOOD - Explicit types
interface DataItem {
  value: number;
  label: string;
}

function processData(data: DataItem[]): number[] {
  return data.map(item => item.value);
}
```

### **2. Strict Null Checks - Handle Undefined/Null**
```typescript
// ❌ BAD - Potential undefined access
function getUser(id: string) {
  const user = users.find(u => u.id === id);
  return user.name; // Error: user might be undefined
}

// ✅ GOOD - Null safety
function getUser(id: string): string | undefined {
  const user = users.find(u => u.id === id);
  return user?.name; // Optional chaining
}

// ✅ BETTER - With assertion
function getUserOrThrow(id: string): string {
  const user = users.find(u => u.id === id);
  if (!user) {
    throw new Error(`User ${id} not found`);
  }
  return user.name;
}
```

### **3. Array/Object Access Safety**
```typescript
// ❌ BAD - Unsafe array access
const firstItem = items[0].name; // items[0] might be undefined

// ✅ GOOD - Safe access with noUncheckedIndexedAccess
const firstItem = items[0]?.name;

// ✅ BETTER - With validation
const firstItem = items.length > 0 ? items[0]!.name : undefined;

// ✅ BEST - Type guard
function getFirstItemName(items: Item[]): string | undefined {
  const first = items[0];
  if (first) {
    return first.name;
  }
  return undefined;
}
```

### **4. Explicit Function Return Types**
```typescript
// ❌ BAD - Implicit return type
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ✅ GOOD - Explicit return type
function calculateTotal(items: PricedItem[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ✅ For async functions
async function fetchUser(id: string): Promise<User | null> {
  try {
    const response = await api.get<User>(`/users/${id}`);
    return response.data;
  } catch {
    return null;
  }
}
```

### **5. Type Guards and Narrowing**
```typescript
// Type guard functions
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value
  );
}

// Usage with narrowing
function processValue(value: string | number | null): string {
  if (value === null) {
    return 'null';
  }
  if (typeof value === 'string') {
    return value.toUpperCase();
  }
  return value.toFixed(2);
}
```

### **6. Strict Property Initialization**
```typescript
// ❌ BAD - Uninitialized properties
class UserService {
  private api: ApiClient; // Error: not initialized
}

// ✅ GOOD - Proper initialization
class UserService {
  private api: ApiClient;
  
  constructor(api: ApiClient) {
    this.api = api;
  }
}

// ✅ ALTERNATIVE - Definite assignment
class UserService {
  private api!: ApiClient; // Use ! only when certain
  
  async initialize(): Promise<void> {
    this.api = await createApiClient();
  }
}
```

### **7. React Component Types**
```typescript
// ✅ Typed functional component
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;
  variant?: 'primary' | 'secondary';
}

const Button: React.FC<ButtonProps> = ({ 
  label, 
  onClick, 
  disabled = false,
  variant = 'primary' 
}) => {
  return (
    <button 
      onClick={onClick} 
      disabled={disabled}
      className={`btn-${variant}`}
    >
      {label}
    </button>
  );
};

// ✅ With children
interface CardProps {
  title: string;
  children: React.ReactNode;
}

const Card: React.FC<CardProps> = ({ title, children }) => {
  return (
    <div className="card">
      <h2>{title}</h2>
      {children}
    </div>
  );
};
```

### **8. Event Handler Types**
```typescript
// ✅ Properly typed event handlers
const handleClick = (event: React.MouseEvent<HTMLButtonElement>): void => {
  event.preventDefault();
  console.log('Clicked');
};

const handleChange = (event: React.ChangeEvent<HTMLInputElement>): void => {
  const value = event.target.value;
  setValue(value);
};

const handleSubmit = (event: React.FormEvent<HTMLFormElement>): void => {
  event.preventDefault();
  // Handle form submission
};
```

### **9. API Response Types**
```typescript
// ✅ Type-safe API calls
interface ApiResponse<T> {
  data: T;
  status: number;
  message?: string;
}

interface ApiError {
  error: string;
  code: string;
  details?: unknown;
}

async function fetchData<T>(url: string): Promise<T> {
  const response = await fetch(url);
  
  if (!response.ok) {
    const error: ApiError = await response.json();
    throw new Error(error.error);
  }
  
  const result: ApiResponse<T> = await response.json();
  return result.data;
}

// Usage
interface User {
  id: string;
  name: string;
  email: string;
}

const user = await fetchData<User>('/api/users/123');
```

### **10. Utility Types Usage**
```typescript
// ✅ Leverage TypeScript utility types
interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
  createdAt: Date;
}

// Partial for updates
type UserUpdate = Partial<User>;

// Pick for subsets
type UserProfile = Pick<User, 'id' | 'name' | 'email'>;

// Omit for exclusions
type UserWithoutTimestamps = Omit<User, 'createdAt'>;

// Required for strict versions
type StrictUser = Required<User>;

// Readonly for immutability
type ImmutableUser = Readonly<User>;
```

## 🚨 COMMON PITFALLS TO AVOID

### **1. Type Assertions - Use Sparingly**
```typescript
// ❌ AVOID - Dangerous type assertion
const user = {} as User; // Bypasses type safety

// ✅ PREFER - Type guards or proper initialization
const user: User = {
  id: '123',
  name: 'John',
  email: 'john@example.com'
};
```

### **2. Any Type - Never Use**
```typescript
// ❌ NEVER - Using any
function processData(data: any): any {
  return data;
}

// ✅ ALWAYS - Use unknown or generics
function processData<T>(data: T): T {
  return data;
}

function handleUnknown(data: unknown): string {
  if (typeof data === 'string') {
    return data;
  }
  return String(data);
}
```

### **3. Non-null Assertions - Use Carefully**
```typescript
// ❌ RISKY - Non-null assertion without check
const name = user!.name; // Runtime error if user is null

// ✅ SAFE - Check before assertion
if (user) {
  const name = user.name; // TypeScript knows user is defined
}

// ✅ SAFER - Use optional chaining
const name = user?.name ?? 'Unknown';
```

## 📋 PRE-COMMIT CHECKLIST

Before committing your TypeScript code, ensure:

- [ ] **No TypeScript errors**: `npx tsc --noEmit` passes
- [ ] **No ESLint errors**: `npm run lint` passes
- [ ] **All functions have return types**
- [ ] **No `any` types used**
- [ ] **All variables have explicit or inferred types**
- [ ] **Null/undefined handled properly**
- [ ] **Array/object access is safe**
- [ ] **No ignored TypeScript errors** (`// @ts-ignore`)
- [ ] **Build succeeds**: `npm run build` passes
- [ ] **Tests pass**: `npm test` passes

## 🛠️ MIGRATION STRATEGY

For existing codebases:

### **Phase 1: Enable Strict Null Checks**
```json
{
  "compilerOptions": {
    "strictNullChecks": true,
    "noUncheckedIndexedAccess": true
  }
}
```

### **Phase 2: Enable No Implicit Any**
```json
{
  "compilerOptions": {
    "noImplicitAny": true
  }
}
```

### **Phase 3: Full Strict Mode**
```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

## 🎯 QUICK REFERENCE

```typescript
// Always type function parameters and returns
function calculate(a: number, b: number): number

// Always handle null/undefined
const value = data?.property ?? defaultValue;

// Always use proper event types
onClick: (e: React.MouseEvent<HTMLButtonElement>) => void

// Always type component props
interface Props { name: string; age?: number; }

// Never use any, use unknown or generics
function process<T>(data: T): T

// Always check before accessing arrays/objects
if (array[index]) { /* safe to use */ }
```

---

**Remember**: Strict TypeScript catches bugs at compile time that would otherwise surface at runtime. The initial effort pays off in reduced debugging time and increased confidence in your code.