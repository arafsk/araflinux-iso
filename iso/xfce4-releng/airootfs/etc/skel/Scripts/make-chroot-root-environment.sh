#!/bin/bash

set -euo pipefail
##################################################################################################################
#
#   DO NOT JUST RUN THIS SCRIPT. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

installed_dir=$(dirname $(readlink -f $(basename `pwd`)))

echo "################################################################"
echo "#####        Installing tools for clean chroot build       #####"
echo "################################################################"

sudo pacman -S --needed --noconfirm devtools namcap archlinux-tools

# Define constants
CHROOT_DIR="$HOME/Documents/chroot-archlinux"
PACMAN_CONF=$installed_dir/"pacman.conf"
MIRRORLIST="/etc/pacman.d/chaotic-mirrorlist"
GPG_CONF=$installed_dir"/gpg.conf"

sudo cp "/etc/pacman.d/gnupg/gpg.conf" "$HOME/Documents/"
sudo cp "/etc/pacman.conf" "$HOME/Documents/"

echo "################################################################"
echo "#####               Setting up clean chroot                #####"
echo "################################################################"

mkdir -p "$CHROOT_DIR"

echo "Creating chroot at $CHROOT_DIR"
sudo mkarchroot "$CHROOT_DIR/root" base-devel

echo "Updating chroot system"
sudo arch-nspawn "$CHROOT_DIR/root" pacman -Syu

echo "Installing git in chroot"
sudo arch-nspawn "$CHROOT_DIR/root" pacman -S --noconfirm git

echo "################################################################"
echo "#####                   Copying config files               #####"
echo "################################################################"

if [[ -f "$PACMAN_CONF" ]]; then
    sudo cp "$PACMAN_CONF" "$CHROOT_DIR/root/etc/pacman.conf"
else
    echo "Error: pacman.conf not found at $PACMAN_CONF"
    exit 1
fi

if [[ -f "$MIRRORLIST" ]]; then
    sudo cp "$MIRRORLIST" "$CHROOT_DIR/root/etc/pacman.d/chaotic-mirrorlist"
else
    echo "Error: chaotic-mirrorlist not found."
    exit 1
fi

if [[ -f "$GPG_CONF" ]]; then
    sudo cp "$GPG_CONF" "$CHROOT_DIR/root/etc/pacman.d/gnupg/gpg.conf"
else
    echo "Error: gpg.conf not found."
    exit 1
fi

echo "################################################################"
echo "#####            Installing Chaotic AUR keyring            #####"
echo "################################################################"

sudo arch-nspawn "$CHROOT_DIR/root" pacman -S --noconfirm chaotic-keyring chaotic-mirrorlist
sudo arch-nspawn "$CHROOT_DIR/root" pacman -Syu

echo "################################################################"
echo "#####                     All Done 🎉                      #####"
echo "################################################################"
