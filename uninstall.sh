#!/bin/bash

# Claude Session Manager - Uninstallation Script
# This script removes the Claude Session Manager from your system

set -e

INSTALL_DIR="$HOME"

echo "╔════════════════════════════════════════╗"
echo "║ Claude Session Manager - Uninstaller  ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Detect shell config
if [ -f "$HOME/.zshrc" ] && grep -q "claude-sessions-helper.sh" "$HOME/.zshrc" 2>/dev/null; then
  SHELL_CONFIG="$HOME/.zshrc"
  SHELL_NAME="zsh"
elif [ -f "$HOME/.bashrc" ] && grep -q "claude-sessions-helper.sh" "$HOME/.bashrc" 2>/dev/null; then
  SHELL_CONFIG="$HOME/.bashrc"
  SHELL_NAME="bash"
else
  echo "⚠️  Could not find Claude Session Manager installation."
  echo "It may have already been uninstalled or installed in a non-standard way."
  exit 1
fi

echo "📋 Found installation:"
echo "  Shell: $SHELL_NAME"
echo "  Config: $SHELL_CONFIG"
echo ""

# Ask for confirmation
read -p "⚠️  Are you sure you want to uninstall Claude Session Manager? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Uninstallation cancelled."
  exit 0
fi
echo ""

# Ask about snapshots
read -p "📦 Keep saved session snapshots in ~/.claude-sessions? (Y/n): " KEEP_SNAPSHOTS
echo ""

# Step 1: Create backup of shell config
echo "🔄 Step 1/4: Creating backup..."
BACKUP_FILE="${SHELL_CONFIG}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$SHELL_CONFIG" "$BACKUP_FILE"
echo "  ✓ Created backup: $BACKUP_FILE"
echo ""

# Step 2: Remove from shell config
echo "⚙️  Step 2/4: Updating shell configuration..."
# Remove the lines added by installer
sed -i.tmp '/# Claude Code session management helpers/,/source ~\/.claude-workflow-helper.sh/d' "$SHELL_CONFIG"
rm -f "${SHELL_CONFIG}.tmp"
echo "  ✓ Removed configuration from $SHELL_CONFIG"
echo ""

# Step 3: Remove helper scripts
echo "🗑️  Step 3/4: Removing helper scripts..."
rm -f "$INSTALL_DIR/.claude-sessions-helper.sh"
rm -f "$INSTALL_DIR/.claude-workflow-helper.sh"
echo "  ✓ Removed helper scripts from $INSTALL_DIR"
echo ""

# Step 4: Handle snapshots
echo "📁 Step 4/4: Handling snapshots..."
if [[ "$KEEP_SNAPSHOTS" =~ ^[Nn]$ ]]; then
  if [ -d "$HOME/.claude-sessions" ]; then
    rm -rf "$HOME/.claude-sessions"
    echo "  ✓ Removed snapshots directory"
  fi
else
  echo "  ℹ️  Kept snapshots in $HOME/.claude-sessions"
  echo "  ℹ️  You can manually delete them later with: rm -rf ~/.claude-sessions"
fi
echo ""

echo "╔════════════════════════════════════════╗"
echo "║    Uninstallation Complete! 👋        ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "📋 What was removed:"
echo "  ✓ Helper scripts from $INSTALL_DIR"
echo "  ✓ Configuration from $SHELL_CONFIG"
if [[ "$KEEP_SNAPSHOTS" =~ ^[Nn]$ ]]; then
  echo "  ✓ Snapshots directory"
else
  echo "  ℹ️  Snapshots preserved in $HOME/.claude-sessions"
fi
echo ""
echo "💾 Backup created:"
echo "  $BACKUP_FILE"
echo ""
echo "🔄 Next steps:"
echo "1. Reload your shell or open a new terminal:"
echo "   source $SHELL_CONFIG"
echo ""
echo "2. The following commands will no longer be available:"
echo "   - claude-sessions"
echo "   - claude-save"
echo "   - claude-restore"
echo "   - claude-list"
echo "   - claude-show"
echo ""
echo "📦 To reinstall later, run:"
echo "   ./install.sh"
echo ""
