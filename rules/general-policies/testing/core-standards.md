# Universal Testing Core Standards

> Canonical principles. Strategy: `./playwright-first.md`. Implementation details: `./implementation-guide.md`. Project-specific deltas: `../../../current-code/testing/clarosfarm-tests.md`.

This document defines core testing principles, philosophy, and requirements applicable to all projects. For implementation details, see `implementation-guide.md`.

## 🧪 TESTING PHILOSOPHY

### Core Principles
1. **Test Behavior, Not Implementation**: Focus on what the code does, not how
2. **Test Early, Test Often**: Write tests alongside code development
3. **Fail Fast**: Quick feedback loops prevent bugs from propagating
4. **Comprehensive Coverage**: Test happy paths, edge cases, and error scenarios
5. **Maintainable Tests**: Tests should be as clean as production code

### Testing Pyramid
```
         /\
        /E2E\      (5-10%) - User journeys
       /------\
      /  API   \   (20-30%) - Integration tests
     /----------\
    /   Unit     \ (60-70%) - Component/function tests
   /--------------\
```

## 📊 COVERAGE REQUIREMENTS

### Minimum Coverage Targets
- **Overall Project**: 80% statement coverage
- **Critical Business Logic**: 90% coverage required
- **API Endpoints**: 95% coverage required
- **UI Components**: 85% coverage required
- **Utility Functions**: 90% coverage required

### Coverage Configuration
```javascript
module.exports = {
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 75,
      functions: 80,
      lines: 80
    },
    './src/core/': {
      statements: 90  // Higher coverage for critical code
    }
  }
};
```

## 🎯 TESTING REQUIREMENTS

### Required Test Types
1. **Unit Tests**: Test individual functions and components in isolation
2. **Integration Tests**: Test component interactions and API endpoints
3. **E2E Tests**: Test complete user workflows
4. **Performance Tests**: Validate response times and resource usage
5. **Security Tests**: Verify authentication, authorization, input validation

### Test Quality Standards
- **Independent**: Tests should not depend on each other
- **Repeatable**: Same result every time
- **Self-Validating**: Clear pass/fail without manual inspection
- **Timely**: Written close to production code
- **Focused**: Each test verifies one behavior

## 🔍 WHAT TO TEST

### Always Test
- **Public APIs**: All public methods and functions
- **Edge Cases**: Boundary conditions and limits
- **Error Handling**: Exception scenarios and error paths
- **State Changes**: Data mutations and side effects
- **Business Rules**: Critical domain logic
- **Security Boundaries**: Authentication and authorization

### Testing Checklist
- [ ] Happy path scenarios work correctly
- [ ] Error cases handled gracefully
- [ ] Edge cases behave as expected
- [ ] Performance meets requirements
- [ ] Security vulnerabilities addressed
- [ ] Accessibility requirements met
- [ ] Cross-browser compatibility verified

## 📐 TEST STRUCTURE

### Arrange-Act-Assert Pattern
```javascript
describe('Feature', () => {
  it('should behave correctly', () => {
    // Arrange - Set up test data and conditions
    const input = { value: 10 };
    
    // Act - Execute the behavior
    const result = calculateTotal(input);
    
    // Assert - Verify the outcome
    expect(result).toBe(10);
  });
});
```

### Test Naming Conventions
- **Descriptive**: `should calculate total with tax when tax rate provided`
- **Behavior-focused**: Start with "should" or "when/then"
- **Specific**: Include input conditions and expected outcomes

## 🚀 CONTINUOUS TESTING

### Test Automation Pipeline
1. **Pre-commit**: Run unit tests for changed files
2. **Pull Request**: Run full test suite
3. **Main Branch**: Run all tests including E2E
4. **Pre-deployment**: Performance and security tests
5. **Post-deployment**: Smoke tests in production

### Test Execution Strategy
```bash
# Development
npm test                 # Run tests in watch mode
npm test:coverage       # Check coverage locally

# CI/CD Pipeline
npm test:ci             # Run all tests once
npm test:e2e            # Run E2E tests
npm test:performance    # Run performance tests
```

## 🏗️ BUILD VALIDATION

### Critical Build Checks
- **Type Safety**: TypeScript compilation must pass
- **Linting**: No ESLint errors in test files
- **Import Resolution**: All imports must resolve
- **Test Discovery**: All test files must be found
- **Coverage Reporting**: Coverage reports must generate

### Build Validation Commands
```bash
npm run build           # Validate production build
npm run type-check      # TypeScript validation
npm run lint:test       # Lint test files
npm run test:build      # Test the built artifacts
```

## 📋 TEST PLANNING

### Test Plan Components
1. **Scope**: What features/changes need testing
2. **Approach**: Types of tests required
3. **Resources**: Time and tools needed
4. **Schedule**: Testing timeline
5. **Risks**: Potential testing challenges

### Test Estimation
- **Unit Tests**: 30-50% of development time
- **Integration Tests**: 20-30% of development time
- **E2E Tests**: 10-20% of development time
- **Test Maintenance**: 10-15% ongoing effort

## 🎖️ TESTING BEST PRACTICES

### Do's
- ✅ Write tests first (TDD) when possible
- ✅ Keep tests simple and focused
- ✅ Use descriptive test names
- ✅ Test one thing at a time
- ✅ Clean up test data after tests
- ✅ Use test fixtures for common data
- ✅ Mock external dependencies

### Don'ts
- ❌ Test implementation details
- ❌ Write brittle tests that break easily
- ❌ Ignore flaky tests
- ❌ Skip tests to meet deadlines
- ❌ Test private methods directly
- ❌ Use production data in tests
- ❌ Leave console.logs in tests

## 🔧 TEST MAINTENANCE

### Keeping Tests Healthy
- **Regular Reviews**: Audit test quality quarterly
- **Refactor Tests**: Keep tests clean as code evolves
- **Update Coverage**: Adjust targets as needed
- **Fix Flaky Tests**: Address intermittent failures immediately
- **Remove Obsolete Tests**: Delete tests for removed features

### Test Metrics to Track
- Test execution time
- Test failure rate
- Coverage trends
- Flaky test count
- Test maintenance effort

---

**Next Steps**: See `implementation-guide.md` for specific testing patterns and examples.