-# Hyprland Dotfiles
-
-Minimalist Hyprland (Wayland) configuration focused on aesthetics and functionality.
-
-## Components
-
-- **Window Manager**: Hyprland with Master/Dwindle layouts, custom animations, blur, and transparency effects
-- **Bar**: Waybar with Spotify integration, app launchers, system monitoring, and weather widget
-- **Terminal**: Foot with JetBrains Mono Nerd Font
-- **Notifications**: Dunst with custom themes and gamemode indicators
-- **Shell**: Bash with Ble.sh enhancement and custom prompt ("ふあん")
-
-## Features
-
-### Keybindings (ALT as main modifier)
-- `ALT + T`: Open terminal (Foot)
-- `ALT + E`: Open file manager (Nautilus)
-- `ALT + R`: Open app launcher (Bemenu)
-- `ALT + F`: Open browser (Firefox)
-- `ALT + Q`: Close active window
-- `ALT + V`: Toggle floating mode
-- `ALT + S`: Toggle scratchpad (Spotify workspace)
-- `WIN + R`: Reload Hyprland configuration
-- `WIN + F1`: Toggle gamemode
-- `ALT + 1-0`: Switch workspaces
-- `ALT + SHIFT + 1-0`: Move window to workspace
-
-### System Features
-- Automatic Spotify scratchpad on special workspace
-- Screenshot tools (hyprshot) for full screen and region capture
-- Gamemode toggle with visual notifications
-- System monitor (btop) accessible via keybind
-- Quick configuration reload with notification
-
-### Appearance
-- Custom workspace icons
-- Transparent inactive windows (70% opacity)
-- Blur effects enabled
-- Rounded corners (8px)
-- Custom cursor theme (Qogir)
-- YAMIS icon theme (auto-installed)
+# dotfiles-hyprland
+
+A minimal, reproducible **Hyprland (Wayland) desktop setup** focused on performance, simplicity, and clean UX.
+
+This repository provides:
+- A complete Wayland environment (Hyprland + Waybar + Foot + Mako)
+- A modular installer with bootstrap, install, update, rollback, and status flows
+- Optional symlink-based deployment for easy maintenance
+- A clean and lightweight workflow optimized for daily use
+
+Designed to be:
+- fast
+- minimal
+- reproducible
+- easy to understand and modify
 
 ## Installation
 
+Clone the repo and run the installer from inside the project directory.
+
+```bash
+git clone https://github.com/YOUR_USER/dotfiles-hyprland.git ~/.local/share/dotfiles-hyprland
+cd ~/.local/share/dotfiles-hyprland
+./install.sh
+```
+
+The default run uses the `auto` flow (`bootstrap + install`).
+
+## Warning
+
+The installer can deploy files in two modes:
+
+- default: copy files to your `$HOME`
+- `--symlink`: symlink files from this repo into your `$HOME`
+
+If you use `--symlink`, do **not** move or delete this repo folder later, or your desktop config will break.
+
+## Installer commands
+
+```bash
+./install.sh --help
+```
+
+```text
+Commands:
+  (none)              Full auto: bootstrap + install
+  bootstrap           Install base system from scratch
+  install             Deploy dotfiles
+  update              Re-deploy only changed files
+  rollback            Restore last backed-up files
+  status              Show current install state
+```
+
+```text
+Options:
+  --install-packages  Install packages via yay/pacman
+  --symlink           Use symlinks instead of copies
+  --no-backup         Skip backup
+  --dry-run           Show actions without changing anything
+  --force             Ignore install lock
+  --yes               Non-interactive mode
+  --profile=NAME      Use a profile name
+  -h, --help          Show help
+```
+
+## Quick examples
+
+Full setup:
+
 ```bash
 ./install.sh
 ```
 
-The installation script will:
-1. Move configuration files to your home directory
-2. Clone YAMIS icon theme repository
-3. Install monochrome icons to `~/.local/share/icons`
-
-## Dependencies
-
-- hyprland
-- waybar
-- foot
-- dunst
-- hyprpaper
-- hypridle
-- bemenu
-- nautilus
-- firefox
-- btop
-- playerctl
-- hyprshot
-- ble.sh
-
-## Structure
+Only bootstrap dependencies:
+
+```bash
+./install.sh bootstrap
+```
+
+Install configs with symlinks:
+
+```bash
+./install.sh install --symlink
+```
+
+Update after pulling new changes:
+
+```bash
+git pull
+./install.sh update
+```
+
+Check current state:
 
+```bash
+./install.sh status
 ```
-.
-├── .bashrc              # Shell configuration with custom prompt
-├── .blerc               # Ble.sh configuration
-├── .config/
-│   ├── hypr/            # Hyprland configurations
-│   │   ├── hyprland.conf
-│   │   ├── hyprpaper.conf
-│   │   ├── hypridle.conf
-│   │   └── assets/      # Scripts (gamemode, toggle)
-│   ├── waybar/          # Bar configuration
-│   │   ├── config.jsonc
-│   │   └── style.css
-│   ├── foot/            # Terminal emulator settings
-│   │   └── foot.ini
-│   └── dunst/           # Notification daemon
-│       ├── dunstrc
-│       └── icons/
-└── install.sh           # Installation script
+
+Rollback backups created during deploy:
+
+```bash
+./install.sh rollback
 ```
 
-## License
+## Manual installation
+
+If you want to do everything manually:
+
+1. Install core dependencies (Hyprland, Waybar, Foot, Mako, btop, Thunar, fonts, etc.).
+2. Copy or symlink this repo's `.config/` entries to `~/.config/`.
+3. Copy or symlink `.zshrc` and `.gtkrc-2.0` to your `$HOME`.
+4. Copy `Wallpapers/` to `~/Pictures/Wallpapers/`.
+5. Log out and log back in.
+
+## Repository layout
+
+- `.config/` → app configs (hypr, waybar, foot, mako, btop, gtk, thunar, etc.)
+- `Wallpapers/` → wallpaper collection
+- `.zshrc` / `.gtkrc-2.0` → home dotfiles
+- `install.sh` → installer and update/rollback/status workflow
+
+## Notes
 
-Personal dotfiles - feel free to use and modify.
+- The script is designed primarily for Arch-based distributions.
+- Package installation is optional during deploy (`--install-packages`) and enabled by default in `auto`.
+- Use `--dry-run` before first deploy if you want to preview all actions.
