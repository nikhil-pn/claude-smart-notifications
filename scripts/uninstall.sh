#!/bin/bash
# Uninstall Claude Code Smart Notifications plugin
set -e

PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/smart-notifications"

echo "Uninstalling Smart Notifications..."

# Kill any active idle timers
for f in /tmp/claude-idle-stop.pid /tmp/claude-idle-input.pid; do
  [ -f "$f" ] && kill "$(cat "$f")" 2>/dev/null
  rm -f "$f"
done

# Remove toggle file
rm -f "$HOME/.claude/.smart-notifications-enabled"

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

# Remove plugin
rm -rf "$PLUGIN_DIR"

echo "Done! Restart Claude Code for changes to take effect."
