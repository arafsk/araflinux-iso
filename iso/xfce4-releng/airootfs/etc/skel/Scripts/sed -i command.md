#######################################
###    enter a build/distro name    ###
#######################################

buildname=$(yad --form --center --text-align=center --undecorated --title="Prime Builder" \
  --image="$HOME/builder/builder2.jpg" \
  --field="Enter Build/Distro Name:":CBE ) ;
bname=$(awk -F '|' '{print $1}' <<<$buildname) ;
sed -i "s/codenamebuild/$bname/g" $HOME/builderbackup/efiboot/loader/entries/01-archiso-x86_64-linux.conf $HOME/builderbackup/efiboot/loader/entries/02-archiso-x86_64-speech-linux.conf $HOME/builderbackup/syslinux/archiso_head.cfg $HOME/builderbackup/syslinux/archiso_pxe-linux.cfg $HOME/builderbackup/syslinux/archiso_sys-linux.cfg $HOME/builderbackup/build.sh $HOME/builderbackup/airootfs/etc/grub.cfg $HOME/builderbackup/grub/grub.cfg $HOME/builderbackup/grub/loopback.cfg $HOME/builderbackup/airootfs/etc/skel/.local/share/scripts/lhinstaller/desktop/move $HOME/builderbackup/airootfs/etc/os-release $HOME/builderbackup/profiledef.sh ; 


