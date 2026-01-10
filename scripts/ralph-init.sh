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

RALPH_GLOBAL="${RALPH_HOME:-$HOME/.ralph}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_NAME="${1:-$(basename "$(pwd)")}"

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

# Copy config template
echo -e "${BLUE}[init]${NC} Creating configuration..."
if [[ -f "$RALPH_GLOBAL/templates/ralph.config.json" ]]; then
    # Update project name in config
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
    }
  },
  "iterations": {
    "max": 20,
    "delaySeconds": 2
  },
  "claude": {
    "model": "sonnet"
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
echo "   ${CYAN}~/.ralph/ralph.sh${NC}"
echo ""
