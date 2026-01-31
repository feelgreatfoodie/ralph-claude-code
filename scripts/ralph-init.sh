#!/usr/bin/env bash
#
# Ralph Init - Initialize Ralph in the current project
#
# Usage: ralph-init [project-name]
#
# Creates the ./ralph/ directory structure in the current project
# with optional config customization.
#

set -euo pipefail

# ============================================================================
# Help
# ============================================================================

show_help() {
    cat << 'EOF'
Ralph Init - Initialize Ralph in the current project

Usage: ralph-init.sh [OPTIONS] [project-name]

Arguments:
  project-name      Name for the project (default: current directory name)

Options:
  -h, --help        Show this help message and exit
  --skip-cachebash  Skip CacheBash MCP configuration check

Description:
  Creates the ./ralph/ directory structure in the current project with
  configuration files, progress tracking, and transcript placeholder.

What it creates:
  ./ralph/ralph.config.json  - Project configuration
  ./ralph/progress.txt       - Progress log for iterations
  ./ralph/transcript.txt     - Placeholder for meeting notes
  ./ralph/archive/           - Archive directory for previous runs

Examples:
  ralph-init.sh              # Initialize with directory name as project
  ralph-init.sh my-app       # Initialize with custom project name
  ralph-init.sh --help       # Show this help message

For more information, see: https://github.com/anthropics/ralph-claude-code
EOF
    exit 0
}

# Handle help flag
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
fi

RALPH_GLOBAL="${RALPH_HOME:-$HOME/.ralph}"
SKIP_CACHEBASH=false

# Parse arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-cachebash)
            SKIP_CACHEBASH=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get and sanitize project name
sanitize_project_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//'
}

RAW_PROJECT_NAME="${POSITIONAL_ARGS[0]:-$(basename "$(pwd)")}"
PROJECT_NAME=$(sanitize_project_name "$RAW_PROJECT_NAME")

# Warn if name was sanitized
if [[ "$PROJECT_NAME" != "$RAW_PROJECT_NAME" ]]; then
    echo -e "${YELLOW}[init]${NC} Project name sanitized: '$RAW_PROJECT_NAME' -> '$PROJECT_NAME'"
fi

# Ensure we have a valid project name
if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="my-project"
    echo -e "${YELLOW}[init]${NC} Using default project name: $PROJECT_NAME"
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║            Ralph Init - Project Setup                        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "${YELLOW}[init]${NC} Warning: Not in a git repository"
    echo -e "${YELLOW}[init]${NC} Ralph works best with git. Consider running: git init"
    echo ""
fi

# Check if already initialized
if [[ -d "./ralph" ]]; then
    echo -e "${YELLOW}[init]${NC} ./ralph directory already exists"
    read -p "Overwrite configuration? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}[init]${NC} Keeping existing configuration"
        exit 0
    fi
fi

# Create directory structure
echo -e "${BLUE}[init]${NC} Creating ./ralph directory..."
mkdir -p ./ralph/archive
mkdir -p ./ralph/prompts

# Copy config template
echo -e "${BLUE}[init]${NC} Creating configuration..."
if [[ -f "$RALPH_GLOBAL/templates/ralph.config.json" ]]; then
    sed "s/\"my-project\"/\"$PROJECT_NAME\"/" "$RALPH_GLOBAL/templates/ralph.config.json" > ./ralph/ralph.config.json
else
    cat > ./ralph/ralph.config.json << EOF
{
  "project": "$PROJECT_NAME",
  "git": {
    "strategy": "single-branch",
    "baseBranch": "main",
    "branchPrefix": "ralph/"
  },
  "quality": {
    "autoDetect": true,
    "commands": {
      "lint": null,
      "typecheck": null,
      "test": null,
      "build": null
    },
    "smartRecovery": true,
    "maxFixAttempts": 3
  },
  "iterations": {
    "max": 20,
    "delaySeconds": 2
  },
  "claude": {
    "model": "sonnet"
  },
  "parallel": {
    "enabled": false,
    "maxConcurrent": 3
  },
  "cachebash": {
    "enabled": true,
    "pollIntervalSeconds": 30
  }
}
EOF
fi

# Initialize progress file
echo -e "${BLUE}[init]${NC} Creating progress.txt..."
cat > ./ralph/progress.txt << EOF
# Progress Log - $PROJECT_NAME

Started: $(date)

## Codebase Patterns
<!-- Patterns discovered during implementation will be added here -->

## Iteration Log
<!-- Each Ralph iteration will append its progress here -->
EOF

# Create placeholder for transcript
echo -e "${BLUE}[init]${NC} Creating transcript placeholder..."
cat > ./ralph/transcript.txt << EOF
# Meeting Transcript / Feature Notes

Replace this file with your meeting transcript or feature notes.
Then run: claude /prd

Example format:
---
Participant 1: We need to build a user login system.
Participant 2: Should support email and password.
Participant 1: Yes, and we'll add OAuth later.
---

Or just write bullet points:
- User authentication with email/password
- Registration form with validation
- Password reset via email
EOF

# Detect tech stack
echo -e "${BLUE}[init]${NC} Detecting tech stack..."
if [[ -f "$RALPH_GLOBAL/lib/detect-stack.sh" ]]; then
    source "$RALPH_GLOBAL/lib/detect-stack.sh"
    detect_stack "."

    if [[ "$STACK_TYPE" != "unknown" ]]; then
        echo -e "${GREEN}[init]${NC} Detected: $STACK_TYPE"
        echo ""
        echo "Quality commands (auto-detected):"
        [[ -n "$LINT_CMD" ]] && echo "  Lint:      $LINT_CMD"
        [[ -n "$TYPECHECK_CMD" ]] && echo "  Typecheck: $TYPECHECK_CMD"
        [[ -n "$TEST_CMD" ]] && echo "  Test:      $TEST_CMD"
        [[ -n "$BUILD_CMD" ]] && echo "  Build:     $BUILD_CMD"
        echo ""
        echo "Override in ./ralph/ralph.config.json if needed."
    else
        echo -e "${YELLOW}[init]${NC} Could not auto-detect tech stack"
        echo -e "${YELLOW}[init]${NC} Set quality commands manually in ./ralph/ralph.config.json"
    fi
else
    echo -e "${YELLOW}[init]${NC} Stack detection not available"
fi

# Add to .gitignore
if [[ -f ".gitignore" ]]; then
    if ! grep -q "ralph/archive" .gitignore 2>/dev/null; then
        echo -e "${BLUE}[init]${NC} Adding ralph/archive to .gitignore..."
        echo "" >> .gitignore
        echo "# Ralph archives" >> .gitignore
        echo "ralph/archive/" >> .gitignore
    fi
fi

# ============================================================================
# CacheBash MCP Configuration Check
# ============================================================================

check_cachebash() {
    if [[ "$SKIP_CACHEBASH" == "true" ]]; then
        return
    fi

    echo ""
    echo -e "${BLUE}[init]${NC} Checking CacheBash MCP configuration..."

    if ! command -v claude &>/dev/null; then
        echo -e "${YELLOW}[init]${NC} Claude Code CLI not found, skipping CacheBash check"
        return
    fi

    if claude mcp list 2>/dev/null | grep -q "cachebash"; then
        echo -e "${GREEN}[init]${NC} CacheBash MCP server is configured"
        echo -e "${GREEN}[init]${NC} Ralph will send status updates to your mobile device"
    else
        echo -e "${YELLOW}[init]${NC} CacheBash MCP server not configured"
        echo ""
        echo "CacheBash enables Ralph to:"
        echo "  - Send status updates to your phone"
        echo "  - Ask questions when blocked (you answer via mobile)"
        echo "  - Notify you of errors and completion"
        echo ""
        read -p "Would you like to set up CacheBash now? (y/N) " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_cachebash
        else
            echo -e "${BLUE}[init]${NC} Skipping CacheBash setup"
            echo -e "${BLUE}[init]${NC} You can set it up later with: claude mcp add cachebash ..."

            # Disable CacheBash in config since it's not set up
            if command -v jq &>/dev/null; then
                jq '.cachebash.enabled = false' ./ralph/ralph.config.json > ./ralph/ralph.config.json.tmp
                mv ./ralph/ralph.config.json.tmp ./ralph/ralph.config.json
            else
                # Fallback: use sed
                sed -i.bak 's/"enabled": true/"enabled": false/' ./ralph/ralph.config.json
                rm -f ./ralph/ralph.config.json.bak
            fi
        fi
    fi
}

setup_cachebash() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}CacheBash Setup${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "To set up CacheBash, you need an API key from the CacheBash mobile app."
    echo ""
    echo "Steps:"
    echo "  1. Download CacheBash from the App Store (iOS) or Play Store (Android)"
    echo "  2. Create an account or sign in"
    echo "  3. Go to Settings -> Copy API Key"
    echo ""
    read -p "Do you have your CacheBash API key ready? (y/N) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}[init]${NC} No problem! You can set up CacheBash later."
        echo ""
        echo "When ready, run:"
        echo -e "  ${CYAN}claude mcp add --transport http cachebash \\${NC}"
        echo -e "  ${CYAN}  \"https://cachebash-mcp-922749444863.us-central1.run.app/v1/mcp\" \\${NC}"
        echo -e "  ${CYAN}  --header \"Authorization: Bearer YOUR_API_KEY\"${NC}"
        return
    fi

    echo ""
    read -p "Paste your CacheBash API key: " API_KEY

    if [[ -z "$API_KEY" ]]; then
        echo -e "${RED}[init]${NC} No API key provided, skipping CacheBash setup"
        return
    fi

    echo ""
    echo -e "${BLUE}[init]${NC} Configuring CacheBash MCP server..."

    if claude mcp add --transport http cachebash \
        "https://cachebash-mcp-922749444863.us-central1.run.app/v1/mcp" \
        --header "Authorization: Bearer $API_KEY" 2>/dev/null; then
        echo -e "${GREEN}[init]${NC} CacheBash configured successfully!"
        echo -e "${GREEN}[init]${NC} Ralph will now send updates to your mobile device."
    else
        echo -e "${RED}[init]${NC} Failed to configure CacheBash"
        echo -e "${YELLOW}[init]${NC} You can try manually with:"
        echo -e "  ${CYAN}claude mcp add --transport http cachebash \\${NC}"
        echo -e "  ${CYAN}  \"https://cachebash-mcp-922749444863.us-central1.run.app/v1/mcp\" \\${NC}"
        echo -e "  ${CYAN}  --header \"Authorization: Bearer YOUR_API_KEY\"${NC}"
    fi
}

# Run CacheBash check
check_cachebash

# ============================================================================
# Summary
# ============================================================================

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Ralph initialized for: $PROJECT_NAME${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Created:"
echo "  ./ralph/ralph.config.json  - Project configuration"
echo "  ./ralph/progress.txt       - Progress log"
echo "  ./ralph/transcript.txt     - Placeholder for meeting notes"
echo ""
echo "Configuration options in ralph.config.json:"
echo "  parallel.enabled    - Enable parallel story execution (default: false)"
echo "  cachebash.enabled   - Enable mobile notifications (default: true)"
echo "  quality.smartRecovery - Auto-fix quality gate errors (default: true)"
echo ""
echo "Next steps:"
echo "─────────────────────────────────────────────────────────────────"
echo ""
echo "1. Add your meeting notes or feature description:"
echo "   ${CYAN}Edit ./ralph/transcript.txt${NC}"
echo ""
echo "2. Generate a PRD:"
echo "   ${CYAN}claude /prd${NC}"
echo ""
echo "3. Convert to JSON (after reviewing PRD):"
echo "   ${CYAN}claude /ralph-convert${NC}"
echo ""
echo "4. Run autonomous implementation:"
echo "   ${CYAN}~/.ralph/ralph.sh${NC}              # Sequential mode"
echo "   ${CYAN}~/.ralph/ralph.sh --parallel${NC}   # Parallel mode (orchestrator)"
echo ""
