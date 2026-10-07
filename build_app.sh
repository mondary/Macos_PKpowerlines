#!/bin/bash
set -e

APP_INTERNAL_NAME="PKpowerlines"

# Version : CHANGELOG.md est la source de vérité (dernier en-tête versionné)
APP_VERSION=$(sed -n 's/^## \[\([0-9][0-9.]*\)\].*/\1/p' CHANGELOG.md | head -1)
if [ -z "$APP_VERSION" ]; then
    echo "✗ Version introuvable dans CHANGELOG.md" >&2
    exit 1
fi
echo "→ Version : $APP_VERSION"
BUILD_CHANNEL="release"
if [ "${PK_DEV_BUILD:-0}" = "1" ]; then
    BUILD_CHANNEL="dev"
    MARKETING_VERSION="$APP_VERSION-dev.$(date -u +%H%M)"
    BUILD_VERSION="$(date +%s)"
else
    MARKETING_VERSION="$APP_VERSION"
    BUILD_VERSION="${APP_VERSION//./}"
fi

# SDK stable : avec CLT seul, le SDK bêta par défaut peut manquer le plugin SwiftUIMacros
STABLE_SDK="/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk"
if [ -d "$STABLE_SDK" ] && [ ! -e "$STABLE_SDK/usr/lib/swift/host/plugins/libSwiftUIMacros.dylib" ] && [ ! -e "/Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/libSwiftUIMacros.dylib" ]; then
    export SDKROOT="$STABLE_SDK"
    echo "→ SDKROOT : $STABLE_SDK (plugin SwiftUIMacros absent du SDK par défaut)"
fi
echo "→ Build release universel (arm64 + x86_64)…"
if swift build -c release --arch arm64 --arch x86_64 2>/dev/null; then
    BINARY_SRC=".build/apple/Products/Release/$APP_INTERNAL_NAME"
else
    # Pas de Xcode (CLT seul) : --arch multi passe par XCBuild, absent → build par triple + lipo
    echo "  (xcbuild indisponible — build par triple + lipo)"
    swift build -c release --triple arm64-apple-macosx13
    swift build -c release --triple x86_64-apple-macosx13
    BINARY_SRC=""
fi

APP_NAME="$APP_INTERNAL_NAME.app"
APP_PATH="release/macos/$APP_NAME"

rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

cat > "$APP_PATH/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_INTERNAL_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.pkpowerlines.app</string>
    <key>CFBundleName</key>
    <string>$APP_INTERNAL_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$MARKETING_VERSION</string>
    <key>CFBundleVersion</key>
    <string>$BUILD_VERSION</string>
    <key>SUFeedURL</key>
    <string>https://raw.githubusercontent.com/mondary/Macos_PKpowerlines/main/appcast.xml</string>
    <key>SUPublicEDKey</key>
    <string>OoygS0py6kkvRJBB8QAXiAli30SXSYvV7V54Z0Gtcj0=</string>
    <key>SUEnableInstallerLauncherService</key>
    <true/>
    <key>PKpowerlinesBuildChannel</key>
    <string>$BUILD_CHANNEL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

if [ -n "$BINARY_SRC" ]; then
    cp "$BINARY_SRC" "$APP_PATH/Contents/MacOS/"
    FRAMEWORKS_SRC="$(dirname "$BINARY_SRC")"
else
    lipo -create .build/arm64-apple-macosx/release/PKpowerlines .build/x86_64-apple-macosx/release/PKpowerlines -output "$APP_PATH/Contents/MacOS/$APP_INTERNAL_NAME"
    FRAMEWORKS_SRC=".build/arm64-apple-macosx/release"
fi
for resource_bundle in "$FRAMEWORKS_SRC"/*.bundle; do
    [ -d "$resource_bundle" ] || continue
    cp -R "$resource_bundle" "$APP_PATH/Contents/Resources/"
done
mkdir -p "$APP_PATH/Contents/Frameworks"
for framework in "$FRAMEWORKS_SRC"/*.framework; do
    [ -d "$framework" ] || continue
    cp -R "$framework" "$APP_PATH/Contents/Frameworks/"
done
if [ -z "$BINARY_SRC" ]; then
    for arm_framework in "$FRAMEWORKS_SRC"/*.framework; do
        [ -d "$arm_framework" ] || continue
        framework_name="$(basename "$arm_framework")"
        x86_framework=".build/x86_64-apple-macosx/release/$framework_name"
        [ -d "$x86_framework" ] || continue
        executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$arm_framework/Info.plist")
        arm_binary="$arm_framework/Versions/Current/$executable"
        x86_binary="$x86_framework/Versions/Current/$executable"
        destination="$APP_PATH/Contents/Frameworks/$framework_name/Versions/Current/$executable"
        [ -f "$arm_binary" ] && [ -f "$x86_binary" ] && lipo -create "$arm_binary" "$x86_binary" -output "$destination"
    done
fi
if [ -n "$(find "$APP_PATH/Contents/Frameworks" -maxdepth 1 -name '*.framework' -print -quit)" ]; then
    install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP_PATH/Contents/MacOS/$APP_INTERNAL_NAME" 2>/dev/null || true
fi
cp "icon.png" "$APP_PATH/Contents/Resources/icon.png" 2>/dev/null || echo "  (icon.png absent, ignoré)"
cp "src/macos/Resources/powerline_black.png" "$APP_PATH/Contents/Resources/powerline_black.png" 2>/dev/null || echo "  (powerline_black.png absent, ignoré)"
cp "src/macos/Resources/powerline_white.png" "$APP_PATH/Contents/Resources/powerline_white.png" 2>/dev/null || echo "  (powerline_white.png absent, ignoré)"

# Icônes et captures des projets PK (page Bibliothèque des réglages)
mkdir -p "$APP_PATH/Contents/Resources/ProjectIcons"
cp src/macos/Resources/ProjectIcons/*.png "$APP_PATH/Contents/Resources/ProjectIcons/" 2>/dev/null || echo "  (ProjectIcons absent, ignoré)"
mkdir -p "$APP_PATH/Contents/Resources/ProjectScreenshots"
cp src/macos/Resources/ProjectScreenshots/*.png "$APP_PATH/Contents/Resources/ProjectScreenshots/" 2>/dev/null || echo "  (ProjectScreenshots absent, ignoré)"

# Génère l'icône .icns depuis icon.png (source unique)
ICON_SRC="icon.png"
if [ -f "$ICON_SRC" ]; then
    mkdir -p "$APP_PATH/Contents/Resources/icon.iconset"
    sips -z 16 16     "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_16x16.png" > /dev/null 2>&1
    sips -z 32 32     "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_16x16@2x.png" > /dev/null 2>&1
    sips -z 32 32     "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_32x32.png" > /dev/null 2>&1
    sips -z 64 64     "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_32x32@2x.png" > /dev/null 2>&1
    sips -z 128 128   "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_128x128.png" > /dev/null 2>&1
    sips -z 256 256   "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_128x128@2x.png" > /dev/null 2>&1
    sips -z 256 256   "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_256x256.png" > /dev/null 2>&1
    sips -z 512 512   "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_256x256@2x.png" > /dev/null 2>&1
    sips -z 512 512   "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_512x512.png" > /dev/null 2>&1
    sips -z 1024 1024 "$ICON_SRC" --out "$APP_PATH/Contents/Resources/icon.iconset/icon_512x512@2x.png" > /dev/null 2>&1
    iconutil -c icns "$APP_PATH/Contents/Resources/icon.iconset" -o "$APP_PATH/Contents/Resources/AppIcon.icns" > /dev/null 2>&1 && rm -rf "$APP_PATH/Contents/Resources/icon.iconset"
else
    echo "  (icon.png absent, icns non générée)"
fi

if [ -f "$APP_PATH/Contents/Resources/AppIcon.icns" ]; then
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon.icns" "$APP_PATH/Contents/Info.plist" 2>/dev/null
fi

echo "✓ App créée : $APP_PATH"
codesign --force --sign - --timestamp=none "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"
file "$APP_PATH/Contents/MacOS/$APP_INTERNAL_NAME"
