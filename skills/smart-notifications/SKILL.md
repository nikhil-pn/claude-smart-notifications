---
name: smart-notifications
description: Toggle smart notifications on or off. Usage /smart-notifications on|off|status
argument-hint: <on|off|status>
allowed-tools: [Bash, Read]
---

# Smart Notifications Toggle

Toggle the smart notification system on or off for Claude Code.

## What to do

Based on the user's argument:

### `on` (or no argument)
1. Run: `touch ~/.claude/.smart-notifications-enabled`
2. Tell the user: Smart notifications are **ON**. They'll get:
   - **Purr** sound + toast when a task completes (away from terminal)
   - **Glass** sound + toast when Claude needs input (away from terminal)
   - **Bottle** sound + toast after 30s idle (on terminal but AFK)

### `off`
1. Run: `rm -f ~/.claude/.smart-notifications-enabled`
2. Also kill any pending idle timers: `[ -f /tmp/claude-idle-stop.pid ] && kill $(cat /tmp/claude-idle-stop.pid) 2>/dev/null; rm -f /tmp/claude-idle-stop.pid; [ -f /tmp/claude-idle-input.pid ] && kill $(cat /tmp/claude-idle-input.pid) 2>/dev/null; rm -f /tmp/claude-idle-input.pid`
3. Tell the user: Smart notifications are **OFF**. No sounds or toasts will fire.

### `status`
1. Check if `~/.claude/.smart-notifications-enabled` exists
2. If yes: tell user notifications are **ON**
3. If no: tell user notifications are **OFF**
