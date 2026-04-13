#!/bin/bash
# Smart Notification — Notification hook (needs input)
# Sound: Glass (away) / Bottle (idle 30s)
# Notifications auto-dismiss and don't clutter notification center

TOGGLE_FILE="$HOME/.claude/.smart-notifications-enabled"
PIDFILE="/tmp/claude-idle-input.pid"
COOLDOWN_FILE="/tmp/claude-idle-input.cooldown"

# Check if notifications are enabled
[ ! -f "$TOGGLE_FILE" ] && exit 0

# Kill any existing idle timer
[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
rm -f "$PIDFILE"

# Detect frontmost app
app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

# Terminal apps — start 30s idle timer with Bottle sound (one-time only)
case "$app" in
  Terminal|iTerm2|Code|Cursor|Comet)
    # Check cooldown — only one idle notification per 5 minutes
    if [ -f "$COOLDOWN_FILE" ]; then
      last=$(cat "$COOLDOWN_FILE")
      now=$(date +%s)
      elapsed=$(( now - last ))
      [ "$elapsed" -lt 300 ] && exit 0
    fi
    (
      sleep 30
      # Re-check cooldown before firing
      if [ -f "$COOLDOWN_FILE" ]; then
        last=$(cat "$COOLDOWN_FILE")
        now=$(date +%s)
        elapsed=$(( now - last ))
        [ "$elapsed" -lt 300 ] && exit 0
      fi
      terminal-notifier -title 'You there?' -message 'Claude needs your input.' -group claude-input
      afplay /System/Library/Sounds/Bottle.aiff
      # Auto-remove notification after sound
      terminal-notifier -remove claude-input
      # Set cooldown
      date +%s > "$COOLDOWN_FILE"
      rm -f "$PIDFILE"
    ) &
    echo $! > "$PIDFILE"
    exit 0
    ;;
esac

# Away from terminal — notify immediately with Glass sound, then auto-remove
terminal-notifier -title 'Input Needed' -message 'Claude is waiting for you.' -group claude-input
afplay /System/Library/Sounds/Glass.aiff
terminal-notifier -remove claude-input &
exit 0
