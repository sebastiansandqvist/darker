#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$CLANG_MODULE_CACHE_PATH"
SWIFT_FLAGS=(--disable-sandbox --cache-path "$PWD/.build/cache"
             --config-path "$PWD/.build/config" --security-path "$PWD/.build/security")
swift build "${SWIFT_FLAGS[@]}" -c release
BIN_DIR="$(swift build "${SWIFT_FLAGS[@]}" -c release --show-bin-path)"
APP="$PWD/build/Darker.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/Darker" "$APP/Contents/MacOS/Darker"
swift scripts/render-icons.swift "$PWD/build"
iconutil -c icns "$PWD/build/Darker.iconset" -o "$APP/Contents/Resources/AppIcon.icns"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>app.local.darker</string>
<key>CFBundleName</key><string>Darker</string>
<key>CFBundleDisplayName</key><string>Darker</string>
<key>CFBundleExecutable</key><string>Darker</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP"
printf '%s\n' "$APP"
