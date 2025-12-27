#!/bin/sh

#####################################
#                                   #
#  @author      : araf_sk           #
#    GitHub    : @arafsk          #
#    Developer : Araf SK  			#
#  﫥  Copyright : Araf SK  			#
#                                   #
#####################################


echo "######################################"
echo "installing git for this script to work"
echo "######################################"

#setting up git
#https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config

git init
git config --global user.name "arafsk"
git config --global user.email "arafsos@protonmail.com"
sudo git config --system core.editor nano
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=18000'
git config --global push.default simple


echo "################################################################"
echo "###################    T H E   E N D      ######################"
echo "################################################################"
