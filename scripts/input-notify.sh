#!/bin/bash
# Smart Notification — Notification hook (needs input)
# Sound: Glass (away) / Bottle (idle 30s)

TOGGLE_FILE="$HOME/.claude/.smart-notifications-enabled"
PIDFILE="/tmp/claude-idle-input.pid"

# Check if notifications are enabled
[ ! -f "$TOGGLE_FILE" ] && exit 0

# Kill any existing idle timer
[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
rm -f "$PIDFILE"

# Detect frontmost app
app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

# Terminal apps — start 30s idle timer with Bottle sound
case "$app" in
  Terminal|iTerm2|Code|Cursor|Comet)
    (sleep 30 && terminal-notifier -title 'You there?' -message 'Claude needs your input.' && afplay /System/Library/Sounds/Bottle.aiff) &
    echo $! > "$PIDFILE"
    exit 0
    ;;
esac

# Away from terminal — notify immediately with Glass sound
terminal-notifier -title 'Input Needed' -message 'Claude is waiting for you.' && afplay /System/Library/Sounds/Glass.aiff &
exit 0
