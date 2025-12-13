#!/bin/bash
# fix-araflinux-iso.sh
# Run from: ~/projects/ (where ArafLinux-XFCE4/ lives)
# → Fixes archiso profile for safe, installable ArafOS

set -euo pipefail

PROFILE="ArafLinux-XFCE4/archiso"
AIROOTFS="$PROFILE/airootfs"

log() { echo -e "\e[1;34m[→]\e[0m $1"; }
ok()  { echo -e "\e[1;32m[✓]\e[0m $1"; }
warn() { echo -e "\e[1;33m[!]\e[0m $1"; }
fail() { echo -e "\e[1;31m[✗]\e[0m $1" >&2; exit 1; }

# === CHECK PREREQS ===
[[ -d "$PROFILE" ]] || fail "Profile not found: $PROFILE"
[[ -f "$PROFILE/packages.x86_64" ]] || fail "Missing packages.x86_64"

log "🔧 Fixing ArafLinux-XFCE4/archiso..."

# === 1. BACKUP (optional but wise) ===
BACKUP="${PROFILE}.backup.$(date +%Y%m%d_%H%M%S)"
log "Backing up to $BACKUP..."
cp -r "$PROFILE" "$BACKUP"
ok "Backup complete."

# === 2. REMOVE DANGEROUS/UNUSED FILES ===
log "🧹 Cleaning unsafe artifacts..."
# Remove old customize_airootfs.sh (dangerous grub-install)
rm -f "$AIROOTFS/root/customize_airootfs.sh"

# Remove hardcoded passwd/shadow (live user should be ephemeral)
rm -f "$AIROOTFS/etc/passwd" "$AIROOTFS/etc/shadow" 2>/dev/null || true
# → mkarchiso will generate minimal ones; live user handled by autologin

# Remove old desktop files (if any)
rm -f "$AIROOTFS/etc/skel/Desktop/install.desktop" 2>/dev/null || true

# === 3. INSTALL SAFE customize_airootfs.sh ===
log "📦 Installing safe customize_airootfs.sh..."
mkdir -p "$AIROOTFS/root"
cat > "$AIROOTFS/root/customize_airootfs.sh" <<'EOF'
#!/bin/bash
set -e -u

# Set live hostname
echo "araflive" > /etc/hostname

# Enable network
systemctl enable NetworkManager
systemctl enable dhcpcd

# Auto-login live user on TTY1
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<'INNER'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin araflinux --noclear %I $TERM
INNER

# Empty root password (live ISO convention)
passwd -d root

# Generate locales
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Prepare GRUB template (do NOT install bootloader here)
mkdir -p /boot/grub
cp /usr/share/grub/grub.cfg /boot/grub/grub.cfg.template 2>/dev/null || true

# Clean machine-id
rm -f /etc/machine-id /var/lib/dbus/machine-id
touch /etc/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id
EOF
chmod +x "$AIROOTFS/root/customize_airootfs.sh"

# === 4. FIX mkinitcpio.conf ===
log "⚙️ Updating mkinitcpio.conf for encryption support..."
cat > "$AIROOTFS/etc/mkinitcpio.conf" <<'EOF'
MODULES=(vfat ext4 btrfs xfs)
BINARIES=()
FILES=()
HOOKS=(base udev autodetect modconf block keyboard keymap encrypt filesystems fsck)
COMPRESSION="zstd"
EOF

# === 5. INSTALL INSTALLER SCRIPT ===
log "📥 Installing archinstall-tui.sh..."
INSTALL_DIR="$AIROOTFS/root/install"
mkdir -p "$INSTALL_DIR"
cat > "$INSTALL_DIR/archinstall-tui.sh" <<'EOF'
#!/bin/bash
set -euo pipefail
LOG="/var/log/araflinux-install.log"
exec > >(tee -a "$LOG") 2>&1
BOLD="\e[1m"; RED="\e[31m"; GREEN="\e[32m"; BLUE="\e[34m"; RESET="\e[0m"
log() { echo -e "${BLUE}[→]${RESET} $*"; }
ok() { echo -e "${GREEN}[✓]${RESET} $*"; }
fail() { echo -e "${RED}[✗]${RESET} $*" >&2; exit 1; }
detect_env() {
  LIVE_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
  [[ -n "$LIVE_USER" ]] || fail "Live user not found."
  LIVE_HOME="/home/$LIVE_USER"
  ok "Live user: $LIVE_USER"
}
select_disk() {
  log "Disks:"
  lsblk -dno NAME,SIZE,ROTA,MODEL | awk '{
    rot = ($3 == "1") ? "HDD" : "SSD";
    print NR ". /dev/" $1 " (" $2 ", " rot ") " substr($0, index($0,$4))
  }'
  echo -ne "${BOLD}Select disk (e.g. 1): ${RESET}"
  read -r idx
  DISK="/dev/$(lsblk -dno NAME | sed -n "${idx}p")"
  [[ -b "$DISK" ]] || fail "Invalid disk."
  [[ "$DISK" != "/dev/loop"* ]] || fail "Refusing loop device (ISO medium?)." 
  ok "Target: $DISK"
}
configure() {
  echo -ne "${BOLD}LUKS encryption? (y/N): ${RESET}"; read -r e
  ENCRYPT=${e^^}
  echo -ne "${BOLD}Filesystem [ext4/btrfs] (default: ext4): ${RESET}"; read -r f
  FS=${f:-ext4}
  [[ "$FS" == "ext4" || "$FS" == "btrfs" ]] || fail "FS must be ext4 or btrfs."
}
partition() {
  log "Wiping partition table on $DISK..."
  wipefs -af "$DISK"
  sgdisk --zap-all "$DISK"
  if [[ -d /sys/firmware/efi ]]; then
    FIRMWARE="uefi"
    sgdisk -n 1:0:+512M -t 1:ef00 "$DISK"
    sgdisk -n 2:0:0     -t 2:8300 "$DISK"
  else
    FIRMWARE="bios"
    sgdisk -n 1:0:+512M -t 1:8300 "$DISK"
    sgdisk -n 2:0:0     -t 2:8300 "$DISK"
  fi
  partprobe "$DISK"; sleep 2
  BOOT="${DISK}1"; ROOT="${DISK}2"
  if [[ "$FIRMWARE" == "uefi" ]]; then mkfs.fat -F32 "$BOOT"; else mkfs.ext4 -L boot "$BOOT"; fi
  if [[ "$ENCRYPT" == "Y" ]]; then
    log "Setting up LUKS..."
    cryptsetup luksFormat --type luks2 -q "$ROOT" || fail "LUKS format failed."
    echo -ne "${BOLD}LUKS passphrase: ${RESET}"
    cryptsetup open "$ROOT" cryptroot || fail "LUKS unlock failed."
    ROOT_DEV="/dev/mapper/cryptroot"
  else
    ROOT_DEV="$ROOT"
  fi
  if [[ "$FS" == "ext4" ]]; then
    mkfs.ext4 -L root "$ROOT_DEV"
  else
    mkfs.btrfs -L root "$ROOT_DEV"
    mount "$ROOT_DEV" /mnt
    btrfs subvolume create /mnt/@ >/dev/null
    btrfs subvolume create /mnt/@home >/dev/null
    umount /mnt
    mount -o subvol=@,compress=zstd "$ROOT_DEV" /mnt
    mkdir -p /mnt/home
    mount -o subvol=@home,compress=zstd "$ROOT_DEV" /mnt/home
  fi
}
install() {
  log "Mounting..."
  mount "$ROOT_DEV" /mnt
  mkdir -p /mnt/boot
  mount "$BOOT" /mnt/boot
  log "Installing packages..."
  if [[ -f /packages.x86_64 ]]; then
    pacstrap /mnt $(cat /packages.x86_64)
  else
    pacstrap /mnt base linux linux-firmware
  fi
  genfstab -U /mnt >> /mnt/etc/fstab
}
configure_system() {
  log "Configuring system..."
  if [[ -d "$LIVE_HOME" ]]; then
    log "Copying live user config to /etc/skel..."
    cp -rT "$LIVE_HOME/" /mnt/etc/skel/ 2>/dev/null || true
    chown -R root:root /mnt/etc/skel
    chmod -R u+rw,go+r /mnt/etc/skel
  fi
  arch-chroot /mnt /bin/bash <<'CHROOT'
set -e
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc
echo "araflinux" > /etc/hostname
LIVE_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
useradd -m -G wheel,audio,video,storage -s /bin/bash "$LIVE_USER"
passwd "$LIVE_USER"
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
if [[ "$ENCRYPT" == "Y" ]]; then
  sed -i 's/HOOKS=(base udev/HOOKS=(base udev encrypt/' /etc/mkinitcpio.conf
fi
mkinitcpio -P
if [ -d /sys/firmware/efi ]; then
  pacman -Sy --noconfirm grub efibootmgr >/dev/null
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArafOS
else
  pacman -Sy --noconfirm grub >/dev/null
  grub-install --target=i386-pc "$DISK"
fi
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
CHROOT
  if [[ "$ENCRYPT" == "Y" ]] && ! grep -q "cryptdevice=.*:cryptroot" /mnt/boot/grub/grub.cfg; then
    fail "GRUB not configured for encryption. Aborting."
  fi
  ok "Installation complete."
}
main() {
  clear
  echo -e "${BOLD}ArafOS Installer${RESET}"
  echo "================"
  echo "This will install ArafOS to a disk."
  echo -e "${RED}ALL DATA ON TARGET DISK WILL BE LOST.${RESET}\n"
  detect_env
  select_disk
  configure
  read -p "Press Enter to start installation (Ctrl+C to abort)..."
  partition
  install
  configure_system
  echo -e "\n${GREEN}✅ SUCCESS${RESET}"
  echo "Unmount with: umount -R /mnt"
  echo "Reboot to enjoy your new ArafOS!"
}
main "$@"
EOF
chmod +x "$INSTALL_DIR/archinstall-tui.sh"

# === 6. INSTALL DESKTOP SHORTCUT ===
log "🖥️ Adding desktop installer shortcut..."
DESKTOP_DIR="$AIROOTFS/usr/share/applications"
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/Install-ArafOS.desktop" <<'EOF'
[Desktop Entry]
Name=Install ArafOS
Comment=Install this system to your hard drive
Exec=alacritty -e sudo /root/install/archinstall-tui.sh
Icon=system-software-install
Terminal=false
Type=Application
Categories=System;
StartupNotify=true
EOF

# === 7. VALIDATE packages.x86_64 DEPENDENCIES ===
log "🔍 Ensuring critical packages are present..."
PKGS_FILE="$PROFILE/packages.x86_64"
NEEDED=("alacritty" "cryptsetup" "btrfs-progs" "dosfstools" "efibootmgr")
for pkg in "${NEEDED[@]}"; do
  if ! grep -q "^$pkg$" "$PKGS_FILE"; then
    warn "Adding missing package: $pkg"
    echo "$pkg" >> "$PKGS_FILE"
  fi
done

# === DONE ===
ok "✅ Fix applied successfully."
echo
echo "Next steps:"
echo "  1. Build ISO:  mkarchiso -v -w work -o out ArafLinux-XFCE4/"
echo "  2. Test in VMware (BIOS + UEFI modes)"
echo "  3. Check logs: /var/log/araflinux-install.log during install"
echo
echo "Backup saved at: $BACKUP"