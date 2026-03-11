# Claude Code Rules

Generic, reusable rules and skills for Claude Code. Designed to work as a git submodule across projects.

## The Problem

Every file in `.claude/rules/` loads into every conversation. Most Claude Code setups accumulate rules over time — detailed guides, code examples, configuration templates — burning context on content that's irrelevant to the current task.

This project keeps always-loaded rules to **276 lines** of non-negotiable standards. Detailed guides live as on-demand skills that load only when you need them.

Read the full story: [From 55 Rules to 6 Rules + 10 Skills](docs/from-55-rules-to-6-rules-10-skills.md)

## Quick Start

### As a git submodule (recommended)

```bash
# Add to your project
git submodule add https://github.com/sahin/ai-rules.git .claude/ai-rules

# Symlink rules and commands into place
ln -s ai-rules/.claude/rules .claude/rules
ln -s ai-rules/.claude/commands .claude/commands
```

### Direct copy

```bash
git clone https://github.com/sahin/ai-rules.git
cp -r ai-rules/.claude/rules /your/project/.claude/rules/
cp -r ai-rules/.claude/commands /your/project/.claude/commands/
```

## What's Included

### Always-Loaded Rules (276 lines)

These load into every conversation — short, declarative standards with no code examples:

| File | Covers |
|------|--------|
| `coding-standards.md` | File naming, size limits, imports, error handling, TypeScript, anti-patterns |
| `testing-requirements.md` | Coverage targets, test pyramid, AAA pattern, before-delivery checklist |
| `api-security-standards.md` | REST design, HTTP status codes, input validation, auth, OWASP top 10 |
| `database-standards.md` | Naming, required columns, constraints, migrations, query performance |
| `git-standards.md` | Branch naming, conventional commits, PR guidelines |
| `project-standards.md` | File organization, docs placement, frontend requirements, env config |

### On-Demand Skills (2,248 lines)

Zero context cost until invoked with `/command`:

| Command | Lines | What's Inside |
|---------|-------|---------------|
| `/test` | 274 | Unit, integration, E2E, Playwright, coverage, CI/CD |
| `/api` | 196 | REST patterns, pagination, versioning, monitoring |
| `/db` | 225 | Migrations, indexes, query optimization, rollback |
| `/frontend` | 296 | Components, responsive design, a11y, performance budgets |
| `/deploy` | 261 | CI/CD pipeline, strategies, health checks, logging |
| `/review` | 162 | Code review checklist, PR requirements, feedback |
| `/adr` | 145 | Architecture Decision Records: template, lifecycle, examples |
| `/perf` | 221 | Response targets, caching, load testing with k6 |
| `/refactor` | 219 | Patterns, process, dependency evaluation |
| `/security` | 249 | OWASP checklist, incident response, SAST/DAST |

## Design Principles

- **Rules = what** (short, declarative standards) / **Skills = how** (detailed guides with examples)
- **276 lines always-loaded** instead of 20,000 — leaves context for your actual code
- **No phantom infrastructure** — every path referenced exists, every feature described works
- **No project-specific content** — generic rules usable by any codebase
- **Platform-native features preferred** — plan mode and TodoWrite over custom enforcement

## Project-Specific Rules

This repo contains only generic standards. Project-specific rules belong in the consuming project's own `.claude/rules/` directory, not here.

## Connect

[![LinkedIn](https://img.shields.io/badge/LinkedIn-sahinboydas-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/sahinboydas)
[![Twitter](https://img.shields.io/badge/Twitter-@sahin-1DA1F2?style=flat&logo=twitter&logoColor=white)](https://www.twitter.com/sahin)

## License

MIT
