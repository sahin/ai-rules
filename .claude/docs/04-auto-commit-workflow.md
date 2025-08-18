# Rule 04: Auto-Commit Workflow

## 🎯 Core Principle
**MANDATORY**: All session changes are automatically committed at session end with intelligent commit messages and rollback capabilities.

## 📋 Rule Definition
- Every modified file is tracked during the session
- Commits are generated automatically when session ends
- Commit messages are intelligent and descriptive
- Rollback scripts are created for easy reversal

## 🔍 Enforcement Mechanism
```
Stop Hook → Automatic git operations
├─ Collects all modified files
├─ Generates descriptive commit message
├─ Executes git add + commit
├─ Creates rollback script
└─ Reports commit hash
```

## 🎯 Commit Message Intelligence
```bash
# Analyzes changes to generate appropriate messages
Route changes → "feat: add [route-name] with [features]"
Bug fixes → "fix: resolve [issue] in [component]"
Tests → "test: add [test-type] for [feature]"
Docs → "docs: update [documentation-type]"
Refactor → "refactor: improve [component] [improvement]"
```

## 📊 Auto-Commit Features
- **File Tracking**: Every Edit/Write/MultiEdit operation tracked
- **Intelligent Staging**: Only intentional changes included
- **Descriptive Messages**: Context-aware commit descriptions
- **Rollback Safety**: Easy reversal with generated scripts

## 🔄 Rollback System
```bash
# Generated for every commit
.rollback/rollback-[hash].sh
├─ git revert [commit-hash]
├─ Restoration commands
├─ File backup references
└─ Session state recovery
```

## ✅ Session Management
- **Clean Boundaries**: Clear start/end points
- **Atomic Changes**: Related changes in single commit
- **Traceability**: Full change history
- **Recovery**: Easy rollback options

## 🎭 Hook Integration
- **PreToolUse**: File modification tracking
- **Stop**: Automatic commit execution
- **Session Management**: State persistence

## 📝 Commit Format
```
type(scope): description

- Change 1: specific modification
- Change 2: another modification
- Change 3: additional change

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

## 💡 Advanced Features
- **Session Metrics**: Track development velocity
- **Change Analysis**: Understand modification patterns
- **Conflict Prevention**: Detect potential merge issues
- **Backup Creation**: Automatic file preservation

---
*Auto-commit ensures no work is lost while maintaining clean git history.*