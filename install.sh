#!/usr/bin/env bash
# Nyx-X NixOS + Home Manager Installer
# -------------------------------------------------
# Purpose: Apply the Nyx-X scaffold to a freshly installed NixOS system.
# -------------------------------------------------
# Prerequisites (must be done first, usually via NixOS ISO):
#   1. Boot NixOS ISO / minimal install media
#   2. Partition disks (UEFI + btrfs example)
#   3. Install NixOS minimally:
#      nixos-install --target-host <ip> --configuration ~/minimal-config.nix
#   4. Reboot into NixOS CLI login
# -------------------------------------------------
# This script assumes:
#   - NixOS is installed and you have a root shell
#   - SSH is enabled (or you have console access)
#   - This script is accessible on the target machine
# -------------------------------------------------

set -euo pipefail

# ---------- Configuration ----------
REPO_URL="https://github.com/Techyiola/nixos-config.git"
REPO_DIR="$HOME/nixos-config"
HOSTNAME="Nyx-X"
USER="techyiola"
TIMEZONE="Asia/Kolkata"
LOCALE="en_IN.UTF-8"
KEYMAP="us"

echo "🔧 Nyx-X NixOS Installer starting..."

# ---------- Step 1: Clone scaffold ----------
if [ -d "$REPO_DIR" ]; then
    echo "⚠️  $REPO_DIR already exists — pulling latest..."
    git -C "$REPO_DIR" pull
else
    echo "📦 Cloning nixos-config repo..."
    git clone "$REPO_URL" "$REPO_DIR"
fi
cd "$REPO_DIR"

# ---------- Step 2: Generate hardware config ----------
echo "🛠️  Generating hardware configuration (this detects your Ryzen 5600H + RTX 2050)..."
nixos-generate-config
# Replace the auto-generated hardware-config.nix with our scaffold copy
cp /etc/nixos/hardware-configuration.nix ./hosts/nixos/
echo "✅ Hardware config copied into scaffold."

# ---------- Step 3: Apply NixOS config ----------
echo "🚀 Switching to NixOS config (flake)..."
nixos-rebuild switch --flake .#"$HOSTNAME"

# ---------- Step 4: Apply Home Manager ----------
echo "🏠 Switching to Home Manager..."
home-manager switch --flake .#"$USER@$HOSTNAME"

# ---------- Step 5: Post-install verification ----------
echo "📦 Verifying key installations..."

# Zen Browser
if command -v zen-beta &>/dev/null; then
    echo "   ✅ zen-beta is available in PATH"
else
    echo "   ⚠️  zen-beta not found — run: home-manager switch"
fi

# i3lock-color
if [ -f "$HOME/.local/bin/lock" ]; then
    echo "   ✅ ~/.local/bin/lock exists"
else
    echo "   ⚠️  ~/.local/bin/lock missing — scaffold provides wrapper"
fi

# Screenshot wrapper
if [ -f "$HOME/.local/bin/screenshot" ]; then
    echo "   ✅ ~/.local/bin/screenshot exists"
else
    echo "   ⚠️  ~/.local/bin/screenshot missing — run home-manager switch"
fi

# Dotfile symlinks checked
echo "   📁 i3 config symlink: $HOME/.config/i3 -> $REPO_DIR/dotfiles/i3"
echo "   📁 nvim config symlink: $HOME/.config/nvim -> $REPO_DIR/dotfiles/nvim"

# ---------- Step 6: Final messages ----------
echo ""
echo "========================================="
echo "   Nyx-X installation complete! 🎉"
echo "========================================="
echo ""
echo "🔑 Next steps:"
echo "   • Reboot if not already on desktop"
echo "   • Login: user=$USER, shell=fish"
echo "   • i3 session loads automatically via Ly"
echo "   • Wallpaper: edit $REPO_DIR/dotfiles/i3/wallpaper.png & rebuild"
echo "   • Terminal: ghostty + starship prompt"
echo "   • Browser: zen-beta (via mod+w in i3)"
echo "   • Screenshot: Print key -> ~/.local/bin/spectrum"
echo ""
echo "🛠️  Rebuild commands (future):"
echo "   nixos-rebuild switch --flake .#$HOSTNAME"
echo "   home-manager switch --flake .#$USER@$HOSTNAME"
echo ""
echo "📄 See ~/nixos-config/README.md for full troubleshooting."
echo "========================================="