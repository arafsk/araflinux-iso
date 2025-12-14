#!/bin/bash
#set -e
##################################################################################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
# Youtube   : https://youtube.com/erikdubois
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
#tput setaf 0 = black 
#tput setaf 1 = red 
#tput setaf 2 = green
#tput setaf 3 = yellow 
#tput setaf 4 = dark blue 
#tput setaf 5 = purple
#tput setaf 6 = cyan 
#tput setaf 7 = gray 
#tput setaf 8 = light blue
##################################################################################################################

echo "What do you want to replace?"
read FIND
echo "What do you want to replace it with?"
read REPLACE

find . \( -name "*.md" -o -name "*.cfg" -o -name "*.conf*" -o -name "grub.cfg" -o -name "dev-rel" -o -name "profiledef.sh" -o -name "packages.x86_64" -o -name "*.yaml" -o -name "*.desc" -o -name "*.qml" \) \
  -type f -exec sed -i "s/$FIND/$REPLACE/g" {} \;
