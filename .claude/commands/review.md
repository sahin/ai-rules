# Code Review Guide

Use this guide when reviewing pull requests, conducting code reviews, or verifying feature completeness.

## Review Checklist

### Functional Correctness
- [ ] Code does what the PR description says
- [ ] Edge cases handled (empty inputs, nulls, boundaries)
- [ ] Error paths handled gracefully
- [ ] No regressions to existing functionality
- [ ] Business logic matches requirements

### Code Quality
- [ ] Functions < 50 lines, single responsibility
- [ ] No deep nesting (max 3 levels)
- [ ] No magic numbers/strings (use named constants)
- [ ] No duplicate code (DRY when seen 3+ times)
- [ ] Clear naming (intention-revealing, consistent)
- [ ] No unnecessary comments (code should be self-documenting)
- [ ] Follows project coding standards

### TypeScript
- [ ] No `any` types (use `unknown` if needed)
- [ ] Explicit return types on public functions
- [ ] Proper error types (not generic `Error`)
- [ ] Null safety (optional chaining, nullish coalescing)

### Security
- [ ] No hardcoded secrets, tokens, or credentials
- [ ] User input validated and sanitized
- [ ] SQL uses parameterized queries (no string concatenation)
- [ ] No XSS vectors (user content escaped on output)
- [ ] Auth/authz checks on protected endpoints
- [ ] Sensitive data not logged

### Performance
- [ ] No N+1 queries
- [ ] Appropriate indexes for new queries
- [ ] No unnecessary re-renders (React.memo, useMemo where needed)
- [ ] Large lists use virtualization
- [ ] Images optimized and lazy-loaded
- [ ] No blocking operations on main thread

### Testing
- [ ] Tests exist for new functionality
- [ ] Tests cover happy path and error cases
- [ ] Tests are independent (no shared state)
- [ ] Test names describe behavior ("should...")
- [ ] Mocks are minimal (prefer real implementations)

### Database
- [ ] Migrations have working rollback scripts
- [ ] New columns have appropriate defaults and constraints
- [ ] Foreign keys have indexes
- [ ] Schema changes are backward-compatible

## PR Requirements

### Size
- **Target**: < 400 lines changed
- **Split if**: > 400 lines, spans multiple features, or needs "and" in description
- **Exceptions**: auto-generated code, large refactors (discuss with team first)

### Description Format
```markdown
## What
Brief summary of changes.

## Why
Context and motivation.

## How
Technical approach taken.

## Testing
- What was tested
- How to verify

## Screenshots
(For UI changes)
```

### Before Requesting Review
- [ ] Self-reviewed all changes (read the diff)
- [ ] All CI checks passing
- [ ] No merge conflicts
- [ ] PR description filled out
- [ ] Linked to relevant issue/ticket
- [ ] Screenshots for UI changes

## Giving Feedback

### Tone
- Be kind and constructive
- Comment on the code, not the person
- Explain the "why" behind suggestions
- Acknowledge good work

### Severity Prefixes
```
[blocker] - Must fix before merge (bugs, security, breaking changes)
[suggestion] - Would improve quality but not required
[nit] - Minor style or preference issue
[question] - Seeking clarification, not requesting changes
```

### Examples
```
[blocker] This SQL query is vulnerable to injection. Use parameterized queries:
  `db.query('SELECT * FROM users WHERE id = $1', [userId])`

[suggestion] Consider extracting this into a custom hook to keep the component focused:
  `const { data, isLoading } = useOrderDetails(orderId);`

[nit] Prefer `const` over `let` here since the value is never reassigned.

[question] What happens if the API returns an empty array here?
```

## Feature Verification Checklist

### Functional Verification
- [ ] Feature works as specified in requirements
- [ ] All acceptance criteria met
- [ ] Works with real data (not just mock/test data)
- [ ] Handles slow network / timeout gracefully

### UI Verification
- [ ] Responsive: works on mobile, tablet, desktop
- [ ] Loading states shown for async operations
- [ ] Error states with user-friendly messages
- [ ] Empty states with helpful guidance
- [ ] No console errors or warnings
- [ ] Consistent with design system / existing UI

### Cross-Browser Testing
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

### Accessibility
- [ ] Keyboard navigable
- [ ] Screen reader compatible
- [ ] Color contrast meets WCAG AA
- [ ] Focus management correct for modals/dialogs

## Approval Criteria

### Must Have for Approval
- No open blockers
- All CI checks passing
- Tests exist for new functionality
- No security vulnerabilities
- Documentation updated (if API or behavior changed)

### Merge Strategy
- **Squash merge**: for feature branches (clean history)
- **Merge commit**: for release branches (preserve history)
- **Rebase**: for keeping up with main (before review)
