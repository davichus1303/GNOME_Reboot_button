#!/usr/bin/env bash
set -euo pipefail

UUID="restart-button@local"
VERSION="1.0"
ARCH="$(uname -m)"
PKG="RestartButton-${VERSION}-${ARCH}.AppImage"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$PROJECT_DIR/dist"
APP_DIR="$PROJECT_DIR/.build/AppDir"
TOOL_DIR="$PROJECT_DIR/.build/appimagetool"

TOOL_URL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR" "$DIST_DIR" "$TOOL_DIR"

cp -r "$PROJECT_DIR/$UUID/." "$APP_DIR/$UUID/"

cat > "$APP_DIR/AppRun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

UUID="restart-button@local"
EXT_DIR="${HOME}/.local/share/gnome-shell/extensions"
TARGET_DIR="${EXT_DIR}/${UUID}"

mkdir -p "${EXT_DIR}"
rm -rf "${TARGET_DIR}"
cp -r "${APPDIR}/${UUID}" "${TARGET_DIR}"
chmod -R u+rwX,go+rX "${TARGET_DIR}"

if command -v gsettings >/dev/null 2>&1 && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    python3 - "${UUID}" <<'PY'
import json
import subprocess
import sys

uuid = sys.argv[1]
value = subprocess.run(
    ['gsettings', 'get', 'org.gnome.shell', 'enabled-extensions'],
    check=True, capture_output=True, text=True).stdout.strip()
extensions = [] if value.startswith('@as') else json.loads(value.replace("'", '"'))
if uuid not in extensions:
    extensions.append(uuid)
    subprocess.run(['gsettings', 'set', 'org.gnome.shell', 'enabled-extensions',
                    json.dumps(extensions).replace('"', "'")], check=True)
PY
fi

cat <<MSG

  Restart Button extension installed to: ${TARGET_DIR}
  Log out and back in so the button shows up in the top bar.

MSG
read -rp "Press Enter to close..." || true
EOF
chmod +x "$APP_DIR/AppRun"

cat > "$APP_DIR/restart-button.desktop" <<EOF
[Desktop Entry]
Name=Restart Button Installer
Comment=Installs the Restart Button GNOME Shell extension
Exec=AppRun
Icon=restart-button
Terminal=true
Type=Application
Categories=Utility;
EOF

python3 - "$APP_DIR" <<'PY'
import struct
import sys
import zlib

out = sys.argv[1]
size = 128
rows = []
for y in range(size):
    row = bytearray(b'\x00')
    for x in range(size):
        # simple reboot-ish arrow: blue field with lighter triangle
        if (x + y) > size and x > y:
            px = (150, 214, 255, 255)
        else:
            px = (53, 132, 228, 255)
        row += bytes(px)
    rows.append(bytes(row))
raw = b''.join(rows)


def chunk(tag, data):
    c = tag + data
    return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)

png = b'\x89PNG\r\n\x1a\n'
png += chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 6, 0, 0, 0))
png += chunk(b'IDAT', zlib.compress(raw, 9))
png += chunk(b'IEND', b'')

with open(f'{out}/restart-button.png', 'wb') as f:
    f.write(png)
PY

if [[ ! -x "$TOOL_DIR/appimagetool" ]]; then
    echo "Descargando appimagetool..."
    curl -fL "$TOOL_URL" -o "$TOOL_DIR/appimagetool"
    chmod +x "$TOOL_DIR/appimagetool"
fi

ARCH="$ARCH" "$TOOL_DIR/appimagetool" --appimage-extract-and-run "$APP_DIR" "$DIST_DIR/$PKG"

echo "AppImage generado: $DIST_DIR/$PKG"