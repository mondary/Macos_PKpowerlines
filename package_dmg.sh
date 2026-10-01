#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
# Version : CHANGELOG.md est la source de vérité (dernier en-tête versionné)
VERSION=$(sed -n 's/^## \[\([0-9][0-9.]*\)\].*/\1/p' "$ROOT/CHANGELOG.md" | head -1)
if [ -z "$VERSION" ]; then
    echo "✗ Version introuvable dans CHANGELOG.md" >&2
    exit 1
fi

APP="$ROOT/release/macos/PKpowerlines.app"
STAGE="$ROOT/dist/dmg-stage"
DMG="$ROOT/dist/PKpowerlines-$VERSION.dmg"
BACKGROUND="$ROOT/packaging/dmg-background.gif"
VENDOR_CREATE_DMG="$ROOT/packaging/vendor/create-dmg/create-dmg"

"$ROOT/build_app.sh"
rm -rf "$STAGE" "$DMG"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/PKpowerlines.app"

# Contrat dmgly (create-dmg) : fenêtre stylée, fond animé, app -> Applications.
CREATE_DMG=""
if [ -x "$VENDOR_CREATE_DMG" ] && [ -f "$BACKGROUND" ]; then
    CREATE_DMG="$VENDOR_CREATE_DMG"
elif command -v create-dmg >/dev/null 2>&1 && [ -f "$BACKGROUND" ]; then
    CREATE_DMG="create-dmg"
fi

if [ -n "$CREATE_DMG" ]; then
    if ! "$CREATE_DMG" \
        --volname "PKpowerlines $VERSION" \
        --window-size 660 494 \
        --icon-size 128 \
        --icon "PKpowerlines.app" 180 170 \
        --app-drop-link 480 170 \
        --hide-extension "PKpowerlines.app" \
        --background "$BACKGROUND" \
        "$DMG" "$STAGE"; then
        rm -f "$DMG"
        hdiutil create -volname "PKpowerlines $VERSION" -srcfolder "$STAGE" \
            -format UDZO -imagekey zlib-level=9 "$DMG"
    fi
else
    ln -s /Applications "$STAGE/Applications"
    hdiutil create -volname "PKpowerlines $VERSION" -srcfolder "$STAGE" \
        -format UDZO -imagekey zlib-level=9 "$DMG"
fi

rm -rf "$STAGE"
echo "Built $DMG"
