# 1. Run fix
./fix-araflinux-iso.sh

# 2. Build
cd ArafLinux-XFCE4
mkarchiso -v -w work -o out .

# 3. In VMware:
#    - Create VM → 2GB RAM, 20GB disk
#    - Boot ISO → double-click "Install ArafOS"
#    - Choose disk → encrypt? → ext4 → install
#    - Reboot (remove ISO) → verify:
#        • Grub menu → ArafOS
#        • Login as araflinux (password set during install)
#        • `sudo -v` works
#        • `lsblk` shows encrypted/mapped device if enabled

# 4. If GRUB fails: 
#    - Boot ISO again → chroot into /mnt → inspect /boot/grub/grub.cfg