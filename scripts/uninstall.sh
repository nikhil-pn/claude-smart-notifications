#!/bin/bash
# Uninstall Claude Code Smart Notifications
echo "Uninstalling Smart Notifications..."

# Kill pending timers
for f in /tmp/claude-idle-stop.pid /tmp/claude-idle-input.pid; do
  [ -f "$f" ] && kill "$(cat "$f")" 2>/dev/null
  rm -f "$f"
done
# Remove scripts
rm -f "$HOME/.claude/scripts/stop-notify.sh"
rm -f "$HOME/.claude/scripts/input-notify.sh"

# Remove skill
rm -rf "$HOME/.claude/skills/smart-notifications"

# Remove toggle file
rm -f "$HOME/.claude/.smart-notifications-enabled"

# Clear any lingering notifications
terminal-notifier -remove claude-stop 2>/dev/null
terminal-notifier -remove claude-input 2>/dev/null

# Restore original terminal-notifier icon
TN_APP=$(find /opt/homebrew/Cellar/terminal-notifier /usr/local/Cellar/terminal-notifier 2>/dev/null -name "terminal-notifier.app" -maxdepth 3 | head -1)
if [ -n "$TN_APP" ]; then
  BACKUP="$TN_APP/Contents/Resources/Terminal.icns.backup"
  if [ -f "$BACKUP" ]; then
    cp "$BACKUP" "$TN_APP/Contents/Resources/Terminal.icns"
    rm "$BACKUP"
    echo "Restored original terminal-notifier icon"
  fi
fi

echo ""
echo "Done! Scripts, skill, and timers removed."
echo "Remember to remove the Stop and Notification hooks from ~/.claude/settings.json"
echo "Restart Claude Code for changes to take effect."
