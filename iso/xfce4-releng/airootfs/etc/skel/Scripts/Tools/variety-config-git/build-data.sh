#!/bin/bash
#CHROOT=$HOME/Documents/chroot-archlinux
#https://wiki.archlinux.org/index.php/DeveloperWiki:Building_in_a_Clean_Chroot
#https://archlinux.org/news/git-migration-completed/
#https://wiki.archlinux.org/title/DeveloperWiki:HOWTO_Be_A_Packager
##################################################################################################################
# Written to be used on 64 bits computers
# Author    :   Erik Dubois
# Website   :   http://www.erikdubois.be
##################################################################################################################
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

if [ -d ".git" ]; then
  echo "Updating with git pull..."
   git pull
fi

PKGBUILD="PKGBUILD"

# Ensure PKGBUILD exists
[[ ! -f $PKGBUILD ]] && { echo "No PKGBUILD found."; exit 1; }

# Read pkgname
pkgname=$(grep -E '^pkgname=' "$PKGBUILD" | cut -d= -f2)

# Get current pkgver and pkgrel
old_pkgver=$(grep -E '^pkgver=' "$PKGBUILD" | cut -d= -f2)
old_pkgrel=$(grep -E '^pkgrel=' "$PKGBUILD" | cut -d= -f2)

# New version: YY.MM
new_pkgver=$(date +%y.%m)

# Set new pkgrel
if [[ "$new_pkgver" != "$old_pkgver" ]]; then
    new_pkgrel="01"
else
    new_pkgrel=$(printf '%02d' $((10#$old_pkgrel + 1)))
fi

# Apply changes
sed -i "s/^pkgver=.*/pkgver=$new_pkgver/" "$PKGBUILD"
sed -i "s/^pkgrel=.*/pkgrel=$new_pkgrel/" "$PKGBUILD"

echo "Updated '$pkgname':"
echo "  pkgver: $old_pkgver → $new_pkgver"
echo "  pkgrel: $old_pkgrel → $new_pkgrel"

destination1=$HOME"/DATA/EDU/nemesis_repo/x86_64/"

destiny=$destination1

#long path
wpdpath=$(dirname $(readlink -f $(basename `pwd`)))
pwdpath=$(echo $PWD)
pwd=$(basename "$PWD")

search1=$(basename "$PWD")
search2=arcolinux
search=$search1

# choice 1 = chroot"
# choice 2 = makepkg"

CHOICE=1

#which packages are always going to be build with makepkg or choice 2
makepkglist=""

for i in $makepkglist
  do
    if [[ "$pwd" == "$i" ]] ; then
      CHOICE=2
    fi
  done

if [ -d /tmp/tempbuild ]; then
  rm -rf /tmp/tempbuild
fi

createcurrentversion(){
  #check current version
  pkgver=$(grep -m1 "pkgver" PKGBUILD | cut -d= -f2)
  pkgrel=$(grep -m1 "pkgrel" PKGBUILD | cut -d= -f2)
  epoch=$(grep -m1 "epoch" PKGBUILD | cut -d= -f2)
  #echo "pkgver = "$pkgver
  echo "pkgver="$pkgver > .current-version
  #echo "pkgrel = "$pkgrel
  echo "pkgrel="$pkgrel >> .current-version
  #echo "epoch = "$epoch
  echo "epoch="$epoch >> .current-version
}

checkversion(){
  #check version
  pkgver=$(grep -m1 "pkgver" PKGBUILD | cut -d= -f2)
  pkgrel=$(grep -m1 "pkgrel" PKGBUILD | cut -d= -f2)
  epoch=$(grep -m1 "epoch" PKGBUILD | cut -d= -f2)
  if [ -f .previous-version ]; then
    oldpkgver=$(grep -m1 "pkgver" .previous-version | cut -d= -f2)
    oldpkgrel=$(grep -m1 "pkgrel" .previous-version | cut -d= -f2)
    oldepoch=$(grep -m1 "epoch" .previous-version | cut -d= -f2)
  fi


  tput setaf 3;
  echo "######################"
  echo "Previous version"
  echo "######################"
  echo "oldpkgver = "$oldpkgver
  echo "oldpkgrel = "$oldpkgrel
  echo "oldepoch = "$oldepoch
  echo "######################"
  echo "New version"
  echo "######################"
  echo "pkgver = "$pkgver
  echo "pkgver="$pkgver > .current-version
  echo "pkgrel = "$pkgrel
  echo "pkgrel="$pkgrel >> .current-version
  echo "epoch = "$epoch
  echo "epoch="$epoch >> .current-version
  echo "We need to build "$name
  echo "######################"
  tput sgr0
  
  if [[ $pkgver != $oldpkgver  ||  $pkgrel != $oldpkgrel  || $epoch != $oldepoch ]] ; then
    buildneeded="true"
  else
    buildneeded="false"
  fi
}

createcurrentversion
checkversion

if [ $buildneeded == "false" ]; then
  echo "#############################################################################################"
  tput setaf 2;echo "No need to build "$name;tput sgr0
  echo "#############################################################################################"
  sleep 1
fi


if [ $buildneeded = "true" ]; then

  if [ -d /tmp/tempbuild ]; then
    rm -rf /tmp/tempbuild
  fi
  mkdir /tmp/tempbuild
  cp -r $pwdpath/* /tmp/tempbuild/

  cd /tmp/tempbuild/

  if [[ $CHOICE == "1" ]] ; then
    #building in chroot
    tput setaf 2
    echo "#############################################################################################"
    echo "#########        Let us build $search in CHROOT ~/Documents/chroot-archlinux"
    echo "#############################################################################################"
    tput sgr0

    CHROOT=$HOME/Documents/chroot-archlinux
    arch-nspawn $CHROOT/root pacman -Syu --noconfirm
    makechrootpkg -c -r $CHROOT
    if [ $? -eq 0 ]; then
      success="true"
    else
      success="false"
    fi
  else
    #building with makepkg - not in chroot
    tput setaf 3
    echo "#############################################################################################"
    echo "#########        Let us build $search with MAKEPKG "$(basename `pwd`)
    echo "#############################################################################################"
    tput sgr0
    makepkg -s
    if [ $? -eq 0 ]; then
      success="true"
    else
      success="false"
    fi
  fi

  if [ $success == true ] ; then 


    echo "#############################################################################################"
    echo "REPO - Copying created files to " $destiny
    echo "#############################################################################################"

    tput setaf 2
    cp -nv *$search*pkg.tar.zst $destiny
      # Check the exit status of the copy command
    if [ $? -ne 0 ]; then
      echo "#############################################################################################"
      echo "Failed to copy $search - it exists already"
      echo "#############################################################################################"
    fi

    file_count=$(find "$destiny" -maxdepth 1 -name "${search}"'*' -print | wc -l)

    if [ "$file_count" -gt 2 ]; then
      # Print the search pattern
      printf "%s\n" "$search" | tee -a /tmp/installed

      # Correct the find command to avoid shell expansion issues with the pattern
      find "$destiny" -maxdepth 1 -name "${search}"'*' -exec basename {} \; | tee -a /tmp/installed
    fi


    tput sgr0

  fi

  echo "#############################################################################################"
  echo "Cleaning up"
  echo "#############################################################################################"
  echo "deleting unnecessary folders"
  echo "#############################################################################################"

  if [[ -f $wpdpath/*.log ]]; then
    rm $pwdpath/*.log
  fi
  if [[ -f $wpdpath/*.deb ]]; then
    rm $pwdpath/*.deb
  fi
  if [[ -f $wpdpath/*.tar.gz ]]; then
    rm $pwdpath/*.tar.gz
  fi

  tput setaf 11
  echo "#############################################################################################"
  echo "###################                       build done                   ######################"
  echo "#############################################################################################"
  tput sgr0
  
  cp $pwdpath/.current-version $pwdpath/.previous-version

fi