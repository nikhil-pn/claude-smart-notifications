#!/bin/bash
# Replace terminal-notifier's icon with the Claude logo
# This makes notifications show the Claude icon instead of the terminal icon

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOGO="$SCRIPT_DIR/../assets/claude-logo.png"

# Find terminal-notifier app bundle
TN_APP=$(find /opt/homebrew/Cellar/terminal-notifier /usr/local/Cellar/terminal-notifier 2>/dev/null -name "terminal-notifier.app" -maxdepth 3 | head -1)

if [ -z "$TN_APP" ]; then
  echo "terminal-notifier.app not found. Install it first: brew install terminal-notifier"
  exit 1
fi

RESOURCES="$TN_APP/Contents/Resources"
ICON_FILE="$RESOURCES/Terminal.icns"

if [ ! -f "$LOGO" ]; then
  echo "Claude logo not found at $LOGO"
  exit 1
fi

# Backup original icon
if [ ! -f "$ICON_FILE.backup" ]; then
  cp "$ICON_FILE" "$ICON_FILE.backup"
  echo "Backed up original icon"
fi

# Create iconset from Claude logo
ICONSET="/tmp/claude-notif.iconset"
mkdir -p "$ICONSET"

sips -z 16 16     "$LOGO" --out "$ICONSET/icon_16x16.png"     > /dev/null 2>&1
sips -z 32 32     "$LOGO" --out "$ICONSET/icon_16x16@2x.png"  > /dev/null 2>&1
sips -z 32 32     "$LOGO" --out "$ICONSET/icon_32x32.png"     > /dev/null 2>&1
sips -z 64 64     "$LOGO" --out "$ICONSET/icon_32x32@2x.png"  > /dev/null 2>&1
sips -z 128 128   "$LOGO" --out "$ICONSET/icon_128x128.png"   > /dev/null 2>&1
sips -z 256 256   "$LOGO" --out "$ICONSET/icon_128x128@2x.png" > /dev/null 2>&1
sips -z 256 256   "$LOGO" --out "$ICONSET/icon_256x256.png"   > /dev/null 2>&1
sips -z 512 512   "$LOGO" --out "$ICONSET/icon_256x256@2x.png" > /dev/null 2>&1
sips -z 512 512   "$LOGO" --out "$ICONSET/icon_512x512.png"   > /dev/null 2>&1
sips -z 1024 1024 "$LOGO" --out "$ICONSET/icon_512x512@2x.png" > /dev/null 2>&1

# Convert to icns and replace
iconutil -c icns "$ICONSET" -o /tmp/claude-notif.icns
cp /tmp/claude-notif.icns "$ICON_FILE"

# Refresh caches
touch "$TN_APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$TN_APP"
killall NotificationCenter 2>/dev/null || true

# Cleanup
rm -rf "$ICONSET" /tmp/claude-notif.icns

echo "Claude logo set! You may need to log out and back in for the icon to fully update."
