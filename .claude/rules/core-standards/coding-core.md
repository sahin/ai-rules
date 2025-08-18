# Core Coding Standards

Essential coding standards applicable to all projects.

## Code Quality Standards (MANDATORY)

### Code Consistency
- **Formatting**: Use automated formatters (Prettier, ESLint)
- **Naming**: Clear, descriptive names for variables, functions, classes
- **Organization**: Logical file and folder structure
- **Comments**: Document complex logic and business rules
- **Version control**: Meaningful commit messages

### Error Handling
- **Explicit handling**: Never ignore errors silently
- **Proper logging**: Log errors with context
- **User messages**: Display appropriate messages
- **Recovery**: Implement fallback behaviors
- **Boundaries**: Catch errors at appropriate levels

## Naming Conventions

### File Naming
- TypeScript/JS: `kebab-case` for files, `PascalCase` for components
- Python: `snake_case`
- Pattern: `<domain>.<role>.<ext>` (e.g., `auth.service.ts`)
- Avoid generic names (`utils.ts`, `helpers.ts`)

### Common Suffixes
- `.routes`, `.controller`, `.service`
- `.repo`, `.types`, `.validators`
- `.schema`, `.hook`, `.utils`, `.test`

## File Size Guidelines

### Single Responsibility Principle
One reason to change per file.

### Size Targets
- React component: 50-200 LOC
- Route/handler: 50-150 LOC
- Service/module: 150-300 LOC
- Test files: ≤300 LOC

### When to Split
- File spans multiple domains
- Adding third reusable helper
- Description needs "and/also"

## Import Organization
```typescript
// 1. Node modules
import React from 'react';

// 2. External packages
import { useQuery } from '@tanstack/react-query';

// 3. Internal modules
import { apiClient } from '@/lib/api';

// 4. Relative imports
import { Button } from './components';
```