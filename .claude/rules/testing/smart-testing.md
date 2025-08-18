# Smart Testing Rule

## 🎯 MANDATORY: Use Smart Testing for All Test Execution

### Core Principle
**ALWAYS use smart test detection to run only affected tests based on code changes.**

### Why This Matters
- **10x faster feedback** - Test only what changed (seconds vs minutes)
- **Resource efficiency** - Don't waste CI/CD resources
- **Developer experience** - Faster iteration cycles
- **Focused debugging** - See only relevant test failures

## 📋 Smart Testing Commands

### Primary Command (Use This First)
```bash
npm run test:smart       # Intelligently runs ALL affected tests (unit, integration, E2E)
```

### Preview Mode (Check Before Running)
```bash
npm run test:smart:dry   # Shows what tests would run without executing
```

### Specific Test Types
```bash
npm run test:smart:unit         # Only affected unit tests
npm run test:smart:integration  # Only affected integration tests  
npm run test:smart:e2e          # Only affected E2E tests
npm run e2e:smart               # Direct E2E smart runner
```

### Verbose/Debug Mode
```bash
npm run test:smart:verbose      # See detailed analysis of why tests are selected
```

### Force Full Test Run
```bash
npm run test:smart:all          # Override smart detection, run everything
```

## 🔍 How Smart Detection Works

### 1. Change Analysis
The system analyzes:
- Uncommitted changes (`git diff`)
- Staged changes (`git diff --cached`)
- Branch changes (`git diff main...HEAD`)

### 2. Impact Mapping

#### Direct Mappings
```javascript
'src/utils/typeGuards.ts' → 'src/utils/__tests__/typeGuards.test.ts'
'src/lib/api/client.ts' → 'src/lib/api/__tests__/client.test.ts'
```

#### Pattern Mappings
```javascript
'components/**/*.tsx' → Component tests
'hooks/*.ts' → Hook tests
'stores/*.ts' → Store tests
```

#### Dependency Analysis
```javascript
'lib/api/client.ts' changes → All integration tests run
'App.tsx' changes → All tests run (core file)
'main.tsx' changes → All tests run (core file)
```

#### Route Impact (E2E)
```javascript
'components/auth/**' → Tests /login, /signup, /register, /profile
'components/Dashboard/**' → Tests /, /gridstack-dashboard
'components/Settings/**' → Tests /settings
```

## 📊 Smart Test Categories

### Core Files (Trigger All Tests)
- `package.json`, `tsconfig.json`, `vite.config.ts`
- `App.tsx`, `main.tsx`
- `.env`, `.env.local`
- Route configuration files

### Isolated Changes (Trigger Specific Tests)
- Component files → Component tests only
- Utility functions → Unit tests only
- API endpoints → Integration tests only
- UI components → E2E tests for affected routes

## 🚫 BANNED: Non-Smart Testing

### ❌ DO NOT USE These Commands Directly
```bash
npm run test              # Runs ALL tests blindly
npm run test:unit         # Runs ALL unit tests
npm run test:integration  # Runs ALL integration tests
npm run e2e:routes        # Runs ALL E2E tests
```

### ✅ ALWAYS USE Smart Equivalents
```bash
npm run test:smart              # Instead of npm run test
npm run test:smart:unit         # Instead of npm run test:unit
npm run test:smart:integration  # Instead of npm run test:integration
npm run e2e:smart               # Instead of npm run e2e:routes
```

## 📈 Performance Comparison

| Scenario | Traditional | Smart Testing | Time Saved |
|----------|------------|---------------|------------|
| Auth component change | 3 min (all tests) | 20 sec (auth tests) | 89% |
| Utility function change | 3 min (all tests) | 5 sec (unit test) | 97% |
| Dashboard widget change | 3 min (all tests) | 30 sec (dashboard) | 83% |
| Core file change | 3 min (all tests) | 3 min (all tests) | 0% (correct) |

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
- name: Smart Test Execution
  run: |
    npm run test:smart --ci
```

### Pre-commit Hook
```bash
#!/bin/bash
npm run test:smart:dry
echo "Run 'npm run test:smart' to test affected code"
```

### PR Validation
```yaml
- name: PR Test Validation
  run: |
    # For PRs, only test changed code
    npm run test:smart
    
    # For main branch, full validation
    if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
      npm run test:smart:all
    fi
```

## 🎯 Usage Examples

### Example 1: Auth Component Change
```bash
# You edited: src/components/auth/LoginForm.tsx

npm run test:smart:dry
# Output: Will run 4 auth tests + 4 E2E routes

npm run test:smart
# Runs: auth unit tests + auth integration + auth E2E routes
# Time: 20 seconds (vs 3 minutes for all tests)
```

### Example 2: API Client Change
```bash
# You edited: src/lib/api/client.ts

npm run test:smart:dry
# Output: Will run all integration tests (API client is core)

npm run test:smart
# Runs: API client tests + all integration tests
# Time: 45 seconds (vs 3 minutes)
```

### Example 3: Type Guard Change
```bash
# You edited: src/utils/typeGuards.ts

npm run test:smart:dry
# Output: Will run typeGuards.test.ts only

npm run test:smart
# Runs: Just the type guard unit test
# Time: 5 seconds (vs 3 minutes)
```

## 🚨 Enforcement

### Self-Audit Questions
Before running tests:
1. "Am I using test:smart instead of test?"
2. "Did I check with --dry-run first?"
3. "Am I testing only what changed?"

### Rule Violations
If you run non-smart tests:
```
⚠️ WARNING: Using non-smart test execution
- Impact: Wasting 80-95% more time
- Solution: Use npm run test:smart instead
```

## 📝 Custom Mappings

To add custom test mappings, edit:
- `scripts/smart-test-detector.cjs` for unit/integration mappings
- `scripts/smart-e2e-test.cjs` for E2E route mappings

Example:
```javascript
// In smart-test-detector.cjs
TEST_MAPPINGS.direct['src/my-feature.ts'] = ['src/__tests__/my-feature.test.ts'];
```

## ✅ Summary

**MANDATORY RULES:**
1. ALWAYS use `test:smart` commands for testing
2. ALWAYS preview with `--dry-run` for unfamiliar changes
3. NEVER use traditional test commands directly
4. ALWAYS let smart detection determine test scope

**Benefits:**
- 10x faster test execution
- Focused, relevant feedback
- Reduced CI/CD costs
- Better developer experience

**Remember:** Smart testing is not optional - it's the required way to run tests in this project.