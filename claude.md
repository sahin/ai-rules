# Claude AI Assistant Rules

## 📁 DUAL-LOCATION STRUCTURE

This project uses a dual-location structure for Claude configuration:

### **Generic Rules (`.claude/`)** 
*Reusable across all projects - designed to be a git submodule*
- Universal coding standards
- Generic hooks and automation
- Language-agnostic patterns
- Common development workflows

### **Project Rules (`.claude-project/`)** 
*Project-specific configuration*
- **[Project Documentation](./.claude-project/CLAUDE.md)** - READ THIS FOR PROJECT CONTEXT
- Custom rules and patterns
- Domain-specific requirements
- Project architecture details

---

## 🚨 AUTOMATED WORKFLOW ACTIVE

### 🤖 HOOKS HANDLE THE HEAVY LIFTING:
- **Rule Loading**: Auto-loads from BOTH directories based on keywords  
- **Testing**: Runs smart tests after file changes
- **Commits**: Auto-commits at session end
- **Validation**: Enforces plan-first workflow

### 📡 DYNAMIC RULE LOADING:
The system automatically loads:
1. **Foundation rules** (always loaded)
2. **Generic rules** based on keywords (from `.claude/`)
3. **Project rules** based on keywords (from `.claude-project/`)

### 📚 WORKFLOW:
1. **Create plan** using template format
2. **Get approval** from user
3. **Write code** (tests run automatically)
4. **Session ends** (auto-commit happens)

---

## 🚨 CRITICAL: 100% RULE COMPLIANCE REQUIRED

### **FUNDAMENTAL PRINCIPLE:**
**I am a "rule-following assistant who happens to be helpful" NOT a "helpful assistant who sometimes follows rules"**

## 📋 PLAN-FIRST APPROACH (MANDATORY)

**Template**: `.claude/rules/user/_mandatory/01-workflow-plan-template.md`

Every task MUST begin with a comprehensive plan. NEVER proceed without explicit user approval.

## 🎯 AUTOMATED TESTING

### **PostToolUse Hook:**
- Detects file changes and runs affected tests
- Shows results inline: "✅ 3 tests passed" or "⚠️ Some tests failed"
- Skips if >10 tests would run (run manually)

## 🔒 COMPLIANCE TRACKING

### **Automated:**
✅ Rules auto-loaded from both directories
✅ Tests run after changes
✅ Changes committed at session end
✅ Plan-first enforced

### **Manual Requirements:**
- Create plans using template
- Wait for user approval
- Follow ALL loaded rules
- Check project CLAUDE.md for specifics

## 🪝 ACTIVE HOOKS

| Hook | Trigger | What It Does |
|------|---------|--------------|
| **UserPromptSubmit** | User message | Loads rules from both directories |
| **PreToolUse** | Before tools | Validates plan approval |
| **PostToolUse** | After edits | Runs smart tests |
| **Stop** | Session end | Auto-commits changes |

### **Configuration:**
- **Generic settings**: `.claude/settings.json`
- **Local settings**: `.claude/settings.local.json`
- **Session data**: `.claude/session/`
- **Metrics**: `.claude/metrics/`

---

## ⚠️ IMPORTANT

**For project-specific requirements, architecture, and domain rules:**
### **→ [READ PROJECT DOCUMENTATION](./.claude-project/CLAUDE.md) ←**

All rules from BOTH locations must be followed. Generic rules provide the foundation, project rules add specific requirements.