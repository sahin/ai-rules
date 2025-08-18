# Playwright Testing Strategy

Test from user perspective first, building features that work for real users.

## Core Philosophy

### Playwright-First Approach
```markdown
1. Write E2E test describing user behavior
2. Run test (it fails - no code yet)
3. Build minimal code to pass test
4. Refactor and optimize
5. Add unit tests for complex logic
6. Mark feature complete

NEVER mark feature complete without E2E test passing.
```

## User Story Translation

### From Story to Test
```markdown
USER STORY:
"As a user, I want to view system status"

E2E TEST:
1. Login as user
2. Navigate to dashboard
3. Verify status widgets visible
4. Check data displays correctly
5. Confirm alerts show
6. Verify user can take action
```

## Test-First Benefits
- Forces thinking from user perspective
- Catches integration issues early
- Documents expected behavior
- Prevents feature regression
- Ensures features actually work

## When to Write E2E Tests

### Always Test
- User authentication flows
- Critical business workflows
- Data management (CRUD)
- Payment processes
- Multi-step forms

### Can Skip E2E
- Pure utility functions
- Internal APIs not user-facing
- Static content pages
- Dev-only tools

## Test Organization
```
tests/e2e/
├── auth/         # Authentication flows
├── dashboard/    # Dashboard features
├── settings/     # Settings management
└── fixtures/     # Shared test data
```