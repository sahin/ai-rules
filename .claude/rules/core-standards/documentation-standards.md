# Documentation Standards

## 🚨 CRITICAL: File Placement Rules

### NEVER Create Documentation in Root Directory!
**All markdown documentation files MUST be placed in the correct location:**

| File Type | Correct Location | Examples |
|-----------|-----------------|----------|
| Feature documentation | `docs/features/` | `docs/features/dashboard.md` |
| Setup/configuration guides | `docs/setup/` | `docs/setup/local-setup.md` |
| Architecture/technical docs | `docs/technical/` | `docs/technical/api-design.md` |
| Change logs (weekly) | `docs/change-logs/` | `docs/change-logs/week-2025-32.md` |
| TODOs/planning | `docs/todos/` | `docs/todos/improvements.md` |
| README files | Component's own directory | `apps/frontend/README.md` |
| Everything else | `docs/others/` | `docs/others/misc-documentation.md` |

### Root Directory - ONLY These Files Allowed:
- `CLAUDE.md` - AI assistant rules (never move)
- `README.md` - Main project readme
- Configuration files (`*.config.*`, `*.json`, etc.)

### Before Creating ANY Documentation:
1. ❌ **NEVER** default to root directory
2. ✅ **ALWAYS** check the table above for correct location
3. ✅ **CREATE** subdirectory if it doesn't exist
4. ✅ **ASK** if unsure about placement

### Common Mistakes:
❌ Never create analysis/reports/maps in root → Always use `docs/` or subdirectories

## Core Principle
Documentation is code. Keep it accurate, current, and useful.

## Required Updates

### For All Changes
- Update relevant .md files in docs/
- Update inline comments for complex logic
- Update API docs for endpoint changes
- Add CHANGELOG.md entry

### CHANGELOG Format
```markdown
## [Version] - YYYY-MM-DD

### Added
- New feature with description

### Changed  
- Modified behavior with impact

### Fixed
- Bug fix with brief cause

### Removed
- Deprecated feature with migration path
```

## Documentation Requirements

### Code Changes
| Change Type | Required Documentation |
|-------------|----------------------|
| New API | Endpoint docs, examples |
| New Component | Props, usage, examples |
| New Config | Environment vars, setup |
| Breaking Change | Migration guide |
| Bug Fix | Root cause, prevention |

### Quality Standards
- **Examples**: Working code samples
- **Current**: Remove outdated info
- **Complete**: Setup, usage, troubleshooting
- **Clear**: Plain language, good structure
- **Linked**: Cross-references

## Workflow

### Before Coding
1. Identify docs to update
2. Plan doc changes with code
3. Estimate doc time

### During Development
1. Update docs alongside code
2. Keep examples working
3. Test documented workflows

### Before Submitting
1. Review all doc changes
2. Test examples
3. Verify CHANGELOG entry
4. Check links work