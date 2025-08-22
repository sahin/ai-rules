#!/bin/bash

# Sahin AI Rules Framework Installation Script
# Installs the complete Claude Code rules framework into any project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if target directory is provided
TARGET_DIR=${1:-$(pwd)}
if [ ! -d "$TARGET_DIR" ]; then
    log_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

echo "🚀 Sahin AI Rules Framework Installation"
echo "========================================"
echo ""
log_info "Installing to: $TARGET_DIR"
echo ""

# Step 1: Backup existing rules if they exist
if [ -d "$TARGET_DIR/.claude/rules" ]; then
    BACKUP_DIR="$TARGET_DIR/.claude/rules-backup-$(date +%Y%m%d-%H%M%S)"
    log_warning "Existing .claude/rules found. Creating backup..."
    cp -r "$TARGET_DIR/.claude/rules" "$BACKUP_DIR"
    log_success "Backup created at: $BACKUP_DIR"
fi

# Step 2: Create directory structure
log_info "Creating directory structure..."
mkdir -p "$TARGET_DIR/.claude"
mkdir -p "$TARGET_DIR/.claude/rules"
mkdir -p "$TARGET_DIR/.claude/docs" 
mkdir -p "$TARGET_DIR/.claude/hooks"
mkdir -p "$TARGET_DIR/.claude/session"
mkdir -p "$TARGET_DIR/.claude/metrics"
log_success "Directory structure created"

# Step 3: Copy rules from current repository
log_info "Copying rules framework..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy all rules
if [ -d "$SCRIPT_DIR/.claude/rules" ]; then
    cp -r "$SCRIPT_DIR/.claude/rules/"* "$TARGET_DIR/.claude/rules/"
    log_success "Rules copied successfully"
else
    log_error "Source rules directory not found at: $SCRIPT_DIR/.claude/rules"
    exit 1
fi

# Copy documentation if it exists
if [ -d "$SCRIPT_DIR/.claude/docs" ]; then
    cp -r "$SCRIPT_DIR/.claude/docs/"* "$TARGET_DIR/.claude/docs/"
    log_success "Documentation copied"
fi

# Copy hooks if they exist
if [ -d "$SCRIPT_DIR/.claude/hooks" ]; then
    cp -r "$SCRIPT_DIR/.claude/hooks/"* "$TARGET_DIR/.claude/hooks/"
    chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true
    log_success "Hooks copied and made executable"
fi

# Step 4: Copy main CLAUDE.md configuration
log_info "Setting up main configuration..."
if [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/"
    log_success "CLAUDE.md configuration copied"
fi

# Step 5: Create settings files
log_info "Creating settings files..."
cat > "$TARGET_DIR/.claude/settings.json" << 'EOF'
{
  "claude": {
    "rulesPath": ".claude/rules",
    "docsPath": ".claude/docs", 
    "hooksEnabled": true,
    "autoCommit": true,
    "testRunner": "auto-detect",
    "todoTracking": true,
    "smartTesting": true,
    "contextOptimization": true
  }
}
EOF

# Create local settings template (ignored by git)
cat > "$TARGET_DIR/.claude/settings.local.json" << 'EOF'
{
  "project": {
    "name": "Your Project Name",
    "type": "web-application",
    "testFramework": "jest",
    "primaryLanguage": "typescript"
  },
  "developer": {
    "name": "Your Name",
    "email": "your.email@example.com"
  }
}
EOF

log_success "Settings files created"

# Step 6: Create gitignore entries for .claude directory
log_info "Updating .gitignore for .claude directory..."
GITIGNORE_FILE="$TARGET_DIR/.gitignore"

# Create .gitignore if it doesn't exist
touch "$GITIGNORE_FILE"

# Add .claude entries if not already present
if ! grep -q ".claude/session" "$GITIGNORE_FILE"; then
    cat >> "$GITIGNORE_FILE" << 'EOF'

# Claude Code AI Rules Framework
.claude/session/
.claude/metrics/
.claude/settings.local.json
.claude/*.log
EOF
    log_success ".gitignore updated"
else
    log_info ".gitignore already contains .claude entries"
fi

# Step 7: Validate installation
log_info "Validating installation..."

# Check required files
REQUIRED_FILES=(
    ".claude/rules/manifest.json"
    ".claude/rules/_mandatory/01-workflow-plan-template.md"
    "CLAUDE.md"
)

VALIDATION_PASSED=true

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$TARGET_DIR/$file" ]; then
        log_success "✓ $file"
    else
        log_error "✗ Missing: $file"
        VALIDATION_PASSED=false
    fi
done

# Check rule counts
RULE_COUNT=$(find "$TARGET_DIR/.claude/rules" -name "*.md" -type f | wc -l)
log_info "Found $RULE_COUNT rule files"

if [ "$RULE_COUNT" -lt 10 ]; then
    log_warning "Low rule count detected. Ensure all rules copied correctly."
fi

# Step 8: Initialize git tracking (if in git repo)
if [ -d "$TARGET_DIR/.git" ]; then
    log_info "Git repository detected. Adding files..."
    cd "$TARGET_DIR"
    
    git add .claude/rules/
    git add .claude/docs/ 2>/dev/null || true
    git add .claude/hooks/ 2>/dev/null || true
    git add .claude/settings.json
    git add CLAUDE.md
    git add .gitignore
    
    log_success "Files staged for git commit"
    
    # Create installation commit
    git commit -m "feat: Install Sahin AI Rules framework

- Add complete .claude/rules framework with 12-rule system
- Install agent framework for specialized AI assistants  
- Set up automated testing and quality gates
- Configure plan-first workflow enforcement
- Add comprehensive testing methodologies

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>" 2>/dev/null || log_warning "Git commit failed (may have no changes)"

    log_success "Installation committed to git"
else
    log_info "No git repository found - skipping git operations"
fi

# Step 9: Display completion summary
echo ""
echo "🎉 INSTALLATION COMPLETE!"
echo "========================="
echo ""
log_success "Sahin AI Rules Framework installed successfully!"
echo ""
echo "📊 Installation Summary:"
echo "• Rules installed: $RULE_COUNT files"
echo "• Configuration: CLAUDE.md"
echo "• Settings: .claude/settings.json" 
echo "• Documentation: .claude/docs/"
echo "• Hooks: .claude/hooks/"
echo ""
echo "🚀 Next Steps:"
echo "1. Review and customize .claude/settings.local.json"
echo "2. Test the installation with: 'Create a simple API endpoint with tests'"
echo "3. The AI will now follow plan-first workflow automatically"
echo ""
echo "📚 Documentation:"
echo "• Framework Guide: .claude/docs/"
echo "• README: https://github.com/sahin/ai-rules"
echo "• Issues: https://github.com/sahin/ai-rules/issues"
echo ""
echo "⚡ Quick Test:"
echo "Send this message to Claude Code:"
echo "'Create an API endpoint for user authentication with tests'"
echo ""
echo "The framework will automatically:"
echo "• Load relevant rules based on keywords"
echo "• Create a structured plan"
echo "• Ask for approval before coding"
echo "• Run tests after changes"
echo "• Commit with conventional format"
echo ""

if [ "$VALIDATION_PASSED" = true ]; then
    echo "✅ All validations passed - Framework ready to use!"
    exit 0
else
    echo "⚠️  Some validations failed - Please check the installation"
    exit 1
fi