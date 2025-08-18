# Monorepo Hygiene Standards

- Use workspace protocol and versioned packages.
- Keep each package under ~3–5k LOC before splitting.
- Enforce lint/format/test at root.
- Make cross-package imports explicit; avoid deep relative imports across packages.
- Document package public surfaces; prefer explicit named exports.
