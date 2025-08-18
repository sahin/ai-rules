# Rule 01: Plan-First Enforcement

## 🎯 Core Principle
**MANDATORY**: Every coding task must begin with an approved plan. No code generation before plan approval.

## 📋 Rule Definition
- All implementation requests must start with a structured plan
- Plans must follow the mandatory template format
- User approval is required before any code execution
- No exceptions for "simple" or "quick" tasks

## 🔍 Enforcement Mechanism
```
PreResponse Hook → Validates plan creation
├─ Blocks immediate help responses
├─ Requires plan template usage
├─ Enforces approval gate
└─ Tracks compliance metrics
```

## 🚫 Blocked Patterns
- "I'll help you..." (immediate assistance)
- "Let me..." (direct action)
- Code generation without plan
- Tool usage without approval

## ✅ Compliant Pattern
```markdown
## Plan: [Task Description]

1. **Research**: [Analysis completed]
2. **Implementation**: [Specific steps]
3. **Testing**: [Test strategy]

Would you like me to proceed with this plan?
```

## 📊 Success Metrics
- 100% plan creation rate
- 95% user approval rate
- 80% reduction in scope creep
- Improved project predictability

## 🎭 Hook Integration
- **PreResponse**: Blocks non-plan responses
- **UserPromptSubmit**: Loads plan template
- **PreToolUse**: Validates approval status

## 💡 Benefits
- Clear scope definition
- Reduced miscommunication
- Better time estimation
- Quality assurance through review

---
*This rule is the foundation of all development workflows and cannot be overridden.*