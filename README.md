# Reboot Button

A [GNOME Shell](https://www.gnome.org/) extension that adds a restart button to the top bar. Clicking it opens the **standard GNOME confirmation dialog** and then restarts the computer — exactly the same flow than the *Restart* option in the system menu.

![Compatibility](https://img.shields.io/badge/GNOME_Shell-46-blue)

## Features

- One click: opens the native "Restart" confirmation dialog with countdown and Cancel option.
- Reuses the shell's own `SystemActions.activateRestart()`, so it respects GNOME's normal restart flow, pending updates, and other users' sessions.
- The button automatically hides when restart is not available (e.g. locked down by a system administrator).
- Works on both X11 and Wayland.

## Requirements

- GNOME Shell **46** (Zorin OS 18.x, Ubuntu 24.04, Fedora 40, …)
- A user session (not the login screen)

## Instalation

Copy the extension folder into your local extensions directory:

```bash
cp -r restart-button@local ~/.local/share/gnome-shell/extensions/
```

Then enable it in GSettings:

```bash
gsettings set org.gnome.shell enabled-extensions "['restart-button@local']"
```

> **Note:** if you already have extensions enabled, the command above replaces the whole list. Copy your current list first (see `gsettings get org.gnome.shell enabled-extensions`) and add the new uuid to it.
>
> A quick way to test a change is to restart the shell with `Alt+F2` → `r` (X11 only).

GNOME Shell only discovers new extensions at session start, so log out and back in (or reboot — fitting for once) to see the button.

## Usage

After installing and re-loging in, a restart icon appears in the top bar right next to the power-off button. Click it to open the standard confirmation dialog, then confirm to reboot.

## Uninstall

```bash
rm -rf ~/.local/share/gnome-shell/extensions/restart-button@local
gsettings reset org.gnome.shell enabled-extensions   # or remove the uuid from the list
```

## Development

```text
.
├── restart-button@local/   # extension source
│   ├── extension.js       # entry point (ESM, GNOME 46 API)
│   ├── indicator.js       # panel button
│   ├── metadata.json
│   ├── stylesheet.css
│   ├── locale/            # gettext template
│   └── LICENSE
├── build-deb.sh           # builds the .deb package
├── build-appimage.sh      # builds the installer AppImage
├── .github/workflows/     # CI (code review) and CD (release)
└── README.md
```

The button is implemented as a `PanelMenu.Button` added through `Main.panel.addToStatusArea()`. On click it calls `SystemActions.getDefault().activateRestart()`, reusing the exact code path used by the GNOME system menu.

## Packaging

Two ways to install the extension without the `extensions.gnome.org` website:

- **Debian package** — run `bash build-deb.sh` and install the result with
  `sudo apt install ./dist/gnome-shell-extension-restart-button_1.0_all.deb`.
- **AppImage** — run `bash build-appimage.sh` and run the generated
  `dist/RestartButton-1.0-*.AppImage`. It installs the extension for the
  current user and enables it in GSettings.

CI also builds both artifacts automatically on every `v*` tag (see
`.github/workflows/`).

## License

[MIT](restart-button@local/LICENSE)