# Todo-Driven Workflow Standards

## 🎯 Purpose
Systematic workflow where every feature request becomes structured todos, executed sequentially, and tracked in changelog.

## 📋 Core Workflow Principles

### The Flow: Request → Plan → Todo → Execute → Changelog
```
1. User Request     → Analyze requirements
2. Create Plan      → Show structured plan for approval  
3. Generate Todo    → Break into executable tasks
4. Execute Tasks    → Work through todo systematically
5. Update Changelog → Move completed tasks to history
6. Next Task        → Continue until todo empty
```

## 🔄 Implementation Methodology

### Phase 1: Request Analysis
```markdown
## MANDATORY: Analyze Before Planning

When user requests feature/fix:
1. Load appropriate rules (via router)
2. Analyze requirements and scope
3. Identify user flows and acceptance criteria
4. Estimate context window usage
5. Plan high-ROI approach (minimal LoC, max impact)

NEVER start planning without understanding:
- What user actually wants
- Existing code that can be reused
- Minimum viable implementation
```

### Phase 2: Plan Creation & Approval
```markdown
## Plan: [Feature Name]

1. **[Phase]**: [Brief description]
   - Files affected: [exact paths]
   - LoC estimate: [number] lines
   - Context usage: [percentage]
   - ROI score: High/Med/Low
   
[Continue with structured plan...]

**Context Window Check**: 
- Total estimated usage: X%
- Task splitting needed: Yes/No
- Dependencies identified: [list]

Would you like me to proceed?
```

### Phase 3: Todo Generation
```markdown
AFTER user approves plan:

1. Create todo file: `todo/tasks-[feature]-YYYY-MM-DD.md`
2. Break plan into executable tasks
3. Size each task for context limits
4. Add dependencies and priorities
5. Include acceptance criteria
```

### Phase 4: Task Execution Loop
```markdown
EXECUTION LOOP:
1. Read next pending task from todo
2. Check context window capacity
3. Execute task with High-ROI rules
4. Test with Playwright (user flows)
5. Mark task complete in todo
6. Move completed task to changelog
7. Repeat until todo empty
```

## 📝 Todo File Format

### Standard Todo Template
```markdown
# Tasks: [Feature Name]
Created: YYYY-MM-DD
Priority: High/Medium/Low
Estimated Context: X% per task

## Task Queue

### Task 1: [Name]
- [ ] Status: Pending
- **Files**: [list of files to modify]
- **LoC**: ~X lines
- **Context**: ~X%
- **Dependencies**: None/[Task IDs]
- **ROI**: High/Med/Low
- **User Story**: As a [user], I want [goal] so I can [benefit]
- **Acceptance**: 
  - [ ] Feature works in browser
  - [ ] Playwright test passes
  - [ ] No console errors
  - [ ] Minimal code changes

### Task 2: [Name]
- [ ] Status: Pending
- **Dependencies**: Task 1
[... continue format ...]
```

### Task Status Tracking
```markdown
Status Options:
- [ ] Pending     → Not started
- [🔄] In Progress → Currently working
- [✅] Complete   → Finished successfully  
- [❌] Failed     → Error occurred
- [⏭️] Skipped    → Skipped intentionally
- [🔄] Retry      → Needs another attempt
```

## 📊 Context Window Management

### Task Sizing Rules
```markdown
CONTEXT WINDOW LIMITS:
- Each task ≤ 70% of total context
- Leave 30% buffer for:
  - Error handling
  - File reading
  - Rule loading
  - Unexpected complexity

SPLITTING STRATEGY:
If task estimate > 70%:
1. Split by file groups
2. Split by feature areas  
3. Split by dependencies
4. Create sub-tasks

Example:
Large: "Build complete auth system" (90% context)
Split: 
- Task 1: "Basic login UI" (40% context)
- Task 2: "Auth logic & API" (50% context)
- Task 3: "Advanced auth features" (60% context)
```

### Context Monitoring
```markdown
BEFORE each task:
1. Check current context usage
2. Estimate task requirements
3. Confirm safe to proceed
4. Split if necessary

DURING execution:
- Monitor context as files load
- Stop if approaching 85%
- Save progress and continue in next session
```

## 📈 High-ROI Task Prioritization

### Priority Matrix
```markdown
TASK PRIORITY RULES:

P0 - CRITICAL (Do first):
- Blocking issues
- Security fixes
- Data loss prevention

P1 - HIGH ROI (Do next):
- High impact, low LoC
- User-facing features
- Core functionality

P2 - MEDIUM (Do when capacity):
- Nice-to-have features
- Performance improvements
- Code quality

P3 - LOW (Do later):
- Edge cases
- Advanced features
- Over-engineering
```

### ROI Scoring
```markdown
ROI = (User Impact × Frequency) / Lines of Code

High ROI (>10):   🚀 Do immediately
Medium ROI (3-10): ✅ Do soon  
Low ROI (<3):     ⏳ Consider deferring

Examples:
- Login button: High impact, used always, 5 LoC = ROI: 20
- Admin panel: Medium impact, used rarely, 200 LoC = ROI: 2
- Error page: Low impact, used never (hopefully), 50 LoC = ROI: 1
```

## 🧪 Testing Integration

### Playwright-First Approach
```markdown
FOR EACH TASK:
1. Define user story
2. Write E2E test first
3. Implement minimal code to pass test
4. Verify user flow works
5. Mark task complete only when test passes

TEST REQUIREMENTS:
- Every user-facing feature needs E2E test
- Test from user perspective, not implementation
- Cover happy path and error cases
- Use real user interactions (click, type, navigate)
```

### Test-Task Relationship
```markdown
Task: "Create login form"
↓
User Story: "User can log in to access dashboard"
↓
E2E Test:
- Navigate to login page
- Fill email and password
- Click login button  
- Verify redirect to dashboard
- Verify user is logged in
↓
Implementation: Build minimum code to pass test
```

## 📚 Changelog Management

### Moving Tasks to Changelog
```markdown
WHEN task is complete:
1. Update task status: [✅] Complete
2. Add completion timestamp
3. Move to appropriate changelog file
4. Include:
   - What was built
   - Files changed
   - Lines added/removed
   - Test results
   - User impact

CHANGELOG STRUCTURE:
docs/changelogs/
├── 2024-01/
│   ├── features.md
│   ├── fixes.md
│   └── improvements.md
└── current.md (current month)

TODO STRUCTURE:
todo/
├── tasks-[feature]-YYYY-MM-DD.md
└── archived/
```

### Changelog Entry Format
```markdown
## [YYYY-MM-DD] [Task Name]

**Type**: Feature/Fix/Improvement
**ROI**: High/Medium/Low
**Impact**: [User benefit]

**Changes**:
- Files modified: X
- Lines added: +X
- Lines removed: -X
- Net change: ±X lines

**Testing**:
- [ ] E2E tests pass
- [ ] Manual testing complete
- [ ] No console errors

**Files Changed**:
- `path/to/file1.tsx` - Added login form
- `path/to/file2.ts` - Added auth logic
- `tests/login.spec.ts` - Added E2E tests

**User Story**: As a user, I can now log in to access my account.
```

## 🔁 Workflow Automation

### Todo Task Manager Integration
```markdown
AUTOMATED FUNCTIONS:
1. Create todo files from approved plans
2. Track task status and progress
3. Move completed tasks to changelog
4. Archive completed todo files
5. Generate progress reports

MANUAL TRIGGERS:
- "Create todo from this plan"
- "Mark task X complete"
- "Move to changelog"  
- "Get next task"
- "Show progress"
```

### Progress Reporting
```markdown
PROGRESS INDICATORS:
- Tasks completed: X/Y (Z%)
- Context usage: Current/Peak
- Estimated time remaining
- ROI score of remaining tasks
- Blocked/waiting tasks

FORMAT:
📊 Progress Report
- Feature: Login System
- Completed: 3/5 tasks (60%)
- Remaining: 2 tasks (~2 hours)  
- Next: "Add password validation"
- Blocking: None
```

## 🎯 Success Criteria

### Task Completion Definition
```markdown
A task is COMPLETE when:
✅ Acceptance criteria met
✅ E2E test passes
✅ No console errors in browser
✅ Code follows high-ROI principles
✅ Documentation updated (if needed)
✅ Manual verification successful

INCOMPLETE examples:
❌ Feature works but test fails
❌ Test passes but console errors
❌ Over-engineered solution
❌ Breaks existing functionality
```

### Quality Gates
```markdown
BEFORE marking complete:
1. Run E2E test suite
2. Check browser console for errors
3. Verify user flow manually
4. Confirm minimal LoC approach used
5. Check for regressions

QUALITY CHECKLIST:
- [ ] Does what user requested
- [ ] Tested from user perspective  
- [ ] Minimal necessary code
- [ ] No breaking changes
- [ ] Ready for production
```

## 🔧 Implementation Rules

### DO ✅
- Create todos from approved plans
- Size tasks for context limits
- Execute tasks sequentially
- Test with real user flows
- Track progress in changelog
- Minimize lines of code
- Maximize user impact

### DON'T ❌
- Start without todo file
- Work on multiple tasks simultaneously
- Skip testing step
- Over-engineer solutions
- Ignore context limits
- Forget to update changelog

## 📖 Quick Reference

```markdown
WORKFLOW STEPS:
1. Request → Analyze → Plan → Get Approval
2. Plan → Generate Todo → Break into Tasks  
3. Task → Execute → Test → Complete
4. Complete → Update Todo → Move to Changelog
5. Next Task → Repeat until Done

TASK FORMAT:
- Clear description
- File list and LoC estimate
- Context usage estimate
- Dependencies and priority
- User story and acceptance criteria
- Playwright test requirement

SUCCESS = User can do what they wanted with minimum code changes
```

## 🔗 Related Rules

- See `../workflow-architecture.md` for the visual workflow
- See `high-roi-development.md` for ROI strategy
- See `testing/playwright-first.md` for testing approach
- See `workflow-rule-router.md` for dynamic rule loading