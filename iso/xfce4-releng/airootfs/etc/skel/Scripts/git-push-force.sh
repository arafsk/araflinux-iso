#!/bin/sh

#####################################
#  @author      : araf_sk           #
#    GitHub    : @arafsk           #
#    Developer : Araf SK           #
#  﫥  Copyright : Araf SK           #
#####################################

echo "##############################"
echo "Merging Local Update to Github"
echo "##############################"

# After changes anything local this i need to do for merge.
git add .
git commit -m "Updated repository with local changes"
git branch -M main
git push origin main --force

echo "##############################"
echo "###### T H E   E N D  ########"
echo "##############################"