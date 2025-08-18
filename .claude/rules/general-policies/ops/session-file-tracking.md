# Session File Tracking Rules

## 🚨 CRITICAL: Only Commit YOUR Session Files

### NEVER Use `git add -A` or `git add .`
**These commands stage files from:**
- Other Claude sessions
- Manual user edits
- IDE auto-saves
- Background processes

### ✅ CORRECT: Track and Commit Only Your Changes

#### During Session
```bash
# Track each file YOU modify
echo "path/to/file.ts" >> .claude/session/files-modified.flag
```

#### When Committing
```bash
# Option 1: Stage specific files
git add path/to/file1.ts path/to/file2.ts

# Option 2: Read from session tracking
FILES=$(cat .claude/session/files-modified.flag | sort -u)
git add $FILES

# Option 3: Use git add with specific patterns
git add .claude/rules/user/general-policies/testing/*.md
```

### ❌ FORBIDDEN Commands
```bash
git add -A              # NEVER - stages everything
git add .               # NEVER - stages all in directory
git add --all           # NEVER - stages everything
git add -u              # RISKY - stages all tracked files
```

### 📋 Session Isolation Rules

1. **Each session tracks its own files**
   - `.claude/session/files-modified.flag` contains YOUR changes
   - Tool-use hook automatically tracks Edit/Write operations

2. **Multiple sessions = Separate tracking**
   - User might have multiple Claude windows open
   - Each modifies different files
   - Must not interfere with each other

3. **Manual verification before commit**
   ```bash
   # Always check what you're about to commit
   git status
   git diff --cached  # Review staged changes
   ```

### 🔍 Detection Pattern
```bash
# Hook detects when you modify a file
if [[ "$TOOL_NAME" =~ ^(Edit|Write|MultiEdit)$ ]]; then
  echo "$FILE_PATH" >> .claude/session/files-modified.flag
fi
```

### 🎯 Best Practices

1. **List files explicitly**
   ```bash
   git add apps/frontend/src/components/Button.tsx
   git add apps/frontend/src/components/Button.test.tsx
   ```

2. **Use patterns for related files**
   ```bash
   git add apps/frontend/src/components/Button*
   git add "*.test.tsx"  # Only if you created these tests
   ```

3. **Verify before committing**
   ```bash
   git status  # Check what's staged
   # Only proceed if it's YOUR changes
   ```

### 🚫 Why This Matters

- **User trust**: Don't commit their uncommitted work
- **Session isolation**: Your changes only
- **Clean history**: Each commit = one logical change
- **Debugging**: Easy to trace what each session did

### 📊 Compliance Check
```bash
# Bad commit pattern (will be flagged)
git log --oneline | grep "git add -A"

# Good commit pattern
git log --oneline | head -5
# Shows specific, focused commits
```