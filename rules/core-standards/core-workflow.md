# Universal Development Practices

## 🚨 CRITICAL RULE - PLAN APPROVAL REQUIRED 🚨

### THIS IS THE MOST IMPORTANT RULE - MUST BE FOLLOWED FOR EVERY PROMPT

**After receiving ANY user prompt, you MUST:**

1. **STOP and CREATE A PLAN FIRST**
   - Present a detailed plan of all intended actions
   - Break down the plan into clear, numbered steps
   - Explain what each step will accomplish
   - List any files that will be created, modified, or deleted
   - Identify potential risks or side effects

2. **MANDATORY: INCLUDE TESTING IN EVERY PLAN**
   - **Every plan MUST include comprehensive testing steps**
   - **Testing will be implemented AFTER feature completion**
   - **Plans must show feature implementation followed by testing phase**
   - **Testing time must be estimated (minimum 30% of development time)**

3. **WAIT FOR EXPLICIT APPROVAL**
   - End your response with: "Would you like me to proceed with this plan?" (approval semantics in `_mandatory/02-approval-gate.md`)
   - Do NOT take any actions until the user explicitly approves
   - Acceptable approval responses: See `_mandatory/02-approval-gate.md`
   - If unclear, ask for clarification

4. **MANDATORY PLAN FORMAT**
   **📍 NOTE: This format has been extracted to [workflow-plan-template.md](../workflow-plan-template.md) for easier access**
   **🚨 You MUST read workflow-plan-template.md and use that EXACT format**
   
   ```
   ## Plan:
   
   1. **[Action Category]**: [Brief description]
      - Specific file/component affected
      - What will change
      - Why this is needed
   
   2. **[Next Action]**: [Description]
      - Details...
   
   3. **🧪 TESTING PHASE** (REQUIRED):
      - **Reference**: See `.cursor/rules/general-policies/testing/core-standards.md` for complete testing requirements
      - **Code changes**: Unit, integration, user, performance, error handling, regression tests
      - **Config/schema changes**: Full test suite validation required
      - **Documentation changes**: Link validation and format review only
      - **Commands**: `npm run test:smart --dry-run` → `npm run test:smart` → `npm run build`
   
   Files to be modified:
   - [List of all files that will be created, modified, or deleted]
   
   Testing files to create/update:
   - [List of test files that will be created or modified]
   
   Potential Impact:
   - [Any risks or considerations]
   
   Would you like me to proceed with this plan?
   ```

5. **🔒 TESTING ENFORCEMENT - NO EXCEPTIONS**
   - **IMMEDIATE ACTIONS FOR MISSING TESTING:**
     - Stop current work immediately
     - Revise plan to include comprehensive testing
     - No code changes until testing plan is approved
     - Re-estimate timeline including testing requirements
   
   - **PLANS WITHOUT TESTING ARE INVALID:**
     - Must include specific test types required
     - Must estimate testing time (minimum 30% of dev time)
     - Must define testing acceptance criteria
     - Must specify which test commands to run

6. **NO EXCEPTIONS**
   - This rule applies to ALL prompts, no matter how simple
   - Even for clarification requests, explain testing implications
   - For multi-step tasks, get approval for the complete plan with testing first

## 🚀 FEATURE-FIRST DEVELOPMENT WORKFLOW

### **MANDATORY: Development Flow for Features**

After plan approval, follow this exact workflow:

1. **IMPLEMENT FEATURE FIRST**
   - Focus on implementing the feature functionality
   - Complete the feature implementation before writing tests
   - Show all changes made to the user
   - **NEW: Verify implementation follows general-policies/testing/core-standards.md build requirements**
   - **NEW: Ensure feature is testable and working before proceeding**

2. **SHOW CHANGES AND PROMPT**
   After making any changes, you MUST:
   - Display the changes clearly
   - **NEW: Show verification status per general-policies/testing/core-standards.md requirements**
   - **NEW: Report if the feature in localhost is functional**
   - Ask one of these questions:
     1. "Do you want me to make more changes to this feature?"
     2. "Feature looks complete. Should I write the tests now?"
     3. "Should I move to the next feature?"

3. **WORKFLOW DECISION POINTS**
   Based on user response:
   - **"1" or "Make more changes"** → Continue feature development
   - **"2" or "Write tests"** → Implement comprehensive tests for the completed feature
   - **"3" or "Next feature"** → Move to the next feature in the plan
   - **No response/unclear** → Ask for clarification

4. **MANDATORY PROMPTING FORMAT**
   After EVERY code change:
   **CHANGED: Added verification status indicators**
   ```
   [Show the changes/implementation]
   
   **NEW: ✅ Build Verification: Passing/Failing (per general-policies/testing/core-standards.md)**
   **NEW: ✅ Code Quality: X issues (per typescript-configuration-guide.md)**
   **NEW: ✅ Feature Status: Working/Not Working/Has Issues**
   
   What would you like me to do next?
   1. Make more changes to this feature (type: add)
   2. Feature is complete, write tests (type: tests)
   3. Move to the next feature (type: next)
   ```

5. **TESTING PHASE (AFTER FEATURE COMPLETION)**
   When user confirms feature is complete:
   - Write comprehensive tests as specified in general-policies/testing/core-standards.md
   - **NEW: Include all test types required by general-policies/testing/core-standards.md**
   - **NEW: Verify all tests pass before proceeding**
   - Show test implementation
   - Ask if tests are sufficient or need modifications

6. **GIT COMMIT PHASE (AFTER TESTS COMPLETION)**
   When tests are complete and passing:
   - Show a git status to see all changed files
   - Generate appropriate commit message based on changes
   - Show the git commit command (DO NOT RUN IT)
   - Show git push/sync commands if needed
   - Wait for user approval before executing

**NEW: ### CONTINUOUS VERIFICATION REQUIREMENTS**

**NEW: During ALL development phases:**
**NEW: - Follow verification steps from general-policies/testing/core-standards.md**
**NEW: - Ensure code meets standards in typescript-configuration-guide.md**
**NEW: - Verify feature functionality before declaring complete**
**NEW: - Fix any issues immediately per code-review-rules.md**
   
   **MANDATORY GIT COMMIT FORMAT:**
   ```
   # Show what will be committed
   git status
   
   # Stage the feature and test files
   git add [list of feature files]
   git add [list of test files]
   
   # Commit with descriptive message
   git commit -m "feat: [brief description of feature]

   - [detailed point 1]
   - [detailed point 2]
   - Added comprehensive tests for [feature]"
   
   # Show push command (if on a branch)
   git push origin [branch-name]
   ```
   
   **PROMPT AFTER SHOWING GIT COMMANDS:**
   ```
   Here are the git commands for this feature. 
   Would you like me to:
   1. Execute these git commands
   2. Modify the commit message
   3. Add/remove files from the commit
   4. Skip git operations
   ```

### POST-FEATURE DEVELOPMENT LOOP (MANDATORY ITERATIVE PROCESS)

After initial feature implementation and testing:

1. **BUILD COMPREHENSIVE TESTS (Iterative)**:
   - **Unit Tests**: Build isolated tests for functions/components
   - **UX Tests**: Test loading states, error messages, button states, form validation UX
   - **UI Tests**: Verify component rendering, prop variations, and accessibility (WCAG 2.1 AA)
   - **Playwright E2E Tests**: Implement critical user journeys, cross-browser compatibility, and visual documentation
   - **Reference**: See `general-policies/testing/core-standards.md` (principles), `general-policies/testing/playwright-first.md` (strategy), and `testing/smart-testing.md` (execution) for detailed requirements

2. **ITERATIVE REFINEMENT LOOP**:
   - **Wait for Fixes**: If tests fail or issues are found, re-enter development phase to fix bugs
   - **Wait for New Features**: If the current feature depends on another unbuilt feature, pause and resume once dependencies are met
   - **Wait for Completed**: Continue in this loop until the requested feature flow is fully working and approved

3. **APPROVAL & MERGE PROCESS (Final Step)**:
   - **Branch Creation**: Once the feature is fully working, all tests pass, and behavior is approved, create a new feature branch (e.g., `feat/my-new-feature`)
   - **Pull Request (PR)**: Create a Pull Request against the default branch (e.g., `main` or `develop`, per repository policy)
   - **Automated Tests Pass**: Ensure all CI/CD tests (including Unit, Integration, API, and E2E Playwright tests) pass successfully on the PR
   - **Code Review & Approval**: Obtain necessary code reviews and approvals
   - **Merge**: Merge the feature branch into the default branch after approvals and passing checks

---

## ✅ FEATURE DEVELOPMENT STANDARDS

**Every new feature MUST include the following:**

### **Loading States**
- Show loading spinners or skeletons during data fetching
- Disable buttons during mutations to prevent double-clicks
- Display appropriate loading indicators for all async operations

### **Comprehensive Error Handling**
- Catch and display user-friendly error messages
- Implement error boundaries for React components
- Log detailed errors for debugging, but never expose system details to the user

### **Form Validation**
- Validate all inputs on the client and server
- Show clear, field-level error messages
- Prevent submission with invalid data

### **Accessibility (a11y)**
- Include proper ARIA labels and roles
- Ensure keyboard navigation works correctly
- Use semantic HTML and maintain WCAG 2.1 AA compliance

### **Empty States**
- Create beautiful, smart empty data states with meaningful icons, helpful messaging, and relevant action buttons

---

## 🧪 TESTING STRATEGY & INTEGRATION

- **Four-Layer Approach**: Employ a mix of Unit, Integration, API, and E2E tests

### 📸 Visual Feature Documentation (MANDATORY for Web Features)
After implementing any web-related feature, you MUST:

1. **Create Visual Documentation Test**
   ```typescript
   // e2e/features/[feature]/feature-demo.spec.ts
   test('document [feature] workflow', async ({ page }) => {
     // Capture screenshots at each step
     // Video automatically records entire flow
   });
   ```

2. **Capture All States**
   - Initial/empty state
   - Loading states
   - Success states
   - Error states
   - Mobile responsive views

3. **Save Documentation**
   - Screenshots: `test-results/[feature]/[date]/screenshot-*.png`
   - Videos: `test-results/[feature]/[date]/video.webm`
   - Context: `test-results/[feature]/[date]/success-context.md`

4. **Update Feature Docs**
   - Link visual assets in feature documentation
   - Include both desktop and mobile screenshots
   - Document any edge cases visually

- **Requirements**: All new features must be tested with a minimum coverage of Unit (80%), Integration (70%), and API (90%)
- **Build Validation (CRITICAL)**: Always run `npm run build` to validate JSX/TSX syntax, as `tsc --noEmit` is not sufficient

---

## 📝 Documentation Requirements

### 1. **MANDATORY: Update Documentation for All Changes**
When making ANY change to the codebase, you MUST:

#### **Always Update Documentation**
- Update relevant `.md` files in `docs/` folder
- Update inline code comments for complex logic
- Update API documentation for endpoint changes
- Update README files for setup/usage changes

#### **Always Update CHANGELOG.md**
- Add entry to `CHANGELOG.md` for every significant change
- Use semantic versioning categories:
  - **Added** - New features
  - **Changed** - Changes in existing functionality  
  - **Deprecated** - Soon-to-be removed features
  - **Removed** - Removed features
  - **Fixed** - Bug fixes
  - **Security** - Security improvements

### 2. **Documentation Update Rules**

#### **Code Changes Requiring Documentation:**
- New components/services/APIs → Update component docs
- Modified APIs → Update API documentation
- New environment variables → Update setup guides
- Changed file structure → Update relevant guides
- New dependencies → Update installation instructions
- Modified workflows → Update development guides

#### **CHANGELOG Format:**
```markdown
## [Version] - YYYY-MM-DD

### Added
- New feature description with brief explanation

### Changed  
- Modified feature description with impact

### Fixed
- Bug fix description with root cause

### Removed
- Removed feature with migration notes
```

### 3. **Documentation Quality Standards**

#### **Requirements:**
- **Clear Examples**: Include code examples for APIs/components
- **Up-to-Date**: Remove outdated information immediately
- **Comprehensive**: Cover setup, usage, troubleshooting
- **Accessible**: Use clear language, proper headings
- **Linked**: Cross-reference related documentation

#### **Documentation Examples:**
- **See** `.cursor/rules/project-coding-standards.md` for concrete documentation examples
- **Both generic and project-specific examples** are provided there
- **Follow the structure** shown in the coding standards file

### 4. **Documentation Workflow**

#### **Before Making Changes:**
1. Identify affected documentation
2. Plan documentation updates alongside code changes
3. Include documentation time in estimates

#### **During Development:**
1. Update documentation as you code
2. Keep examples current with implementation
3. Update tests that verify documentation examples

#### **Before Submitting:**
1. Review all documentation changes
2. Test documentation examples
3. Verify CHANGELOG entry is complete
4. Check for broken links or references

### 5. **Special Cases**

#### **Breaking Changes:**
- **MUST** include migration guide
- **MUST** update major version in CHANGELOG
- **MUST** document compatibility impacts
- **MUST** provide before/after examples

#### **New Features:**
- **MUST** include usage examples
- **MUST** document all props/parameters
- **MUST** include troubleshooting section
- **MUST** link to related documentation

#### **Bug Fixes:**
- **MUST** document root cause (briefly)
- **MUST** include steps to prevent recurrence
- **MUST** update related troubleshooting docs

### 6. **Documentation Enforcement**

#### **Code Review Requirements:**
- [ ] Documentation updated for all changes
- [ ] CHANGELOG.md entry added
- [ ] Examples tested and working
- [ ] Links verified
- [ ] Outdated information removed

#### **Automated Checks:**
- Documentation must be updated in same PR as code
- CHANGELOG.md must be modified for significant changes
- No documentation TODOs left in production code

## 🛡️ CODE QUALITY & SECURITY

### **TypeScript Best Practices**
- Enable strict mode and avoid `any` type
- Use explicit types for function parameters and return values

### **Security Best Practices**
- See `general-policies/backend/security.md` for the complete security checklist
- Validate all user inputs on both client and server
- Sanitize data to prevent XSS and other injection attacks
- Never hardcode sensitive information; use environment variables

---

## 📊 PERFORMANCE GUIDELINES

- **Key Patterns**: Use query optimization, pagination, component memoization, virtual scrolling, and code splitting
- **Considerations**: Implement loading states everywhere, optimize re-renders, and monitor bundle size

---

## 🚫 NO MOCK DATA RULE

- **NEVER** hardcode mock or sample data in UI components or production code. All data must come from an API
- Development data should be managed through database seeders

---

## 📁 FILE ORGANIZATION RULES

### 🚫 **FILE PLACEMENT RULE**

**Files belong in their domain folder, not root.** Creating a component? → `apps/frontend/src/`. Writing an API? → `apps/backend/src/`. Simple.

**Root = configs only.**

### **Root Directory Cleanliness (MANDATORY)**

The project root directory must remain clean and organized. Only the following files are allowed in the root:

#### **Allowed in Root:**
- Configuration files (package.json, tsconfig.json, vite.config.ts, etc.)
- Essential documentation (README.md, CHANGELOG.md, CLAUDE.md)
- License and security files (LICENSE, SECURITY.md)
- Git-related files (.gitignore, .gitattributes)
- IDE configuration folders (.vscode, .cursor)

#### **NOT Allowed in Root (MUST be organized):**
- Implementation summaries (*_SUMMARY.md, *_COMPLETE.md, *_ANALYSIS.md)
- Fix documentation (*_FIXES.md, *_FIX_*.md)
- Feature implementation docs (*_IMPLEMENTATION.md)
- Test files (test-*.html, test-*.sh)
- Temporary documentation or notes

### **Documentation Organization:**

#### **All documentation MUST follow this structure:**
```
docs/
├── completed-fixes/       # Completed fix summaries and analyses
│   ├── *_SUMMARY.md
│   ├── *_ANALYSIS.md
│   ├── *_COMPLETE.md
│   └── *_FIXES.md
├── in-progress/          # Work in progress documentation
├── visual/                          # Visual architecture docs
├── api/                  # API documentation
├── guides/               # How-to guides
└── *.md                  # General documentation
```

#### **Automatic File Placement Rules:**
1. **Fix/Implementation Summaries**: 
   - Files matching patterns: `*_SUMMARY.md`, `*_FIXES.md`, `*_COMPLETE.md`, `*_ANALYSIS.md`, `*_IMPLEMENTATION.md`
   - **MUST** go to: `docs/completed-fixes/`

2. **Test Files**:
   - HTML test files: `test-*.html` → `tests/`
   - Shell test scripts: `test-*.sh` → `scripts/` or `tests/`

3. **Temporary Files**:
   - Any temporary documentation or WIP files → `docs/in-progress/`
   - Should be moved to proper location or deleted when complete

### **Enforcement:**
- **Before ANY commit**: Check root directory for misplaced files
- **During code review**: Verify no documentation files in root
- **CI/CD check**: Automated validation of root directory cleanliness

### **Moving Files Workflow:**
When you find misplaced files in root:
1. Identify the file type and proper location
2. Move file to correct directory
3. Update any references to the file
4. Update .gitignore if needed
5. Commit with message: `chore: organize documentation files`

---

## 🔧 GIT WORKFLOW

- Use conventional commits (`feat:`, `fix:`, `chore:`)
- Write clear, descriptive, and atomic commit messages
- Reference issue numbers in commits

---

## 🔄 RULE CHANGE PROTOCOL (MANDATORY)

### **When Changing ANY Rule File:**

#### **1. Pre-Change Requirements:**
- **Create a plan** detailing all rule changes
- **Identify impact** on other rule files and documentation
- **Get explicit approval** before making changes

#### **2. Post-Change Checklist (MANDATORY):**
When any rule file is modified, you MUST:

- [ ] **Check ALL .md files** in the project for references to the changed rule
- [ ] **Search for AI/LLM/IDE instruction files** - these could be named anything but often contain:
  - Instructions for AI assistants
  - Development guidelines
  - Coding standards
  - Project-specific rules
  - Files that IDEs or AI tools might read for context
- [ ] **Verify compatibility** with development tools:
  - VS Code + GitHub Copilot
  - Cursor
  - Windsurf  
  - Claude Code
  - JetBrains AI Assistant
  - Other AI-powered development tools
- [ ] **Update cross-references** between rule files
- [ ] **Fix broken links** to renamed or moved rules
- [ ] **Update rule descriptions** in overview files
- [ ] **Check for outdated examples** that reference old rule formats

#### **3. How to Find AI/IDE Rule Files:**
```bash
# MANDATORY: Search for potential AI/IDE instruction files

# Find all .md files that might contain rules or instructions
find . -name "*.md" -type f | grep -v node_modules | xargs grep -l -i -E "(rule|guideline|standard|instruction|AI|LLM|assistant|IDE|development|coding)"

# Search for common AI/IDE configuration patterns in .md files
grep -r -i --include="*.md" -E "(must follow|mandatory|required|rule|guideline|AI assistant|LLM|IDE)" . | grep -v node_modules

# Look for instruction-like content in any .md file
find . -name "*.md" -exec grep -l "follow\|adhere\|comply\|must\|should\|require" {} \; 2>/dev/null | grep -v node_modules

# Known common locations to check:
- /.cursor/rules/*.md          # Cursor rules
- /CLAUDE.md                   # Claude AI rules  
- /.cursorrules               # Cursor rules file
- /.github/*.md               # GitHub documentation
- /docs/*.md                  # Documentation that might contain rules
- /README.md                  # Often contains development guidelines
- /CONTRIBUTING.md            # Contribution guidelines
- Any .md file in project root
```

#### **4. Rule Change Workflow:**
1. **Plan the change** with full impact analysis
2. **Get approval** for the plan
3. **Make the rule change**
4. **Search all .md files** for potential AI/IDE instructions
5. **Update all references** found
6. **Verify the rules still make sense** for AI tools and IDEs
7. **Document the change** in CHANGELOG.md

#### **5. What to Look For:**
When checking .md files, look for:
- References to the changed rule file
- Instructions that might conflict with the change
- Guidelines that need updating
- Examples that use old rule formats
- Cross-references between documentation
- Any file that provides instructions to developers or AI tools

### **Rule Synchronization Requirements:**
- **Discovery-based approach**: Search for instruction files rather than assuming names
- **Content-aware**: Look for files containing rules/guidelines regardless of filename
- **AI Tool Agnostic**: Rules must work across different AI assistants and LLMs
- **Consistency**: All rule files must be internally consistent
- **Version control**: Track all rule changes in git history

## 📋 Code Review Checklist

Before submitting any feature:
- [ ] Loading states implemented
- [ ] Error handling added
- [ ] Tests written and passing
- [ ] **Documentation updated** ✨ NEW
- [ ] **CHANGELOG.md updated** ✨ NEW
- [ ] Types properly defined
- [ ] Accessibility verified
- [ ] Performance optimized
- [ ] Security validated
- [ ] Code reviewed

## 🎯 **PRAGMATIC TYPESCRIPT POLICY**

### **TypeScript Error Management Strategy**

#### **Development vs Production Standards:**

**Development Environment:**
- ✅ TypeScript errors are **warnings**, not blockers
- ✅ Focus on **functionality** over type perfection
- ✅ Gradual type improvements encouraged
- ✅ Developer productivity prioritized

**Production Deployment:**
- 🚨 **Critical Errors**: Must be fixed (security, runtime crashes)
- ⚠️ **Type Errors**: Can be deployed with documented plan
- 📊 **Error Threshold**: Maximum **500 TypeScript errors**
- 📈 **Improvement Requirement**: Each sprint must **reduce error count**

#### **Acceptable TypeScript Errors:**
- ✅ **Unused variable warnings** (`no-unused-vars`)
- ✅ **Missing type annotations** on legacy code
- ✅ **Third-party library type mismatches**
- ✅ **Complex generic type issues**
- ✅ **Legacy code without strict typing**

#### **Unacceptable TypeScript Errors:**
- ❌ **Security vulnerabilities** (exposed secrets, XSS potential)
- ❌ **Runtime crash potential** (null pointer exceptions)
- ❌ **Data corruption risks** (type coercion issues)
- ❌ **API contract violations** (incorrect request/response types)

### **Gradual Improvement Workflow:**

#### **For New Code:**
```typescript
// ✅ REQUIRED: All new code must be properly typed
function createUser(data: CreateUserDto): Promise<User> {
  // New functions must have explicit types
}
```

#### **For Legacy Code:**
```typescript
// ✅ ALLOWED: Fix types when touching the file
function legacyFunction(data: any) { // Fix this when editing
  // Opportunistic improvements when working in this area
}
```

#### **Technical Debt Management:**
- **Sprint Planning**: Allocate 20% of sprint to type improvements
- **Boy Scout Rule**: When working on old files, fix TypeScript errors
- **Tracking**: Monitor error count trends in each release
- **Target**: Reduce errors by 10-20 per sprint

### **Quality Gates Updated:**

```yaml
quality_gates:
  production:
    critical_errors: 0           # Security, runtime crashes
    typescript_errors: < 500     # Reasonable threshold
    error_trend: decreasing      # Must improve over time
    new_code_coverage: 90%       # New code must be well-typed
  
  development:
    typescript_errors: warning_only
    new_code_typed: required
    legacy_fixes: opportunistic
    build_blocking: false        # Don't block development
``` 