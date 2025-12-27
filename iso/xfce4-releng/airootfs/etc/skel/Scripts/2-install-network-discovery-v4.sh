#!/bin/bash
set -e
##################################################################################################################
# Author	:	Erik Dubois
# Website	:	https://www.erikdubois.be
# Website	:	https://www.arcolinux.info
# Website	:	https://www.arcolinux.com
# Website	:	https://www.arcolinuxd.com
# Website	:	https://www.arcolinuxforum.com
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

echo "Network Discovery"

sudo pacman -S --noconfirm --needed avahi
sudo systemctl enable avahi-daemon.service
sudo systemctl start avahi-daemon.service

#shares on a mac
sudo pacman -S --noconfirm --needed nss-mdns

#shares on a linux
sudo pacman -S --noconfirm --needed gvfs-smb

tput setaf 5;echo "################################################################"
echo "Change /etc/nsswitch.conf for access to nas servers etc..."
echo "################################################################"
echo;tput sgr0

# https://wiki.archlinux.org/title/Domain_name_resolution
if [ -f /usr/local/share/edu/nsswitch.conf ]; then
	echo "Make backup and copy edu conf over"
	echo
	sudo cp /etc/nsswitch.conf /etc/nsswitch.conf.backup.nemesis
	sudo cp /usr/local/share/edu/nsswitch.conf /etc/nsswitch.conf
fi

echo "################################################################"
echo "####       network discovery  software installed        ########"
echo "################################################################"
