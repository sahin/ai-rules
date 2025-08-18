# 📋 MANDATORY PLAN FORMAT

## 🔬 RESEARCH FIRST, PLAN SECOND

### ✅ BEFORE CREATING THIS PLAN:
- Research completed (using tools as needed)
- Understanding verified through file reading
- Feasibility confirmed via documentation
- ❌ NO "research" or "investigate" steps allowed in plan

## USE THIS EXACT TEMPLATE

```markdown
## Plan: [Brief description]

**📡 Hook Status:**
- Rules auto-loaded: [X rules based on keywords: API, testing, etc.] OR [No keywords detected - using foundation rules only]
- Smart testing: [Enabled - will run after file changes]
- Auto-commit: [Enabled - will commit at session end]

**🪝 Hook Execution Timeline:**
```
[Pre-Plan]
├─ UserPromptSubmit → Loads rules based on keywords
└─ PreResponse → Validates plan format

[During Implementation]
├─ PreToolUse → Tracks each file modification
├─ PostToolUse → Runs smart tests after edits
└─ Stop → Auto-commits at session end
```

1. **[Implementation Action]**: [Concrete action based on research]
   - Specific file/component affected: [exact path, already verified to exist]
   - What will change: [specific changes, already confirmed possible]
   - Why this is needed: [clear reason based on research findings]
   
   **🪝 Hook Called:**
   ```
   PreToolUse → Validating edit permission ✅
   PostToolUse → Running X tests... ✅ All passed
   ```

2. **[Next Implementation]**: [Another concrete action]
   - Specific file/component affected: [exact path]
   - What will change: [specific changes]
   - Why this is needed: [clear reason]
   
   **🪝 Hook Called:**
   ```
   PreToolUse → File tracked for commit ✅
   PostToolUse → 0 tests affected, skipping
   ```

3. **🧪 TESTING PHASE** (REQUIRED):
   - **Code changes**: Unit, integration, user tests
   - **Commands**: `npm run test:smart --dry-run` → `npm run test:smart` → `npm run build`
   
   **🪝 Hooks During Testing:**
   ```
   [Bash Tool] → No hooks for bash commands
   [Stop Hook Preview] → Ready to auto-commit X files
   ```

Files to be modified:
- [List all files]
- Checkpoint(git) will be created with claude hooks

**Files Changed/Modified Content:**

**`/path/to/file1.ts`** (new file):
```typescript
// Show complete file content for new files
export const newFunction = () => {
  // implementation
};
```

**`/path/to/file2.tsx`** (modified):
```typescript
// EXISTING: Current relevant code context
const existingCode = 'current implementation';

// ADD: New code being added
const newCode = 'new implementation';

// MODIFY: Changed code (show before/after or clear description)
- const oldValue = 'old';
+ const newValue = 'new';

// REMOVE: Code being removed (if applicable)
// const deprecatedCode = 'removed';
```

**`/path/to/file3.json`** (configuration changes):
```json
{
  // ADD: New configuration
  "newSetting": "value",
  
  // MODIFY: Updated values
  "existingSetting": "newValue"
}
```

Testing files to create/update:
- [List test files]

Potential Impact:
- [Risks or considerations]

Would you like me to proceed with this plan?
```

## PLAN COMPLETION TEMPLATE (After execution)

After completing all plan tasks, provide this status:

```markdown
## ✅ Plan Completed

**🪝 Hook Execution Summary:**
```
Hook               │ Calls │ Total Time │ Actions
───────────────────┼───────┼────────────┼─────────────────────
UserPromptSubmit   │   1   │    87ms    │ Loaded X rules
PreToolUse         │   X   │    XXms    │ Tracked X files  
PostToolUse        │   X   │   X.Xs     │ Ran X tests
Stop               │   1   │   X.Xs     │ Committed, cleaned
───────────────────┼───────┼────────────┼─────────────────────
Total              │  XX   │   X.XXs    │ X.X% overhead
```

**Files Modified:** [count] files
- file1.ts
- file2.tsx
- file3.md

**Committed:** ✅ `[commit-hash]`
**Rollback:** `git revert [commit-hash]` or `.rollback/rollback-[hash].sh`

**Testing Status:**
- [ ] Unit tests: [status]
- [ ] Integration tests: [status]
- [ ] Build: [status]

**Summary:** [Brief description of what was accomplished]
```

## 🚫 COMMON MISTAKES

1. **Starting with explanation** → Start with "## Plan:"
2. **Vague descriptions** → Be specific about files and changes
3. **Missing test section** → Testing is MANDATORY
4. **Not asking for approval** → Always end with approval request

## ✅ QUICK VALIDATION

Before submitting:
- [ ] Starts with "## Plan:"
- [ ] Lists specific files
- [ ] Includes testing section
- [ ] Ends with approval question
- [ ] No code written yet

## 📝 AUTO-COMMIT NOTICE

**AUTOMATIC**: The Stop hook will automatically commit all modified files when the plan completes.
- No manual commit commands needed
- Intelligent commit messages generated
- Rollback scripts created automatically
- Session metrics tracked

If you need to manually trigger a commit mid-plan:
```bash
bash .claude/hooks/plan-complete.sh [file1] [file2]
```