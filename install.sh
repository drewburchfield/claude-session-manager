#!/bin/bash

# Claude Session Manager - Installation Script
# This script installs the Claude Session Manager to your system

set -e

INSTALL_DIR="$HOME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════╗"
echo "║  Claude Session Manager - Installer   ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Detect shell
if [ -n "$ZSH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.zshrc"
  SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.bashrc"
  SHELL_NAME="bash"
else
  echo "⚠️  Warning: Could not detect shell type."
  echo "Please specify your shell config file:"
  read -p "Shell config path (e.g., ~/.zshrc or ~/.bashrc): " SHELL_CONFIG
  SHELL_NAME="unknown"
fi

echo "📋 Installation Summary:"
echo "  Shell: $SHELL_NAME"
echo "  Config: $SHELL_CONFIG"
echo "  Install location: $INSTALL_DIR"
echo ""

# Check if already installed
if grep -q "claude-sessions-helper.sh" "$SHELL_CONFIG" 2>/dev/null; then
  echo "⚠️  Claude Session Manager appears to be already installed."
  read -p "Reinstall/Update? (y/N): " REINSTALL
  if [[ ! "$REINSTALL" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
  fi
  echo ""
fi

# Step 1: Copy scripts
echo "📦 Step 1/4: Copying scripts..."
cp "$SCRIPT_DIR/claude-sessions.sh" "$INSTALL_DIR/.claude-sessions-helper.sh"
cp "$SCRIPT_DIR/claude-workflow.sh" "$INSTALL_DIR/.claude-workflow-helper.sh"
chmod +x "$INSTALL_DIR/.claude-sessions-helper.sh"
chmod +x "$INSTALL_DIR/.claude-workflow-helper.sh"
echo "  ✓ Copied helper scripts to $INSTALL_DIR"
echo ""

# Step 2: Create snapshots directory
echo "📁 Step 2/4: Creating snapshots directory..."
mkdir -p "$HOME/.claude-sessions"
echo "  ✓ Created $HOME/.claude-sessions"
echo ""

# Step 3: Update shell config
echo "⚙️  Step 3/4: Updating shell configuration..."

# Create backup
BACKUP_FILE="${SHELL_CONFIG}.backup-$(date +%Y%m%d-%H%M%S)"
if [ -f "$SHELL_CONFIG" ]; then
  cp "$SHELL_CONFIG" "$BACKUP_FILE"
  echo "  ✓ Created backup: $BACKUP_FILE"
fi

# Check if already added
if ! grep -q "Claude Code session management helpers" "$SHELL_CONFIG" 2>/dev/null; then
  cat >> "$SHELL_CONFIG" << 'EOF'

# Claude Code session management helpers
source ~/.claude-sessions-helper.sh
source ~/.claude-workflow-helper.sh
EOF
  echo "  ✓ Added configuration to $SHELL_CONFIG"
else
  echo "  ℹ️  Configuration already present in $SHELL_CONFIG"
fi
echo ""

# Step 4: Verify installation
echo "✅ Step 4/4: Verifying installation..."
if [ -f "$INSTALL_DIR/.claude-sessions-helper.sh" ] && [ -f "$INSTALL_DIR/.claude-workflow-helper.sh" ]; then
  echo "  ✓ Scripts installed successfully"
else
  echo "  ✗ Script installation failed"
  exit 1
fi

if [ -d "$HOME/.claude-sessions" ]; then
  echo "  ✓ Snapshots directory created"
else
  echo "  ✗ Snapshots directory creation failed"
  exit 1
fi

if grep -q "claude-sessions-helper.sh" "$SHELL_CONFIG"; then
  echo "  ✓ Shell configuration updated"
else
  echo "  ✗ Shell configuration update failed"
  exit 1
fi
echo ""

echo "╔════════════════════════════════════════╗"
echo "║     Installation Complete! 🎉         ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "📚 Next Steps:"
echo ""
echo "1. Reload your shell configuration:"
echo "   source $SHELL_CONFIG"
echo ""
echo "2. Or open a new terminal window"
echo ""
echo "3. Verify installation:"
echo "   claude-sessions"
echo ""
echo "4. Try saving your current sessions:"
echo "   claude-save"
echo ""
echo "📖 Available commands:"
echo "  - claude-sessions           # View running sessions"
echo "  - claude-save               # Save current sessions"
echo "  - claude-restore            # Get restore commands"
echo "  - claude-list               # List all snapshots"
echo "  - claude-show               # View saved sessions"
echo ""
echo "💡 Read the full documentation:"
echo "   cat $SCRIPT_DIR/README.md"
echo ""
echo "🐛 Issues? Check the troubleshooting section in README.md"
echo ""
