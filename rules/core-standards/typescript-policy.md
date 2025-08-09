# TypeScript Policy

## Pragmatic Approach
Balance type safety with development velocity.

## Development Standards

### New Code Requirements
- Fully typed (no implicit any)
- Explicit function return types
- Proper interface definitions
- Documented type exports

### Legacy Code Approach
- Improve types when modifying files
- Don't block features for perfect types
- Track improvement metrics
- Apply Boy Scout Rule

## Error Thresholds

### Production
- Critical errors: 0 (security, runtime)
- Type errors: <500 allowed
- Trend: Must decrease each sprint
- New code: 90% type coverage

### Development
- Type errors are warnings
- Focus on functionality first
- Build doesn't block on types
- Gradual improvement encouraged

## Acceptable Type Issues
- Third-party library mismatches
- Complex generic scenarios  
- Legacy code transitions
- Unused variable warnings

## Unacceptable Issues
- Security vulnerabilities
- Runtime crash risks
- Data corruption potential
- API contract violations

## Improvement Strategy
## Levels

### Required (default)
- Follow this policy as the canonical baseline across repos
- See strict profile for opt-in tightening

### Strict profile (opt-in)
- Use `general-policies/frontend/typescript-strict.md` for strict flags and patterns
- Enable via project `tsconfig` and ESLint preset switch

- Allocate 20% sprint time to type debt
- Monitor error trends
- Target: -10 to -20 errors per sprint
- Celebrate incremental progress