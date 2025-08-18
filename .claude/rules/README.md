# Rules Scopes and Conventions

## Scopes
- **General Policies**: Always applies across projects (base rules)
- **Core Standards**: Organization conventions (canonical policies)
- **Project**: Repository-specific deltas/overrides extending general-policies/foundation

## Extension Model
- Project docs must start with a banner: “Extends <path>; deltas only”
- General Policies docs are the base; Core Standards can define canonical policies
- Architecture visuals should link to canonical rules (no duplicate prose)

## Canonical Pointers
- Workflow: `general-policies/todo-driven-workflow.md`
- Approval: `_mandatory/02-approval-gate.md`
- TypeScript: `core-standards/typescript-policy.md` (Consolidated - includes strict profile)
- Testing: `general-policies/testing/core-standards.md` (principles) + `general-policies/testing/playwright-first.md` (strategy) + `testing/smart-testing.md` (execution)

## Routers
- General router: `workflow-rule-router.md` (generic, reusable)
- Project router: `project/workflow-rule-router.project.md` (project-specific extensions)
Load order: General first, then project router for domain deltas.

## Authoring Rules
- Add front-matter (id, title, scope, owner, last_reviewed)
- Update `rule-manifest.json` with scope and extends
- Prefer links over duplication; keep docs short and actionable


