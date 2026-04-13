# CLAUDE.md — Claude Smart Notifications

## Project Overview

macOS-only Claude Code plugin that sends smart notifications (sound + toast) when Claude finishes a task or needs user input. Stays silent when the user is focused in their terminal/editor.

## Architecture

Two bash scripts triggered by Claude Code hooks:

- `scripts/stop-notify.sh` — fires on `Stop` hook (task complete)
- `scripts/input-notify.sh` — fires on `Notification` hook (needs input)

Both scripts follow the same logic:
1. Check toggle file (`~/.claude/.smart-notifications-enabled`)
2. Detect frontmost app via `osascript`
3. If on a terminal app (Terminal, iTerm2, Code, Cursor, Comet) → spawn 30s idle timer via `nohup`
4. If away from terminal → notify immediately with sound, auto-dismiss after 3s

Sound is delivered via `terminal-notifier -sound <name>` (non-blocking). No `afplay` calls.

## Key Files

| File | Purpose |
|------|---------|
| `scripts/stop-notify.sh` | Task complete notification (Purr sound away, Bottle idle) |
| `scripts/input-notify.sh` | Input needed notification (Glass sound away, Bottle idle) |
| `scripts/install.sh` | One-command installer |
| `scripts/uninstall.sh` | Clean uninstaller |
| `scripts/setup-icon.sh` | Replace terminal-notifier icon with Claude logo |
| `skills/smart-notifications/SKILL.md` | `/smart-notifications on\|off\|status` slash command |
| `.claude-plugin/plugin.json` | Plugin manifest |

## State Files

| File | Purpose |
|------|---------|
| `~/.claude/.smart-notifications-enabled` | Toggle (exists = ON) |
| `/tmp/claude-idle-stop.pid` | Background idle timer PID (stop hook) |
| `/tmp/claude-idle-input.pid` | Background idle timer PID (input hook) |
| `/tmp/claude-idle-stop.cooldown` | Unix timestamp of last idle notification |
| `/tmp/claude-idle-input.cooldown` | Unix timestamp of last idle notification |

## Development Notes

- Scripts must exit within 5 seconds (hook timeout). Currently exits in ~0.2s.
- Idle timers use `nohup bash -c '...' >/dev/null 2>&1 &` to survive hook timeout process group kill.
- The `-group` parameter on `terminal-notifier` prevents duplicate notifications (new ones replace old).
- Auto-dismiss runs in a background subshell: `( sleep 3; terminal-notifier -remove <group> ) &`
- Cooldown and PID cleanup happen immediately after notification send, before the 3s dismiss delay.
- Both source scripts (`scripts/`) and installed copies (`~/.claude/scripts/`) must be kept in sync.

## Testing

See [TEST.md](TEST.md) for the full automated test report. Run manually with:

```bash
bash /tmp/claude-notification-test.sh
```
