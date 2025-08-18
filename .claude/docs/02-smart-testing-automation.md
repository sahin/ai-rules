# Rule 02: Smart Testing Automation

## 🎯 Core Principle
**MANDATORY**: Use intelligent test detection to run only affected tests, achieving 90% time savings while maintaining quality.

## 📋 Rule Definition
- Always use `npm run test:smart` instead of full test suites
- Tests are automatically triggered by file changes
- Change detection maps files to specific test requirements
- No blind "test everything" execution

## 🔍 Enforcement Mechanism
```
PostToolUse Hook → Smart test execution
├─ git diff analysis → Maps changed files
├─ Impact detection → Identifies affected tests
├─ Selective execution → Runs only required tests
└─ Results reporting → Shows pass/fail status
```

## 🎯 Change Detection Matrix
```yaml
File Types → Test Strategy:
  "*.tsx routes": ["E2E tests", "Visual baselines"]
  "*.tsx components": ["Unit tests", "Component tests"]
  "*.py routes": ["API tests", "Integration tests"]
  "*.ts utils": ["Unit tests only"]
  "package.json": ["Full test suite"]
```

## 📊 Smart Commands
```bash
npm run test:smart:dry     # Preview what will run
npm run test:smart         # Execute affected tests
npm run test:smart:unit    # Unit tests only
npm run test:smart:e2e     # E2E tests only
```

## 🚫 Banned Commands
- `npm run test` (runs everything)
- `npm run test:unit` (runs all units)
- `npm run test:e2e` (runs all E2E)

## ✅ Performance Gains
- **90% faster execution**: 15 seconds vs 3 minutes
- **Targeted feedback**: Only relevant failures
- **Resource efficiency**: Minimal CI usage
- **Developer focus**: Clear error scope

## 🎭 Hook Integration
- **PostToolUse**: Automatic test triggering
- **PreToolUse**: Test readiness validation
- **Stop**: Final test validation

## 💡 Intelligence Features
- Dependency impact analysis
- Route-to-test mapping
- Component usage tracking
- Critical path detection

---
*Smart testing is not optional - it's the required way to validate changes.*