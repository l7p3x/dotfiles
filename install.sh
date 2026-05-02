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
        hyprshot \
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
    rm -rf /tmp/yamis
    git clone https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set.git \
        /tmp/yamis

    ICONS_DEST="$HOME/.local/share/icons/yet-another-monochrome-icon-set"

    if [[ -d "$ICONS_DEST" ]]; then
        sudo rm -rf "$ICONS_DEST"
    fi

    mkdir -p "$ICONS_DEST"

    cp -r /tmp/yamis/. "$ICONS_DEST/"
    rm -rf "$ICONS_DEST/.git"

    echo "  Done."
}

# --- GTK Theme --------------------------------------------------------------
install_theme() {
    echo "[3/6] Installing Reversal-Dark GTK theme..."
    rm -rf /tmp/reversal
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

    EXCLUSIONS=("install.sh" ".git" ".gitignore" "README.md" ".config" "Wallpapers")

    shopt -s dotglob nullglob
    cd "$SCRIPT_DIR"

    # .config/* -> ~/.config/
    if [[ -d "$SCRIPT_DIR/.config" ]]; then
        echo "  Copying .config/* -> $TARGET_DIR/"
        for item in "$SCRIPT_DIR/.config"/*/; do
            name="$(basename "$item")"
            echo "    $name -> $TARGET_DIR/$name"
            rm -rf "$TARGET_DIR/$name"
            cp -rf "$item" "$TARGET_DIR/$name"
        done
    fi

    # Wallpapers -> ~/Pictures/Wallpapers
    if [[ -d "$SCRIPT_DIR/Wallpapers" ]]; then
        echo "  Copying Wallpapers -> $HOME/Pictures/Wallpapers"
        mkdir -p "$HOME/Pictures/Wallpapers"
        cp -rf "$SCRIPT_DIR/Wallpapers/." "$HOME/Pictures/Wallpapers/"
    else
        echo "  Criando $HOME/Pictures/Wallpapers (pasta vazia)..."
        mkdir -p "$HOME/Pictures/Wallpapers"
    fi

    for item in *; do
        exclude=false
        for excl in "${EXCLUSIONS[@]}"; do
            [[ "$item" == "$excl" ]] && exclude=true && break
        done

        if [[ "$exclude" == false ]]; then
            if [[ "$item" == .zshrc || "$item" == .gtkrc-2.0 ]]; then
                echo "  Copying $item -> $HOME/$item"
                cp -rf "$SCRIPT_DIR/$item" "$HOME/$item"
            else
                echo "  Copying $item -> $TARGET_DIR/$item"
                rm -rf "$TARGET_DIR/$item"
                cp -rf "$SCRIPT_DIR/$item" "$TARGET_DIR/$item"
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

    # Symlinks dos assets GTK 4 do Reversal
    REVERSAL_GTK4="$HOME/.local/share/themes/$THEME/gtk-4.0"
    if [[ -d "$REVERSAL_GTK4" ]]; then
        echo "  Linking GTK 4 assets from theme..."
        ln -sf "$REVERSAL_GTK4/assets"       "$HOME/.config/gtk-4.0/assets"
        ln -sf "$REVERSAL_GTK4/gtk.css"      "$HOME/.config/gtk-4.0/gtk.css"
        ln -sf "$REVERSAL_GTK4/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
    else
        echo "  AVISO: pasta gtk-4.0 não encontrada em $REVERSAL_GTK4 — tema GTK 4 não será aplicado."
    fi

    # gsettings
    if command -v gsettings &>/dev/null; then
        if [[ -z "$DBUS_SESSION_BUS_ADDRESS" ]]; then
            CURRENT_USER="${SUDO_USER:-$USER}"
            USER_BUS=$(ls /run/user/$(id -u "$CURRENT_USER")/bus 2>/dev/null || true)
            if [[ -n "$USER_BUS" ]]; then
                export DBUS_SESSION_BUS_ADDRESS="unix:path=$USER_BUS"
            fi
        fi

        if [[ -n "$DBUS_SESSION_BUS_ADDRESS" ]]; then
            gsettings set org.gnome.desktop.interface gtk-theme    "$THEME"      2>/dev/null || true
            gsettings set org.gnome.desktop.interface icon-theme   "$ICONS"      2>/dev/null || true
            gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"     2>/dev/null || true
            gsettings set org.gnome.desktop.interface font-name    "$FONT"       2>/dev/null || true
            gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
        else
            echo "  AVISO: sessão D-Bus não encontrada — gsettings ignorado."
            echo "         Execute manualmente após o login:"
            echo "         gsettings set org.gnome.desktop.interface gtk-theme '$THEME'"
        fi
    fi

    # Hyprland cursor env vars
    if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
        if ! grep -q "XCURSOR_THEME" "$HOME/.config/hypr/hyprland.conf"; then
            echo "" >> "$HOME/.config/hypr/hyprland.conf"
            echo "env = XCURSOR_THEME,$CURSOR" >> "$HOME/.config/hypr/hyprland.conf"
            echo "env = XCURSOR_SIZE,24"        >> "$HOME/.config/hypr/hyprland.conf"
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

    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    if [[ "$(getent passwd "$CURRENT_USER" | cut -d: -f7)" == "$ZSH_PATH" ]]; then
        echo "  zsh já é o shell padrão para $CURRENT_USER."
    else
        chsh -s "$ZSH_PATH" "$CURRENT_USER"
        echo "  Shell changed to zsh for user: $CURRENT_USER"
        echo "  Re-login to apply."
    fi
}

# --- Main -------------------------------------------------------------------
install_deps
install_icons
install_theme
install_dotfiles
apply_theme
set_zsh_default

if command -v hyprctl &>/dev/null && hyprctl version &>/dev/null 2>&1; then
    echo "Reloading Hyprland..."
    hyprctl reload
else
    echo "Hyprland não está rodando — reload ignorado."
fi

echo ""
echo "Installation complete."
echo "Please log out and log back in to apply all changes."
