<p align="center">
  <img src="assets/claude-logo.png" alt="Claude Logo" width="120" height="120" style="border-radius: 20px;">
</p>

<h1 align="center">Claude Code Smart Notifications</h1>

<p align="center">
  <strong>Get notified when Claude finishes or needs you — only when you're away from your editor.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-only-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS">
  <img src="https://img.shields.io/badge/Claude_Code-plugin-D97757?style=for-the-badge" alt="Claude Code Plugin">
  <img src="https://img.shields.io/badge/tests-27%2F28_passed-2EA043?style=for-the-badge" alt="Tests">
  <img src="https://img.shields.io/badge/version-1.1.0-blue?style=for-the-badge" alt="Version">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-yellow?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/homebrew-required-FBB040?style=flat-square&logo=homebrew&logoColor=white" alt="Homebrew">
</p>

---

<br>

## How It Works

```
Claude finishes a task / needs input
         |
         v
 Are you on a terminal app?
 (Terminal, iTerm2, VS Code, Cursor, Comet)
         |                    |
        YES                   NO
         |                    |
         v                    v
  Start 30s idle timer    Notify immediately
         |                with sound + toast
         v                    |
  Still idle after 30s?       v
     |          |         Auto-dismiss
    YES         NO        after 3 seconds
     |       (cancel)
     v
  Notify with
  Bottle sound
  "You there?"
```

<br>

## Notifications

| Scenario | Message | Sound |
|:---------|:--------|:-----:|
| Task complete (you're away) | **Done!** Check your Claude terminal. | Purr |
| Needs your input (you're away) | **Input Needed** Claude is waiting for you. | Glass |
| Idle 30s on terminal (AFK) | **You there?** Claude finished / needs input. | Bottle |
| Active on terminal | *Nothing. No interruptions.* | *Silent* |

<br>

## Features

| Feature | Description |
|:--------|:------------|
| **Smart Detection** | Stays silent when you're focused on Terminal, iTerm2, VS Code, Cursor, or Comet |
| **Idle Detection** | If you're on a terminal but step away for 30s, it catches you with a nudge |
| **Auto-Dismiss** | Notifications appear with sound, stay for 3 seconds, then vanish. No clutter |
| **Non-Blocking Sound** | Uses `terminal-notifier -sound` for reliable audio — no blocking, no timeouts |
| **Toggle On/Off** | `/smart-notifications on\|off\|status` right inside Claude Code |
| **Claude Logo** | Notifications show the Claude icon instead of the default terminal icon |

<br>

## Quick Start

```bash
git clone https://github.com/nikhil-pn/claude-smart-notifications.git /tmp/claude-smart-notifications \
  && bash /tmp/claude-smart-notifications/scripts/install.sh
```

Then restart Claude Code. That's it.

<br>

## Manual Install

<details>
<summary><strong>Step-by-step instructions</strong></summary>

<br>

**1. Install terminal-notifier**

```bash
brew install terminal-notifier
```

After installing, go to **System Settings > Notifications > terminal-notifier** and make sure notifications are enabled (set to **Banners** or **Alerts**).

**2. Copy scripts and skill**

```bash
mkdir -p ~/.claude/scripts
cp scripts/stop-notify.sh scripts/input-notify.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/*.sh

mkdir -p ~/.claude/skills/smart-notifications
cp skills/smart-notifications/SKILL.md ~/.claude/skills/smart-notifications/
```

**3. Add hooks to `~/.claude/settings.json`**

Add these inside the `"hooks"` object:

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

</details>

<br>

## Usage

| Command | What it does |
|:--------|:-------------|
| `/smart-notifications on` | Enable notifications |
| `/smart-notifications off` | Disable notifications + kill timers |
| `/smart-notifications status` | Check if enabled or disabled |

<br>

## Testing

See **[TEST.md](TEST.md)** for the full automated test report (27/28 passed).

```bash
# Test notification with sound
terminal-notifier -title 'Done!' -message 'Check your Claude terminal.' -group test -sound Purr

# Test app detection
osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'

# Test the actual scripts
bash ~/.claude/scripts/stop-notify.sh
bash ~/.claude/scripts/input-notify.sh
```

<br>

## Customize

| What | How |
|:-----|:----|
| Change sounds | Edit `stop-notify.sh` / `input-notify.sh` — replace sound names with any from `/System/Library/Sounds/` |
| Add more editors | Add app names to the `case` statement in both scripts (e.g. `Warp\|Alacritty`) |
| Change idle timeout | Replace `sleep 30` with your preferred seconds |
| Change messages | Edit `-title` and `-message` values in the scripts |
| List available sounds | `ls /System/Library/Sounds/` |

<br>

## File Structure

```
claude-smart-notifications/
  scripts/
    stop-notify.sh        # Task complete notification
    input-notify.sh       # Needs input notification
    setup-icon.sh         # Claude logo for notifications
    install.sh            # One-command installer
    uninstall.sh          # Clean uninstaller
  skills/
    smart-notifications/
      SKILL.md            # /smart-notifications slash command
  assets/
    claude-logo.png       # Claude logo
```

<br>

## Uninstall

```bash
rm -f ~/.claude/scripts/stop-notify.sh ~/.claude/scripts/input-notify.sh
rm -rf ~/.claude/skills/smart-notifications
rm -f ~/.claude/.smart-notifications-enabled

kill $(cat /tmp/claude-idle-stop.pid 2>/dev/null) 2>/dev/null
kill $(cat /tmp/claude-idle-input.pid 2>/dev/null) 2>/dev/null
rm -f /tmp/claude-idle-stop.pid /tmp/claude-idle-input.pid
```

Then remove the `Stop` and `Notification` hooks from `~/.claude/settings.json`.

<br>

## Requirements

- **macOS** (uses `osascript`, `sips`, `iconutil`)
- [**Homebrew**](https://brew.sh)
- [**terminal-notifier**](https://github.com/julienXX/terminal-notifier) (`brew install terminal-notifier`)
- [**Claude Code**](https://claude.ai/code)

<br>

---

<p align="center">
  <sub>Built with Claude Code by <a href="https://github.com/nikhil-pn">Nikhil PN</a></sub>
</p>
