# Rule 06: Dynamic Rule Loading

## 🎯 Core Principle
**MANDATORY**: Rules are loaded dynamically based on keywords, context, and project needs, optimizing performance while ensuring comprehensive coverage.

## 📋 Rule Definition
- Rules load automatically based on user message keywords
- Context-aware loading reduces token usage by 60%
- Both global and project-specific rules are considered
- Dependencies between rules are automatically resolved

## 🔍 Loading Mechanism
```
Keyword Detection → Rule Selection → Dynamic Loading
├─ Scans user message for trigger words
├─ Maps keywords to relevant rule files
├─ Loads global rules (.claude/rules/user/)
├─ Loads project rules (.claude-project/rules/)
└─ Resolves dependencies and conflicts
```

## 🎯 Keyword Mapping
```yaml
Development Keywords:
  "frontend", "react", "component" → frontend-development.md
  "backend", "api", "database" → backend-development.md
  "test", "testing", "spec" → testing-standards.md
  "deploy", "production" → deployment-rules.md

Project Keywords:
  "database", "model", "schema" → database-rules.md
  "auth", "security", "login" → security-rules.md
  "multi-tenant", "isolation" → security-rules.md
```

## 📊 Loading Strategy
- **Minimal Base**: Always load mandatory rules
- **Contextual Expansion**: Add relevant rules based on keywords
- **Project Overlay**: Apply project-specific modifications
- **Dependency Resolution**: Load required supporting rules

## 🔄 Rule Hierarchy
```
Priority Order:
1. Mandatory rules (always loaded)
2. Project-specific rules (override globals)
3. Global rules (provide foundation)
4. Contextual rules (add specificity)
```

## ✅ Performance Benefits
- **60% token reduction**: Only load relevant rules
- **Faster responses**: Less processing overhead
- **Targeted guidance**: More specific, actionable advice
- **Scalable system**: Handles growing rule libraries

## 🎭 Loading Integration
- **UserPromptSubmit Hook**: Triggers loading process
- **Keyword Analysis**: Natural language processing
- **Rule Caching**: Avoid redundant loading
- **Session Memory**: Maintain loaded rules across interactions

## 📝 Loading Configuration
```json
{
  "rule_loading": {
    "strategy": "dynamic",
    "cache_duration": 3600,
    "max_rules_per_session": 15,
    "keyword_sensitivity": 0.8,
    "auto_dependency_resolution": true
  }
}
```

## 💡 Advanced Features
- **Learning System**: Improves keyword detection over time
- **Usage Analytics**: Tracks which rules are most valuable
- **Conflict Detection**: Prevents contradictory rules
- **Custom Mappings**: Project-specific keyword associations

---
*Dynamic rule loading ensures you get the right guidance at the right time.*