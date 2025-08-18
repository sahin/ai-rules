# 🪝 Hooks Integration Guide

## Overview

The hooks system is the automation backbone of the User Rules System. It provides seamless integration points that transform manual development processes into intelligent, automated workflows.

## Hook Architecture

### Hook Types & Responsibilities

#### 1. User Interaction Hooks

**UserPromptSubmit Hook**
```bash
#!/bin/bash
# Location: .claude/hooks/user-prompt-submit.sh
# Trigger: Every user message
# Purpose: Intelligent context preparation

# Keyword detection and analysis
analyze_user_message() {
  local message="$1"
  
  # Extract development keywords
  keywords=$(echo "$message" | grep -oE '\b(component|api|test|deploy|fix|add|create|update)\b')
  
  # Determine project context
  if [[ "$message" =~ "frontend"|"react"|"component" ]]; then
    load_frontend_rules
  elif [[ "$message" =~ "backend"|"api"|"database" ]]; then
    load_backend_rules
  elif [[ "$message" =~ "test"|"testing"|"spec" ]]; then
    load_testing_rules
  fi
  
  # Log context for other hooks
  echo "context_prepared=true" > .claude/session/context.flag
  echo "keywords_detected=$keywords" >> .claude/session/context.log
}

# Rule loading optimization
load_frontend_rules() {
  echo "Loading frontend rule set..."
  # Load only relevant rules to reduce token usage
  RULES_TO_LOAD=(
    "frontend/react-patterns.md"
    "frontend/component-standards.md"
    "testing/frontend-testing.md"
  )
  
  for rule in "${RULES_TO_LOAD[@]}"; do
    if [[ -f ".claude/rules/user/general-policies/$rule" ]]; then
      echo "loaded_rule=$rule" >> .claude/session/loaded-rules.log
    fi
  done
}

# Performance metrics
log_performance() {
  end_time=$(date +%s%N)
  duration=$(((end_time - start_time) / 1000000))
  echo "hook_execution_time_ms=$duration" >> .claude/session/metrics.json
}

# Main execution
start_time=$(date +%s%N)
analyze_user_message "$USER_MESSAGE"
log_performance
```

#### 2. Validation Hooks

**PreResponse Hook**
```bash
#!/bin/bash
# Location: .claude/hooks/pre-response.sh
# Trigger: Before generating any response
# Purpose: Plan-first enforcement

validate_response_compliance() {
  local response_draft="$1"
  
  # Check for immediate help patterns (BLOCKED)
  if [[ "$response_draft" =~ ^"I'll help you"|^"Let me help"|^"I can help" ]]; then
    echo "❌ VIOLATION: Immediate help pattern detected"
    echo "📋 REQUIRED: Must create plan first using template"
    echo "🔄 ACTION: Response blocked, plan template injected"
    
    # Inject plan template
    inject_plan_template
    exit 1
  fi
  
  # Check for code generation without plan approval
  if [[ "$response_draft" =~ "\`\`\`" ]] && [[ ! -f ".claude/session/plan-approved.flag" ]]; then
    echo "❌ VIOLATION: Code generation without approved plan"
    echo "📋 REQUIRED: Plan approval before implementation"
    echo "🔄 ACTION: Code generation blocked"
    exit 1
  fi
  
  # Validate plan format if planning response
  if [[ "$response_draft" =~ "## Plan:" ]]; then
    validate_plan_format "$response_draft"
  fi
}

validate_plan_format() {
  local plan_content="$1"
  
  # Required sections check
  local required_sections=("Research" "Implementation" "Testing")
  
  for section in "${required_sections[@]}"; do
    if [[ ! "$plan_content" =~ "$section" ]]; then
      echo "❌ VIOLATION: Missing required section: $section"
      echo "📋 TEMPLATE: $(cat .claude/rules/user/_mandatory/01-workflow-plan-template.md)"
      exit 1
    fi
  done
  
  # Approval question check
  if [[ ! "$plan_content" =~ "Would you like me to proceed" ]]; then
    echo "❌ VIOLATION: Missing approval question"
    echo "📋 REQUIRED: Must end with explicit approval request"
    exit 1
  fi
  
  echo "✅ VALIDATION: Plan format compliant"
}

inject_plan_template() {
  # Provide plan template for immediate use
  cat > .claude/session/required-response.md << 'EOF'
## Plan: [Task Description]

**📡 Hook Status:**
- Rules loaded: [X rules based on keywords]
- Smart testing: [Enabled]
- Auto-commit: [Enabled]

1. **Research**: [Analysis of current state - already completed]
   - File: [specific file path]
   - Current state: [description]
   - Requirements: [what needs to be done]

2. **Implementation**: [Specific approach]
   - Change: [exact modification]
   - Files affected: [list of files]
   - Dependencies: [any requirements]

3. **Testing**: [Validation strategy]
   - Tests to run: [specific test files]
   - Commands: npm run test:smart
   - Validation: [success criteria]

Files to be modified:
- [specific file paths]

Would you like me to proceed with this plan?
EOF

  echo "template_injected=true" > .claude/session/plan-template.flag
}

# Main execution
validate_response_compliance "$RESPONSE_DRAFT"
```

#### 3. Implementation Hooks

**PreToolUse Hook**
```bash
#!/bin/bash
# Location: .claude/hooks/pre-tool-use.sh
# Trigger: Before any file modification tool
# Purpose: Permission validation and change tracking

validate_tool_permission() {
  local tool_name="$1"
  local tool_args="$2"
  
  # Block file modifications without approved plan
  if [[ "$tool_name" =~ ^(Write|Edit|MultiEdit)$ ]]; then
    if [[ ! -f ".claude/session/plan-approved.flag" ]]; then
      echo "❌ BLOCKED: File modification without approved plan"
      echo "📋 REQUIRED: Create and approve plan first"
      exit 1
    fi
    
    # Log file for tracking
    echo "$tool_args" >> .claude/session/modified-files.log
    
    # Create backup before modification
    create_file_backup "$tool_args"
  fi
  
  # Validate tool usage patterns
  validate_tool_usage "$tool_name" "$tool_args"
}

create_file_backup() {
  local file_path="$1"
  
  if [[ -f "$file_path" ]]; then
    local backup_dir=".claude/backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    cp "$file_path" "$backup_dir/$(basename "$file_path").backup"
    
    echo "backup_created=$backup_dir/$(basename "$file_path").backup" >> .claude/session/backups.log
  fi
}

validate_tool_usage() {
  local tool_name="$1"
  local tool_args="$2"
  
  case "$tool_name" in
    "Write")
      validate_write_operation "$tool_args"
      ;;
    "Edit")
      validate_edit_operation "$tool_args"
      ;;
    "Bash")
      validate_bash_command "$tool_args"
      ;;
  esac
}

validate_write_operation() {
  local file_path="$1"
  
  # Enforce test-first for new implementation files
  if [[ "$file_path" =~ \.(tsx?|jsx?)$ ]] && [[ "$file_path" =~ (components|lib|services) ]]; then
    local test_file="${file_path%.*}.test.${file_path##*.}"
    
    if [[ ! -f "$test_file" ]]; then
      echo "⚠️ WARNING: Creating implementation without test file"
      echo "📋 RECOMMENDATION: Consider TDD approach"
      echo "📝 TEST FILE: $test_file"
      
      # Log for metrics
      echo "tdd_violation=true" >> .claude/session/quality-metrics.log
    fi
  fi
}

# Track operation for commit preparation
track_operation() {
  local operation="$1"
  local target="$2"
  
  cat >> .claude/session/operations.log << EOF
{
  "timestamp": "$(date -Iseconds)",
  "operation": "$operation",
  "target": "$target",
  "hook": "PreToolUse"
}
EOF
}

# Main execution
validate_tool_permission "$TOOL_NAME" "$TOOL_ARGS"
track_operation "$TOOL_NAME" "$TOOL_ARGS"
```

**PostToolUse Hook**
```bash
#!/bin/bash
# Location: .claude/hooks/post-tool-use.sh
# Trigger: After any file modification
# Purpose: Smart testing and quality validation

execute_smart_testing() {
  local modified_file="$1"
  
  # Analyze file changes
  local change_type=$(analyze_file_change "$modified_file")
  
  case "$change_type" in
    "react_component")
      run_component_tests "$modified_file"
      ;;
    "api_route")
      run_api_tests "$modified_file"
      ;;
    "utility_function")
      run_unit_tests "$modified_file"
      ;;
    "route_file")
      run_e2e_tests "$modified_file"
      create_visual_baseline "$modified_file"
      ;;
  esac
}

analyze_file_change() {
  local file_path="$1"
  
  # File type analysis
  if [[ "$file_path" =~ routes/.*\.tsx$ ]]; then
    echo "route_file"
  elif [[ "$file_path" =~ components/.*\.tsx$ ]]; then
    echo "react_component"
  elif [[ "$file_path" =~ routes/.*\.py$ ]]; then
    echo "api_route"
  elif [[ "$file_path" =~ lib/.*\.ts$ ]]; then
    echo "utility_function"
  else
    echo "generic_file"
  fi
}

run_component_tests() {
  local component_file="$1"
  local test_file="${component_file%.*}.test.${component_file##*.}"
  
  echo "🧪 Running component tests for: $(basename "$component_file")"
  
  if [[ -f "$test_file" ]]; then
    # Run specific component test
    npm run test:smart:unit -- "$test_file"
    log_test_result "component" "$?" 
  else
    echo "⚠️ No test file found: $test_file"
    echo "test_missing=true" >> .claude/session/quality-issues.log
  fi
  
  # Run related integration tests
  find_and_run_integration_tests "$component_file"
}

run_api_tests() {
  local api_file="$1"
  
  echo "🧪 Running API tests for: $(basename "$api_file")"
  
  # Extract API endpoints from file
  local endpoints=$(grep -oE "router\.(get|post|put|delete)\(['\"]([^'\"]+)" "$api_file" | cut -d'"' -f2)
  
  # Run tests for each endpoint
  for endpoint in $endpoints; do
    run_endpoint_test "$endpoint"
  done
}

create_visual_baseline() {
  local route_file="$1"
  
  # Extract route path from filename
  local route_path=$(extract_route_path "$route_file")
  
  if [[ -n "$route_path" ]]; then
    echo "📸 Creating visual baseline for: $route_path"
    
    # Create baseline screenshot
    npm run visual:update -- --route="$route_path"
    
    if [[ $? -eq 0 ]]; then
      local baseline_file="screenshots/baseline/${route_path//\//-}.png"
      echo "✅ Baseline created: $baseline_file"
      echo "🔗 View baseline: file://$(pwd)/$baseline_file"
      
      # Log for session summary
      echo "baseline_created=$baseline_file" >> .claude/session/visual-baselines.log
    else
      echo "❌ Failed to create baseline for: $route_path"
    fi
  fi
}

extract_route_path() {
  local route_file="$1"
  
  # Convert filename to route path
  # e.g., _auth._app.dashboard.tsx -> /dashboard
  local route_name=$(basename "$route_file" .tsx)
  route_name=${route_name//_auth._app./}
  route_name=${route_name//./\/}
  
  echo "/$route_name"
}

log_test_result() {
  local test_type="$1"
  local exit_code="$2"
  
  local status="PASS"
  if [[ $exit_code -ne 0 ]]; then
    status="FAIL"
  fi
  
  cat >> .claude/session/test-results.json << EOF
{
  "timestamp": "$(date -Iseconds)",
  "type": "$test_type",
  "status": "$status",
  "exit_code": $exit_code
}
EOF
}

# Performance tracking
start_time=$(date +%s%N)

# Main execution
if [[ "$TOOL_NAME" =~ ^(Write|Edit|MultiEdit)$ ]]; then
  execute_smart_testing "$TOOL_ARGS"
fi

# Log performance
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))
echo "post_tool_execution_time_ms=$duration" >> .claude/session/metrics.json
```

#### 4. Session Management Hooks

**Stop Hook**
```bash
#!/bin/bash
# Location: .claude/hooks/stop.sh
# Trigger: Session end
# Purpose: Auto-commit and cleanup

auto_commit_changes() {
  echo "💾 Auto-commit process starting..."
  
  # Collect all modified files
  local modified_files=()
  if [[ -f ".claude/session/modified-files.log" ]]; then
    while IFS= read -r file; do
      if [[ -n "$file" ]]; then
        modified_files+=("$file")
      fi
    done < .claude/session/modified-files.log
  fi
  
  if [[ ${#modified_files[@]} -eq 0 ]]; then
    echo "📝 No files to commit"
    return 0
  fi
  
  # Generate intelligent commit message
  local commit_message=$(generate_commit_message "${modified_files[@]}")
  
  # Stage files
  for file in "${modified_files[@]}"; do
    git add "$file"
  done
  
  # Create commit
  git commit -m "$commit_message"
  local commit_hash=$(git rev-parse HEAD)
  
  echo "✅ Committed: $commit_hash"
  echo "commit_hash=$commit_hash" > .claude/session/final-commit.log
  
  # Create rollback script
  create_rollback_script "$commit_hash" "${modified_files[@]}"
}

generate_commit_message() {
  local files=("$@")
  local message_type="feat"
  local scope=""
  local description=""
  
  # Analyze file types to determine commit type
  for file in "${files[@]}"; do
    if [[ "$file" =~ test\.|spec\. ]]; then
      message_type="test"
    elif [[ "$file" =~ fix|bug ]]; then
      message_type="fix"
    elif [[ "$file" =~ routes/ ]]; then
      scope="routes"
    elif [[ "$file" =~ components/ ]]; then
      scope="components"
    fi
  done
  
  # Generate description based on session data
  if [[ -f ".claude/session/session-state.json" ]]; then
    description=$(extract_plan_title_from_session)
  else
    description="update $(basename "${files[0]}")"
  fi
  
  # Format commit message
  local full_message="$message_type"
  if [[ -n "$scope" ]]; then
    full_message="$full_message($scope)"
  fi
  full_message="$full_message: $description

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
  
  echo "$full_message"
}

create_rollback_script() {
  local commit_hash="$1"
  shift
  local files=("$@")
  
  local rollback_dir=".rollback"
  mkdir -p "$rollback_dir"
  
  local rollback_script="$rollback_dir/rollback-${commit_hash:0:7}.sh"
  
  cat > "$rollback_script" << EOF
#!/bin/bash
# Rollback script for commit $commit_hash
# Generated: $(date)

echo "🔄 Rolling back changes from commit $commit_hash..."

# Git revert
git revert $commit_hash --no-edit

# Restore backup files if needed
EOF

  # Add file-specific restore commands
  if [[ -f ".claude/session/backups.log" ]]; then
    while IFS= read -r backup_entry; do
      if [[ "$backup_entry" =~ backup_created=(.+) ]]; then
        local backup_path="${BASH_REMATCH[1]}"
        local original_file=$(echo "$backup_path" | sed 's|.claude/backups/[^/]*/||' | sed 's|\.backup$||')
        echo "cp \"$backup_path\" \"$original_file\"" >> "$rollback_script"
      fi
    done < .claude/session/backups.log
  fi
  
  cat >> "$rollback_script" << 'EOF'

echo "✅ Rollback completed successfully"
echo "📋 Manual verification recommended"
EOF

  chmod +x "$rollback_script"
  echo "📜 Rollback script created: $rollback_script"
}

collect_session_metrics() {
  echo "📊 Collecting session metrics..."
  
  # Calculate session duration
  local session_start=$(head -1 .claude/session/session-state.json | grep -o '"created_at":"[^"]*"' | cut -d'"' -f4)
  local session_end=$(date -Iseconds)
  
  # Count operations
  local files_modified=$(wc -l < .claude/session/modified-files.log 2>/dev/null || echo 0)
  local tests_run=$(grep -c "status" .claude/session/test-results.json 2>/dev/null || echo 0)
  
  # Calculate compliance score
  local violations=$(grep -c "violation=true" .claude/session/*.log 2>/dev/null || echo 0)
  local total_operations=$(grep -c "timestamp" .claude/session/*.log 2>/dev/null || echo 1)
  local compliance_score=$(( (total_operations - violations) * 100 / total_operations ))
  
  # Generate final metrics
  cat > .claude/session/final-metrics.json << EOF
{
  "session_summary": {
    "started": "$session_start",
    "ended": "$session_end",
    "files_modified": $files_modified,
    "tests_executed": $tests_run,
    "compliance_score": $compliance_score,
    "violations": $violations
  },
  "performance": {
    "smart_testing_enabled": true,
    "time_saved_testing": "$(calculate_time_saved)",
    "automation_success_rate": "$(calculate_automation_success)"
  }
}
EOF

  echo "📈 Session metrics saved to .claude/session/final-metrics.json"
}

cleanup_session() {
  echo "🧹 Cleaning up session data..."
  
  # Archive session data
  local archive_dir=".claude/archive/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$archive_dir"
  
  # Move session files to archive
  if [[ -d ".claude/session" ]]; then
    mv .claude/session/* "$archive_dir/"
  fi
  
  echo "📦 Session data archived to: $archive_dir"
}

# Main execution
collect_session_metrics
auto_commit_changes
cleanup_session

echo "🎉 Session completed successfully!"
echo "📊 Check .claude/session/final-metrics.json for detailed metrics"
```

## Hook Configuration & Management

### Hook Registration

```json
{
  "hooks": {
    "userPromptSubmit": {
      "script": ".claude/hooks/user-prompt-submit.sh",
      "enabled": true,
      "timeout": 5000,
      "async": false
    },
    "preResponse": {
      "script": ".claude/hooks/pre-response.sh", 
      "enabled": true,
      "timeout": 3000,
      "async": false,
      "blocking": true
    },
    "preToolUse": {
      "script": ".claude/hooks/pre-tool-use.sh",
      "enabled": true,
      "timeout": 2000,
      "async": false,
      "blocking": true
    },
    "postToolUse": {
      "script": ".claude/hooks/post-tool-use.sh",
      "enabled": true,
      "timeout": 30000,
      "async": true
    },
    "stop": {
      "script": ".claude/hooks/stop.sh",
      "enabled": true,
      "timeout": 10000,
      "async": false
    }
  },
  "global_settings": {
    "max_concurrent_hooks": 3,
    "hook_log_level": "info",
    "error_handling": "graceful",
    "performance_monitoring": true
  }
}
```

### Hook Performance Monitoring

```bash
#!/bin/bash
# Location: .claude/hooks/monitor-performance.sh
# Purpose: Track hook execution performance

monitor_hook_performance() {
  local hook_name="$1"
  local execution_time="$2"
  local exit_code="$3"
  
  # Log performance data
  cat >> .claude/metrics/hook-performance.json << EOF
{
  "timestamp": "$(date -Iseconds)",
  "hook": "$hook_name",
  "execution_time_ms": $execution_time,
  "exit_code": $exit_code,
  "status": "$([ $exit_code -eq 0 ] && echo "success" || echo "failure")"
}
EOF

  # Alert on performance issues
  if [[ $execution_time -gt 5000 ]]; then
    echo "⚠️ PERFORMANCE WARNING: $hook_name took ${execution_time}ms"
  fi
  
  if [[ $exit_code -ne 0 ]]; then
    echo "❌ HOOK ERROR: $hook_name failed with exit code $exit_code"
  fi
}

# Generate performance report
generate_performance_report() {
  echo "📊 Hook Performance Report"
  echo "========================="
  
  # Aggregate performance data
  local total_hooks=$(jq -r '. | length' .claude/metrics/hook-performance.json 2>/dev/null || echo 0)
  local avg_time=$(jq -r '[.[].execution_time_ms] | add / length' .claude/metrics/hook-performance.json 2>/dev/null || echo 0)
  local success_rate=$(jq -r '[.[] | select(.status == "success")] | length' .claude/metrics/hook-performance.json 2>/dev/null || echo 0)
  
  echo "Total hook executions: $total_hooks"
  echo "Average execution time: ${avg_time}ms"
  echo "Success rate: $(( success_rate * 100 / total_hooks ))%"
  
  # Performance recommendations
  if [[ $(echo "$avg_time > 1000" | bc -l) -eq 1 ]]; then
    echo "💡 RECOMMENDATION: Consider optimizing hook performance"
  fi
}
```

## Hook Integration Best Practices

### 1. Error Handling
```bash
# Graceful error handling in hooks
handle_hook_error() {
  local hook_name="$1"
  local error_message="$2"
  
  echo "❌ Hook Error in $hook_name: $error_message" >&2
  
  # Log error for debugging
  echo "$(date -Iseconds): $hook_name - $error_message" >> .claude/logs/hook-errors.log
  
  # Attempt graceful recovery
  case "$hook_name" in
    "preResponse")
      # Provide fallback response guidance
      echo "📋 Fallback: Please ensure your request follows proper format"
      ;;
    "postToolUse")
      # Continue without smart testing
      echo "⚠️ Continuing without smart testing validation"
      ;;
  esac
}
```

### 2. Performance Optimization
```bash
# Optimize hook execution
optimize_hook_execution() {
  # Use background jobs for non-blocking operations
  if [[ "$HOOK_TYPE" == "async" ]]; then
    {
      execute_hook_logic "$@"
    } &
    
    # Don't wait for completion
    return 0
  fi
  
  # Use caching for expensive operations
  local cache_key=$(echo "$@" | md5sum | cut -d' ' -f1)
  local cache_file=".claude/cache/hook-$cache_key"
  
  if [[ -f "$cache_file" ]] && [[ $(find "$cache_file" -mmin -60) ]]; then
    # Use cached result if less than 1 hour old
    cat "$cache_file"
    return 0
  fi
  
  # Execute and cache result
  local result=$(execute_hook_logic "$@")
  echo "$result" > "$cache_file"
  echo "$result"
}
```

### 3. State Coordination
```bash
# Coordinate state between hooks
coordinate_hook_state() {
  local hook_name="$1"
  local state_data="$2"
  
  # Update shared state
  jq --arg hook "$hook_name" --arg data "$state_data" \
     '.[$hook] = $data' .claude/session/hook-state.json > tmp.$$.json && \
     mv tmp.$$.json .claude/session/hook-state.json
  
  # Notify dependent hooks
  case "$hook_name" in
    "userPromptSubmit")
      trigger_dependent_hooks "preResponse"
      ;;
    "preToolUse")
      prepare_state_for_post_hook
      ;;
  esac
}
```

## Integration Testing

### Hook Testing Framework
```bash
#!/bin/bash
# Location: .claude/hooks/test-hooks.sh
# Purpose: Test hook functionality

test_hook_integration() {
  echo "🧪 Testing hook integration..."
  
  # Test UserPromptSubmit hook
  test_user_prompt_hook() {
    local test_message="Add a new React component"
    export USER_MESSAGE="$test_message"
    
    # Execute hook
    .claude/hooks/user-prompt-submit.sh
    
    # Verify results
    if [[ -f ".claude/session/context.flag" ]]; then
      echo "✅ UserPromptSubmit: Context preparation successful"
    else
      echo "❌ UserPromptSubmit: Context preparation failed"
    fi
  }
  
  # Test PreResponse hook
  test_pre_response_hook() {
    local test_response="I'll help you create a component"
    export RESPONSE_DRAFT="$test_response"
    
    # This should fail (immediate help pattern)
    if ! .claude/hooks/pre-response.sh; then
      echo "✅ PreResponse: Correctly blocked immediate help"
    else
      echo "❌ PreResponse: Failed to block immediate help"
    fi
  }
  
  # Test PostToolUse hook
  test_post_tool_use_hook() {
    local test_file="components/TestComponent.tsx"
    export TOOL_NAME="Write"
    export TOOL_ARGS="$test_file"
    
    # Create test file
    mkdir -p components
    echo "export default function TestComponent() { return null; }" > "$test_file"
    
    # Execute hook
    .claude/hooks/post-tool-use.sh
    
    # Check for test execution
    if grep -q "component" .claude/session/test-results.json; then
      echo "✅ PostToolUse: Smart testing executed"
    else
      echo "❌ PostToolUse: Smart testing failed"
    fi
    
    # Cleanup
    rm -f "$test_file"
  }
  
  # Run all tests
  test_user_prompt_hook
  test_pre_response_hook
  test_post_tool_use_hook
  
  echo "🎉 Hook integration testing completed"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_hook_integration
fi
```

## Troubleshooting Hooks

### Common Issues & Solutions

#### 1. Hook Permission Errors
```bash
# Fix hook permissions
fix_hook_permissions() {
  echo "🔧 Fixing hook permissions..."
  find .claude/hooks -name "*.sh" -exec chmod +x {} \;
  echo "✅ Hook permissions updated"
}
```

#### 2. Hook Performance Issues
```bash
# Diagnose slow hooks
diagnose_hook_performance() {
  echo "🔍 Diagnosing hook performance..."
  
  # Find slowest hooks
  jq -r '.[] | select(.execution_time_ms > 1000) | "\(.hook): \(.execution_time_ms)ms"' \
     .claude/metrics/hook-performance.json | sort -nr
}
```

#### 3. Hook State Corruption
```bash
# Reset hook state
reset_hook_state() {
  echo "🔄 Resetting hook state..."
  
  # Backup current state
  cp .claude/session/hook-state.json .claude/session/hook-state.backup.json
  
  # Reset to clean state
  echo '{}' > .claude/session/hook-state.json
  
  echo "✅ Hook state reset completed"
}
```

## Advanced Hook Features

### 1. Conditional Hook Execution
```bash
# Execute hooks based on conditions
conditional_hook_execution() {
  local hook_name="$1"
  local condition="$2"
  
  case "$condition" in
    "development")
      if [[ "$NODE_ENV" == "development" ]]; then
        execute_hook "$hook_name"
      fi
      ;;
    "production")
      if [[ "$NODE_ENV" == "production" ]]; then
        execute_hook "$hook_name"
      fi
      ;;
    "file_type:"*)
      local file_type="${condition#file_type:}"
      if [[ "$CURRENT_FILE" =~ \.$file_type$ ]]; then
        execute_hook "$hook_name"
      fi
      ;;
  esac
}
```

### 2. Hook Chaining
```bash
# Chain hooks for complex workflows
chain_hooks() {
  local hooks=("$@")
  
  for hook in "${hooks[@]}"; do
    if ! execute_hook "$hook"; then
      echo "❌ Hook chain broken at: $hook"
      return 1
    fi
  done
  
  echo "✅ Hook chain completed successfully"
}
```

### 3. Parallel Hook Execution
```bash
# Execute hooks in parallel
parallel_hook_execution() {
  local hooks=("$@")
  local pids=()
  
  # Start all hooks
  for hook in "${hooks[@]}"; do
    execute_hook "$hook" &
    pids+=($!)
  done
  
  # Wait for completion
  for pid in "${pids[@]}"; do
    wait $pid || echo "❌ Hook failed: PID $pid"
  done
  
  echo "✅ Parallel hook execution completed"
}
```

---

The hooks system transforms the User Rules System from a passive guidance tool into an active, intelligent development partner that anticipates needs, enforces quality, and automates routine tasks while maintaining complete transparency and control.