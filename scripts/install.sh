#!/bin/bash
# Install Claude Code Smart Notifications plugin
set -e

PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/smart-notifications"

echo "Installing Smart Notifications plugin..."

# Check for terminal-notifier
if ! command -v terminal-notifier &> /dev/null; then
  echo "Installing terminal-notifier..."
  brew install terminal-notifier
fi

# Create plugin directory
mkdir -p "$PLUGIN_DIR"/{.claude-plugin,hooks,scripts,skills/smart-notifications}

# Copy plugin files
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cp "$SCRIPT_DIR/.claude-plugin/plugin.json"                    "$PLUGIN_DIR/.claude-plugin/plugin.json"
cp "$SCRIPT_DIR/hooks/hooks.json"                              "$PLUGIN_DIR/hooks/hooks.json"
cp "$SCRIPT_DIR/scripts/stop-notify.sh"                        "$PLUGIN_DIR/scripts/stop-notify.sh"
cp "$SCRIPT_DIR/scripts/input-notify.sh"                       "$PLUGIN_DIR/scripts/input-notify.sh"
cp "$SCRIPT_DIR/scripts/setup-icon.sh"                         "$PLUGIN_DIR/scripts/setup-icon.sh"
cp "$SCRIPT_DIR/skills/smart-notifications/SKILL.md"           "$PLUGIN_DIR/skills/smart-notifications/SKILL.md"
mkdir -p "$PLUGIN_DIR/assets"
cp "$SCRIPT_DIR/assets/claude-logo.png"                        "$PLUGIN_DIR/assets/claude-logo.png"

# Make scripts executable
chmod +x "$PLUGIN_DIR/scripts/"*.sh

# Enable notifications by default
touch "$HOME/.claude/.smart-notifications-enabled"

# Set up Claude icon (optional)
echo ""
read -p "Replace terminal-notifier icon with Claude logo? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$PLUGIN_DIR/scripts/setup-icon.sh"
fi

echo ""
echo "Done! Smart Notifications installed."
echo ""
echo "  Toggle:  /smart-notifications on|off|status"
echo "  Sounds:  Purr (task done) | Glass (needs input) | Bottle (idle)"
echo ""
echo "Restart Claude Code for the plugin to load."
