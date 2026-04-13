# Claude Code Smart Notifications

> A Claude Code plugin for macOS. Get notified when Claude finishes or needs you — only when you're away from your editor.

![macOS](https://img.shields.io/badge/macOS-only-black)
![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-orange)

---

## What It Does

| Scenario | Notification | Sound |
|----------|-------------|-------|
| Task complete (you're away) | **Done!** — Check your Claude terminal. | Purr |
| Needs your input (you're away) | **Input Needed** — Claude is waiting for you. | Glass |
| Idle 30s on terminal (AFK) | **You there?** — Claude finished / needs input. | Bottle |
| Active on terminal | Nothing. No interruptions. | Silent |

**Smart detection** — skips notifications when you're focused on Terminal, iTerm2, VS Code, Cursor, or Claude desktop.

**Idle detection** — if you're on the terminal but step away (no input for 30s), it notifies you anyway.

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

**2. Copy the plugin**

```bash
PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/smart-notifications"
mkdir -p "$PLUGIN_DIR"
cp -r .claude-plugin hooks scripts skills assets "$PLUGIN_DIR/"
chmod +x "$PLUGIN_DIR/scripts/"*.sh
```

**3. Enable notifications**

```bash
touch ~/.claude/.smart-notifications-enabled
```

**4. (Optional) Set Claude logo as notification icon**

```bash
bash "$PLUGIN_DIR/scripts/setup-icon.sh"
```

**5. Restart Claude Code**

The plugin loads on startup. Restart Claude Code (or start a new session) to activate.

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
Are you on Terminal / iTerm2 / VS Code / Cursor / Claude desktop?
    |                          |
   YES                         NO
    |                          |
    v                          v
Start 30s idle timer      Notify immediately
    |                    (sound + toast)
    v
Still idle after 30s?
    |           |
   YES          NO (you came back)
    |
    v
Notify with Bottle sound
"You there?"
```

---

## Test

**Test sounds:**

```bash
afplay /System/Library/Sounds/Purr.aiff   # Task complete sound
afplay /System/Library/Sounds/Glass.aiff   # Needs input sound
afplay /System/Library/Sounds/Bottle.aiff  # Idle notification sound
```

**Test notification:**

```bash
terminal-notifier -title 'Done!' -message 'Check your Claude terminal.'
```

**Test app detection:**

```bash
osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'
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
bash ~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/smart-notifications/scripts/uninstall.sh
```

Or manually:

```bash
rm -rf ~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/smart-notifications
rm -f ~/.claude/.smart-notifications-enabled
```

---

## File Structure

```
claude-smart-notifications/
  .claude-plugin/
    plugin.json              # Plugin metadata
  hooks/
    hooks.json               # Hook declarations (Stop + Notification)
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

- macOS (uses `osascript`, `afplay`, `sips`, `iconutil`)
- [Homebrew](https://brew.sh)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) (`brew install terminal-notifier`)
- [Claude Code](https://claude.ai/code)

---

*Built with Claude Code*
