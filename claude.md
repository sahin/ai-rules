# Claude Code Rules

Generic, reusable rules and skills for Claude Code. Designed to work as a git submodule across projects.

## Always-Loaded Rules (`.claude/rules/`)

These load into every conversation (~550 lines total):

| File | Covers |
|------|--------|
| `coding-standards.md` | File naming, size limits, imports, error handling, TypeScript, anti-patterns |
| `testing-requirements.md` | Coverage targets, test pyramid, AAA pattern, before-delivery checklist |
| `api-security-standards.md` | REST design, HTTP status codes, input validation, auth, OWASP top 10 |
| `database-standards.md` | Naming, required columns, constraints, migrations, query performance |
| `git-standards.md` | Branch naming, conventional commits, PR guidelines |
| `project-standards.md` | File organization, docs placement, frontend requirements, env config |

## On-Demand Skills (`.claude/commands/`)

Zero context cost until invoked. Use `/command` to load:

| Command | Guide |
|---------|-------|
| `/test` | Testing: unit, integration, E2E, Playwright, coverage, CI/CD |
| `/api` | API development: REST patterns, pagination, versioning, monitoring |
| `/db` | Database: migrations, indexes, query optimization, rollback |
| `/frontend` | Frontend: components, responsive design, a11y, performance budgets |
| `/deploy` | Deployment: CI/CD pipeline, strategies, health checks, logging |
| `/review` | Code review: checklist, PR requirements, feedback, verification |
| `/adr` | Architecture Decision Records: template, lifecycle, examples |
| `/perf` | Performance: response targets, caching, load testing with k6 |
| `/refactor` | Refactoring: patterns, process, dependency evaluation |
| `/security` | Security: OWASP checklist, incident response, SAST/DAST |

## Notes

- Plan mode and TodoWrite are native Claude Code features (no custom enforcement needed)
- Project-specific rules belong in the consuming project's `.claude/rules/`, not here
