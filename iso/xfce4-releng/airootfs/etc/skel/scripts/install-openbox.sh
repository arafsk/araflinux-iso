#!/usr/bin/env bash
set -Eeuo pipefail

### ─────────────────────────────
### Arch Linux Openbox Installer
### ─────────────────────────────

LOG="$HOME/openbox-install.log"
exec > >(tee -a "$LOG") 2>&1

die() { echo "[ERROR] $*" >&2; exit 1; }
msg() { echo "[INFO] $*"; }

### ── HARD REQUIREMENTS ──
[[ -f /etc/arch-release ]] || die "This script is ARCH LINUX ONLY"
command -v sudo >/dev/null || die "sudo not found"
ping -c1 archlinux.org >/dev/null || die "No internet"

ONLY_CONFIG=false
[[ "${1:-}" == "--only-config" ]] && ONLY_CONFIG=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/openbox"

### ── PACMAN SAFETY ──
sudo -v
while fuser /var/lib/pacman/db.lck >/dev/null 2>&1; do
  msg "Waiting for pacman lock..."
  sleep 2
done

### ── PACKAGES ──
PACMAN_PKGS=(
  xorg-server xorg-xinit openbox tint2 polybar
  rofi dunst feh lxappearance
  thunar thunar-archive-plugin thunar-volman gvfs
  pipewire pipewire-pulse pavucontrol pamixer
  network-manager-applet xfce4-power-manager
  flameshot qimgv firefox micro
  acpid avahi fd ripgrep unzip wget curl git
  ttf-font-awesome terminus-font
  base-devel cmake meson ninja
)

AUR_PKGS=(
  obmenu-generator
)

### ── INSTALL PACKAGES ──
if ! $ONLY_CONFIG; then
  msg "Updating system"
  sudo pacman -Syu --noconfirm

  msg "Installing pacman packages"
  sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

  if ! command -v yay >/dev/null; then
    msg "Installing yay"
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
  fi

  msg "Installing AUR packages"
  yay -S --needed --noconfirm "${AUR_PKGS[@]}"

  sudo systemctl enable acpid avahi-daemon
fi

### ── CONFIG SETUP ──
msg "Configuring Openbox"

[[ -d "$CONFIG_DIR" ]] && mv "$CONFIG_DIR" "$CONFIG_DIR.bak.$(date +%s)"
mkdir -p "$CONFIG_DIR"

cp -a "$SCRIPT_DIR/config/." "$CONFIG_DIR/" \
  || die "Config copy failed"

sed -i "s|USER_HOME_DIR|$HOME|g" "$CONFIG_DIR/menu.xml" 2>/dev/null || true

### ── THEMES ──
if ! $ONLY_CONFIG && [[ -d "$SCRIPT_DIR/config/themes" ]]; then
  mkdir -p ~/.themes
  cp -r "$SCRIPT_DIR/config/themes/"* ~/.themes/
fi

### ── MENU GENERATION ──
if ! $ONLY_CONFIG && command -v obmenu-generator >/dev/null; then
  msg "Generating Openbox menu"
  obmenu-generator -p -i || msg "Menu will auto-generate on login"
fi

### ── DONE ──
echo
msg "DONE"
echo "Logout → Select Openbox session"
