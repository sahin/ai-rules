# Anti-Patterns to Avoid

## 🚫 CODE SMELLS (MUST AVOID)

### 1. **God Objects**
Classes or components doing too much - violates Single Responsibility Principle

```typescript
// ❌ BAD - God Component
const UserDashboard = () => {
  // Handles authentication
  // Manages user data
  // Renders multiple unrelated sections
  // Handles API calls
  // Manages routing
  // Contains business logic
  return <div>Everything in one component</div>;
};

// ✅ GOOD - Separated Responsibilities
const UserDashboard = () => {
  return (
    <div>
      <UserProfile />
      <UserSettings />
      <UserActivity />
    </div>
  );
};
```

### 2. **Magic Numbers/Strings**
Use named constants for all magic values

```typescript
// ❌ BAD - Magic numbers
if (user.age > 18 && user.score >= 750) {
  return "approved";
}

// ✅ GOOD - Named constants
const LEGAL_AGE = 18;
const APPROVAL_THRESHOLD = 750;
const STATUS = {
  APPROVED: "approved",
  REJECTED: "rejected"
} as const;

if (user.age > LEGAL_AGE && user.score >= APPROVAL_THRESHOLD) {
  return STATUS.APPROVED;
}
```

### 3. **Deep Nesting**
Maximum 3 levels of indentation

```typescript
// ❌ BAD - Too deeply nested
function processOrder(order: Order) {
  if (order) {
    if (order.items) {
      if (order.items.length > 0) {
        if (order.customer) {
          if (order.customer.verified) {
            // Process order
          }
        }
      }
    }
  }
}

// ✅ GOOD - Early returns
function processOrder(order: Order) {
  if (!order?.items?.length) return;
  if (!order.customer?.verified) return;
  
  // Process order
}
```

### 4. **Long Methods**
Maximum 50 lines per function

```typescript
// ❌ BAD - 100+ line function
function massiveFunction() {
  // Line 1-20: Input validation
  // Line 21-40: Data processing
  // Line 41-60: Business logic
  // Line 61-80: API calls
  // Line 81-100: Response formatting
}

// ✅ GOOD - Extracted functions
function processData(input: Input) {
  validateInput(input);
  const processed = transformData(input);
  const result = applyBusinessLogic(processed);
  return formatResponse(result);
}
```

### 5. **Duplicate Code**
Extract common logic to reusable functions

```typescript
// ❌ BAD - Duplicated validation
function createUser(data: UserData) {
  if (!data.email || !data.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!data.password || data.password.length < 8) {
    throw new Error('Password too short');
  }
  // Create user logic
}

function updateUser(id: string, data: UserData) {
  if (!data.email || !data.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!data.password || data.password.length < 8) {
    throw new Error('Password too short');
  }
  // Update user logic
}

// ✅ GOOD - Extracted validation
function validateUserData(data: UserData) {
  if (!data.email || !data.email.includes('@')) {
    throw new Error('Invalid email');
  }
  if (!data.password || data.password.length < 8) {
    throw new Error('Password too short');
  }
}

function createUser(data: UserData) {
  validateUserData(data);
  // Create user logic
}

function updateUser(id: string, data: UserData) {
  validateUserData(data);
  // Update user logic
}
```

### 6. **Tight Coupling**
Use dependency injection and interfaces

```typescript
// ❌ BAD - Tight coupling
class UserService {
  private db = new PostgreSQLDatabase(); // Hardcoded dependency
  
  async getUser(id: string) {
    return this.db.query('SELECT * FROM users WHERE id = ?', [id]);
  }
}

// ✅ GOOD - Dependency injection
interface Database {
  query(sql: string, params: unknown[]): Promise<unknown>;
}

class UserService {
  constructor(private db: Database) {}
  
  async getUser(id: string) {
    return this.db.query('SELECT * FROM users WHERE id = ?', [id]);
  }
}
```

## 🔷 TYPESCRIPT ANTI-PATTERNS

### 1. **Using `any` Without Justification**

```typescript
// ❌ BAD - Lazy typing
function processData(data: any): any {
  return data.someProperty;
}

// ✅ GOOD - Proper types
interface ApiResponse {
  data: unknown;
  status: number;
}

function processData(data: ApiResponse): string | null {
  if (typeof data.data === 'string') {
    return data.data;
  }
  return null;
}
```

### 2. **Ignoring Compiler Errors with @ts-ignore**

```typescript
// ❌ BAD - Suppressing errors without reason
// @ts-ignore
const result = someFunction(wrongType);

// ✅ GOOD - Fix the actual issue
const result = someFunction(properlyTypedValue);
```

### 3. **Mutating Function Parameters**

```typescript
// ❌ BAD - Mutating parameters
function updateUser(user: User) {
  user.lastUpdated = new Date(); // Modifies input
  return user;
}

// ✅ GOOD - Immutable approach
function updateUser(user: User): User {
  return {
    ...user,
    lastUpdated: new Date()
  };
}
```

### 4. **Using `var` Instead of `const/let`**

```typescript
// ❌ BAD - Function-scoped var
for (var i = 0; i < items.length; i++) {
  setTimeout(() => console.log(i), 100); // Always logs items.length
}

// ✅ GOOD - Block-scoped let/const
for (let i = 0; i < items.length; i++) {
  setTimeout(() => console.log(i), 100); // Logs 0, 1, 2, etc.
}
```

### 5. **Implicit Returns in Complex Arrow Functions**

```typescript
// ❌ BAD - Complex logic in implicit return
const processUser = (user: User) => user.active && user.verified && 
  user.roles.includes('admin') && user.lastLogin > new Date(Date.now() - 86400000) ?
  { ...user, status: 'online' } : { ...user, status: 'offline' };

// ✅ GOOD - Explicit function body
const processUser = (user: User): UserWithStatus => {
  const isActiveAdmin = user.active && 
                       user.verified && 
                       user.roles.includes('admin');
  const recentLogin = user.lastLogin > new Date(Date.now() - 86400000);
  
  const status = isActiveAdmin && recentLogin ? 'online' : 'offline';
  return { ...user, status };
};
```

## ⚛️ REACT ANTI-PATTERNS

### 1. **Direct State Mutation**

```tsx
// ❌ BAD - Mutating state directly
const [users, setUsers] = useState<User[]>([]);

const addUser = (user: User) => {
  users.push(user); // Direct mutation
  setUsers(users);
};

// ✅ GOOD - Immutable updates
const addUser = (user: User) => {
  setUsers(prev => [...prev, user]);
};
```

### 2. **Using Array Index as Key in Dynamic Lists**

```tsx
// ❌ BAD - Index as key
{items.map((item, index) => (
  <Item key={index} data={item} />
))}

// ✅ GOOD - Unique, stable keys
{items.map((item) => (
  <Item key={item.id} data={item} />
))}
```

### 3. **Inline Function Definitions in Render**

```tsx
// ❌ BAD - New function on every render
const UserList = ({ users }: Props) => {
  return (
    <div>
      {users.map(user => (
        <button key={user.id} onClick={() => handleClick(user.id)}>
          {user.name}
        </button>
      ))}
    </div>
  );
};

// ✅ GOOD - useCallback or extract function
const UserList = ({ users, onUserClick }: Props) => {
  const handleClick = useCallback((userId: string) => {
    onUserClick(userId);
  }, [onUserClick]);

  return (
    <div>
      {users.map(user => (
        <button key={user.id} onClick={() => handleClick(user.id)}>
          {user.name}
        </button>
      ))}
    </div>
  );
};
```

### 4. **Missing Dependency Arrays in Hooks**

```tsx
// ❌ BAD - Missing dependencies
const [data, setData] = useState(null);

useEffect(() => {
  fetchUserData(userId).then(setData);
}, []); // Missing userId dependency

// ✅ GOOD - Complete dependencies
useEffect(() => {
  fetchUserData(userId).then(setData);
}, [userId]); // Includes all dependencies
```

### 5. **Async Operations in useEffect Without Cleanup**

```tsx
// ❌ BAD - Potential memory leak
useEffect(() => {
  fetchData().then(setData);
}, []);

// ✅ GOOD - Cleanup for cancellation
useEffect(() => {
  const controller = new AbortController();
  
  fetchData({ signal: controller.signal })
    .then(setData)
    .catch(error => {
      if (error.name !== 'AbortError') {
        console.error('Fetch error:', error);
      }
    });
    
  return () => controller.abort();
}, []);
```

## 📊 DATABASE ANTI-PATTERNS

### 1. **N+1 Query Problem**

```sql
-- ❌ BAD - N+1 queries
-- Main query
SELECT id FROM users;
-- Then for each user (N queries):
SELECT * FROM posts WHERE user_id = ?;

-- ✅ GOOD - Single optimized query
SELECT u.*, p.* 
FROM users u 
LEFT JOIN posts p ON u.id = p.user_id;
```

### 2. **Missing Indexes on Frequently Queried Columns**

```sql
-- ❌ BAD - No index on frequently searched column
SELECT * FROM orders WHERE customer_email = 'user@example.com';

-- ✅ GOOD - Add appropriate index
CREATE INDEX idx_orders_customer_email ON orders(customer_email);
```

## 🔒 SECURITY ANTI-PATTERNS

### 1. **SQL Injection Vulnerability**

```typescript
// ❌ BAD - String concatenation
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ GOOD - Parameterized queries
const query = 'SELECT * FROM users WHERE id = ?';
const result = await db.query(query, [userId]);
```

### 2. **Hardcoded Secrets**

```typescript
// ❌ BAD - Hardcoded API key
const API_KEY = 'sk-1234567890abcdef';

// ✅ GOOD - Environment variables
const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error('API_KEY environment variable is required');
}
```

## 🚀 PERFORMANCE ANTI-PATTERNS

### 1. **Inefficient Re-renders**

```tsx
// ❌ BAD - Object creation in render
const ExpensiveComponent = ({ items }: Props) => {
  return (
    <div>
      {items.filter(item => item.active).map(item => ( // New array every render
        <Item key={item.id} config={{ theme: 'dark' }} /> // New object every render
      ))}
    </div>
  );
};

// ✅ GOOD - Memoized computations
const ExpensiveComponent = ({ items }: Props) => {
  const config = useMemo(() => ({ theme: 'dark' }), []);
  const activeItems = useMemo(
    () => items.filter(item => item.active),
    [items]
  );

  return (
    <div>
      {activeItems.map(item => (
        <Item key={item.id} config={config} />
      ))}
    </div>
  );
};
```

### 2. **Memory Leaks**

```typescript
// ❌ BAD - Event listener not cleaned up
useEffect(() => {
  const handleResize = () => setWindowWidth(window.innerWidth);
  window.addEventListener('resize', handleResize);
  // Missing cleanup
}, []);

// ✅ GOOD - Proper cleanup
useEffect(() => {
  const handleResize = () => setWindowWidth(window.innerWidth);
  window.addEventListener('resize', handleResize);
  
  return () => window.removeEventListener('resize', handleResize);
}, []);
```

## ⚠️ DETECTION RULES

### **Automated Detection Commands**

```bash
# Find long functions (>50 lines)
grep -n "function\|const.*=.*(" *.ts *.tsx | while read line; do
  # Custom script to count lines until closing brace
done

# Find magic numbers
grep -r "[^a-zA-Z_][0-9]\{2,\}" --include="*.ts" --include="*.tsx" .

# Find console.log statements
grep -r "console\." --include="*.ts" --include="*.tsx" .

# Find any type usage
grep -r ": any\|<any>" --include="*.ts" --include="*.tsx" .

# Find @ts-ignore usage
grep -r "@ts-ignore" --include="*.ts" --include="*.tsx" .
```

### **Code Review Checklist**

- [ ] No functions longer than 50 lines
- [ ] No nesting deeper than 3 levels
- [ ] No magic numbers or strings
- [ ] No duplicate code blocks
- [ ] No `any` types without justification
- [ ] No `@ts-ignore` without explanation
- [ ] No direct state mutations
- [ ] No missing useEffect dependencies
- [ ] No memory leaks from event listeners
- [ ] No hardcoded sensitive data

## 🎯 **REFACTORING PRIORITY**

### **High Priority (Fix Immediately)**
1. Security vulnerabilities (SQL injection, XSS, hardcoded secrets)
2. Memory leaks and performance issues
3. Functions longer than 100 lines

### **Medium Priority (Fix During Feature Work)**
1. Magic numbers and duplicate code
2. Deep nesting and god objects
3. Missing TypeScript types

### **Low Priority (Opportunistic Fixes)**
1. Code style inconsistencies
2. Non-critical performance optimizations
3. Documentation improvements

---

**Related Rules**: See `core-standards/coding-standards.md` for general coding standards and `general-policies/refactoring.md` for systematic improvement strategies.