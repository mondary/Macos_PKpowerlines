#!/bin/bash
set -e

echo "→ Build release universel (arm64 + x86_64)…"
swift build -c release --arch arm64 --arch x86_64

APP_NAME="Maram.app"
APP_PATH="release/macos/$APP_NAME"
BINARY_SRC=".build/apple/Products/Release/Maram"

rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

cat > "$APP_PATH/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Maram</string>
    <key>CFBundleIdentifier</key>
    <string>com.maram.app</string>
    <key>CFBundleName</key>
    <string>Maram</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2.0</string>
    <key>CFBundleVersion</key>
    <string>2</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

cp "$BINARY_SRC" "$APP_PATH/Contents/MacOS/"

echo "✓ App créée : $APP_PATH"
file "$APP_PATH/Contents/MacOS/Maram"
