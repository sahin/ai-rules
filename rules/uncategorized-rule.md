> Canonicalization: The guidance below has been integrated into dedicated rule files. Use this file as an overview only; see linked canonical files for authoritative rules.

```yaml
# .cursorrules
# Purpose: Make AI navigate code by feature-first structure, consistent names, SRP-sized files, and rich headers.

- name: Feature-first project layout (see: `workflow-architecture.md`)
  globs: ["**/*"]
  rule: |
    Always organize code by FEATURE first, then by LAYER. Prefer:
      apps/{web,api,worker}/src/features/<feature>/{backend,frontend,shared}
    Keep cross-cutting/shared code in apps/*/src/shared and in top-level packages/.
    Use a monorepo (pnpm workspaces + Turborepo/Nx). Place app code in /apps, shared libs/design system in /packages, infra in /infra, docs in /docs.

- name: Naming conventions
  globs: ["**/*"]
  rule: |
    Use descriptive, consistent names:
      - kebab-case for file names in TS/JS; PascalCase for React components; snake_case for Python.
      - Prefer <domain>.<role>.<ext> (e.g., auth.service.ts, billing.webhook.handler.ts).
      - Avoid generic names (utils.ts, helpers.ts, index.ts) unless the folder is uniquely named and the entrypoint is obvious.
      - Keep filenames under ~60 characters; use folders to convey specificity instead of ultra-long names.
    Common suffixes: .routes, .controller, .service, .repo, .types, .validators, .schema, .hook, .utils, .test.

- name: SRP + file size targets
  globs: ["**/*.{ts,tsx,js,py}"]
  rule: |
    Follow Single Responsibility Principle (“one reason to change”).
    Soft limits to keep files AI-friendly:
      - React component: 50–200 LOC
      - Route/handler: 50–150 LOC
      - Service/module: 150–300 LOC
      - Test files: ≤300 LOC, roughly 1:1 with source
    Split a file when it spans multiple domains, adds a third reusable helper, or its description needs “and/also”.

- name: Required header comment in source files
  globs: ["apps/**/src/**/*.{ts,tsx,js,py}"]
  rule: |
    At the top of each new/edited source file, include a short header so AI can find and relate files. Use this template:
    """
    /**
     * Purpose: <one-sentence scope>
     * Tags: <comma-separated keywords>
     * Inputs: <API signatures, props, or function inputs>
     * Outputs: <returns/thrown errors/side effects>
     * See also: <relative paths to closely related files>
     */
    """
    Keep it accurate and update it on every significant change.

- name: Feature folders mirror layers
  globs: ["apps/**/src/features/*/**"]
  rule: |
    Within a feature, mirror layers for clarity:
      features/<feature>/
        backend/   -> routes, controllers, services, repos
        frontend/  -> components, hooks, pages
        shared/    -> types, schemas, validators
    Do not mix client/server concerns in the same file.

- name: Tests colocated and mirrored
  globs: ["apps/**/src/**/*.{ts,tsx,js,py}"]
  rule: |
    Place tests next to the source with mirrored names:
      foo.service.ts -> foo.service.test.ts
      LoginForm.tsx  -> LoginForm.test.tsx
    Prefer focused, readable tests over large integration bundles. Keep fixtures/factories in a /testutils or __fixtures__ sibling.

- name: Barrel files (export surfaces)
  globs: ["apps/**/src/features/*/**/index.ts"]
  rule: |
    Use barrels sparingly and only to define a feature’s public surface. Prefer explicit named exports. Avoid “export *”.

- name: Shared code boundaries
  globs: ["apps/**/src/shared/**", "packages/**"]
  rule: |
    Keep shared modules generic and dependency-light. No imports from app-specific features into shared. If something gets used by 2+ features, extract it here with strong typing and docs.

- name: Top-level discovery docs
  globs: ["**/*"]
  rule: |
    Maintain these docs and keep them current for AI retrieval:
      /README.md              -> run, build, deploy quickstart
      /CODEMAP.md             -> high-level path map of important features/packages
      /docs/ARCHITECTURE.md   -> system context, data flow, boundaries
      /docs/DECISIONS/ADR-*.md-> key decisions and trade-offs
      /GLOSSARY.md            -> domain terms

- name: API design & validators
  globs: ["apps/**/src/features/*/backend/**/*.{ts,js}"]
  rule: |
    For each route/controller, create adjacent validators/schemas (e.g., zod or yup). Name clearly: auth.validators.ts, user.schema.ts. Keep handlers thin; push logic into services.

- name: Frontend components & hooks
  globs: ["apps/**/src/features/*/frontend/**/*.{ts,tsx}"]
  rule: |
    One component per file unless trivially small. Extract data-fetching and complex state to hooks (useX.ts). Keep components presentational where possible. Avoid coupling to backend details.

- name: Environment and configs
  globs: ["**/*"]
  rule: |
    Separate env concerns:
      env.server.ts for server-only
      env.client.ts for client-safe
    Keep config files explicit: vite.config.ts, tailwind.config.ts, eslint.config.ts, tsconfig.*.json. No hidden magic.

- name: Monorepo hygiene
  globs: ["**/*"]
  rule: |
    Use workspace protocol and versioned packages. Keep each package < ~3–5k LOC before splitting. Enforce lint/format/test at root. Make cross-package imports explicit; no deep relative imports across packages.

- name: When creating or refactoring files
  globs: ["**/*"]
  rule: |
    Prefer creating:
      - auth/service -> auth.service.ts
      - auth/routes  -> auth.routes.ts
      - billing/webhooks -> stripe.webhook.handler.ts
    If a filename exceeds ~60 chars, use deeper folders (auth/token/refresh.ts) instead of longer names (auth-token-refresh-flow-handler.ts).

- name: Pull request guidance
  globs: ["**/*"]
  rule: |
    Keep PRs feature-scoped and under ~400 lines changed. Include: what/why, before/after, risks, and follow-ups. Update headers and READMEs. Link ADMs/ADRs when decisions change architecture.

- name: Refactor cues for AI
  globs: ["**/*"]
  rule: |
    When a file violates SRP or size targets, propose extraction with explicit names and paths. Add “See also” references between newly-related files. Prefer small, incremental diffs.

```
