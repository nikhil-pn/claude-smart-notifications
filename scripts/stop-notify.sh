#!/bin/bash
# Smart Notification — Stop hook (task complete)
# Sound: Purr (away) / Bottle (idle 30s)
# Notifications auto-dismiss and don't clutter notification center

TOGGLE_FILE="$HOME/.claude/.smart-notifications-enabled"
PIDFILE="/tmp/claude-idle-stop.pid"
COOLDOWN_FILE="/tmp/claude-idle-stop.cooldown"

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
      terminal-notifier -title 'You there?' -message 'Claude finished your task.' -group claude-stop
      afplay /System/Library/Sounds/Bottle.aiff
      # Auto-remove notification after sound
      terminal-notifier -remove claude-stop
      # Set cooldown
      date +%s > "$COOLDOWN_FILE"
      rm -f "$PIDFILE"
    ) &
    echo $! > "$PIDFILE"
    exit 0
    ;;
esac

# Away from terminal — notify immediately with Purr sound, then auto-remove
terminal-notifier -title 'Done!' -message 'Check your Claude terminal.' -group claude-stop
afplay /System/Library/Sounds/Purr.aiff
terminal-notifier -remove claude-stop &
exit 0
