#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="store"
DEST="store/website"

rm -rf "$DEST"
mkdir -p "$DEST/assets"

cp "$SRC/index.html" "$SRC/styles.css" "$SRC/app.js" "$DEST/"
find "$SRC/assets" -maxdepth 1 -type f ! -name 'ART-DIRECTION.md' -exec cp {} "$DEST/assets/" \;

echo "✓ Bundle FTP prêt : $DEST ($(find "$DEST" -type f | wc -l | tr -d ' ') fichiers)"
