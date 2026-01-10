#!/usr/bin/env bash
#
# Ralph Package - Create a portable Ralph installation
#
# Usage: package.sh [output-file]
#
# Creates a tarball that can be shared with colleagues.
# Does NOT include any credentials or API keys.
#

set -euo pipefail

RALPH_HOME="${RALPH_HOME:-$HOME/.ralph}"
OUTPUT_FILE="${1:-ralph-portable.tar.gz}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          Ralph Portable Package Creator                      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Copy Ralph files (excluding archives and any sensitive data)
echo -e "${BLUE}[package]${NC} Collecting Ralph files..."
mkdir -p "$TEMP_DIR/.ralph"

# Copy core files
cp "$RALPH_HOME/ralph.sh" "$TEMP_DIR/.ralph/"
cp "$RALPH_HOME/ralph-init.sh" "$TEMP_DIR/.ralph/"
cp "$RALPH_HOME/prompt.md" "$TEMP_DIR/.ralph/"
cp "$RALPH_HOME/install.sh" "$TEMP_DIR/.ralph/"
cp "$RALPH_HOME/README.md" "$TEMP_DIR/.ralph/"
cp "$RALPH_HOME/package.sh" "$TEMP_DIR/.ralph/"

# Copy lib
cp -r "$RALPH_HOME/lib" "$TEMP_DIR/.ralph/"

# Copy skills
cp -r "$RALPH_HOME/skills" "$TEMP_DIR/.ralph/"

# Copy templates
cp -r "$RALPH_HOME/templates" "$TEMP_DIR/.ralph/"

# Create empty archive directory
mkdir -p "$TEMP_DIR/.ralph/archive"

# Create installation instructions
cat > "$TEMP_DIR/INSTALL.txt" << 'EOF'
Ralph for Claude Code - Installation Instructions
================================================

1. Extract to home directory:
   tar -xzf ralph-portable.tar.gz -C ~/

2. Make scripts executable (should already be set):
   chmod +x ~/.ralph/*.sh ~/.ralph/lib/*.sh

3. (Optional) Add to PATH:
   echo 'export PATH="$HOME/.ralph:$PATH"' >> ~/.zshrc
   echo 'alias ralph="~/.ralph/ralph.sh"' >> ~/.zshrc
   source ~/.zshrc

4. Install Claude Code CLI (if not already installed):
   Visit: https://docs.anthropic.com/claude-code

5. Authenticate Claude Code:
   claude auth login

6. Initialize Ralph in your project:
   cd your-project
   ~/.ralph/ralph-init.sh

You're ready to go! See ~/.ralph/README.md for full documentation.
EOF

# Create tarball
echo -e "${BLUE}[package]${NC} Creating tarball..."
cd "$TEMP_DIR"
tar -czf "$OUTPUT_FILE" .ralph INSTALL.txt

# Move to original directory
mv "$OUTPUT_FILE" "$OLDPWD/"
cd "$OLDPWD"

# Get file size
SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Package created: $OUTPUT_FILE ($SIZE)${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Share this file with colleagues. They need to:"
echo "  1. Extract: tar -xzf $OUTPUT_FILE -C ~/"
echo "  2. Install Claude Code CLI"
echo "  3. Authenticate with their own credentials"
echo ""
echo "See INSTALL.txt in the package for detailed instructions."
echo ""
