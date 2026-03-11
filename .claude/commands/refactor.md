# Refactoring Guide

Use this guide when refactoring code, evaluating dependencies, or improving code structure.

## When to Refactor

### Triggers
- **Rule of Three**: Code duplicated 3+ times -> extract
- **Long functions**: > 50 lines -> split by responsibility
- **Deep nesting**: > 3 levels -> early returns, extract methods
- **God class/module**: Does too many things -> split by domain
- **Shotgun surgery**: One change requires editing many files -> consolidate
- **Feature envy**: Function uses another module's data more than its own -> move it
- **Primitive obsession**: Raw strings/numbers everywhere -> create domain types
- **Large file**: > 300 LOC (service) or > 200 LOC (component) -> split

### Do NOT Refactor When
- No tests exist (write tests first)
- Under time pressure for a critical fix (fix first, refactor later)
- The code works and won't be modified again
- You're not confident you understand what the code does

## Refactoring Process

### Step 1: Ensure Test Coverage
```bash
# Check existing coverage for the file(s) you'll refactor
npx jest --coverage --collectCoverageFrom='src/path/to/file.ts' src/path/to/file.test.ts

# Write missing tests BEFORE refactoring
# Tests should verify current behavior (even if it has bugs)
```

### Step 2: Small Steps, Frequent Commits
```
1. Make ONE small change
2. Run tests (all must pass)
3. Commit with descriptive message
4. Repeat

# Example commit sequence:
# refactor: extract validateEmail from UserService
# refactor: extract sendNotification from UserService
# refactor: rename UserService to UserRegistrationService
```

### Step 3: Verify Behavior Preserved
- All existing tests still pass
- No new console errors or warnings
- Manual smoke test of affected features
- Performance not degraded (check response times)

## Common Refactoring Patterns

### Extract Function
```typescript
// BEFORE: Long function with mixed concerns
async function processOrder(order: Order) {
  // 20 lines of validation...
  // 15 lines of price calculation...
  // 10 lines of notification...
}

// AFTER: Clear responsibilities
async function processOrder(order: Order) {
  validateOrder(order);
  const total = calculateTotal(order);
  await sendConfirmation(order, total);
}
```

### Replace Conditional with Polymorphism
```typescript
// BEFORE: Switch/if chains
function calculateShipping(type: string, weight: number): number {
  if (type === 'standard') return weight * 0.5;
  if (type === 'express') return weight * 1.5 + 5;
  if (type === 'overnight') return weight * 3 + 15;
  throw new Error(`Unknown type: ${type}`);
}

// AFTER: Strategy pattern
const shippingStrategies: Record<string, (weight: number) => number> = {
  standard: (w) => w * 0.5,
  express: (w) => w * 1.5 + 5,
  overnight: (w) => w * 3 + 15,
};

function calculateShipping(type: string, weight: number): number {
  const strategy = shippingStrategies[type];
  if (!strategy) throw new Error(`Unknown type: ${type}`);
  return strategy(weight);
}
```

### Extract Custom Hook (React)
```typescript
// BEFORE: Component with mixed data fetching and UI logic
function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchUser(userId).then(setUser).catch(setError).finally(() => setIsLoading(false));
  }, [userId]);

  // ... 50 lines of render logic
}

// AFTER: Separated concerns
function useUser(userId: string) {
  return useQuery({ queryKey: ['user', userId], queryFn: () => fetchUser(userId) });
}

function UserProfile({ userId }: Props) {
  const { data: user, isLoading, error } = useUser(userId);
  // ... clean render logic
}
```

### Simplify Conditionals
```typescript
// BEFORE: Nested conditionals
function getDiscount(user: User, order: Order): number {
  if (user.isPremium) {
    if (order.total > 100) {
      if (order.items.length > 5) {
        return 0.2;
      }
      return 0.15;
    }
    return 0.1;
  }
  return 0;
}

// AFTER: Early returns (guard clauses)
function getDiscount(user: User, order: Order): number {
  if (!user.isPremium) return 0;
  if (order.total > 100 && order.items.length > 5) return 0.2;
  if (order.total > 100) return 0.15;
  return 0.1;
}
```

### Replace Magic Values
```typescript
// BEFORE
if (user.role === 3) { ... }
if (retries > 5) { ... }
const timeout = 30000;

// AFTER
const ROLES = { ADMIN: 3, USER: 1, MODERATOR: 2 } as const;
const MAX_RETRIES = 5;
const REQUEST_TIMEOUT_MS = 30_000;

if (user.role === ROLES.ADMIN) { ... }
if (retries > MAX_RETRIES) { ... }
```

## Dependency Evaluation

### When Adding a Dependency
Ask these questions:
1. **Do we really need it?** Can we write 20-50 lines instead?
2. **How maintained is it?** Last commit, open issues, bus factor
3. **How large is it?** Check bundle impact with `bundlephobia.com`
4. **Is it secure?** Check `npm audit`, known vulnerabilities
5. **License compatible?** MIT/Apache-2.0 are safe. GPL may not be.

### Decision Matrix
| Factor | Add Package | Write In-House |
|--------|-------------|----------------|
| Complexity | > 100 LOC to replicate | < 50 LOC to replicate |
| Maintenance | Active, > 1000 stars | Abandoned or risky |
| Bundle size | < 10KB gzipped | > 50KB gzipped |
| Stability | Stable API (> v1.0) | Frequent breaking changes |

### Updating Dependencies
```bash
# Check for outdated packages
npm outdated

# Update patch/minor (safe)
npm update

# Major updates: check changelogs for breaking changes
npm install package@latest

# Audit for vulnerabilities
npm audit
npm audit fix
```

### License Compatibility
| License | Can Use? | Notes |
|---------|----------|-------|
| MIT | Yes | No restrictions |
| Apache-2.0 | Yes | Patent grant included |
| BSD-2/3 | Yes | Minimal restrictions |
| ISC | Yes | Simplified MIT |
| GPL-2.0/3.0 | Caution | Copyleft - may require open-sourcing |
| AGPL-3.0 | Caution | Network copyleft - server use triggers |
| SSPL | No | Too restrictive for most uses |
| Unlicensed | No | No legal protection |

## Code Smell Severity

| Smell | Severity | Action |
|-------|----------|--------|
| Duplicate code (3+) | High | Extract immediately |
| Function > 50 lines | High | Split this sprint |
| File > 300 LOC | Medium | Plan split in backlog |
| Deep nesting > 3 | Medium | Refactor when touching |
| Unused code | Low | Delete when noticed |
| Inconsistent naming | Low | Fix when touching file |
| Missing types | Low | Add when modifying function |
