#!/bin/bash
#

project="araflinux-iso"
echo "-----------------------------------------------------------------------------"
echo "this is project https://github.com/arafsk/$project"
echo "-----------------------------------------------------------------------------"

git config --global pull.rebase false
git config --global push.default simple
git config --global user.name "arafsk"
git config --global user.email "arafsos@protonmail.com"
sudo git config --system core.editor nano
#git config --global credential.helper cache
#git config --global credential.helper 'cache --timeout=32000'
git remote set-url origin git@github.com:arafsk/araflinux-iso.git

echo
echo "Everything set"

echo "################################################################"
echo "###################    T H E   E N D      ######################"
echo "################################################################"
