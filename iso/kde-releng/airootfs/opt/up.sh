#!/bin/bash
#set -e

workdir=$(pwd)


sh x86_64/updaterepo.sh

# Below command will backup everything inside the project folder
git add --all .

# Committing to the local repository with a message containing the time details and commit text

git commit -m "update"

# Push the local files to github

if grep -q main .git/config; then
	echo "Using main"
		git push -u origin main
fi

echo
tput setaf 6
echo "##############################################################"
echo "###################  $(basename $0) done"
echo "##############################################################"
tput sgr0
echo
