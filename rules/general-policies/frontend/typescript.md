# TypeScript Configuration Guide

> Canonical policy lives in `../../../core-standards/typescript-policy.md` (Required). Strict profile in `./typescript-strict.md`. This document is a migration/stub; prefer the canonical policy.

This document provides the recommended ESLint and TypeScript configurations to support the Pragmatic TypeScript Policy.

## 🔧 **ESLint Configuration**

### **Recommended `.eslintrc.js` Settings:**

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
    },
    {
      // LENIENT: Legacy code files
      files: ["**/legacy/**/*", "**/old-components/**/*"],
      rules: {
        "@typescript-eslint/no-explicit-any": "off",
        "@typescript-eslint/no-unused-vars": "off"
      }
    }
  ]
};
```

## 📊 **TypeScript Configuration**

### **Recommended `tsconfig.json` Updates:**

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
    "alwaysStrict": true
  },
  
  // PRAGMATIC: Don't fail build on errors, just warn
  "compileOnSave": false,
  
  // Include all files, even with errors
  "skipLibCheck": true
}
```

## 🎯 **Development Workflow**

### **For Developers:**

#### **Working on New Features:**
```typescript
// ✅ REQUIRED: New code must be properly typed
export function createUser(userData: CreateUserDto): Promise<User> {
  // All parameters and return types explicit
  return userService.create(userData);
}
```

#### **Working on Legacy Files:**
```typescript
// ⚠️ LEGACY: Fix types opportunistically
function legacyFunction(data: any) { // TODO: Type this when refactoring
  // When you touch this file, gradually improve types
  const typedData = data as UserData; // Small improvements OK
  return processUser(typedData);
}
```

#### **Boy Scout Rule Implementation:**
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

## 📈 **Error Tracking & Management**

### **Monitoring Script:**
```bash
#!/bin/bash
# scripts/typescript-health.sh

echo "📊 TypeScript Health Report"
echo "=========================="

# Count current errors
ERROR_COUNT=$(npx tsc --noEmit 2>&1 | grep -c "error TS")
echo "Current TypeScript errors: $ERROR_COUNT"

# Check against threshold
if [ "$ERROR_COUNT" -gt 500 ]; then
  echo "⚠️ WARNING: Error count ($ERROR_COUNT) exceeds threshold (500)"
  echo "Please prioritize TypeScript cleanup in next sprint"
else
  echo "✅ Error count within acceptable range"
fi

# Track trend (save to file for comparison)
echo "$ERROR_COUNT,$(date)" >> .typescript-errors.log
echo "📈 Error trend logged"
```

### **Git Pre-commit Hook:**
```bash
#!/bin/sh
# .git/hooks/pre-commit

# Only check that NEW code doesn't add errors
git diff --cached --name-only --diff-filter=A | grep -E '\.(ts|tsx)$' | while read file; do
  if [ -f "$file" ]; then
    echo "🔍 Checking new file: $file"
    npx tsc --noEmit "$file"
    if [ $? -ne 0 ]; then
      echo "❌ New TypeScript file has errors. Please fix before committing."
      exit 1
    fi
  fi
done
```

## 🎯 **Sprint Planning Integration**

### **TypeScript Debt Stories:**
```markdown
# User Story Template
**As a** developer
**I want** to reduce TypeScript errors in [module/component]
**So that** we improve code maintainability and catch more bugs

**Acceptance Criteria:**
- [ ] Reduce errors in target module by 50%
- [ ] No new errors introduced
- [ ] Tests still pass
- [ ] Functionality unchanged

**Effort:** 2 story points (20% of sprint capacity)
```

### **Definition of Done Updates:**
```markdown
## Definition of Done - Updated

### For New Features:
- [ ] All new code properly typed (no `any` usage)
- [ ] TypeScript builds without NEW errors
- [ ] Function signatures have explicit return types

### For Bug Fixes:
- [ ] Fix doesn't introduce new TypeScript errors
- [ ] Opportunistically improve types in touched files
- [ ] Document any remaining technical debt

### For Refactoring:
- [ ] Significant reduction in TypeScript errors
- [ ] Improved type safety in refactored areas
- [ ] Legacy code patterns updated where possible
```

This configuration supports gradual improvement while maintaining productivity and code quality!