#!/bin/bash
# Smart Notification — Stop hook (task complete)
# Sound: Purr (away) / Bottle (idle 30s)
# Notifications auto-dismiss after a few seconds — no clutter

TOGGLE_FILE="$HOME/.claude/.smart-notifications-enabled"
PIDFILE="/tmp/claude-idle-stop.pid"

[ ! -f "$TOGGLE_FILE" ] && exit 0

# Kill any existing idle timer
[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
rm -f "$PIDFILE"

# Clean up stale PID file from old script version
rm -f /tmp/claude-idle-notify.pid

# Detect frontmost app
app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)

# Terminal apps — start 30s idle timer with Bottle sound
case "$app" in
  Terminal|iTerm2|Code|Cursor|Comet)
    nohup bash -c '
      sleep 30
      terminal-notifier -title "You there?" -message "Claude finished your task." -group claude-stop -sound Bottle
      rm -f "'"$PIDFILE"'"
      sleep 3
      terminal-notifier -remove claude-stop
    ' >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
    exit 0
    ;;
esac

# Away from terminal — notify immediately with Purr sound, then auto-dismiss
terminal-notifier -title "Done!" -message "Check your Claude terminal." -group claude-stop -sound Purr
( sleep 3; terminal-notifier -remove claude-stop ) &
exit 0
