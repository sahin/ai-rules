# Environment and Configuration Standards

- Separate environment concerns:
  - `env.server.ts` for server-only
  - `env.client.ts` for client-safe
- Keep config files explicit and at root: `vite.config.ts`, `tailwind.config.ts`, `eslint.config.ts`, `tsconfig.*.json`.
- No hidden magic; prefer explicit imports and documented configuration.
