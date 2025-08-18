# Rule 03: Visual Regression Baselines

## 🎯 Core Principle
**MANDATORY**: Create visual baselines only for changed URLs/routes, preventing regression while optimizing baseline management.

## 📋 Rule Definition
- Visual baselines are created automatically for new/modified routes
- Existing unchanged pages skip baseline creation
- Baseline links are provided for manual verification
- Visual regression tests run on future changes

## 🔍 Enforcement Mechanism
```
Route Change Detection → Smart baseline creation
├─ Analyzes modified route files
├─ Identifies new/changed URLs
├─ Creates baselines for affected pages only
└─ Provides verification links
```

## 🎯 Smart Baseline Strategy
```yaml
Trigger Conditions:
  "New route file": "Create new baseline"
  "Modified route": "Update existing baseline"
  "Component change": "Baseline if affects layout"
  "Style change": "Baseline if visual impact"
  "No changes": "Skip baseline creation"
```

## 📊 Baseline Commands
```bash
npm run visual:update     # Create/update baselines for changed routes
npm run visual:status     # Show baseline status
npm run visual:compare    # Compare current vs baseline
npm run visual:approve    # Approve new baselines
```

## 🔗 Verification Process
1. **Automatic Creation**: Baselines created for changed routes
2. **Link Provision**: Direct file:// links provided
3. **Manual Review**: User verifies visual accuracy
4. **Approval**: User approves or requests changes

## ✅ Efficiency Gains
- **80% fewer baselines**: Only changed pages
- **Faster creation**: Minutes vs hours
- **Relevant testing**: No false positives from unchanged pages
- **Clear feedback**: Direct visual links

## 🎭 Hook Integration
- **PostToolUse**: Baseline creation trigger
- **Route Analysis**: Change detection
- **Link Generation**: Verification paths

## 📸 Baseline Organization
```
screenshots/baseline/
├─ route-name.png         # Main page view
├─ route-name-mobile.png  # Mobile variant
├─ route-name-tablet.png  # Tablet variant
└─ route-name-dark.png    # Dark theme variant
```

## 💡 Quality Features
- Multi-device baseline capture
- Theme variant support
- Responsive breakpoint testing
- Accessibility state capture

---
*Visual regression baselines ensure UI consistency while maintaining development velocity.*