# Test Requirements

## Coverage Requirements
- **API Endpoints**: 100% coverage (non-negotiable)
- **UI Components**: 80% coverage minimum
- **Critical Logic**: 90% coverage required
- **Utilities**: 90% coverage required
- **Overall Project**: 80% statement coverage

## Testing Pyramid
```
    /E2E\     (10%) User journeys
   /-----\
  / API   \   (30%) Integration
 /---------\
/   Unit    \ (60%) Components
```

## Required Test Types
1. **Unit Tests**: Isolated function/component tests
2. **Integration Tests**: API and service interactions
3. **E2E Tests**: Complete user workflows
4. **Performance Tests**: Response time validation
5. **Security Tests**: Auth and input validation

## Test Quality Standards
- **Independent**: No test dependencies
- **Repeatable**: Consistent results
- **Self-Validating**: Clear pass/fail
- **Focused**: One behavior per test
- **Fast**: Quick feedback loops