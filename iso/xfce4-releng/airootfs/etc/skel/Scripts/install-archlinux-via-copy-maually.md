#!/bin/bash
###################################################################################################
###################################################################################################
#############                          Prime Installer 2025                       #################
###################################################################################################
###################################################################################################
username=globaluser
enableautologin=response1
sleep 1 ;
sudo cp -rv .local/share/scripts/lhinstaller/noerrors /mnt/etc/xdg/ ; 
sudo cp -rv .local/share/scripts/lhinstaller/login1 /mnt/ ;  
sudo sed -i "s/global-user/$username/g" /mnt/login1 ;
sudo sed -i "s/answer/$enableautologin/g" /mnt/login1 ;
cp -rv .local/share/scripts/lhinstaller/desktop/desktop/{.,}* /mnt/home/$username/ ;
#find /etc/skel/.local/share/scripts/ -maxdepth 1 -type f -execdir cp -rv "{}" /mnt/home/$username/.local/share/scripts/ ";" ; 
sudo cp -rv /usr/share/backgrounds /mnt/usr/share/ ;
sudo cp -rv /etc/1/walls/. /mnt/usr/share/backgrounds/walls ;
#sudo cp -rv /etc/1/ /mnt/etc/ ;
sudo sed -i 's/#Color/Color/g' /mnt/etc/pacman.conf ; 
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /mnt/etc/pacman.conf ;
sudo sed -i "s/Arch Linux/codenamebuild/g" /mnt/boot/grub/grub.cfg ;
sed -i "s/live/$username/g" /mnt/home/$username/.config/gtk-3.0/bookmarks ; 
sed -i "s/live/$username/g" /mnt/home/$username/.config/session/dolphin_dolphin_dolphin ; 
sed -i "s/live/$username/g" /mnt/home/$username/.config/GIMP/3.0/theme.css ; 
sudo rm -rf /mnt/home/$username/.local/share/scripts/* ;

