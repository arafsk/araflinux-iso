#######################################
### copy desktop to builder folder  ###
#######################################

echo
read -p "Ready to copy files to custom ISO.
echo

cp -rv $HOME/builderbackup/airootfs/usr/share/backgrounds/. /usr/share/backgrounds ; 
rsync -av --progress $HOME/. $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/ --exclude builder --exclude builderbackup --exclude .mozilla --exclude .cache --exclude builder.zip ; 
cp -rv /usr/share/backgrounds $HOME/builderbackup/airootfs/usr/share ; 
cp -rv /usr/share/icons/. $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.icons/ ; 
cp -rv /usr/share/themes/. $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.themes/ ;
me="$(whoami)" ;
sed -i "s/$me/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/gtk-3.0/bookmarks ;
sed -i "s/arafsk/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/gtk-3.0/bookmarks ;
sed -i "s/$me/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/session/dolphin_dolphin_dolphin ;
sed -i "s/$me/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/GIMP/3.0/theme.css ;
sed -i "s/$me/live/g" $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/ibus/bus/*-unix-0 ;
dconf dump / > $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/desktop/.config/org.settings ; #OCT 08, 2025

echo
read -p "Finished copy.
echo
