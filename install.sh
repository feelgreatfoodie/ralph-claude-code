#!/usr/bin/env bash
#
# Ralph for Claude Code - Installation Script
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/feelgreatfoodie/ralph-claude-code/main/install.sh | bash
#
#   Or clone the repo and run:
#   ./install.sh
#
# This script installs Ralph to ~/.ralph/
#

set -euo pipefail

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

RALPH_HOME="${RALPH_HOME:-$HOME/.ralph}"

# Detect if we're running from a cloned repo or via curl
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -f "$SCRIPT_DIR/scripts/ralph.sh" ]]; then
    SOURCE_DIR="$SCRIPT_DIR"
    INSTALL_MODE="local"
else
    SOURCE_DIR=""
    INSTALL_MODE="remote"
fi

# ============================================================================
# Helper Functions
# ============================================================================

print_banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║         ${BOLD}Ralph for Claude Code${NC}${CYAN} - Installer                   ║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║         Autonomous AI Agent Loop for Building Apps           ║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

log_step() {
    echo -e "${BLUE}[install]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[install]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[install]${NC} $1"
}

log_error() {
    echo -e "${RED}[install]${NC} $1"
}

# ============================================================================
# Prerequisite Checks
# ============================================================================

check_prerequisites() {
    log_step "Checking prerequisites..."

    local has_errors=false

    # Check for git
    if command -v git &>/dev/null; then
        log_success "Git found: $(git --version)"
    else
        log_error "Git is not installed"
        echo "       Please install git first:"
        echo "       - Mac: xcode-select --install"
        echo "       - Windows: https://git-scm.com/download/win"
        echo "       - Linux: sudo apt install git"
        has_errors=true
    fi

    # Check for Claude CLI
    if command -v claude &>/dev/null; then
        log_success "Claude Code CLI found"
    else
        log_warn "Claude Code CLI not found in PATH"
        echo ""
        echo -e "       ${YELLOW}Ralph requires Claude Code CLI to run.${NC}"
        echo "       Install from: https://claude.ai/download"
        echo "       After installing, run: claude auth login"
        echo ""
    fi

    # Check for bash version (need 4+ for associative arrays, but we avoid them)
    local bash_version="${BASH_VERSION%%[^0-9]*}"
    if [[ "$bash_version" -ge 3 ]]; then
        log_success "Bash version: $BASH_VERSION"
    else
        log_warn "Bash version $BASH_VERSION may have compatibility issues"
    fi

    if [[ "$has_errors" == "true" ]]; then
        echo ""
        log_error "Please fix the above errors and run the installer again."
        exit 1
    fi

    echo ""
}

# ============================================================================
# Installation
# ============================================================================

backup_existing() {
    if [[ -d "$RALPH_HOME" ]]; then
        log_step "Found existing installation, creating backup..."
        local backup_dir="$RALPH_HOME.backup-$(date +%Y%m%d-%H%M%S)"
        mv "$RALPH_HOME" "$backup_dir"
        log_success "Backup created at: $backup_dir"
    fi
}

create_directories() {
    log_step "Creating directory structure..."
    mkdir -p "$RALPH_HOME"/{scripts,skills/prd,skills/ralph-convert,templates,lib,archive,prompts}
}

install_from_local() {
    log_step "Installing from local repository..."

    # Copy scripts
    cp "$SOURCE_DIR/scripts/ralph.sh" "$RALPH_HOME/"
    cp "$SOURCE_DIR/scripts/ralph-init.sh" "$RALPH_HOME/"
    cp "$SOURCE_DIR/scripts/package.sh" "$RALPH_HOME/"

    # Copy prompt
    cp "$SOURCE_DIR/prompt.md" "$RALPH_HOME/"

    # Copy prompts (orchestrator and subagent)
    cp "$SOURCE_DIR/prompts/"*.md "$RALPH_HOME/prompts/"

    # Copy lib
    cp "$SOURCE_DIR/lib/detect-stack.sh" "$RALPH_HOME/lib/"

    # Copy skills
    cp "$SOURCE_DIR/skills/prd/prompt.md" "$RALPH_HOME/skills/prd/"
    cp "$SOURCE_DIR/skills/ralph-convert/prompt.md" "$RALPH_HOME/skills/ralph-convert/"

    # Copy templates
    cp "$SOURCE_DIR/templates/"* "$RALPH_HOME/templates/"

    # Initialize global learnings file if it doesn't exist
    if [[ ! -f "$RALPH_HOME/learnings.md" ]]; then
        cp "$RALPH_HOME/templates/learnings.md" "$RALPH_HOME/learnings.md"
        log_step "Initialized global learnings file"
    fi
}

install_from_remote() {
    log_step "Downloading Ralph from GitHub..."

    local BASE_URL="https://raw.githubusercontent.com/feelgreatfoodie/ralph-claude-code/main"

    # Download scripts
    curl -fsSL "$BASE_URL/scripts/ralph.sh" -o "$RALPH_HOME/ralph.sh"
    curl -fsSL "$BASE_URL/scripts/ralph-init.sh" -o "$RALPH_HOME/ralph-init.sh"
    curl -fsSL "$BASE_URL/scripts/package.sh" -o "$RALPH_HOME/package.sh"

    # Download prompt
    curl -fsSL "$BASE_URL/prompt.md" -o "$RALPH_HOME/prompt.md"

    # Download prompts (orchestrator and subagent for parallel mode)
    curl -fsSL "$BASE_URL/prompts/orchestrator.md" -o "$RALPH_HOME/prompts/orchestrator.md"
    curl -fsSL "$BASE_URL/prompts/subagent-story.md" -o "$RALPH_HOME/prompts/subagent-story.md"

    # Download lib
    curl -fsSL "$BASE_URL/lib/detect-stack.sh" -o "$RALPH_HOME/lib/detect-stack.sh"

    # Download skills
    curl -fsSL "$BASE_URL/skills/prd/prompt.md" -o "$RALPH_HOME/skills/prd/prompt.md"
    curl -fsSL "$BASE_URL/skills/ralph-convert/prompt.md" -o "$RALPH_HOME/skills/ralph-convert/prompt.md"

    # Download templates
    curl -fsSL "$BASE_URL/templates/ralph.config.json" -o "$RALPH_HOME/templates/ralph.config.json"
    curl -fsSL "$BASE_URL/templates/prd.json.example" -o "$RALPH_HOME/templates/prd.json.example"
    curl -fsSL "$BASE_URL/templates/prd.md.example" -o "$RALPH_HOME/templates/prd.md.example"
    curl -fsSL "$BASE_URL/templates/transcript.example.txt" -o "$RALPH_HOME/templates/transcript.example.txt"
    curl -fsSL "$BASE_URL/templates/learnings.md" -o "$RALPH_HOME/templates/learnings.md"

    # Initialize global learnings file if it doesn't exist
    if [[ ! -f "$RALPH_HOME/learnings.md" ]]; then
        cp "$RALPH_HOME/templates/learnings.md" "$RALPH_HOME/learnings.md"
    fi
}

set_permissions() {
    log_step "Setting executable permissions..."
    chmod +x "$RALPH_HOME/ralph.sh"
    chmod +x "$RALPH_HOME/ralph-init.sh"
    chmod +x "$RALPH_HOME/package.sh"
    chmod +x "$RALPH_HOME/lib/detect-stack.sh"
}

detect_shell() {
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        echo "zsh"
    elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash"* ]]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

print_success() {
    local shell_type=$(detect_shell)
    local rc_file=""

    case "$shell_type" in
        zsh)  rc_file="~/.zshrc" ;;
        bash) rc_file="~/.bashrc" ;;
        *)    rc_file="your shell's rc file" ;;
    esac

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║              Installation Complete! ${NC}                          ${GREEN}║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Ralph is installed at:${NC} $RALPH_HOME"
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}NEXT STEPS${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}1. Add Ralph to your PATH${NC} (recommended)"
    echo ""
    echo "   Run this command:"
    echo -e "   ${CYAN}echo 'export PATH=\"\$HOME/.ralph:\$PATH\"' >> $rc_file${NC}"
    echo ""
    echo "   Then reload your shell:"
    echo -e "   ${CYAN}source $rc_file${NC}"
    echo ""
    echo -e "${BOLD}2. Verify Claude Code is installed${NC}"
    echo ""
    echo "   Run:"
    echo -e "   ${CYAN}claude --version${NC}"
    echo ""
    echo "   If not installed, get it from: https://claude.ai/download"
    echo ""
    echo -e "${BOLD}3. Initialize Ralph in a project${NC}"
    echo ""
    echo "   Navigate to your project and run:"
    echo -e "   ${CYAN}~/.ralph/ralph-init.sh${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}QUICK START${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "   mkdir my-project && cd my-project"
    echo "   git init"
    echo "   ~/.ralph/ralph-init.sh"
    echo "   # Edit ./ralph/transcript.txt with your feature description"
    echo "   claude   # then type: /prd"
    echo "   # Review ./ralph/prd.md"
    echo "   claude   # then type: /ralph-convert"
    echo "   ~/.ralph/ralph.sh"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "For detailed documentation, see: $RALPH_HOME/README.md"
    echo "Or visit: https://github.com/feelgreatfoodie/ralph-claude-code"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_banner
    check_prerequisites
    backup_existing
    create_directories

    if [[ "$INSTALL_MODE" == "local" ]]; then
        install_from_local
    else
        install_from_remote
    fi

    set_permissions
    print_success
}

main "$@"
