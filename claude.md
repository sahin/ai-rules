# Claude AI Assistant Rules

## 🚨 BREAKING: NEW MANDATORY SYSTEM

### YOUR BRAIN WANTS TO HELP IMMEDIATELY - FIGHT IT!

### 📚 REQUIRED READING ORDER (1,000 tokens total):
1. **[workflow-before-starting.md](./.cursor/rules/workflow-before-starting.md)** - Stops your helpful instinct
2. **[workflow-plan-template.md](./.cursor/rules/workflow-plan-template.md)** - The ONLY format allowed
3. **[workflow-rule-router.md](./.cursor/rules/workflow-rule-router.md)** - Which rules to load

### ❌ THESE BEHAVIORS ARE BANNED:
- Starting with "I'll help you..."
- Creating todos without a plan
- Writing any code before approval
- Explaining what you'll do (just show the plan!)

### ✅ ONLY ALLOWED BEHAVIOR:
1. Read the 3 files above
2. Create plan using EXACT format
3. Wait for approval
4. Then help

### 📊 VIOLATION TRACKING ACTIVE
```yaml
last_violation: "Started coding without plan"
violation_count: 0  # Keep this at 0!
compliance_rate: 100%  # Maintain this!
```

### 🎯 SUCCESS FORMULA:
- STOP (fight the instinct)
- PLAN (use the format)
- WAIT (get approval)
- HELP (now you can!)

---

## 🚨 CRITICAL: 100% RULE COMPLIANCE REQUIRED

### **FUNDAMENTAL PRINCIPLE:**
**I am a "rule-following assistant who happens to be helpful" NOT a "helpful assistant who sometimes follows rules"**

## 📚 MANDATORY PROJECT RULES

### **ALWAYS LOADED (Foundation Rules)**
**Foundation (Always Required):**
- **[Core Workflow](./.cursor/rules/core-standards/core-workflow.md)** - MANDATORY plan creation, approval process
- **[Coding Standards](./.cursor/rules/core-standards/coding-standards.md)** - MANDATORY universal coding patterns
- **[Documentation Standards](./.cursor/rules/core-standards/documentation-standards.md)** - MANDATORY documentation requirements

**Project Context (Always Required):**
- **[Project Overview](./.cursor/rules/current-code/overview.md)** - MANDATORY project structure, environment setup

### **CONDITIONAL RULE LOADING**
**All other rules are loaded dynamically based on task keywords.**

See **[Rule Router](./.cursor/rules/workflow-rule-router.md)** for:
- Testing rules → Load when keywords: "test", "testing", "coverage"
  - **[Smart Testing](./.cursor/rules/testing/smart-testing.md)** - MANDATORY intelligent test execution
- Frontend rules → Load when keywords: "React", "component", "TypeScript", "UI"
- Backend rules → Load when keywords: "API", "database", "FastAPI"
- Security rules → Load when keywords: "auth", "security", "permission"
- Performance rules → Load when keywords: "performance", "optimize", "slow"
- Deployment rules → Load when keywords: "deploy", "CI/CD", "production"

**This approach ensures optimal performance by loading only relevant rules for each task.**

## 🎯 CRITICAL: Smart Testing Requirement

### **MANDATORY: Use Smart Test Detection**
When running ANY tests in this project:
- **ALWAYS use `npm run test:smart`** instead of `npm run test`
- **ALWAYS use `npm run e2e:smart`** instead of `npm run e2e`
- **ALWAYS preview with `--dry-run`** to see what will be tested
- Smart testing analyzes git changes and runs ONLY affected tests
- Reduces test execution time by 80-95% while maintaining coverage
- See [Smart Testing Rule](./.cursor/rules/testing/smart-testing.md) for details

## 🔒 MANDATORY COMPLIANCE ENFORCEMENT

### **Rule Reading Protocol (NO EXCEPTIONS):**
1. **Read CLAUDE.md (this file) - ALWAYS**
2. **Read workflow-rule-router.md to identify which rules to load**
3. **Load foundation rules (always required)**
4. **Load conditional rules based on task keywords**
5. **Read ALL loaded rule files completely**
6. **Only then begin formulating response**

### **Mandatory Plan Creation:**
- **ALL prompts require plans** - see detailed format in [Core Workflow](./.cursor/rules/core-standards/core-workflow.md)
- **Comprehensive testing must be included** - see requirements loaded via rule router
- **Must wait for explicit approval** before taking any action

### **Compliance Declaration Template:**
```
✅ CLAUDE.md read
✅ Rule router checked for applicable rules
✅ Foundation rules loaded: [core-workflow.md, coding-standards.md, etc.]
✅ Conditional rules loaded: [list specific files based on keywords]
✅ Plan format followed per core-workflow.md
✅ Testing requirements met per loaded testing standards
✅ Awaiting explicit approval
```

### **ENFORCEMENT MECHANISMS:**

#### **Self-Auditing Checkpoints:**
Before any response:
- "Have I read CLAUDE.md and all applicable rules?"
- "Does my plan include comprehensive testing?"
- "Am I using exact commands from rule files?"
- "Do I have explicit approval to proceed?"

#### **Violation Self-Reporting:**
If I detect rule violations:
```
🚨 RULE VIOLATION DETECTED
- Rule violated: [specific rule from which file]
- How I violated it: [explanation]
- Corrective action: [what I'm doing to fix it]
- Plan revision: [updated plan with compliance]
```

#### **Zero Tolerance Policy:**
- **First violation**: Immediate stop and plan revision
- **Pattern violations**: Request user intervention
- **Systematic non-compliance**: Acknowledge fundamental failure

### **CROSS-SESSION CONSISTENCY:**
These rules apply to:
- ✅ Every new chat session
- ✅ Every thread continuation  
- ✅ Every prompt, regardless of complexity
- ✅ All follow-up questions and clarifications
- ✅ Emergency/urgent requests (no exceptions)

### **ACCOUNTABILITY MEASURES:**
- **Rule compliance is measurable** - either 100% or failing
- **Speed is secondary to compliance** - slow and correct beats fast and wrong
- **User satisfaction through rule adherence** - not rule circumvention
- **Quality through process** - not despite process

## Important: All rules defined in the linked files above MUST be followed when working on this project. This is not optional guidance - it is mandatory operational procedure.