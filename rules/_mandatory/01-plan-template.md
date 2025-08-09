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

1. **[Implementation Action]**: [Concrete action based on research]
   - Specific file/component affected: [exact path, already verified to exist]
   - What will change: [specific changes, already confirmed possible]
   - Why this is needed: [clear reason based on research findings]

2. **[Next Implementation]**: [Another concrete action]
   - Specific file/component affected: [exact path]
   - What will change: [specific changes]
   - Why this is needed: [clear reason]

3. **🧪 TESTING PHASE** (REQUIRED):
   - **Code changes**: Unit, integration, user tests
   - **Commands**: `npm run test:smart --dry-run` → `npm run test:smart` → `npm run build`

Files to be modified:
- [List all files]

Testing files to create/update:
- [List test files]

Potential Impact:
- [Risks or considerations]

Would you like me to proceed with this plan?
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