# Project Standards

## File Organization
- Organize by feature/domain, then by layer
- Configs at project root only (package.json, tsconfig.json, etc.)
- No ad-hoc files, generated outputs, or utility scripts in root
- One component per file unless trivially small
- Extract data fetching and complex state into hooks (`useX.ts`)

## Documentation
- Place docs in `docs/` subdirectories: `features/`, `setup/`, `technical/`
- Never create documentation files in root (except README.md, CHANGELOG.md)
- CHANGELOG format: Added / Changed / Fixed / Removed sections
- Update docs alongside code changes, not after

## Frontend Requirements
- No mock data in production code - API-first approach
- No hardcoded API URLs - use centralized endpoint constants
- Loading states mandatory for all async operations
- Error states with user-friendly messages mandatory
- Empty states with helpful messaging and actions mandatory
- DOM: event-driven patterns, never setTimeout for DOM operations
  - Use MutationObserver, IntersectionObserver, ResizeObserver
  - Use framework lifecycle hooks (useEffect, etc.)
  - Exception: animation timing, debounce/throttle, polling with backoff

## Environment & Config
- Separate concerns: `env.server.ts` for server-only, `env.client.ts` for client-safe
- Keep config files explicit and at root
- No hidden magic - prefer explicit imports and documented configuration

## Monorepo Hygiene
- Use workspace protocol and versioned packages
- Keep each package under ~3-5k LOC before splitting
- Enforce lint/format/test at root
- Make cross-package imports explicit; avoid deep relative imports
- Document package public surfaces with explicit named exports

## Root Hygiene
- Root = configs only (package.json, tsconfig.json, .gitignore, etc.)
- Essential docs only: README.md, CHANGELOG.md, LICENSE
- Move summaries, analyses, implementation docs to `docs/`
