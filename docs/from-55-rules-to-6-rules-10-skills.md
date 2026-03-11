# From 55 Rules to 6 Rules + 10 Skills: A 98% Context Reduction for Claude Code

## The Problem Nobody Talks About

Here's something most Claude Code users don't realize: **every file in `.claude/rules/` loads into every single conversation**. Every. Single. One.

When I started this project eight months ago, I had good intentions. I wanted comprehensive, well-organized rules that would make Claude follow best practices without being told. So I built a system of 55 rule files, neatly organized into directories:

```
.claude/rules/
  _mandatory/           (4 files - plan enforcement)
  core-standards/       (8 files - coding foundations)
  general-policies/
    backend/            (5 files - API, database, security)
    frontend/           (2 files - web, responsive)
    testing/            (11 files - every testing pattern imaginable)
    ops/                (11 files - git, deploy, monitoring, etc.)
    (7 more files)      (refactoring, dependencies, anti-patterns...)
  testing/              (4 files - more testing rules)
  agents/               (1 file - an AI agent that never worked)
  (5 more root files)   (manifest, router, workflow...)
```

~20,000 lines of rules. Loaded before Claude even reads your first message.

I was proud of this structure. It was organized. It was thorough. It covered everything from TypeScript naming conventions to Playwright visual regression testing to PostgreSQL migration safety to Kubernetes deployment strategies.

It was also a disaster I didn't see coming.

## The Math That Changed Everything

Claude Code has a context window. It's large -- but finite. Every token in that window is a resource. And resources you spend on instructions are resources you can't spend on understanding code, reasoning about problems, or generating solutions.

Here's what my "comprehensive" rules were actually doing:

| What | Lines | Context Cost |
|------|-------|-------------|
| 55 rule files | ~20,000 | Loaded into EVERY conversation |
| CLAUDE.md | 99 | Also loaded every time |
| User's actual code | ??? | Whatever's left |
| Claude's reasoning space | ??? | Whatever's left after that |

Think about what that means in practice. When a user asks Claude to "fix the login button", before Claude can even look at the button component, it has already consumed a massive chunk of its context window reading about:

- Zero-downtime PostgreSQL migration patterns
- Playwright Page Object Model structures
- Kubernetes canary deployment strategies
- WCAG 2.1 AA accessibility compliance checklists
- k6 load testing configuration templates
- ADR (Architecture Decision Record) templates
- API versioning header negotiation strategies

None of that is relevant to fixing a login button. But it's all loaded. Every time.

I was burning the majority of Claude's useful context on rules that were mostly reference material -- code examples, configuration templates, checklists, migration patterns. Content that's valuable maybe 5% of the time, but loaded 100% of the time.

It's like carrying an entire library in your backpack because you *might* need to look something up. You can barely walk, but hey -- at least you have that obscure book on Kubernetes networking if you ever need it.

## How It Got This Bad

This didn't happen overnight. It was a slow accumulation driven by a reasonable-sounding logic:

**Month 1**: "Claude keeps writing tests without the AAA pattern. I'll add a testing standards file."

**Month 2**: "The tests are better, but Claude doesn't know our Playwright configuration. Let me add a Playwright patterns file. And an E2E testing file. And a visual regression file."

**Month 3**: "Claude wrote a raw SQL query without parameterization. I need a security rules file. And while I'm at it, an API design file for RESTful conventions."

**Month 4**: "We need database migration safety rules. And a deployment checklist. And observability standards. And git workflow rules because Claude keeps using `git add -A`."

**Month 5**: "I should organize all this. Let me create subdirectories: `backend/`, `frontend/`, `testing/`, `ops/`. Much cleaner."

**Month 6**: "These rules should enforce themselves. Let me add mandatory plan templates, approval gates, circuit breakers, a workflow router, and a rule manifest."

**Month 7**: "Let me add an agent framework for rule learning. And a multi-agent coordination protocol. And session tracking."

**Month 8**: I had 55 files, 20,000 lines, and Claude was noticeably worse at actual coding tasks. Not because the rules were wrong -- because there was no context left for the work.

Each individual addition made sense. The cumulative effect was catastrophic.

## The Insight: Rules vs. Skills

The breakthrough came from understanding that Claude Code has **two** places for instructions, and they behave very differently:

### Rules (`.claude/rules/`)
- Auto-load into **every** conversation
- No way to opt out or conditionally load
- Should contain only non-negotiable standards
- Every line costs context in every session
- Think of them as "constitutional law" -- short, foundational, always in effect

### Skills (`.claude/commands/`)
- Load **only** when you type `/command`
- Zero context cost until invoked
- Perfect for reference material, guides, checklists
- Can be as detailed as you want -- it's free until needed
- Think of them as "reference books" -- on the shelf until you need them

The question became: **what actually needs to be in every conversation, and what can wait until asked?**

The answer, it turns out, is that very little needs to be in every conversation. The non-negotiable standards -- "use kebab-case for files", "never use `git add -A`", "API coverage must be 100%" -- are short, declarative statements. They don't need code examples. They don't need configuration templates. They don't need step-by-step workflows.

The detailed stuff -- "here's how to set up a Playwright Page Object Model", "here's a zero-downtime migration template", "here's how to configure k6 load testing" -- that's reference material. You need it when you're doing that specific task, and not a moment before.

## The Separation

### What stays as always-loaded rules (the "what")

Non-negotiable standards that apply to literally every coding task. These are the things where, if Claude doesn't know them, the output is wrong regardless of what the task is:

**1. Coding Standards (54 lines)**

File naming conventions, size limits, import organization, error handling principles, TypeScript policy, anti-patterns to avoid. This is the stuff that makes code consistent -- `kebab-case` for files, `PascalCase` for components, max 50 lines per function, never ignore errors silently.

No code examples. No ESLint configs. Just the rules.

**2. Testing Requirements (31 lines)**

Coverage targets: API endpoints 100%, UI components 80%, critical logic 90%, overall 80%. Test pyramid: 60% unit, 30% integration, 10% E2E. Use AAA pattern. Name tests with "should" or "when/then". Co-locate tests next to source files.

No Playwright configs. No mocking examples. No CI/CD pipeline definitions. Just the numbers and the principles.

**3. API & Security Standards (62 lines)**

RESTful URL design, HTTP status codes, response format, input validation requirements, auth patterns, security headers, rate limiting, OWASP top 10 awareness.

No middleware implementations. No OpenAPI spec templates. No monitoring dashboards. Just the standards.

**4. Database Standards (42 lines)**

`snake_case` naming, required columns (PK, `created_at`, `updated_at`), foreign key constraints with indexes, `NOT NULL` explicit, migrations versioned and reversible, no N+1 queries.

No migration templates. No query optimization examples. No backup procedures. Just the rules.

**5. Git Standards (45 lines)**

Branch naming (`feature/`, `bugfix/`, `hotfix/`), conventional commits (`feat:`, `fix:`, `docs:`), never `git add -A` or `git add .`, PRs under 400 lines.

No CI/CD YAML. No release workflows. No tagging strategies. Just the conventions.

**6. Project Standards (42 lines)**

Feature-based file organization, docs in `docs/` subdirectories, no mock data in production, no hardcoded API URLs, loading/error/empty states mandatory for UI, event-driven DOM patterns (never `setTimeout` for DOM operations).

No component examples. No CSS guides. No full form patterns. Just the requirements.

**Total: 276 lines.** That's it. The essentials that Claude needs in every conversation to produce consistent, standards-compliant code.

### What becomes on-demand skills (the "how")

Detailed guides, code examples, templates, and checklists -- loaded only when the task calls for them:

| Skill | Lines | What's Inside | When You Need It |
|-------|-------|---------------|------------------|
| `/test` | 274 | Playwright config, Page Object patterns, E2E structure, mocking strategies, smart testing commands, visual regression, responsive testing, accessibility testing | Writing or debugging tests |
| `/api` | 196 | Pagination implementation, Zod validation, versioning strategy, OpenAPI docs, monitoring middleware, rate limiting implementation, deployment checklist | Building API endpoints |
| `/db` | 225 | Migration templates (create table, add column, add FK), zero-downtime patterns, index types and strategies, EXPLAIN ANALYZE guide, connection pooling, rollback procedures, data type reference | Database schema or query work |
| `/frontend` | 296 | Component structure patterns, state management rules, custom hooks, all required UI states (loading/error/empty with code), responsive breakpoints, form validation with react-hook-form + zod, WCAG 2.1 AA checklist, Core Web Vitals targets, image optimization, DOM observer patterns | UI development |
| `/deploy` | 261 | CI/CD pipeline stages with requirements, blue-green/canary/rolling strategies, health check implementation with code, rollback procedures and triggers, structured logging standards, RED metrics, alerting rules, idempotency patterns with code, pre-deployment checklist | Deployment or infrastructure |
| `/review` | 162 | Full review checklist (functional, quality, TS, security, performance, testing, database), PR size and description requirements, feedback tone and severity prefixes with examples, feature verification checklist, cross-browser testing, approval criteria, merge strategies | Code reviews |
| `/adr` | 145 | When to create ADRs (and when not to), full template with all sections, status lifecycle, storage conventions, complete example (PostgreSQL selection with alternatives analysis) | Architecture decisions |
| `/perf` | 221 | Response time targets by endpoint type, Core Web Vitals with thresholds, bundle budgets, rendering performance targets, caching strategies (browser, Redis) with code, TTL guidelines, k6 load/stress/spike test scripts, optimization checklists (database, API, frontend), monitoring metrics | Performance work |
| `/refactor` | 219 | Refactoring triggers (rule of three, long functions, deep nesting, etc.), when NOT to refactor, step-by-step process, common patterns with before/after code (extract function, replace conditional, extract hook, simplify conditionals, replace magic values), dependency evaluation matrix, license compatibility table, code smell severity guide | Refactoring sessions |
| `/security` | 249 | Complete feature security checklist (input validation, output encoding, auth, authz, rate limiting, data protection, error handling, headers, dependencies), OWASP top 10 with code examples for each, incident response framework with severity levels, SAST/DAST integration, secrets management rules | Security reviews or audits |

**Total: 2,248 lines.** Available when needed. Invisible when not.

The beauty of this approach: when you type `/test`, Claude gets 274 lines of detailed testing guidance loaded right when it needs them, alongside the 276 lines of always-loaded standards. That's 550 lines of highly relevant context instead of 20,000 lines of mostly irrelevant context.

## Deep Dive: What Made the Old Rules So Bloated

Let's look at some specific examples of what was wrong and how the content was redistributed.

### Example 1: Testing (15 files -> 1 rule + 1 skill)

The old system had **fifteen** files about testing spread across two directories:

```
.claude/rules/general-policies/testing/
  core-standards.md
  implementation-guide.md
  test-patterns.md
  test-requirements.md
  unit-testing.md
  integration-testing.md
  api-testing.md
  e2e-playwright.md
  playwright-patterns.md
  playwright-strategy.md
  cross-farm-data-isolation.md
  test-automation.md

.claude/rules/testing/
  smart-testing.md
  always-test-before-delivery.md
  visual-regression-verification.md
  frontend-validation-comprehensive.md
```

Much of this was redundant. `test-requirements.md` and `core-standards.md` overlapped heavily. `e2e-playwright.md`, `playwright-patterns.md`, and `playwright-strategy.md` were three files covering the same tool. `cross-farm-data-isolation.md` was project-specific content that had leaked into generic rules.

**After**: The non-negotiable numbers (coverage targets, pyramid ratios) went into the 31-line `testing-requirements.md` rule. Everything else -- the Playwright configs, the mocking patterns, the E2E workflow, the smart testing commands -- went into the 274-line `/test` skill.

A developer fixing a simple bug never needs to see Playwright Page Object patterns. A developer writing E2E tests can type `/test` and get everything.

### Example 2: Plan Enforcement (4 files -> 0)

The `_mandatory/` directory contained four files:

```
_mandatory/
  00-workflow-before-starting-circuit-breaker.md
  01-workflow-plan-template.md
  02-approval-gate.md
  03-plan-content-preview.md
```

These files implemented a custom "plan-first workflow" where Claude was instructed to create a plan from a specific template, show it for approval, and only proceed after the user confirmed. It included circuit breakers that would block tool execution if no plan was detected.

The problem: **Claude Code now has native plan mode**. You can enter plan mode, Claude creates a plan, you approve it, and it executes. It's built into the tool. These four files were doing what the platform now does natively, but worse -- because a custom text-based enforcement mechanism is always going to be more brittle than a first-party feature.

Similarly, `todo-driven-workflow.md` replicated what `TodoWrite` does natively.

**After**: All five files deleted. Zero replacement needed. The platform handles it.

### Example 3: Phantom Infrastructure (fiction -> truth)

The old CLAUDE.md was 99 lines and contained this:

```markdown
## ACTIVE HOOKS

| Hook | Trigger | What It Does |
|------|---------|--------------|
| UserPromptSubmit | User message | Loads rules from both directories |
| PreToolUse | Before tools | Validates plan approval |
| PostToolUse | After edits | Runs smart tests |
| Stop | Session end | Auto-commits changes |

### Configuration:
- Session data: .claude/session/
- Metrics: .claude/metrics/
```

Sounds impressive. The reality:

- The hooks directory was **empty**. No hooks were implemented.
- `.claude/session/` didn't exist.
- `.claude/metrics/` didn't exist.
- "Dynamic rule loading based on keywords" was a concept, not code.
- "Auto-commits at session end" never happened.

This wasn't just wasted context -- it was actively harmful. Claude would read these instructions and try to interact with systems that didn't exist. It would reference "the session data" or "the metrics tracking" in its responses, confusing both itself and the user.

**After**: The new CLAUDE.md is 38 lines. Every path it references exists. Every feature it describes works. No fiction.

## The Other Cleanup

### Dead code and outdated metadata

- **`manifest.json`**: Listed 29 rules with descriptions and categories. But 55 rules existed. The manifest was wrong about half the files in its own directory.
- **`workflow-rule-router.md`**: Described a routing system that would load rules based on task keywords. The routing was never connected to anything.
- **`agents/rule-learning-agent.md`**: Described an AI agent that would learn from coding sessions and update rules automatically. It was a design document for a feature that never shipped.

All deleted. If it doesn't work, it's not documentation -- it's noise.

### Domain contamination

This rules project was meant to be generic and reusable -- a git submodule you could drop into any project. But content from a specific project (a hydroponic farm management system) had leaked throughout:

- Database rules referenced `farm_id` columns and multi-tenant farm isolation
- Testing rules referenced sensor data validation and greenhouse monitoring
- API rules referenced irrigation scheduling endpoints

Every instance was found and stripped. The verification:

```bash
grep -ri "farm\|hydroponic\|greenhouse\|sensor\|irrigation\|claros" .claude/rules/ .claude/commands/
# No results
```

## The Results

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Always-loaded files | 55 | 6 | -89% |
| Always-loaded lines | ~20,000 | 276 | **-98.6%** |
| On-demand skills | 0 | 10 | +10 |
| Total available content | ~20,000 | 2,524 | Better organized |
| CLAUDE.md size | 99 lines | 38 lines | -62% |
| Phantom references | Many | 0 | Clean |
| Domain contamination | Throughout | 0 | Clean |
| Dead code / outdated metadata | 5+ files | 0 | Clean |

The total available content actually went **up** in quality while going down in size. The old 20,000 lines included significant redundancy, dead references, and project-specific content. The new 2,524 lines (276 always-loaded + 2,248 on-demand) are all relevant, accurate, and well-organized.

## The Practical Impact

### Before: Every conversation

```
Context window usage:
[========= RULES (20,000 lines) =========][=== code ===][= reasoning =]
```

Claude has read about Playwright, Kubernetes, k6, PostgreSQL migrations, WCAG accessibility, API versioning, and 49 other topics. It has a sliver of space left for your actual code and its reasoning about your problem.

### After: Normal conversation

```
Context window usage:
[= RULES (276) =][============= code =============][======= reasoning =======]
```

Claude knows the standards. It has massive space for your code and deep reasoning about your problem.

### After: Specialized conversation (e.g., testing)

```
Context window usage:
[= RULES (276) =][= /test (274) =][========= code =========][==== reasoning ====]
```

You typed `/test`, so Claude also has detailed testing guidance. Still far less context used than before, and all of it is relevant to what you're actually doing.

## What You Can Take From This

### 1. Audit your rules directory right now

```bash
# Count total lines in your rules
wc -l .claude/rules/**/*.md

# Count individual files
find .claude/rules -name "*.md" | wc -l
```

If the total is more than a few hundred lines, you're almost certainly wasting context. If it's over 1,000 lines, you're definitely hurting Claude's performance on your actual tasks.

### 2. Apply the "every conversation" test

For each rule file, ask yourself: "Does Claude need this for **literally every task**, including fixing a typo in a README?"

- "Use conventional commits" -- Yes, Claude should always know this.
- "Here's how to configure Playwright with custom fixtures" -- No. Only when writing E2E tests.
- "Never use `git add -A`" -- Yes, always relevant.
- "Here's a complete k6 load testing script template" -- No. Only during performance work.

If the answer is "only when doing X" -- it's a skill, not a rule.

### 3. Rules = standards, Skills = guides

This is the core principle:

- **Rules** tell Claude **what** the standards are (short, declarative, no examples)
- **Skills** tell Claude **how** to implement them (detailed, with code examples, templates, checklists)

A rule says: "Coverage target for API endpoints is 100%."
A skill shows: how to set up the test runner, write API tests with supertest, mock dependencies, measure coverage, and integrate with CI.

The rule ensures Claude always knows the target. The skill provides the implementation guide when it's time to actually write the tests.

### 4. Don't build what the platform provides

Before creating custom enforcement mechanisms, check if Claude Code already handles it natively:

- **Plan enforcement?** Use native plan mode. Don't write circuit breakers and approval gates in markdown.
- **Task tracking?** Use TodoWrite. Don't write a custom todo-driven workflow in rules.
- **Permission control?** Use `settings.json` deny rules. Don't write lengthy "NEVER do X" paragraphs.
- **Dynamic rule loading?** Use skills (`/command`). Don't design a keyword-based routing system.

Platform features are maintained, tested, and improved by the Claude Code team. Custom markdown enforcement is brittle, untested, and burns context.

### 5. Verify your references are real

```bash
# Check if your CLAUDE.md references things that exist
grep -oP '\.\S+/' CLAUDE.md | sort -u | while read dir; do
  [ -d "$dir" ] || echo "PHANTOM: $dir does not exist"
done
```

Phantom references aren't just wasted context. They actively confuse Claude. When Claude reads "session data is stored in `.claude/session/`" and that directory doesn't exist, it either hallucinates about the session data or wastes tool calls trying to find it.

### 6. Watch for scope creep

Set a budget for your rules directory. Ours is ~300 lines. If you need to add something, you need to either:

1. Remove something else, or
2. Add it as a skill instead

This prevents the slow accumulation that took us from a reasonable set of standards to 20,000 lines of everything.

### 7. Separate generic from project-specific

If your rules are meant to be reusable (like ours, as a git submodule), ruthlessly remove project-specific content. It doesn't matter how important your farm_id isolation strategy is -- it doesn't belong in generic rules that other projects will consume.

Project-specific rules belong in the consuming project's own `.claude/rules/` directory.

## A Note on the Process

This modernization was done in a single session with Claude Opus 4.6. The process was:

1. **Audit**: Read all 55 files, categorize each as "always needed" or "on-demand"
2. **Plan**: Design the 6 rules + 10 skills structure with line budgets
3. **Delete**: Remove all 55 old files (git history preserves everything)
4. **Create rules**: Write 6 lean rule files (276 lines total)
5. **Create skills**: Write 10 comprehensive skill files (2,248 lines total)
6. **Rewrite CLAUDE.md**: 38 lines of truth, no phantom references
7. **Verify**: Grep for contamination, count lines, check for orphan references

The hardest part was the deletion. It feels wrong to delete 20,000 lines of carefully written content. But the content isn't gone -- the valuable parts live on in skills, and the rest was redundant, outdated, or fictional.

## The Takeaway

More rules doesn't mean better behavior. Context is a finite resource.

Every line of rules you load is a line of code Claude can't see. A line of reasoning it can't do. A line of your actual problem it can't think about. A token of creativity it can't express.

The goal isn't to tell Claude everything you know about software engineering. The goal is to tell Claude the minimum it needs to produce consistent, high-quality output -- and make the rest available on demand.

276 lines of the right rules beat 20,000 lines of everything.

Every. Single. Time.

---

*This modernization was performed on a Claude Code rules project using Claude Opus 4.6. The project is designed as a git submodule providing generic, reusable rules for any codebase. The full source is available as a reference for anyone looking to optimize their own Claude Code configuration.*
