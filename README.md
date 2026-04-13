# Claude Code Smart Notifications

> A Claude Code plugin for macOS. Get notified when Claude finishes or needs you — only when you're away from your editor.

![macOS](https://img.shields.io/badge/macOS-only-black)
![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-orange)
![Tests](https://img.shields.io/badge/tests-27%2F28_passed-brightgreen)

---

## What It Does

| Scenario | Notification | Sound |
|----------|-------------|-------|
| Task complete (you're away) | **Done!** — Check your Claude terminal. | Purr |
| Needs your input (you're away) | **Input Needed** — Claude is waiting for you. | Glass |
| Idle 30s on terminal (AFK) | **You there?** — Claude finished / needs input. | Bottle |
| Active on terminal | Nothing. No interruptions. | Silent |

**Smart detection** — skips notifications when you're focused on Terminal, iTerm2, VS Code, Cursor, or Comet.

**Idle detection** — if you're on the terminal but step away (no input for 30s), it notifies you anyway.

**Auto-dismiss** — notifications appear with sound, stay visible for 3 seconds, then auto-dismiss. No clutter.

**Non-blocking sound** — uses `terminal-notifier -sound` flag for reliable, non-blocking audio. No `afplay` dependency.

**Toggle on/off** — use `/smart-notifications on|off|status` inside Claude Code.

**Claude logo** — notifications show the Claude icon instead of the default terminal icon.

---

## Install

### One-command install

```bash
git clone https://github.com/nikhil-pn/claude-smart-notifications.git /tmp/claude-smart-notifications && bash /tmp/claude-smart-notifications/scripts/install.sh
```

### Manual install

**1. Install terminal-notifier**

```bash
brew install terminal-notifier
```

After installing, go to **System Settings > Notifications > terminal-notifier** and make sure notifications are enabled (set to **Banners** or **Alerts**).

**2. Copy scripts and skill**

```bash
# Copy notification scripts
mkdir -p ~/.claude/scripts
cp scripts/stop-notify.sh scripts/input-notify.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/*.sh

# Copy slash command skill
mkdir -p ~/.claude/skills/smart-notifications
cp skills/smart-notifications/SKILL.md ~/.claude/skills/smart-notifications/
```

**3. Add hooks to settings.json**

Add these hooks to your `~/.claude/settings.json` inside the `"hooks"` object:

```json
"Stop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash ~/.claude/scripts/stop-notify.sh",
        "timeout": 5
      }
    ]
  }
],
"Notification": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash ~/.claude/scripts/input-notify.sh",
        "timeout": 5
      }
    ]
  }
]
```

**4. Enable notifications**

```bash
touch ~/.claude/.smart-notifications-enabled
```

**5. (Optional) Set Claude logo as notification icon**

```bash
bash scripts/setup-icon.sh
```

**6. Restart Claude Code**

---

## Usage

Inside Claude Code:

| Command | What it does |
|---------|-------------|
| `/smart-notifications on` | Enable notifications |
| `/smart-notifications off` | Disable notifications + kill timers |
| `/smart-notifications status` | Check if enabled or disabled |

---

## How It Works

```
Claude finishes a task / needs input
    |
    v
Are you on Terminal / iTerm2 / VS Code / Cursor / Comet?
    |                          |
   YES                         NO
    |                          |
    v                          v
Start 30s idle timer      Notify immediately
    |                    (sound + toast → auto-dismiss)
    v
Still idle after 30s?
    |           |
   YES          NO (you came back)
    |
    v
Notify with Bottle sound
"You there?" (auto-dismiss)
```

---

## Test

See [TEST.md](TEST.md) for the full automated test report (27/28 passed).

**Quick manual tests:**

```bash
# Test notification with sound
terminal-notifier -title 'Done!' -message 'Check your Claude terminal.' -group test -sound Purr

# Test app detection
osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'

# Test the actual scripts
bash ~/.claude/scripts/stop-notify.sh    # Trigger stop notification
bash ~/.claude/scripts/input-notify.sh   # Trigger input notification
```

---

## Customize

| What | How |
|------|-----|
| Change sounds | Edit `stop-notify.sh` / `input-notify.sh` — replace sound names with any file from `/System/Library/Sounds/` |
| Add more editors | Add app names to the `case` statement in both scripts (e.g., `Warp\|Alacritty`) |
| Change idle timeout | Replace `sleep 30` with your preferred seconds |
| Change messages | Edit `-title` and `-message` values in the scripts |
| List available sounds | `ls /System/Library/Sounds/` |

---

## Uninstall

```bash
# Remove scripts and skill
rm -f ~/.claude/scripts/stop-notify.sh ~/.claude/scripts/input-notify.sh
rm -rf ~/.claude/skills/smart-notifications
rm -f ~/.claude/.smart-notifications-enabled

# Kill any pending timers
kill $(cat /tmp/claude-idle-stop.pid 2>/dev/null) 2>/dev/null
kill $(cat /tmp/claude-idle-input.pid 2>/dev/null) 2>/dev/null
rm -f /tmp/claude-idle-stop.pid /tmp/claude-idle-input.pid
```

Then remove the `Stop` and `Notification` hooks from `~/.claude/settings.json`.

---

## File Structure

```
claude-smart-notifications/
  scripts/
    stop-notify.sh           # Task complete notification logic
    input-notify.sh          # Needs input notification logic
    setup-icon.sh            # Replace terminal-notifier icon with Claude logo
    install.sh               # One-command installer
    uninstall.sh             # Clean uninstaller
  skills/
    smart-notifications/
      SKILL.md               # /smart-notifications on|off|status command
  assets/
    claude-logo.png          # Claude logo for notification icon
```

---

## Requirements

- macOS (uses `osascript`, `sips`, `iconutil`)
- [Homebrew](https://brew.sh)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) (`brew install terminal-notifier`)
- [Claude Code](https://claude.ai/code)

---

*Built with Claude Code*
