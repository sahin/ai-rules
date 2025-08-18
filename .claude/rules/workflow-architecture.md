# Claude Workflow Architecture - Visual Documentation

> Visual supplement. Canonical rules: `../general-policies/todo-driven-workflow.md` (workflow), `../general-policies/testing/playwright-first.md` (testing strategy), `../general-policies/high-roi-development.md` (ROI). Prefer those for authoritative guidance.

## 🏗️ Complete System Architecture

### Overview Workflow
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          CLAUDE WORKFLOW SYSTEM                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  User Request → Analysis → Plan → Approval → Todo → Execute → Changelog        │
│       ↓           ↓        ↓        ↓        ↓       ↓         ↓              │
│   [Natural    [Context] [Task    [User    [Auto   [Work    [History]          │
│    Language]   Rules]   List]    OK/NO]    File]   Loop]    Track]            │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 Todo-Driven Development Flow

### Phase 1: Request Analysis & Planning
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              PHASE 1: ANALYSIS                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │  User Request   │
                            │                 │
                            │ "Build login    │
                            │  with tests"    │
                            └─────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │ Load Rules      │
                            │                 │
                            │ • Workflow      │
                            │ • Testing       │
                            │ • High-ROI      │
                            └─────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │ Analyze         │
                            │ Requirements    │
                            │                 │
                            │ • Features      │
                            │ • User Flows    │
                            │ • Dependencies  │
                            └─────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │ Create Plan     │
                            │                 │
                            │ • Task List     │
                            │ • Priorities    │
                            │ • Estimates     │
                            └─────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │ Show to User    │ ←── "Would you like me to proceed?"
                            │                 │
                            │ Plan Format     │
                            │ with Tasks      │
                            └─────────────────┘
```

### Phase 2: Todo Creation & Task Management
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            PHASE 2: TODO CREATION                              │
└─────────────────────────────────────────────────────────────────────────────────┘

User Approves Plan
        │
        ▼
┌─────────────────┐
│ Generate Todo   │
│ File            │
│                 │
│ tasks-YYYY.md   │
└─────────────────┘
        │
        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Task 1          │    │ Task 2          │    │ Task 3          │
│ [ ] Login UI    │    │ [ ] Auth Logic  │    │ [ ] Tests       │
│                 │    │                 │    │                 │
│ Files: 3        │    │ Files: 2        │    │ Files: 5        │
│ LOC: ~50        │    │ LOC: ~30        │    │ LOC: ~100       │
│ Priority: High  │    │ Priority: High  │    │ Priority: Med   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                                ▼
                    ┌─────────────────────┐
                    │ Context Window      │
                    │ Size Check          │
                    │                     │
                    │ Split if > 80%      │
                    │ of context limit    │
                    └─────────────────────┘
```

### Phase 3: Execution Loop
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           PHASE 3: EXECUTION LOOP                              │
└─────────────────────────────────────────────────────────────────────────────────┘

                        ┌─────────────────┐
                        │ Get Next Task   │ ←─────────────────┐
                        │ from Todo       │                  │
                        │                 │                  │
                        │ [ ] → [🔄]      │                  │
                        └─────────────────┘                  │
                                │                            │
                                ▼                            │
                        ┌─────────────────┐                  │
                        │ Execute Task    │                  │
                        │                 │                  │
                        │ High-ROI Rules: │                  │
                        │ • Min LoC       │                  │
                        │ • Max Impact    │                  │
                        │ • User-First    │                  │
                        └─────────────────┘                  │
                                │                            │
                                ▼                            │
                        ┌─────────────────┐                  │
                        │ Create Files    │                  │
                        │                 │                  │
                        │ Playwright      │                  │
                        │ Tests First     │                  │
                        └─────────────────┘                  │
                                │                            │
                                ▼                            │
                        ┌─────────────────┐                  │
                        │ Test & Verify   │                  │
                        │                 │                  │
                        │ User Flows      │                  │
                        │ Work?           │                  │
                        └─────────────────┘                  │
                                │                            │
                                ▼                            │
                     ┌─────────────────┐                     │
                     │ Mark Complete   │                     │
                     │                 │                     │
                     │ [🔄] → [✅]     │                     │
                     └─────────────────┘                     │
                                │                            │
                                ▼                            │
                     ┌─────────────────┐                     │
                     │ Move to         │                     │
                     │ Changelog       │                     │
                     │                 │                     │
                     │ + Timestamp     │                     │
                     │ + Files Changed │                     │
                     │ + Test Results  │                     │
                     └─────────────────┘                     │
                                │                            │
                                ▼                            │
                     ┌─────────────────┐                     │
                     │ More Tasks?     │ ──Yes──────────────┘
                     │                 │
                     │ Check Todo      │
                     └─────────────────┘
                                │
                               No
                                ▼
                     ┌─────────────────┐
                     │ Session         │
                     │ Complete        │
                     │                 │
                     │ Show Summary    │
                     └─────────────────┘
```

## 🎯 High-ROI Development Strategy

### Decision Matrix
```
                    High Impact              Low Impact
                ┌─────────────────────┬─────────────────────┐
    Low LoC     │     🚀 DO FIRST     │    ✅ DO NEXT      │
                │                     │                     │
                │ • User login        │ • UI polish        │
                │ • Critical bugs     │ • Nice-to-haves    │
                │ • Core features     │ • Minor features   │
                └─────────────────────┼─────────────────────┤
    High LoC    │    ⚠️ MINIMIZE      │    ❌ AVOID        │
                │                     │                     │
                │ • Complex features  │ • Over-engineering │
                │ • Must-have only    │ • Premature optim  │
                │ • Break into steps  │ • Scope creep      │
                └─────────────────────┴─────────────────────┘
```

### Code Change Strategy
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            MINIMIZE LOC CHANGES                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  1. Reuse Existing → 2. Extend Current → 3. Create New (only if needed)       │
│                                                                                 │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                     │
│  │ Check:      │     │ Modify:     │     │ Build:      │                     │
│  │             │     │             │     │             │                     │
│  │ • Components│────▶│ • Add props │────▶│ • New files │                     │
│  │ • Hooks     │     │ • Extend fn │     │ • Only when │                     │
│  │ • Utils     │     │ • Add types │     │   necessary │                     │
│  │ • Types     │     │ • Small add │     │ • Minimal   │                     │
│  └─────────────┘     └─────────────┘     └─────────────┘                     │
│                                                                                 │
│  Target: 80% reuse, 15% extend, 5% new                                        │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🎭 Playwright-First Testing Flow

### User Experience Driven Development
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         PLAYWRIGHT-FIRST APPROACH                              │
└─────────────────────────────────────────────────────────────────────────────────┘

Start with User Story
        │
        ▼
┌─────────────────┐
│ "As a user,     │
│  I want to      │
│  login so I     │
│  can access     │
│  my account"    │
└─────────────────┘
        │
        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Write E2E Test  │    │ Create UI       │    │ Add Logic       │
│                 │    │                 │    │                 │
│ test('login')   │ ──▶│ LoginForm.tsx   │ ──▶│ useAuth.ts      │
│ .fill(email)    │    │ Input fields    │    │ API calls       │
│ .fill(password) │    │ Submit button   │    │ State mgmt      │
│ .click(login)   │    │ Error handling  │    │ Validation      │
│ .expect(url)    │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                                ▼
                    ┌─────────────────────┐
                    │ Test Passes?        │
                    │                     │
                    │ User can actually   │
                    │ login successfully  │
                    └─────────────────────┘
                                │
                           Yes  │  No
                                ▼
                        ┌─────────────┐
                        │ Task        │
                        │ Complete    │ ←─── Fix & Retry
                        │             │
                        │ ✅ Working  │
                        └─────────────┘
```

### Test-First Development Cycle
```
User Flow → E2E Test → Implementation → Verification
    ↑                                        │
    └────────────── Feedback Loop ←──────────┘

                    ┌─────────────────┐
                    │ Each Feature:   │
                    │                 │
                    │ 1. User story   │
                    │ 2. E2E test     │
                    │ 3. Minimal code │
                    │ 4. Test passes  │
                    │ 5. Refactor     │
                    └─────────────────┘
```

## 📊 Context Window Management

### Task Splitting Strategy
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          CONTEXT WINDOW OPTIMIZATION                           │
└─────────────────────────────────────────────────────────────────────────────────┘

                        ┌─────────────────┐
                        │ Large Feature   │
                        │ Request         │
                        │                 │
                        │ "Build complete │
                        │  auth system"   │
                        └─────────────────┘
                                │
                                ▼
                        ┌─────────────────┐
                        │ Analyze Size    │
                        │                 │
                        │ Estimate:       │
                        │ • Files: 15     │
                        │ • LoC: 800      │
                        │ • Context: 90%  │
                        └─────────────────┘
                                │
                                ▼
                        ┌─────────────────┐
                        │ Split Strategy  │
                        │                 │
                        │ Rule: Each task │
                        │ ≤ 70% context   │
                        └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Task 1          │    │ Task 2          │    │ Task 3          │
│ Basic Login UI  │    │ Auth Logic      │    │ Advanced Auth   │
│                 │    │                 │    │                 │
│ Files: 3        │    │ Files: 4        │    │ Files: 8        │
│ Context: 45%    │    │ Context: 60%    │    │ Context: 70%    │
│ Dependencies: - │    │ Depends: Task1  │    │ Depends: Task2  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Context Usage Monitor
```
Context Window Status:
┌─────────────────────────────────────────────────────────────┐
│ Used: 45% [████████████████████████░░░░░░░░░░░░░░░░░░░░░░░] │
│                                                             │
│ Files Loaded: 8                                            │
│ Rules Loaded: 3                                            │
│ Todo Context: 15%                                          │
│ Code Context: 30%                                          │
│ Available: 55%                                             │
└─────────────────────────────────────────────────────────────┘

Status: 🟢 Safe to continue
Action: ✅ Execute current task
```

## 📝 File Organization

### Project Structure for Workflow
```
project/
├── .cursor/
│   ├── rules/
│   │   ├── _reasoning-architecture/
│   │   │   └── claude-workflow-architecture.md  ← This file
│   │   ├── general-policies/
│   │   │   ├── todo-driven-workflow.md          ← Core workflow
│   │   │   ├── high-roi-development.md          ← ROI strategy
│   │   │   └── testing/
│   │   │       └── playwright-first.md          ← User-first testing
│   │   └── workflow-rule-router.md              ← Dynamic loading
│   │
│   └── templates/
│       ├── todo-task.md                         ← Task template
│       └── changelog-entry.md                   ← Change template
│
├── docs/
│   ├── todos/                                   ← Active todos
│   │   ├── current-tasks-2024.md
│   │   └── feature-requests.md
│   │
│   └── changelogs/                              ← Completed work
│       ├── 2024-01/
│       ├── 2024-02/
│       └── current.md
│
└── scripts/
    ├── todo-task-manager.js                     ← Automation
    └── context-window-monitor.js                ← Size tracking
```

## 🔄 Integration Points

### How Everything Connects
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            INTEGRATION FLOW                                    │
└─────────────────────────────────────────────────────────────────────────────────┘

Workflow Router ←→ Rules System ←→ Todo Manager ←→ Task Execution
       │              │              │              │
       │              │              │              │
    Keywords       Load Rules     Create/Read    Execute with
    Detect         Based on       Todo Files     Context Limits
       │           Keywords          │              │
       │              │              │              │
       ▼              ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ Dynamic     │ │ Context     │ │ Progress    │ │ High-ROI    │
│ Loading     │ │ Aware       │ │ Tracking    │ │ Strategy    │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
       │              │              │              │
       └──────────────┼──────────────┼──────────────┘
                      │              │
                      ▼              ▼
              ┌─────────────────────────────┐
              │     Changelog System        │
              │                             │
              │ • Track completed work      │
              │ • Audit trail              │
              │ • Progress history         │
              └─────────────────────────────┘
```

## 🎯 Success Metrics

### Workflow Efficiency
```
Target KPIs:
┌─────────────────────────────────────────────────────────────────┐
│ • Context Usage: < 70% average                                 │
│ • Task Completion: > 95%                                       │
│ • Code Reuse: > 80%                                           │
│ • New LoC: < 20% of total changes                             │
│ • E2E Test Coverage: 100% of user flows                       │
│ • User Story → Working Feature: < 2 iterations                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Feature-first layout and layering (summary)

- Organize by feature, then by layer: `apps/{web,api,worker}/src/features/<feature>/{backend,frontend,shared}`.
- Mirror layers inside each feature; do not mix client/server in one file.
- Shared code lives in `apps/*/src/shared` or `packages/` when used by 2+ features.

## 📖 Usage Summary

This architecture provides:
1. **Systematic workflow** - From request to completion
2. **Context optimization** - Smart task splitting
3. **Progress tracking** - Todo to changelog flow
4. **Quality assurance** - Playwright-first testing
5. **Efficiency focus** - High ROI, minimal LoC
6. **Audit trail** - Complete change history

The visual diagrams show exactly how each piece connects and flows together into a cohesive development system.