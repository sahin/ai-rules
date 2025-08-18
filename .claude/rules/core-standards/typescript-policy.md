# TypeScript Policy

## Pragmatic Approach
Balance type safety with development velocity.

## Development Standards

### New Code Requirements
- Fully typed (no implicit any)
- Explicit function return types
- Proper interface definitions
- Documented type exports

### Legacy Code Approach
- Improve types when modifying files
- Don't block features for perfect types
- Track improvement metrics
- Apply Boy Scout Rule

## Error Thresholds

### Production
- Critical errors: 0 (security, runtime)
- Type errors: <500 allowed
- Trend: Must decrease each sprint
- New code: 90% type coverage

### Development
- Type errors are warnings
- Focus on functionality first
- Gradual improvement over perfection

## ESLint Configuration

### Pragmatic .eslintrc.js Settings:
```javascript
module.exports = {
  extends: [
    '@typescript-eslint/recommended',
  ],
  rules: {
    // PRAGMATIC: Change these from "error" to "warn"
    "@typescript-eslint/no-explicit-any": "warn",           // Allow any in legacy code
    "@typescript-eslint/no-unused-vars": "warn",            // Warn, don't block
    "@typescript-eslint/no-unsafe-assignment": "warn",      // Gradual improvement
    "@typescript-eslint/no-unsafe-member-access": "warn",   // Legacy code friendly
    "@typescript-eslint/no-unsafe-call": "warn",            // Allow for migration
    "@typescript-eslint/no-unsafe-return": "warn",          // Gradual typing
    
    // KEEP AS ERRORS: Security and critical issues
    "@typescript-eslint/no-var-requires": "error",          // Security: proper imports
    "no-eval": "error",                                      // Security: no eval
    "no-implied-eval": "error",                             // Security: no implied eval
    "@typescript-eslint/no-non-null-assertion": "error",    // Runtime safety
    
    // NEW CODE STANDARDS: Strict for new files
    "@typescript-eslint/explicit-function-return-type": ["warn", {
      "allowExpressions": true,
      "allowTypedFunctionExpressions": true
    }]
  },
  
  // PRAGMATIC: Separate rules for new vs legacy code
  overrides: [
    {
      // STRICT: New code files (created after this policy)
      files: ["**/*.new.ts", "**/*.new.tsx", "**/new-features/**/*"],
      rules: {
        "@typescript-eslint/no-explicit-any": "error",
        "@typescript-eslint/no-unused-vars": "error",
        "@typescript-eslint/explicit-function-return-type": "error"
      }
    }
  ]
};
```

## TypeScript Configuration

### Pragmatic tsconfig.json:
```json
{
  "compilerOptions": {
    "strict": true,                    // Keep strict mode
    "noImplicitAny": false,           // PRAGMATIC: Allow implicit any in legacy
    "strictNullChecks": true,         // Keep for safety
    "strictFunctionTypes": true,      // Keep for safety
    "noUnusedLocals": false,          // PRAGMATIC: Don't block on unused vars
    "noUnusedParameters": false,      // PRAGMATIC: Don't block on unused params
    "noImplicitReturns": false,       // PRAGMATIC: Allow implicit returns
    
    // KEEP STRICT: Critical safety features
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    
    // Build options
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

### Strict Profile (for new projects/modules):
```json
{
  "compilerOptions": {
    // ALL STRICT FLAGS ENABLED
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
    "noImplicitOverride": true
  }
}
```

## Development Workflow

### For New Features:
```typescript
// ✅ REQUIRED: New code must be properly typed
export function createUser(userData: CreateUserDto): Promise<User> {
  // All parameters and return types explicit
  return userService.create(userData);
}
```

### For Legacy Files:
```typescript
// ⚠️ LEGACY: Fix types opportunistically
function legacyFunction(data: any) { // TODO: Type this when refactoring
  // When you touch this file, gradually improve types
  const typedData = data as UserData; // Small improvements OK
  return processUser(typedData);
}
```

### Boy Scout Rule:
```typescript
// BEFORE: Working in legacy file
function updateUser(id, data) { // No types
  return database.update(id, data);
}

// AFTER: Applying Boy Scout Rule
function updateUser(id: number, data: Partial<User>): Promise<User> {
  return database.update(id, data);
}
```

## Error Tracking

### Health Check Script:
```bash
#!/bin/bash
# Count current errors
ERROR_COUNT=$(npx tsc --noEmit 2>&1 | grep -c "error TS")
echo "Current TypeScript errors: $ERROR_COUNT"

# Check against threshold
if [ "$ERROR_COUNT" -gt 500 ]; then
  echo "⚠️ WARNING: Error count ($ERROR_COUNT) exceeds threshold (500)"
else
  echo "✅ Error count within acceptable range"
fi
```

## Sprint Integration

### TypeScript Debt Stories:
- Reduce errors in target module by 50%
- No new errors introduced  
- Opportunistically improve types in touched files
- 20% of sprint capacity for gradual improvement

This policy balances type safety with development velocity through gradual improvement.