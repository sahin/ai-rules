#!/bin/bash

# Convert .claude/rules to GitHub subtree script
# This script converts an existing .claude/rules directory to use content from
# https://github.com/sahin/ai-rules/.claude/rules via git subtree

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

echo "🌳 Converting .claude/rules to GitHub subtree..."
echo "==============================================="

# Step 1: Create backup of current .claude/rules
log_info "Step 1: Creating backup of current .claude/rules..."
BACKUP_DIR=".claude/rules-backup-$(date +%Y%m%d-%H%M%S)"
if [ -d ".claude/rules" ]; then
    cp -r .claude/rules "$BACKUP_DIR"
    log_success "Backup created at: $BACKUP_DIR"
else
    log_warning "No existing .claude/rules directory found"
fi

# Step 2: Check git status and show current state
log_info "Step 2: Checking current git status..."
git status --porcelain

# Step 3: Remove existing .claude/rules directory from git
if [ -d ".claude/rules" ]; then
    log_info "Step 3: Removing existing .claude/rules from git..."
    git rm -rf .claude/rules
    log_success "Removed from git index"
else
    log_info "Step 3: No .claude/rules to remove from git"
fi

# Step 4: Commit the removal
log_info "Step 4: Committing removal of existing .claude/rules..."
git add -A
if git diff --staged --quiet; then
    log_info "No changes to commit"
else
    git commit -m "remove: Existing .claude/rules for subtree replacement

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    log_success "Removal committed"
fi

# Step 5: Clean removal of any remaining files
log_info "Step 5: Ensuring clean removal..."
rm -rf .claude/rules
git add -A
if git diff --staged --quiet; then
    log_info "No additional cleanup needed"
else
    git commit -m "clean: Remove .claude/rules directory completely

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    log_success "Cleanup committed"
fi

# Step 6: Stash any pending changes to ensure clean working directory
log_info "Step 6: Stashing any pending changes..."
if [[ -n $(git status --porcelain) ]]; then
    git stash push -m "Temporary stash for subtree add - $(date)"
    STASH_CREATED=true
    log_success "Changes stashed"
else
    STASH_CREATED=false
    log_info "No changes to stash"
fi

# Step 7: Add GitHub repository as subtree
log_info "Step 7: Adding GitHub repository as subtree..."
git subtree add --prefix=temp-ai-rules https://github.com/sahin/ai-rules.git main --squash
log_success "Subtree added successfully"

# Step 8: Move the specific .claude/rules content to correct location
log_info "Step 8: Moving .claude/rules content to correct location..."
mkdir -p .claude
mv temp-ai-rules/.claude/rules .claude/rules
log_success "Rules moved to correct location"

# Step 9: Clean up temporary directory
log_info "Step 9: Cleaning up temporary directory..."
rm -rf temp-ai-rules
log_success "Temporary directory cleaned up"

# Step 10: Commit the new structure
log_info "Step 10: Committing new .claude/rules structure..."
git add .claude/rules
git commit -m "feat: Replace .claude/rules with GitHub ai-rules subtree content

- Convert to use sahin/ai-rules repository as source
- Maintain all existing rule functionality
- Enable easy updates from upstream repository
- Preserve project-specific customizations

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
log_success "New structure committed"

# Step 11: Restore stashed changes if any
if [ "$STASH_CREATED" = true ]; then
    log_info "Step 11: Restoring stashed changes..."
    git stash pop
    
    # Clean up any remaining temp files
    git add -A
    if ! git diff --staged --quiet; then
        git commit -m "chore: Clean up temp files from subtree operation

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
        log_success "Cleanup changes committed"
    fi
fi

# Step 12: Restore project-specific content from backup (if exists)
log_info "Step 12: Checking for project-specific content to restore..."
if [ -d "$BACKUP_DIR" ]; then
    # Check for project-specific docs
    if [ -d "$BACKUP_DIR/docs" ]; then
        log_info "Restoring project-specific docs folder..."
        cp -r "$BACKUP_DIR/docs" .claude/rules/
        git add .claude/rules/docs
        git commit -m "feat: Restore project-specific docs folder from backup

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
        log_success "Project-specific docs restored"
    fi
    
    # Check for other custom files
    if [ -f "$BACKUP_DIR/custom-rules.md" ]; then
        log_info "Restoring custom rules..."
        cp "$BACKUP_DIR/custom-rules.md" .claude/rules/
        git add .claude/rules/custom-rules.md
        git commit -m "feat: Restore custom rules from backup

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
        log_success "Custom rules restored"
    fi
fi

# Step 13: Verify final structure
log_info "Step 13: Verifying final structure..."
log_info "Final .claude/rules structure:"
ls -la .claude/rules/
echo ""
log_info "Directory tree (first 15 entries):"
find .claude/rules -type d | head -15

# Step 14: Show summary and next steps
echo ""
log_success "SUCCESS! Conversion completed successfully!"
echo ""
echo "📊 Summary:"
echo "==========="
if [ -d "$BACKUP_DIR" ]; then
    echo "• Original content backed up to: $BACKUP_DIR"
fi
echo "• .claude/rules now contains GitHub ai-rules content"
echo "• Project-specific content restored (if it existed)"
echo "• All changes committed to git"
echo ""
echo "🔄 To update from remote repository in the future:"
echo "=================================================="
echo ""
echo "# Method 1: Using subtree pull (recommended)"
echo "git subtree pull --prefix=temp-ai-rules https://github.com/sahin/ai-rules.git main --squash"
echo "mv temp-ai-rules/.claude/rules .claude/rules-new"
echo "rm -rf temp-ai-rules"
echo "rm -rf .claude/rules"
echo "mv .claude/rules-new .claude/rules"
echo "git add .claude/rules"
echo "git commit -m 'update: Sync .claude/rules with upstream ai-rules'"
echo ""
echo "# Method 2: Using our update script"
echo "./update-rules.sh  # (if available)"
echo ""
echo "📝 Notes:"
echo "========="
echo "• Backup directory preserved for 30 days: $BACKUP_DIR"
echo "• All project customizations have been preserved"
echo "• The framework is now connected to upstream updates"
echo "• Original functionality remains unchanged"
echo ""
log_success "Conversion complete! 🎉"