# Git Standards

## Branch Naming
- `feature/description` or `feature/TICKET-123-description`
- `bugfix/description` or `bugfix/TICKET-123-description`
- `hotfix/description` for production-critical fixes
- Lowercase with hyphens, max 50 chars, present tense

## Commit Format (Conventional Commits)
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation only
- `refactor:` no functional change
- `test:` adding/updating tests
- `chore:` build tasks, deps, maintenance
- `perf:` performance improvement

### Rules
- Subject: max 72 chars, present tense, imperative mood, no period
- Body: explain what and why, not how (optional)
- Footer: reference issues, note breaking changes (optional)

## NEVER Do
- `git add -A`, `git add .`, `git add --all` - always add specific files
- `git push --force` to shared branches
- `git reset --hard` without backup
- Commit secrets, credentials, or .env files
- Rewrite published history

## Pull Requests
- Title follows commit format
- Description: summary, changes made, testing done
- Max ~400 lines changed (split larger PRs)
- All CI checks passing before merge
- At least 1 approval required
- All review feedback addressed before merge
