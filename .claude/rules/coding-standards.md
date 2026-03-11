# Coding Standards

## File Naming
- Files: `kebab-case` (e.g., `user-service.ts`)
- Components: `PascalCase` (e.g., `UserProfile.tsx`)
- Pattern: `<domain>.<role>.<ext>` (e.g., `auth.service.ts`, `user.schema.ts`)
- Common suffixes: `.routes`, `.controller`, `.service`, `.repo`, `.types`, `.validators`, `.hook`, `.test`

## File Size Limits
- React component: 50-200 LOC
- Route/handler: 50-150 LOC
- Service/module: 150-300 LOC
- Test file: max 300 LOC
- Split when: file spans multiple domains, needs "and/also" in description, or has 3+ reusable helpers

## Import Organization
```typescript
// 1. Node built-ins
import path from 'path';
// 2. External packages
import { useQuery } from '@tanstack/react-query';
// 3. Internal modules (aliases)
import { apiClient } from '@/lib/api';
// 4. Relative imports
import { Button } from './components';
```

## Error Handling
- Never ignore errors silently - always handle or propagate
- Log errors with context (operation, userId, requestId)
- User-facing messages: specific but not technical, with actionable next steps
- Use error boundaries in React for component-level failures
- Async operations: always catch with proper cleanup
- Never expose stack traces or internal details to users

## TypeScript Policy
- **New code**: fully typed, explicit return types, no implicit `any`
- **Legacy code**: improve types when modifying files (Boy Scout Rule)
- **Threshold**: keep project-wide TS errors under 500, trending down
- **Critical errors**: security/runtime type issues fixed immediately
- Prefer type guards over type assertions
- Use `unknown` over `any`, optional chaining over verbose null checks

## Anti-Patterns to Avoid
- **God objects**: classes/components doing too much - split by responsibility
- **Magic numbers/strings**: use named constants
- **Deep nesting**: max 3 levels - use early returns
- **Long functions**: max 50 lines - extract focused methods
- **Duplicate code**: extract when seen 3+ times
- **Tight coupling**: use dependency injection and interfaces
- **Direct state mutation**: always use immutable updates in React
- **Missing hook dependencies**: include all deps in useEffect/useMemo/useCallback
- **Array index as key**: use stable unique IDs for dynamic lists
- **Memory leaks**: clean up event listeners, abort controllers, subscriptions in useEffect cleanup
