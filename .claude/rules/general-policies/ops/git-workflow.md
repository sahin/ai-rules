# Git Workflow Standards

## 🌿 BRANCH NAMING CONVENTIONS (MANDATORY)

### **Branch Types**
All branches must follow standardized naming patterns:

#### **Feature Branches**
```bash
# Pattern: feature/[ticket-id]-short-description
feature/PROJ-123-user-authentication
feature/PROJ-456-payment-integration
feature/dashboard-improvements  # If no ticket system
```

#### **Bug Fix Branches**
```bash
# Pattern: bugfix/[ticket-id]-short-description  
bugfix/PROJ-789-login-redirect-issue
bugfix/PROJ-101-payment-timeout
bugfix/memory-leak-fix  # If no ticket system
```

#### **Hotfix Branches**
```bash
# Pattern: hotfix/[ticket-id]-critical-fix
hotfix/PROJ-999-security-vulnerability
hotfix/PROJ-888-payment-gateway-down
hotfix/production-crash-fix
```

#### **Release Branches**
```bash
# Pattern: release/v[version]
release/v2.1.0
release/v1.5.2-hotfix
```

#### **Maintenance Branches**
```bash
# Pattern: maintenance/[purpose]
maintenance/dependency-updates
maintenance/security-patches
maintenance/performance-improvements
```

### **Branch Naming Rules**
- Use **lowercase** with **hyphens** for separation
- Include **ticket ID** when available
- Keep descriptions **short but descriptive** (max 50 characters)
- Use **present tense** for actions (`add-feature`, not `added-feature`)

---

## 📝 COMMIT MESSAGE STANDARDS (MANDATORY)

### **Conventional Commits Format**
All commits must follow the Conventional Commits specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### **Commit Types**
```bash
feat:     # New feature
fix:      # Bug fix  
docs:     # Documentation changes
style:    # Code style changes (formatting, no logic change)
refactor: # Code refactoring (no functional changes)
test:     # Adding or updating tests
chore:    # Build tasks, dependency updates, etc.
perf:     # Performance improvements
ci:       # CI/CD configuration changes
revert:   # Reverts a previous commit
```

#### **Commit Examples**
```bash
# Feature commits
feat(auth): add OAuth2 integration with Google
feat(payments): implement Stripe payment processing
feat: add user profile dashboard

# Bug fix commits
fix(login): resolve redirect loop after authentication
fix(api): handle null pointer in user lookup
fix: prevent memory leak in image processing

# Documentation commits
docs(README): update installation instructions
docs(api): add endpoint documentation for payments
docs: add troubleshooting guide

# Refactoring commits
refactor(database): extract connection pool logic
refactor(components): simplify user profile component
refactor: optimize database query performance

# Test commits
test(auth): add integration tests for login flow
test(payments): add unit tests for payment validation
test: increase coverage for user service

# Chore commits
chore(deps): update React to v18.2.0
chore(build): optimize webpack configuration
chore: update Node.js to LTS version
```

### **Commit Message Guidelines**
- **Subject line**: Max 72 characters, present tense, no period
- **Body**: Explain **what** and **why**, not how (optional)
- **Footer**: Reference issues, breaking changes (optional)

```bash
# Good commit with body and footer
feat(payments): add support for recurring subscriptions

Implement monthly and yearly subscription options with automatic
billing cycle management. Includes payment retry logic and
customer notification system.

Closes #456
Breaking change: Payment API now requires subscription_type field
```

### **Commit Message Requirements**
- [ ] Use conventional commit format
- [ ] Subject line under 72 characters
- [ ] Present tense, imperative mood ("add" not "added")
- [ ] Reference ticket numbers when available
- [ ] No trailing periods in subject
- [ ] Capitalize first letter of subject

---

## 🔄 PULL REQUEST REQUIREMENTS (MANDATORY)

### **PR Creation Standards**
Every pull request must meet these requirements:

#### **PR Title Format**
```bash
# Follow same format as commit messages
feat(auth): Add OAuth2 integration with Google
fix(payments): Resolve timeout issues in Stripe integration
docs: Update API documentation for v2.1
```

#### **PR Description Template**
```markdown
## Summary
Brief description of what this PR does and why.

## Changes Made
- [ ] Added OAuth2 authentication flow
- [ ] Updated user model to include provider field  
- [ ] Added integration tests for auth flow
- [ ] Updated documentation

## Testing Done
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Edge cases tested

## Breaking Changes
- None / List any breaking changes

## Related Issues
- Closes #123
- Related to #456

## Screenshots/Videos (if applicable)
[Add screenshots or videos showing the changes]

## Deployment Notes
Any special considerations for deployment.
```

### **Pre-PR Checklist (MANDATORY)**
Before creating a pull request, ensure:

- [ ] **Code Quality**
  - [ ] All tests pass locally
  - [ ] Code follows project style guide
  - [ ] No linting errors
  - [ ] TypeScript compilation successful

- [ ] **Testing Requirements**
  - [ ] Unit tests written for new features
  - [ ] Integration tests added where needed
  - [ ] Test coverage meets minimum requirements (80%)
  - [ ] Manual testing performed

- [ ] **Documentation**
  - [ ] Code comments added for complex logic
  - [ ] API documentation updated
  - [ ] README updated if needed
  - [ ] CHANGELOG.md updated

- [ ] **Security & Performance**
  - [ ] No sensitive data exposed
  - [ ] Performance impact considered
  - [ ] Security review completed
  - [ ] Dependencies audited

### **PR Review Requirements**
- **Minimum reviewers**: 1 for small changes, 2 for major changes
- **Required approvals**: At least 1 approval before merge
- **Automated checks**: All CI/CD checks must pass
- **Review criteria**: Functionality, code quality, security, performance

### **PR Size Guidelines**
- **Small PR**: < 200 lines changed (preferred)
- **Medium PR**: 200-500 lines changed  
- **Large PR**: > 500 lines changed (requires justification)

```bash
# Check PR size before creating
git diff --stat main..feature/my-branch

# If too large, consider splitting into smaller PRs
git checkout feature/my-branch-part-1
git cherry-pick commit1 commit2
git checkout feature/my-branch-part-2  
git cherry-pick commit3 commit4
```

---

## 🚫 PROTECTED BRANCH RULES (MANDATORY)

### **Main/Master Branch Protection**
The main branch must have these protections:

```yaml
# GitHub branch protection settings
branch_protection:
  main:
    required_status_checks:
      strict: true
      contexts:
        - continuous-integration
        - code-quality
        - security-scan
    
    enforce_admins: true
    required_pull_request_reviews:
      required_approving_review_count: 1
      dismiss_stale_reviews: true
      require_code_owner_reviews: true
    
    restrictions:
      users: []
      teams: ["core-developers"]
    
    allow_force_pushes: false
    allow_deletions: false
```

### **Direct Push Prevention**
```bash
# ❌ NEVER DO THIS - Direct push to main
git checkout main
git commit -m "Quick fix"
git push origin main

# ✅ ALWAYS DO THIS - Create PR
git checkout -b bugfix/quick-fix  
git commit -m "fix: resolve critical issue"
git push origin bugfix/quick-fix
# Then create PR through GitHub/GitLab
```

---

## 🔀 MERGE STRATEGIES (MANDATORY)

### **Merge Strategy by Branch Type**

#### **Feature Branches**
```bash
# Use squash merge for clean history
git checkout main
git merge --squash feature/PROJ-123-new-feature
git commit -m "feat(feature): add user dashboard functionality

- Implement user profile management
- Add responsive design for mobile
- Include comprehensive test suite

Closes #123"
```

#### **Hotfix Branches**
```bash
# Use regular merge to preserve context
git checkout main
git merge --no-ff hotfix/PROJ-999-critical-fix
```

#### **Release Branches**
```bash
# Use merge commit to mark release points
git checkout main
git merge --no-ff release/v2.1.0
git tag v2.1.0
```

### **Merge Requirements**
- All CI/CD checks must pass
- Required approvals obtained
- No merge conflicts
- Target branch up-to-date
- Security scans completed

---

## 🏷️ TAGGING STRATEGY (MANDATORY)

### **Version Tagging**
Use semantic versioning for release tags:

```bash
# Semantic versioning: MAJOR.MINOR.PATCH
git tag v1.0.0    # Initial release
git tag v1.0.1    # Patch release (bug fixes)
git tag v1.1.0    # Minor release (new features, backward compatible)
git tag v2.0.0    # Major release (breaking changes)

# Push tags to remote
git push origin --tags
```

### **Tag Annotations**
```bash
# Create annotated tags with release notes
git tag -a v1.2.0 -m "Release v1.2.0

Features:
- Add user authentication system
- Implement payment processing
- Add dashboard analytics

Bug Fixes:
- Fix memory leak in image processing  
- Resolve login redirect issues

Breaking Changes:
- API endpoint /users now requires authentication"
```

### **Pre-release Tags**
```bash
# For beta/alpha releases
git tag v1.2.0-beta.1
git tag v1.2.0-alpha.3  
git tag v1.2.0-rc.1     # Release candidate
```

---

## 🚀 RELEASE WORKFLOW (MANDATORY)

### **Release Branch Workflow**
```bash
# 1. Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# 2. Finalize version numbers and documentation
# Update package.json, CHANGELOG.md, etc.
git add .
git commit -m "chore(release): prepare v1.2.0 release"

# 3. Create PR to main
# PR title: "Release v1.2.0"
# Run all tests, security scans, performance tests

# 4. After PR approval and merge
git checkout main
git pull origin main
git tag v1.2.0
git push origin v1.2.0

# 5. Merge back to develop
git checkout develop  
git merge main
git push origin develop

# 6. Delete release branch
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

### **Hotfix Workflow**
```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/v1.2.1-security-fix

# 2. Make critical fix
git add .
git commit -m "fix(security): patch XSS vulnerability in user input"

# 3. Create PR to main (expedited review)
# 4. After merge, tag immediately
git checkout main
git pull origin main
git tag v1.2.1
git push origin v1.2.1

# 5. Merge to develop
git checkout develop
git merge main
git push origin develop
```

---

## 📊 GIT WORKFLOW METRICS (RECOMMENDED)

### **Track These Metrics**
```bash
# Lead time (time from commit to deployment)
git log --since="1 week ago" --pretty=format:"%h %ad %s" --date=iso

# Deployment frequency
git tag --sort=-version:refname | head -10

# Change failure rate
git log --grep="fix:" --grep="hotfix:" --since="1 month ago" --oneline | wc -l

# Mean time to recovery
# Track time from issue detection to fix deployment
```

### **Branch Health Indicators**
- Number of long-lived feature branches (should be minimal)
- Average PR size (aim for <200 lines)
- Time from PR creation to merge (aim for <24 hours)
- Number of failed CI/CD runs per PR

---

## 🛠️ GIT CONFIGURATION (MANDATORY)

### **Required Git Configuration**
```bash
# User configuration
git config --global user.name "Your Full Name"
git config --global user.email "your.email@company.com"

# Signing commits (if required)
git config --global user.signingkey YOUR_GPG_KEY_ID
git config --global commit.gpgsign true

# Editor and merge tool
git config --global core.editor "code --wait"
git config --global merge.tool vscode

# Line ending handling
git config --global core.autocrlf input  # Unix/Mac
git config --global core.autocrlf true   # Windows

# Default branch name
git config --global init.defaultBranch main

# Push configuration
git config --global push.default current
git config --global push.autoSetupRemote true
```

### **Useful Git Aliases**
```bash
# Add these to ~/.gitconfig or use git config --global
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.lg "log --oneline --graph --decorate"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.visual "!gitk"
```

---

## 🚨 GIT WORKFLOW VIOLATIONS

### **Zero Tolerance Violations**
- [ ] Direct push to protected branches
- [ ] Force push to shared branches  
- [ ] Committing secrets or sensitive data
- [ ] Rewriting published history
- [ ] Missing required commit message format

### **Code Review Required Violations**
- [ ] Large PRs without justification (>500 lines)
- [ ] PRs without adequate testing
- [ ] Missing documentation updates
- [ ] Unclear or missing PR descriptions
- [ ] Bypassing required approvals

---

## 📋 GIT WORKFLOW CHECKLIST

### **Daily Development**
- [ ] Pull latest changes before starting work
- [ ] Create feature branch from updated main/develop
- [ ] Make atomic commits with clear messages
- [ ] Push branch regularly (at least daily)
- [ ] Keep branch up-to-date with main/develop

### **Before Creating PR**
- [ ] Rebase branch on latest main/develop
- [ ] Squash related commits if needed
- [ ] Run all tests locally
- [ ] Update documentation
- [ ] Write clear PR description

### **During Code Review**
- [ ] Address all feedback promptly
- [ ] Update tests as needed
- [ ] Keep PR scope focused
- [ ] Resolve merge conflicts quickly

### **After PR Merge**
- [ ] Delete feature branch
- [ ] Verify deployment successful
- [ ] Update local branches
- [ ] Close related issues

---

**Related Rules**: See `core-standards/core-workflow.md` for development workflow integration and `general-policies/ops/observability.md` for git operation monitoring.