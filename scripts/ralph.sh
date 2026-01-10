#!/usr/bin/env bash
#
# Ralph for Claude Code - Autonomous AI Agent Loop
#
# Usage: ralph.sh [max_iterations]
#
# This script orchestrates repeated Claude Code CLI invocations to complete
# all user stories in a PRD. Each iteration runs with fresh context, preserving
# knowledge through git commits, progress.txt, and CLAUDE.md files.
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

RALPH_GLOBAL_DIR="${RALPH_HOME:-$HOME/.ralph}"
RALPH_LOCAL_DIR="./ralph"
MAX_ITERATIONS="${1:-20}"
DELAY_SECONDS=2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}[ralph]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[ralph]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[ralph]${NC} $1"
}

log_error() {
    echo -e "${RED}[ralph]${NC} $1"
}

log_iteration() {
    echo -e "${CYAN}[ralph]${NC} ══════════════════════════════════════════════════════════"
    echo -e "${CYAN}[ralph]${NC} ITERATION $1 / $MAX_ITERATIONS"
    echo -e "${CYAN}[ralph]${NC} ══════════════════════════════════════════════════════════"
}

# Find a file, preferring local over global
find_file() {
    local filename="$1"
    if [[ -f "$RALPH_LOCAL_DIR/$filename" ]]; then
        echo "$RALPH_LOCAL_DIR/$filename"
    elif [[ -f "$RALPH_GLOBAL_DIR/$filename" ]]; then
        echo "$RALPH_GLOBAL_DIR/$filename"
    else
        echo ""
    fi
}

# Load configuration with local override
load_config() {
    local config_file
    config_file=$(find_file "ralph.config.json")

    if [[ -n "$config_file" ]]; then
        log_info "Loading config from: $config_file"

        # Extract values using grep/sed (portable, no jq dependency)
        GIT_STRATEGY=$(grep -o '"strategy"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | sed 's/.*: *"\([^"]*\)"/\1/' || echo "single-branch")
        GIT_BASE_BRANCH=$(grep -o '"baseBranch"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | sed 's/.*: *"\([^"]*\)"/\1/' || echo "main")
        GIT_BRANCH_PREFIX=$(grep -o '"branchPrefix"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | sed 's/.*: *"\([^"]*\)"/\1/' || echo "ralph/")
        MAX_ITERATIONS_CONFIG=$(grep -o '"max"[[:space:]]*:[[:space:]]*[0-9]*' "$config_file" | sed 's/.*: *//' || echo "")
        DELAY_CONFIG=$(grep -o '"delaySeconds"[[:space:]]*:[[:space:]]*[0-9]*' "$config_file" | sed 's/.*: *//' || echo "")
        CLAUDE_MODEL=$(grep -o '"model"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | sed 's/.*: *"\([^"]*\)"/\1/' || echo "sonnet")

        # Apply config values if not overridden by CLI
        [[ -z "${1:-}" && -n "$MAX_ITERATIONS_CONFIG" ]] && MAX_ITERATIONS="$MAX_ITERATIONS_CONFIG"
        [[ -n "$DELAY_CONFIG" ]] && DELAY_SECONDS="$DELAY_CONFIG"
    else
        log_warn "No config file found, using defaults"
        GIT_STRATEGY="single-branch"
        GIT_BASE_BRANCH="main"
        GIT_BRANCH_PREFIX="ralph/"
        CLAUDE_MODEL="sonnet"
    fi
}

# ============================================================================
# PRD Management
# ============================================================================

get_prd_file() {
    local prd_file
    prd_file=$(find_file "prd.json")

    if [[ -z "$prd_file" ]]; then
        log_error "No prd.json found in $RALPH_LOCAL_DIR or $RALPH_GLOBAL_DIR"
        log_error "Run 'claude /prd' to generate a PRD first"
        exit 1
    fi

    echo "$prd_file"
}

get_branch_name() {
    local prd_file="$1"
    grep -o '"branchName"[[:space:]]*:[[:space:]]*"[^"]*"' "$prd_file" | sed 's/.*: *"\([^"]*\)"/\1/' || echo "ralph/feature"
}

get_incomplete_count() {
    local prd_file="$1"
    # Count stories where passes is false or not present
    grep -c '"passes"[[:space:]]*:[[:space:]]*false' "$prd_file" || echo "0"
}

check_all_complete() {
    local prd_file="$1"
    local incomplete
    incomplete=$(get_incomplete_count "$prd_file")
    [[ "$incomplete" -eq 0 ]]
}

# ============================================================================
# Git Management
# ============================================================================

setup_git_branch() {
    local branch_name="$1"

    # Ensure we're in a git repo
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        log_error "Not in a git repository"
        exit 1
    fi

    local current_branch
    current_branch=$(git branch --show-current)

    if [[ "$current_branch" != "$branch_name" ]]; then
        if git show-ref --verify --quiet "refs/heads/$branch_name"; then
            log_info "Switching to existing branch: $branch_name"
            git checkout "$branch_name"
        else
            log_info "Creating new branch: $branch_name from $GIT_BASE_BRANCH"
            git checkout -b "$branch_name" "$GIT_BASE_BRANCH"
        fi
    else
        log_info "Already on branch: $branch_name"
    fi
}

# ============================================================================
# Archive Management
# ============================================================================

archive_previous_run() {
    local prd_file="$1"
    local last_branch_file="$RALPH_LOCAL_DIR/.last-branch"
    local current_branch
    current_branch=$(get_branch_name "$prd_file")

    # Create local ralph dir if needed
    mkdir -p "$RALPH_LOCAL_DIR"

    if [[ -f "$last_branch_file" ]]; then
        local last_branch
        last_branch=$(cat "$last_branch_file")

        if [[ "$last_branch" != "$current_branch" ]]; then
            local archive_name
            archive_name=$(echo "$last_branch" | sed 's|^ralph/||')
            archive_name="${archive_name}-$(date +%Y%m%d-%H%M%S)"

            log_info "Archiving previous run: $archive_name"
            mkdir -p "$RALPH_LOCAL_DIR/archive/$archive_name"

            # Move previous run files to archive
            [[ -f "$RALPH_LOCAL_DIR/progress.txt" ]] && mv "$RALPH_LOCAL_DIR/progress.txt" "$RALPH_LOCAL_DIR/archive/$archive_name/"
            [[ -f "$RALPH_LOCAL_DIR/prd.json" ]] && cp "$RALPH_LOCAL_DIR/prd.json" "$RALPH_LOCAL_DIR/archive/$archive_name/"

            # Reset progress for new run
            echo "# Progress Log - $current_branch" > "$RALPH_LOCAL_DIR/progress.txt"
            echo "Started: $(date)" >> "$RALPH_LOCAL_DIR/progress.txt"
            echo "" >> "$RALPH_LOCAL_DIR/progress.txt"
        fi
    fi

    echo "$current_branch" > "$last_branch_file"
}

# ============================================================================
# Progress Management
# ============================================================================

init_progress_file() {
    local progress_file="$RALPH_LOCAL_DIR/progress.txt"

    if [[ ! -f "$progress_file" ]]; then
        mkdir -p "$RALPH_LOCAL_DIR"
        cat > "$progress_file" << 'EOF'
# Progress Log

This file accumulates learnings across Ralph iterations.
Each iteration should append discoveries, patterns, and gotchas here.

## Codebase Patterns
<!-- Reusable patterns discovered during implementation -->

## Iteration Log
EOF
        log_info "Initialized progress.txt"
    fi
}

# ============================================================================
# Claude Execution
# ============================================================================

run_claude_iteration() {
    local iteration="$1"
    local prompt_file
    local prd_file
    local progress_file="$RALPH_LOCAL_DIR/progress.txt"

    prompt_file=$(find_file "prompt.md")
    prd_file=$(get_prd_file)

    if [[ -z "$prompt_file" ]]; then
        log_error "No prompt.md found"
        exit 1
    fi

    log_info "Running Claude iteration with:"
    log_info "  Prompt: $prompt_file"
    log_info "  PRD: $prd_file"
    log_info "  Model: $CLAUDE_MODEL"

    # Build the Claude command
    local claude_cmd="claude"

    # Add model flag if not default
    if [[ "$CLAUDE_MODEL" == "opus" ]]; then
        claude_cmd="$claude_cmd --model claude-opus-4-5-20251101"
    fi

    # Run Claude with the prompt, capturing output
    # The prompt.md instructs Claude what to do
    local output
    output=$($claude_cmd --print --prompt-file "$prompt_file" 2>&1) || true

    # Check for completion signal
    if echo "$output" | grep -q '<ralph>COMPLETE</ralph>'; then
        log_success "All stories completed!"
        return 0
    fi

    # Check for iteration complete signal
    if echo "$output" | grep -q '<ralph>ITERATION_COMPLETE</ralph>'; then
        log_success "Iteration $iteration completed successfully"
        return 1  # Continue to next iteration
    fi

    # Check for error signal
    if echo "$output" | grep -q '<ralph>ERROR</ralph>'; then
        log_error "Iteration encountered an error"
        echo "$output" | grep -A5 '<ralph>ERROR</ralph>' || true
        return 2
    fi

    # Default: assume iteration completed
    return 1
}

# ============================================================================
# Main Loop
# ============================================================================

main() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Ralph for Claude Code - Autonomous Agent Loop       ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Load configuration
    load_config "$@"

    # Get PRD file
    local prd_file
    prd_file=$(get_prd_file)
    log_info "Using PRD: $prd_file"

    # Archive previous run if branch changed
    archive_previous_run "$prd_file"

    # Initialize progress file
    init_progress_file

    # Setup git branch
    local branch_name
    branch_name=$(get_branch_name "$prd_file")
    setup_git_branch "$branch_name"

    # Check if already complete
    if check_all_complete "$prd_file"; then
        log_success "All stories are already complete!"
        exit 0
    fi

    local incomplete
    incomplete=$(get_incomplete_count "$prd_file")
    log_info "Stories remaining: $incomplete"

    # Main iteration loop
    local iteration=1
    while [[ $iteration -le $MAX_ITERATIONS ]]; do
        log_iteration "$iteration"

        # Run Claude
        local result
        run_claude_iteration "$iteration" && result=$? || result=$?

        case $result in
            0)
                # All complete
                log_success "══════════════════════════════════════════════════════════"
                log_success "RALPH COMPLETE - All stories implemented!"
                log_success "══════════════════════════════════════════════════════════"
                exit 0
                ;;
            1)
                # Iteration complete, continue
                ;;
            2)
                # Error occurred
                log_error "Stopping due to error in iteration $iteration"
                exit 1
                ;;
        esac

        # Check if all complete after this iteration
        if check_all_complete "$prd_file"; then
            log_success "══════════════════════════════════════════════════════════"
            log_success "RALPH COMPLETE - All stories implemented!"
            log_success "══════════════════════════════════════════════════════════"
            exit 0
        fi

        # Delay before next iteration
        log_info "Waiting ${DELAY_SECONDS}s before next iteration..."
        sleep "$DELAY_SECONDS"

        ((iteration++))
    done

    # Max iterations reached
    log_warn "══════════════════════════════════════════════════════════"
    log_warn "MAX ITERATIONS REACHED ($MAX_ITERATIONS)"
    incomplete=$(get_incomplete_count "$prd_file")
    log_warn "Stories remaining: $incomplete"
    log_warn "══════════════════════════════════════════════════════════"
    exit 1
}

# Run main
main "$@"
