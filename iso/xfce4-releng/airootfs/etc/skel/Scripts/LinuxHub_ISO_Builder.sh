#!/usr/bin/env bash
###################################################################################################
###################################################################################################
#################             LinuxHub Prime Builder v2.0.1 2025              #####################
###################################################################################################
###################################################################################################


#######################################
###    Install required software    ###
#######################################

lxterminal -e 'sudo pacman -S --overwrite \* --needed wget yad lxterminal pluma gimp archiso arch-install-scripts nemo --noconfirm' ;
### Needed to transfer ISO from VM to Desktop ###
lxterminal -e 'sudo pacman -S --overwrite \* --needed --noconfirm grilo-plugins gvfs gvfs-afc gvfs-dnssd gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb gvfs-wsdd loupe malcontent spice spice-gtk spice-vdagent' ;

#######################################
###   create build dialog welcome   ###
#######################################

lxterminal -e 'yes | cp -rv $HOME/builder $HOME/builderbackup/' ; ### back up builder in case of errors ###

yad --form --undecorated --center --title="Prime Builder" --image-on-top --border=20 --image="$HOME/builder/builder1.jpg" \
  --button="Proceed:1" ;

#######################################
###    enter a build/distro name    ###
#######################################

buildname=$(yad --form --center --text-align=center --undecorated --title="Prime Builder" \
  --image="$HOME/builder/builder2.jpg" \
  --field="Enter Build/Distro Name:":CBE ) ;
bname=$(awk -F '|' '{print $1}' <<<$buildname) ;
sed -i "s/codenamebuild/$bname/g" $HOME/builderbackup/efiboot/loader/entries/01-archiso-x86_64-linux.conf $HOME/builderbackup/efiboot/loader/entries/02-archiso-x86_64-speech-linux.conf $HOME/builderbackup/syslinux/archiso_head.cfg $HOME/builderbackup/syslinux/archiso_pxe-linux.cfg $HOME/builderbackup/syslinux/archiso_sys-linux.cfg $HOME/builderbackup/build.sh $HOME/builderbackup/airootfs/etc/grub.cfg $HOME/builderbackup/grub/grub.cfg $HOME/builderbackup/grub/loopback.cfg $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/move $HOME/builderbackup/profiledef.sh ; 

#######################################
###    edit images for installer    ###
#######################################

yad --undecorated --center --title="Prime Builder" --image-on-top --form --image="$HOME/builder/builder3.jpg" \
--field="Open Images with Gimp to Edit":fbtn "gimp $HOME/builderbackup/airootfs/usr/share/backgrounds/walls/default.jpg $HOME/builderbackup/syslinux/splash.png $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/installer1.png" \
--button="Proceed:1" ;

#######################################
###    Custom wallpapers folder     ###
#######################################

yad --undecorated --center --title="Prime Builder" --image-on-top --form --image="$HOME/builder/builder10.jpg" \
--field="Open Custom Wallpaper Folder - OK to Skip":fbtn "nemo $HOME/builderbackup/airootfs/usr/share/backgrounds/walls" \
--button="Proceed:1" ;

#######################################
### copy desktop to builder folder  ###
#######################################

yad --undecorated --center --title="Prime Builder" --image-on-top --form --image="$HOME/builder/builder4.jpg" \
--field="Copy Customized Files to builder":fbtn "lxterminal -e 'cp -rv $HOME/builderbackup/airootfs/usr/share/backgrounds/. /usr/share/backgrounds ; rsync -av --progress $HOME/. $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/ --exclude builder --exclude builderbackup --exclude .mozilla --exclude .cache --exclude builder.tar.xz ; cp -rv /usr/share/backgrounds $HOME/builderbackup/airootfs/usr/share ; cp -rv /usr/share/icons/. $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.icons/ ; cp -rv /usr/share/themes/. $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.themes/'" \
--button="Proceed:1" ;
me="$(whoami)" ;
sed -i "s/$me/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/gtk-3.0/bookmarks ;
sed -i "s/$me/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/session/dolphin_dolphin_dolphin ;
sed -i "s/$me/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/GIMP/3.0/theme.css ;
sed -i "s/$me/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/ibus/bus/*-unix-0 ;
dconf dump / > $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/org.settings ; #OCT 08, 2025

#######################################
### manually remove files you want  ###
#######################################

yad --undecorated --center --title="Prime Builder" --image-on-top --form --image="$HOME/builder/builder5.jpg" \
--field="Remove any files you don't want on the custom build - OK to Skip":fbtn "nemo $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/" \
--button="Proceed:1" ;

#######################################
### manually install desktop files  ###
#######################################

yad --undecorated --center --title="Prime Builder" --image-on-top --form --image="$HOME/builder/builder6.jpg" \
--field="Manually edit file to install desktop":fbtn "pluma $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop.json" \
--button="Proceed:1" ;

#######################################
### manually install desktop files  ###
#######################################

yad --undecorated --center --title="Prime Builder" --image-on-top --form --image="$HOME/builder/builder7.jpg" \
--field="Manually edit file to install AUR files - OK to skip":fbtn "pluma $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/login1" \
--button="Proceed:1" ;

#######################################
###   Build the custom ISO image    ###
#######################################
cd ~ ;
yad --undecorated --center --title="Prime Builder" --image-on-top --form --image="$HOME/builder/builder8.jpg" \
--field="Build Custom ISO":fbtn "lxterminal -e 'sudo mkarchiso -v -w output -o output builderbackup/ && killall yad'" \
--button="Finish:1" ;

#######################################
###        Open ISO Folder          ###
#######################################
cd ~ ;
yad --undecorated --center --title="Prime Builder" --image-on-top --form --image="$HOME/builder/builder9.jpg" \
--field="Open Output Folder":fbtn "nemo $HOME/output" \
--button="Finish:1" ;
