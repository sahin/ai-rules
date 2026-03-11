# Testing Requirements

## Coverage Targets
- API endpoints: 100% (non-negotiable)
- UI components: 80% minimum
- Critical business logic: 90%
- Overall project: 80% statement coverage

## Test Pyramid
- 60% unit tests (components, functions, isolated logic)
- 30% integration tests (API, services, database)
- 10% E2E tests (complete user workflows)

## Standards
- Pattern: Arrange-Act-Assert (AAA) for all tests
- Naming: start with "should" or use "when/then" format
- Co-location: `Component.test.tsx` next to `Component.tsx`
- Independence: no test should depend on another test's state
- Determinism: tests must produce consistent results

## Before Delivery
- All tests passing (unit, integration, E2E)
- Build succeeds without errors
- No console errors in browser
- Feature works as specified in requirements
- Error states and edge cases handled

## What to Test
- Always: public APIs, edge cases, error paths, business logic, state changes
- Never: implementation details, private methods, framework internals
- Focus: behavior over implementation, user perspective over developer perspective
