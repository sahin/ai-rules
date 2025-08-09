# 🚀 CLAUDE SMART RULE ROUTER v2

**Note**: This router manages ALL rule files in the project. Rules are loaded dynamically based on task keywords rather than all being listed in CLAUDE.md.

## 🛑 MANDATORY READING ORDER
1. **workflow-before-starting.md** - Breaks your helpful instinct (200 tokens)
2. **workflow-plan-template.md** - Shows exact format (300 tokens)  
3. **This file** - Tells you which rules to load (500 tokens)

## 📊 SELF-ACCOUNTABILITY CHECK
Before proceeding, confirm:
- [ ] I read workflow-before-starting.md
- [ ] I read workflow-plan-template.md
- [ ] I will create a plan before ANY action
- [ ] I will wait for approval

If any unchecked → STOP and start over

## 🎯 DYNAMIC RULE LOADING SYSTEM

### 🔍 ALWAYS LOADED (Foundation Rules):
```bash
FOUNDATION_RULES=(
  "core-standards/core-workflow.md"              # Always needed
  "core-standards/coding-standards.md"           # Universal code patterns
  "core-standards/documentation-standards.md"     # Documentation requirements
  "current-code/overview.md"                      # Project context & setup
)
```

### 📦 CONDITIONAL RULE LOADING:

#### API KEYWORDS
Keywords: "API", "endpoint", "REST", "route", "request", "response"
```bash
ADD_RULES=(
  "general-policies/backend/api-design.md"          # API patterns
  "current-code/backend/fastapi.md"               # FastAPI specifics
  "general-policies/testing/implementation-guide.md" # API testing patterns
)
# Example: "Create an API endpoint" loads these + foundation rules
```

#### DATABASE KEYWORDS
Keywords: "database", "DB", "query", "SQL", "schema", "migration", "model"
```bash
ADD_RULES=(
  "general-policies/backend/database-schema.md"     # Database design
  "current-code/backend/database.md"              # Project database patterns
)
# Example: "Design database schema" loads these + foundation rules
```

#### REACT/COMPONENT KEYWORDS
Keywords: "component", "React", "hook", "state", "props", "render"
```bash
ADD_RULES=(
  "general-policies/frontend/web-development.md"    # UI/UX requirements
  "current-code/frontend/react-patterns.md"       # React patterns
  "general-policies/testing/implementation-guide.md" # Component testing patterns
)
# Example: "Build a React component" loads these + foundation rules
```

#### UI/DESIGN KEYWORDS
Keywords: "UI", "design", "style", "theme", "layout", "CSS", "responsive"
```bash
ADD_RULES=(
  "general-policies/frontend/web-development.md"    # UI/UX requirements
)
# Example: "Design a new UI theme" loads these + foundation rules
```

#### TYPESCRIPT KEYWORDS
Keywords: "TypeScript", "TS", "type", "interface", "generic", "typing", "strict", "type-check"
```bash
ADD_RULES=(
  "general-policies/frontend/typescript.md"         # TypeScript guide
  "general-policies/frontend/typescript-strict.md"  # Strict TypeScript patterns
  "core-standards/typescript-policy.md"          # TypeScript policy
)
# Example: "Fix TypeScript errors" loads these + foundation rules
```

#### TESTING KEYWORDS (Specific Types)
Keywords: "test", "testing", "coverage", "TDD"
```bash
ADD_RULES=(
  "general-policies/testing/core-standards.md"      # Testing philosophy & requirements
  "general-policies/testing/implementation-guide.md" # Practical patterns
  "testing/smart-testing.md"                  # Smart testing commands
)
# Example: "Write tests for new feature" loads these + foundation rules
```

Keywords: "unit test", "jest", "mock", "spy", "component test"
```bash
ADD_RULES=(
  "general-policies/testing/core-standards.md"      # Testing philosophy
  "general-policies/testing/implementation-guide.md" # Unit & component patterns
)
# Example: "Write unit tests for user service" loads these + foundation rules
```

Keywords: "e2e", "playwright", "integration test", "browser test"
```bash
ADD_RULES=(
  "general-policies/testing/e2e-playwright.md"      # E2E patterns
  "general-policies/testing/core-standards.md"      # Testing philosophy
  "testing/smart-testing.md"                  # Smart testing commands
)
# Example: "Create e2e tests for login flow" loads these + foundation rules
```

#### PROJECT-SPECIFIC TESTING KEYWORDS (see project router)
Keywords: "project test", "multi-tenant", "isolation"
```bash
ADD_RULES=(
  "general-policies/testing/core-standards.md"      # Testing philosophy
)
# Project-specific rule loading lives in current-code/workflow-rule-router.project.md
```

#### SECURITY KEYWORDS
Keywords: "auth", "authentication", "security", "permission", "JWT", "token", "login", "registration", "input validation", "XSS", "SQL injection", "secrets", "CORS", "CSRF"
```bash
ADD_RULES=(
  "general-policies/backend/security.md"            # Security standards & checklist
  "current-code/backend/security.md"              # Project security
)
# Example: "Add user authentication" loads these + foundation rules
```

#### GIT/VERSION CONTROL KEYWORDS
Keywords: "git", "commit", "branch", "merge", "PR", "pull request", "version control", "repository"
```bash
ADD_RULES=(
  "general-policies/ops/git-workflow.md"            # Git workflow & standards
)
# Example: "Create a pull request" loads these + foundation rules
```

#### DEPLOYMENT KEYWORDS
Keywords: "deploy", "CI/CD", "production", "build", "release"
```bash
ADD_RULES=(
  "general-policies/ops/deployment.md"              # Deployment standards
  "current-code/ops/deployment.md"                # Project deployment
  "general-policies/ops/git-workflow.md"            # Git workflow for deployments
)
```

#### PERFORMANCE KEYWORDS  
Keywords: "performance", "optimize", "slow", "cache", "speed", "performance budget", "bundle size"
```bash
ADD_RULES=(
  "general-policies/ops/performance.md"             # Performance standards & budgets
  "current-code/ops/performance.md"               # Project performance
)
```

#### CODE QUALITY KEYWORDS
Keywords: "refactor", "refactoring", "technical debt", "code smell", "anti-pattern", "clean code"
```bash
ADD_RULES=(
  "general-policies/refactoring.md"                 # Refactoring guidelines
  "general-policies/anti-patterns.md"               # Anti-patterns to avoid
)
# Example: "Refactor user service" loads these + foundation rules
```

#### DEPENDENCIES KEYWORDS
Keywords: "dependency", "dependencies", "package", "npm", "library", "third-party", "security audit"
```bash
ADD_RULES=(
  "general-policies/dependencies.md"                # Dependency management
)  
# Example: "Add new package dependency" loads these + foundation rules
```

#### MONITORING/OBSERVABILITY KEYWORDS
Keywords: "monitoring", "observability", "logging", "metrics", "alerts", "health check", "tracing"
```bash
ADD_RULES=(
  "general-policies/ops/observability.md"           # Observability standards
)
# Example: "Add logging to service" loads these + foundation rules
```

#### ROLLBACK/IDEMPOTENCY KEYWORDS  
Keywords: "rollback", "idempotent", "idempotency", "migration", "database migration", "deployment rollback"
```bash
ADD_RULES=(
  "general-policies/ops/idempotency.md"             # Idempotency & rollback rules
)
# Example: "Create database migration" loads these + foundation rules
```

#### ARCHITECTURE KEYWORDS
Keywords: "architecture", "design decision", "ADR", "architecture decision", "system design"
```bash
ADD_RULES=(
  "core-standards/decision-records.md"           # Architecture Decision Records
)
# Example: "Document architecture decision" loads these + foundation rules
```

#### DOCUMENTATION KEYWORDS
Keywords: "documentation", "docs", "README", "markdown", ".md", "report", "analysis", "summary", "guide", "manual"
```bash
ADD_RULES=(
  "core-standards/documentation-standards.md"    # Documentation requirements & file placement
)
# Example: "Create analysis report" loads these + foundation rules
# Example: "Write documentation for API" loads these + foundation rules
```

#### FEATURE COMPLETION KEYWORDS
Keywords: "feature complete", "mark complete", "done", "verification", "feature verification", "manual testing", "localhost testing"
```bash
ADD_RULES=(
  "general-policies/feature-verification.md"        # Feature completion verification
)
# Example: "Mark feature as complete" loads these + foundation rules
```

#### CONTINUOUS WORK KEYWORDS
Keywords: "continuous work", "work loop", "batch process", "run loop", "work session", "keep working", "continue until"
```bash
ADD_RULES=(
  "general-policies/ops/continuous-work-loop.md"    # Continuous work methodology
)
# Example: "Run a work loop until I stop" loads these + foundation rules
```

#### TODO-DRIVEN WORKFLOW KEYWORDS
Keywords: "todo", "task", "plan", "workflow", "todo file", "task manager", "high roi", "minimum loc", "playwright first"
```bash
ADD_RULES=(
  "general-policies/todo-driven-workflow.md"        # Todo-driven development workflow
  "workflow-architecture.md"  # Complete workflow visualization
  "general-policies/high-roi-development.md"        # High ROI strategy and patterns
  "general-policies/testing/playwright-first.md"    # User-first testing approach
)
# Example: "Create todo from this plan" loads these + foundation rules
# Example: "Show me the workflow" loads these + foundation rules
# Example: "Use high ROI approach" loads these + foundation rules
```

#### CODE REVIEW KEYWORDS
Keywords: "review", "PR", "pull request", "merge"
```bash
ADD_RULES=(
  "general-policies/ops/code-review.md"             # Review standards
  "current-code/ops/code-review.md"               # Project review
  "general-policies/feature-verification.md"        # Verification before review
)
```

## 🧠 SMART LOADING ALGORITHM

The router automatically:
1. **Starts with** foundation rules (always loaded)
2. **Scans** user message for keywords
3. **Adds** relevant rule sets based on matches
4. **Removes** duplicates
5. **Loads** minimal set needed for the task

## 🚨 VIOLATION CONSEQUENCES
Each violation gets logged:
```
VIOLATION LOG:
- Skipped plan: ❌ [timestamp]
- Started coding first: ❌ [timestamp]
- Ignored approval: ❌ [timestamp]
```

## ✅ SUCCESS METRICS
Track your compliance:
```
SUCCESS LOG:
- Created plan first: ✅ [timestamp]
- Waited for approval: ✅ [timestamp]
- Loaded correct rules: ✅ [timestamp]
```

## 💡 QUICK REFERENCE
- Plan format location: `workflow-plan-template.md`
- Testing requirements: `general-policies/testing/core-standards.md`
- Project overview: `current-code/overview.md`
- All rules directory: `.cursor/rules/`

Remember: Load ONLY what's needed - Being efficient means loading the RIGHT rules, not ALL rules




