# 🚀 CLAUDE SMART RULE ROUTER v3 (Hook-Automated)

**🎯 AUTOMATED**: UserPromptSubmit hook now auto-loads rules based on keywords.
No manual rule checking needed - this file is for reference only.

## 📡 HOW HOOK AUTOMATION WORKS
1. **You type a message** → Hook scans for keywords
2. **Keywords detected** → Relevant rules auto-loaded
3. **No keywords found** → Foundation rules only (core-workflow, coding-standards, documentation)
4. **You see status** → Plan shows "Rules auto-loaded: X rules based on keywords: [list]"

## ⚠️ HOOK FEEDBACK EXAMPLES
- **With keywords**: "Rules auto-loaded: 5 rules based on keywords: API, testing"
- **Without keywords**: "No keywords detected - using foundation rules only"
- **Always loaded**: core-workflow.md, coding-standards.md, documentation-standards.md

## 🔗 PROJECT-SPECIFIC RULES
For project-specific rule loading, see: `project/workflow-rule-router.project.md`
This router handles universal rules only. Project-specific implementations are loaded separately.

## 🎯 DYNAMIC RULE LOADING SYSTEM

### 🔍 ALWAYS LOADED (Foundation Rules):
```bash
FOUNDATION_RULES=(
  "core-standards/core-workflow.md"              # Always needed
  "core-standards/coding-standards.md"           # Universal code patterns
  "core-standards/documentation-standards.md"     # Documentation requirements
)
```

### 📦 CONDITIONAL RULE LOADING:

#### API KEYWORDS (🚨 100% TEST COVERAGE REQUIRED)
Keywords: "API", "endpoint", "REST", "route", "request", "response", "backend", "FastAPI"
```bash
ADD_RULES=(
  "general-policies/backend/api-design.md"          # API patterns + 100% testing requirements
  "general-policies/testing/implementation-guide.md" # API testing patterns
  # Additional API patterns as needed
)
# Example: "Create an API endpoint" loads these + foundation rules
# CRITICAL: Task is NOT complete without 100% test coverage
```

#### DATABASE KEYWORDS
Keywords: "database", "DB", "query", "SQL", "schema", "migration", "model"
```bash
ADD_RULES=(
  "general-policies/backend/database-schema.md"     # Database design
)
# Example: "Design database schema" loads these + foundation rules
```

#### REACT/COMPONENT KEYWORDS
Keywords: "component", "React", "hook", "state", "props", "render"
```bash
ADD_RULES=(
  "general-policies/frontend/web-development.md"    # UI/UX requirements
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
  "core-standards/typescript-policy.md"          # TypeScript policy (consolidated)
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
# Project-specific rule loading lives in project/workflow-rule-router.project.md
```

#### SECURITY KEYWORDS
Keywords: "auth", "authentication", "security", "permission", "JWT", "token", "login", "registration", "input validation", "XSS", "SQL injection", "secrets", "CORS", "CSRF"
```bash
ADD_RULES=(
  "general-policies/backend/security.md"            # Security standards & checklist
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
  "general-policies/ops/git-workflow.md"            # Git workflow for deployments
)
```

#### PERFORMANCE KEYWORDS  
Keywords: "performance", "optimize", "slow", "cache", "speed", "performance budget", "bundle size"
```bash
ADD_RULES=(
  "general-policies/ops/performance.md"             # Performance standards & budgets
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
  "testing/always-test-before-delivery.md"          # Mandatory pre-delivery testing
)
# Example: "Mark feature as complete" loads these + foundation rules
```

#### DELIVERY/COMPLETION KEYWORDS
Keywords: "working", "ready", "delivered", "finished", "complete", "success", "it works", "all set"
```bash
ADD_RULES=(
  "testing/always-test-before-delivery.md"          # MANDATORY pre-delivery verification
  "general-policies/feature-verification.md"        # Feature completion checklist
)
# Example: "The feature is now working" loads these + foundation rules
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
  "general-policies/feature-verification.md"        # Verification before review
)
```

#### CONFIGURATION KEYWORDS
Keywords: "env", "environment", "config", "configuration", ".env", "settings"
```bash
ADD_RULES=(
  "general-policies/ops/environment-configs.md"     # Environment configuration standards
)
# Example: "Configure environment variables" loads these + foundation rules
```

#### PROJECT STRUCTURE KEYWORDS
Keywords: "file structure", "folder structure", "project structure", "directory structure", "monorepo", "workspace", "package", "organize"
```bash
ADD_RULES=(
  "general-policies/ops/monorepo-hygiene.md"        # Monorepo and project structure standards
  "core-standards/documentation-standards.md"       # File placement standards
)
# Example: "Organize the project structure" loads these + foundation rules
```

## 🧠 KEYWORD DETECTION (Reference)

The hook automatically detects and loads rules for:
- **API/REST** → api-design.md, implementation-guide.md  
- **Database/SQL** → database-schema.md
- **React/Component** → web-development.md, implementation-guide.md
- **Testing** → core-standards.md, smart-testing.md
- **Security/Auth** → security.md
- **Deploy/CI/CD** → deployment.md, git-workflow.md

See keyword mappings below for complete list.

## 📊 AUTOMATION METRICS
Hooks now track automatically:
- Rules loaded per session
- Keywords detected
- Test execution after changes
- Auto-commits at session end
- Compliance with plan-first workflow

Check `.claude/metrics/` for session data.

## 💡 QUICK REFERENCE
- **Hook configs**: `.claude/hooks/user-prompt-submit.sh`
- **Plan template**: `_mandatory/01-workflow-plan-template.md`  
- **Metrics tracking**: `.claude/metrics/sessions.log`
- **Manual override**: Can still reference specific rules if needed

**Remember**: Hooks handle the heavy lifting - focus on creating quality plans!




