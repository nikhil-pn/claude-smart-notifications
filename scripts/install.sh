#!/bin/bash
# Install Claude Code Smart Notifications
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Installing Smart Notifications..."

# Check for terminal-notifier
if ! command -v terminal-notifier &> /dev/null; then
  echo "Installing terminal-notifier..."
  brew install terminal-notifier
fi

# Copy notification scripts
mkdir -p "$HOME/.claude/scripts"
cp "$SCRIPT_DIR/scripts/stop-notify.sh" "$HOME/.claude/scripts/stop-notify.sh"
cp "$SCRIPT_DIR/scripts/input-notify.sh" "$HOME/.claude/scripts/input-notify.sh"
chmod +x "$HOME/.claude/scripts/"*.sh

# Copy slash command skill
mkdir -p "$HOME/.claude/skills/smart-notifications"
cp "$SCRIPT_DIR/skills/smart-notifications/SKILL.md" "$HOME/.claude/skills/smart-notifications/SKILL.md"

# Add hooks to settings.json
SETTINGS="$HOME/.claude/settings.json"
if [ -f "$SETTINGS" ]; then
  # Check if hooks already exist
  if grep -q "stop-notify.sh" "$SETTINGS"; then
    echo "Hooks already configured in settings.json"
  else
    echo ""
    echo "Add these hooks to your ~/.claude/settings.json under \"hooks\":"
    echo ""
    echo '  "Stop": [{ "hooks": [{ "type": "command", "command": "bash ~/.claude/scripts/stop-notify.sh", "timeout": 5 }] }],'
    echo '  "Notification": [{ "hooks": [{ "type": "command", "command": "bash ~/.claude/scripts/input-notify.sh", "timeout": 5 }] }]'
    echo ""
  fi
else
  echo "No settings.json found. Create one at ~/.claude/settings.json with the hooks."
fi

# Enable notifications by default
touch "$HOME/.claude/.smart-notifications-enabled"

# Set up Claude icon (optional)
echo ""
read -p "Replace terminal-notifier icon with Claude logo? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$SCRIPT_DIR/scripts/setup-icon.sh"
fi

echo ""
echo "Done! Smart Notifications installed."
echo ""
echo "  Toggle:  /smart-notifications on|off|status"
echo "  Sounds:  Purr (task done) | Glass (needs input) | Bottle (idle)"
echo "  Features: Smart grouping | Persistent alerts | 5min idle cooldown"
echo ""
echo "Restart Claude Code to activate."
