# Test Automation

## CI/CD Pipeline
1. **Pre-commit**: Unit tests for changed files
2. **Pull Request**: Full test suite
3. **Main Branch**: All tests including E2E
4. **Pre-deploy**: Performance and security
5. **Post-deploy**: Production smoke tests

## Smart Test Detection
```bash
# Automatic test discovery
npm run test:smart     # Detects affected tests
npm run test:changed   # Tests for git changes
```

## Test Caching
- Cache results by file hash
- Skip unchanged test suites
- Invalidate on dependency changes

## Execution Commands
```bash
npm test              # Watch mode
npm test:coverage     # Coverage check
npm test:ci          # CI pipeline
npm test:e2e         # E2E suite
```

## Build Validation
- TypeScript compilation must pass
- No ESLint errors in tests
- Coverage thresholds met
- All imports resolved