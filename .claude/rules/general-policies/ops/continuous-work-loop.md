# Continuous Work Loop Standards

## 🎯 Purpose
Enable systematic continuous work with progress tracking and user-controlled interruption.

## 🔄 Work Loop Methodology

### Core Concept
```markdown
WORK LOOP PATTERN:
1. Present work queue
2. Show 5-second countdown for interruption
3. Execute task
4. Update progress
5. Repeat until complete or interrupted
```

### Implementation Format

#### Start of Work Session
```markdown
## 🔄 CONTINUOUS WORK SESSION STARTING

**Total Tasks**: [X] items
**Estimated Time**: ~[Y] minutes
**Progress**: 0% [░░░░░░░░░░]

⏱️ **Starting in 5 seconds** - Type "stop" or interrupt to cancel

5... 4... 3... 2... 1...

---
```

#### During Work Loop
```markdown
## 📊 WORK PROGRESS UPDATE

**Current Task**: [Task name] (3 of 10)
**Status**: In Progress
**Progress**: 30% [███░░░░░░░]

### Completed:
✅ Task 1: File analysis
✅ Task 2: Rule creation

### Working On:
🔄 Task 3: Implementation

### Remaining:
⏳ Task 4: Testing
⏳ Task 5: Documentation
⏳ ... [X more]

⏸️ **Next task in 5 seconds** - Interrupt now to stop

---
```

#### Progress Indicators
```markdown
0%   [░░░░░░░░░░] Starting
10%  [█░░░░░░░░░] 
25%  [██░░░░░░░░]
50%  [█████░░░░░]
75%  [███████░░░]
90%  [█████████░]
100% [██████████] Complete!
```

## 📋 Task Queue Management

### Task Structure
```typescript
interface WorkTask {
  id: number;
  name: string;
  type: 'create' | 'modify' | 'analyze' | 'test' | 'document';
  estimatedTime: number; // seconds
  dependencies: number[]; // task IDs
  status: 'pending' | 'in-progress' | 'completed' | 'failed' | 'skipped';
  result?: any;
  error?: string;
}

interface WorkSession {
  tasks: WorkTask[];
  startTime: Date;
  completedCount: number;
  failedCount: number;
  totalCount: number;
  isPaused: boolean;
  progress: number; // 0-100
}
```

### Task Prioritization
```markdown
Priority Order:
1. Dependencies first
2. Quick wins (< 30 seconds)
3. Critical path items
4. Nice-to-haves
5. Documentation
```

## 🎬 Work Session Examples

### Example 1: File Organization Session
```markdown
## 🔄 CONTINUOUS WORK SESSION: Organize Project Files

**Total Tasks**: 8 items
**Estimated Time**: ~12 minutes
**Progress**: 0% [░░░░░░░░░░]

### Task Queue:
1. ⏳ Analyze current file structure
2. ⏳ Create file index
3. ⏳ Move misplaced files
4. ⏳ Update imports
5. ⏳ Generate documentation
6. ⏳ Test file paths
7. ⏳ Update PROJECT_MAP.md
8. ⏳ Commit changes

⏱️ **Starting in 5 seconds** - Interrupt to cancel

5... 4... 3... 2... 1...

---

### Task 1/8: Analyzing file structure
🔍 Scanning directories...
Progress: 12% [█░░░░░░░░░]

[Work output here]

✅ Task 1 Complete: Found 245 files

⏸️ **Next task in 5 seconds** - Interrupt to stop

---
```

### Example 2: Code Refactoring Session
```markdown
## 🔄 CONTINUOUS WORK SESSION: Refactor Authentication

**Total Tasks**: 12 items
**Progress**: 42% [████░░░░░░]

### Completed (5/12):
✅ Extract auth logic to hook
✅ Create auth context
✅ Update LoginForm component
✅ Add type definitions
✅ Update imports

### Current (6/12):
🔄 Writing unit tests...
Progress: 50% [█████░░░░░]

### Remaining (6):
⏳ Integration tests
⏳ Update documentation
⏳ Migration guide
⏳ Deprecation notices
⏳ Final review
⏳ Commit changes

⏸️ **Continue in 5 seconds** - Interrupt to pause
```

## 🛑 Interruption Handling

### User Interruption Points
```markdown
WHEN USER CAN INTERRUPT:
✅ During 5-second countdown
✅ Between tasks
✅ During long-running tasks (check every 30s)

WHEN NOT TO INTERRUPT:
❌ During file writes
❌ During git operations
❌ During test execution
```

### Interruption Recovery
```markdown
## ⏸️ WORK SESSION PAUSED

**Progress Saved**: 62% complete
**Completed Tasks**: 8 of 13
**Time Elapsed**: 14 minutes

### To Resume:
"Continue work session"

### To Modify:
"Show remaining tasks"
"Skip task X"
"Add task Y"

### To Complete:
"Finish current task only"
"Complete critical tasks only"
```

## 📊 Progress Calculation

### Simple Progress
```javascript
const progress = (completedTasks / totalTasks) * 100;
```

### Weighted Progress
```javascript
const weightedProgress = tasks.reduce((acc, task) => {
  if (task.status === 'completed') {
    return acc + task.weight;
  }
  return acc;
}, 0) / totalWeight * 100;
```

### Time-Based Progress
```javascript
const timeProgress = (elapsedTime / estimatedTotalTime) * 100;
```

## 🎯 Work Session Best Practices

### DO ✅
- Show clear progress indicators
- Provide interruption windows
- Save state between interruptions
- Group related tasks
- Show time estimates
- Update progress frequently

### DON'T ❌
- Run without interruption ability
- Hide progress from user
- Mix unrelated tasks
- Skip error handling
- Ignore dependencies

## 📝 Work Session Template

```markdown
## 🔄 CONTINUOUS WORK SESSION: [Session Name]

**Objective**: [Clear goal]
**Total Tasks**: [X] items
**Estimated Time**: ~[Y] minutes
**Progress**: 0% [░░░░░░░░░░]

### Configuration:
- Auto-continue: Yes/No
- Pause between tasks: 5 seconds
- Show detailed output: Yes/No
- Commit after each task: Yes/No

### Task Queue:
[List of tasks with status indicators]

### Rules:
- Interrupt anytime during countdown
- Progress saved automatically
- Failed tasks will be retried once
- Dependencies respected

⏱️ **Starting in 5 seconds** - Interrupt to cancel

[Countdown...]

---

[Work execution with progress updates]

---

## ✅ SESSION COMPLETE

**Final Stats**:
- Tasks Completed: X/Y
- Success Rate: Z%
- Time Taken: M minutes
- Files Modified: N
- Tests Passed: P/Q

### Summary:
[What was accomplished]

### Next Steps:
[What to do next]
```

## 🔧 Implementation Code

### Progress Tracker
```javascript
class WorkProgressTracker {
  constructor(tasks) {
    this.tasks = tasks;
    this.startTime = Date.now();
    this.currentTaskIndex = 0;
  }
  
  getProgress() {
    const completed = this.tasks.filter(t => t.status === 'completed').length;
    return {
      percentage: Math.round((completed / this.tasks.length) * 100),
      completed,
      total: this.tasks.length,
      timeElapsed: Date.now() - this.startTime,
      currentTask: this.tasks[this.currentTaskIndex]
    };
  }
  
  renderProgressBar(percentage) {
    const filled = Math.round(percentage / 10);
    const empty = 10 - filled;
    return '[' + '█'.repeat(filled) + '░'.repeat(empty) + ']';
  }
  
  async waitWithCountdown(seconds = 5) {
    for (let i = seconds; i > 0; i--) {
      console.log(`${i}...`);
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
}
```

## 🏁 Success Metrics

### Good Work Session
- Clear objectives
- Visible progress
- Interruptible
- State preserved
- Helpful output

### Poor Work Session
- No progress shown
- Can't interrupt
- State lost on stop
- Unclear what's happening
- No time estimates

## 💡 Tips for Efficiency

1. **Batch similar tasks** - Group by type
2. **Quick wins first** - Build momentum
3. **Show impact** - What changed
4. **Estimate conservatively** - Better to finish early
5. **Handle failures gracefully** - Don't stop on error
6. **Save progress often** - Every task completion

## 🔗 Related Rules

- See `workflow-plan-template.md` for planning
- See `feature-verification.md` for completion

## 📚 Usage Guide

- See `/docs/todos/continuous-work-loop-usage-guide.md` for quick reference and examples