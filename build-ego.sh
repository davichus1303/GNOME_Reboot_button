#!/usr/bin/env bash
set -euo pipefail

UUID="restart-button@local"
PKG_NAME="${UUID}.shell-extension.zip"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$PROJECT_DIR/.build/ego"
DIST_DIR="$PROJECT_DIR/dist"
PKG="$DIST_DIR/$PKG_NAME"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR" "$DIST_DIR"

cp "$PROJECT_DIR/$UUID"/metadata.json \
   "$PROJECT_DIR/$UUID"/extension.js \
   "$PROJECT_DIR/$UUID"/indicator.js \
   "$PROJECT_DIR/$UUID"/stylesheet.css \
   "$PROJECT_DIR/$UUID"/LICENSE \
   "$STAGE_DIR/"

(cd "$STAGE_DIR" && zip -qr "$PKG" .)

echo "Paquete para extensions.gnome.org: $PKG"