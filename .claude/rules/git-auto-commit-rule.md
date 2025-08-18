# Git Auto-Commit with Rollback Rule

## Purpose
This rule ensures that every significant code change is automatically committed with proper versioning and rollback capability.

## Requirements

### 1. Automatic Commit Creation
After completing any significant task or code modification:
- Create a descriptive git commit
- Include rollback information in commit message
- Push to remote repository (if explicitly allowed)

### 2. Commit Message Format
```
<type>: <description>

<detailed changes>

Rollback: git revert <commit-hash>
Previous: <previous-commit-hash>

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 3. Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `test`: Test additions/modifications
- `chore`: Maintenance tasks
- `perf`: Performance improvements

### 4. Rollback Strategy
Every commit should include:
- Clear rollback instructions
- Reference to previous stable commit
- Any special considerations for rollback

### 5. Safety Checks Before Commit
- Run linting if available
- Check for syntax errors
- Verify no sensitive data is included
- Ensure tests pass (if quick tests available)

## Implementation Steps

### Automated Implementation (Recommended)

#### Hook System Architecture:
1. **tool-use.sh**: Validates tool usage patterns (no file tracking)
2. **auto-commit.sh**: Accepts file list as parameters, commits only specified files
3. **plan-complete.sh**: Wrapper that passes files to auto-commit.sh

#### Usage After Plan Completion:
```bash
# Pass the list of modified files from your plan
bash .claude/hooks/plan-complete.sh file1.ts file2.tsx file3.md

# Or use auto-commit directly
bash .claude/hooks/auto-commit.sh /path/to/file1 /path/to/file2
```

#### Benefits:
- Works with multiple concurrent Claude sessions
- Commits only plan-specific files
- Generates intelligent commit messages based on file types
- No session file conflicts

### Implementation

Use the automated hook system after completing tasks:

```bash
# After completing tasks in your plan, pass the modified files
bash .claude/hooks/plan-complete.sh file1.ts file2.tsx file3.md

# Or use auto-commit directly
bash .claude/hooks/auto-commit.sh /path/to/file1 /path/to/file2
```

The hooks automatically:
- Generate intelligent commit messages based on file changes
- Include rollback information
- Handle multiple concurrent sessions safely
- Commit only plan-specific files

For details, see `.claude/hooks/README.md`

## Rollback Procedures

### Quick Rollback
```bash
# Revert last commit
git revert HEAD --no-edit

# Revert specific commit
git revert <commit-hash> --no-edit
```

### Safe Rollback with Backup
```bash
# Create backup branch first
git branch backup-$(date +%Y%m%d-%H%M%S)

# Then revert
git revert HEAD --no-edit
```

### Emergency Rollback
```bash
# Hard reset to previous commit (destructive!)
git reset --hard HEAD~1

# Or reset to specific commit
git reset --hard <commit-hash>
```

## Git Hooks Integration

### Post-Commit Hook (.git/hooks/post-commit)
```bash
#!/bin/bash
# Automatically create rollback script after each commit

COMMIT_HASH=$(git rev-parse HEAD)
PREV_HASH=$(git rev-parse HEAD~1)

cat > .rollback/rollback-$COMMIT_HASH.sh << EOF
#!/bin/bash
# Rollback commit $COMMIT_HASH
echo "Rolling back to $PREV_HASH"
git revert $COMMIT_HASH --no-edit
EOF

chmod +x .rollback/rollback-$COMMIT_HASH.sh
echo "Rollback script created: .rollback/rollback-$COMMIT_HASH.sh"
```

### Pre-Push Hook (.git/hooks/pre-push)
```bash
#!/bin/bash
# Verify commit has rollback information

COMMIT_MSG=$(git log -1 --pretty=%B)
if ! echo "$COMMIT_MSG" | grep -q "Rollback:"; then
    echo "Error: Commit message missing rollback instructions"
    echo "Add 'Rollback: git revert HEAD' to commit message"
    exit 1
fi
```

## Best Practices

1. **Commit Frequently**: Small, focused commits are easier to rollback
2. **Test Before Commit**: Run basic tests to ensure code works
3. **Document Changes**: Clear commit messages help with rollback decisions
4. **Tag Stable Versions**: Use git tags for known-good states
5. **Backup Important Work**: Push to feature branches regularly

## Example Workflow

```bash
# 1. Make changes
vim src/feature.js

# 2. Check changes
git diff

# 3. Run tests (if available)
npm test

# 4. Create commit with rollback info
# IMPORTANT: Only add files YOU modified in this session
git add path/to/file1.ts path/to/file2.ts  # Specific files only
PREV=$(git rev-parse HEAD)
git commit -m "feat: add new feature X

- Added function Y
- Modified component Z
- Updated tests

Rollback: git revert HEAD
Previous stable: $PREV

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 5. Optional: push to remote
git push origin HEAD
```

## Monitoring and Maintenance

1. **Keep rollback scripts organized**: Store in `.rollback/` directory
2. **Clean old rollback scripts**: Remove scripts older than 30 days
3. **Document major rollbacks**: Keep a ROLLBACK_LOG.md file
4. **Test rollback procedures**: Regularly verify rollback works

## Emergency Contacts
If a rollback fails or causes issues:
1. Check git reflog for recovery options
2. Use git fsck to verify repository integrity
3. Contact team lead before force-pushing

---

**Note**: This rule should be adapted based on project requirements and team conventions.