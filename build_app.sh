#!/bin/bash

swift build -c release

APP_NAME="Maram.app"
APP_PATH="build/$APP_NAME"

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
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
</dict>
</plist>
EOF

cp ".build/release/Maram" "$APP_PATH/Contents/MacOS/"

echo "App créée : $APP_PATH"
