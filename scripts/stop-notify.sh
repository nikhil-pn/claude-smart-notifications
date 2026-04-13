#!/bin/bash
# Smart Notification — Stop hook (task complete)
# Sound: Purr (away) / Bottle (idle 30s)
# Notifications auto-dismiss after a few seconds — no clutter

TOGGLE_FILE="$HOME/.claude/.smart-notifications-enabled"
PIDFILE="/tmp/claude-idle-stop.pid"
COOLDOWN_FILE="/tmp/claude-idle-stop.cooldown"

[ ! -f "$TOGGLE_FILE" ] && exit 0

# Kill any existing idle timer
[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
rm -f "$PIDFILE"

# Clean up stale PID file from old script version
rm -f /tmp/claude-idle-notify.pid

# Detect frontmost app
app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)

# Terminal apps — start 30s idle timer with Bottle sound (one-time only)
case "$app" in
  Terminal|iTerm2|Code|Cursor|Comet)
    if [ -f "$COOLDOWN_FILE" ]; then
      last=$(cat "$COOLDOWN_FILE")
      now=$(date +%s)
      [ $(( now - last )) -lt 300 ] && exit 0
    fi
    nohup bash -c '
      sleep 30
      if [ -f "'"$COOLDOWN_FILE"'" ]; then
        last=$(cat "'"$COOLDOWN_FILE"'")
        now=$(date +%s)
        [ $(( now - last )) -lt 300 ] && exit 0
      fi
      terminal-notifier -title "You there?" -message "Claude finished your task." -group claude-stop -sound Bottle
      sleep 3
      terminal-notifier -remove claude-stop
      date +%s > "'"$COOLDOWN_FILE"'"
      rm -f "'"$PIDFILE"'"
    ' >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
    exit 0
    ;;
esac

# Away from terminal — notify immediately with Purr sound, then auto-dismiss
terminal-notifier -title "Done!" -message "Check your Claude terminal." -group claude-stop -sound Purr
( sleep 3; terminal-notifier -remove claude-stop ) &
exit 0
