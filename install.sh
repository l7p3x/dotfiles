#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME/.config"

echo "=== Dotfiles Installer ==="
echo ""

# --- Dependencies -----------------------------------------------------------
install_deps() {
    echo "[1/6] Installing dependencies..."

    if ! command -v yay &>/dev/null; then
        echo "  yay not found, installing..."
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        cd "$SCRIPT_DIR"
    fi

    yay -S --needed --noconfirm \
        zsh \
        hyprland \
        hyprpaper \
        hypridle \
        hyprcursor \
        foot \
        ttf-jetbrains-mono-nerd \
        zen-browser \
        qogir-cursor-theme \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        zsh-history-substring-search \
        nwg-look \
        git

    echo "  Done."
}

# --- Icons ------------------------------------------------------------------
install_icons() {
    echo "[2/6] Installing yet-another-monochrome icon set..."
    git clone https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set.git \
        /tmp/yamis
    mkdir -p "$HOME/.local/share/icons"
    cp -r /tmp/yamis "$HOME/.local/share/icons/yet-another-monochrome-icon-set"
    echo "  Done."
}

# --- GTK Theme --------------------------------------------------------------
install_theme() {
    echo "[3/6] Installing Reversal-Dark GTK theme..."
    git clone https://github.com/yeyushengfan258/Reversal-gtk-theme.git /tmp/reversal
    cd /tmp/reversal
    bash install.sh -d "$HOME/.local/share/themes" -t default
    cd "$SCRIPT_DIR"
    echo "  Done."
}

# --- Dotfiles ---------------------------------------------------------------
install_dotfiles() {
    echo "[4/6] Copying dotfiles..."
    mkdir -p "$TARGET_DIR"

    EXCLUSIONS=("install.sh" ".git" ".gitignore" "README.md")

    shopt -s dotglob nullglob
    cd "$SCRIPT_DIR"

    for item in *; do
        exclude=false
        for excl in "${EXCLUSIONS[@]}"; do
            [[ "$item" == "$excl" ]] && exclude=true && break
        done

        if [[ "$exclude" == false ]]; then
            if [[ "$item" == .zshrc || "$item" == .gtkrc-2.0 ]]; then
                echo "  Copying $item -> $HOME/"
                cp -r "$item" "$HOME/$item"
            else
                echo "  Copying $item -> $TARGET_DIR/"
                cp -r "$item" "$TARGET_DIR/$item"
            fi
        else
            echo "  Skipping: $item"
        fi
    done

    echo "  Done."
}

# --- Apply Theme, Icons and Cursor ------------------------------------------
apply_theme() {
    echo "[5/6] Applying theme, icons and cursor..."

    THEME="Reversal-Dark"
    ICONS="yet-another-monochrome-icon-set"
    CURSOR="Qogir"
    FONT="JetBrainsMono Nerd Font 11"

    # GTK 3
    mkdir -p "$HOME/.config/gtk-3.0"
    cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=$THEME
gtk-icon-theme-name=$ICONS
gtk-cursor-theme-name=$CURSOR
gtk-font-name=$FONT
gtk-application-prefer-dark-theme=1
EOF

    # GTK 4
    mkdir -p "$HOME/.config/gtk-4.0"
    cat > "$HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=$THEME
gtk-icon-theme-name=$ICONS
gtk-cursor-theme-name=$CURSOR
gtk-font-name=$FONT
gtk-application-prefer-dark-theme=1
EOF

    # gsettings
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
        gsettings set org.gnome.desktop.interface icon-theme "$ICONS"
        gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
        gsettings set org.gnome.desktop.interface font-name "$FONT"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    fi

    # Hyprland cursor env vars
    if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
        if ! grep -q "XCURSOR_THEME" "$HOME/.config/hypr/hyprland.conf"; then
            echo "" >> "$HOME/.config/hypr/hyprland.conf"
            echo "env = XCURSOR_THEME,$CURSOR" >> "$HOME/.config/hypr/hyprland.conf"
            echo "env = XCURSOR_SIZE,24" >> "$HOME/.config/hypr/hyprland.conf"
        fi
    fi

    # xsettingsd
    mkdir -p "$HOME/.config/xsettingsd"
    cat > "$HOME/.config/xsettingsd/xsettingsd.conf" <<EOF
Net/ThemeName "$THEME"
Net/IconThemeName "$ICONS"
Gtk/CursorThemeName "$CURSOR"
EOF

    echo "  Done."
}

# --- Default Shell ----------------------------------------------------------
set_zsh_default() {
    echo "[6/6] Setting zsh as default shell..."

    ZSH_PATH="$(which zsh)"
    CURRENT_USER="${SUDO_USER:-$USER}"

    # Add zsh to /etc/shells if not present
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    # Change shell for the actual user
    sudo chsh -s "$ZSH_PATH" "$CURRENT_USER"

    echo "  Shell changed to zsh for user: $CURRENT_USER"
    echo "  Re-login to apply."
}

# --- Main -------------------------------------------------------------------
install_deps
install_icons
install_theme
install_dotfiles
apply_theme
set_zsh_default

echo ""
echo "Installation complete."
echo "Please log out and log back in to apply all changes."
