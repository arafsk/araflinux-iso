#!/bin/bash

rm araflinux-repo*

echo "repo-add"
repo-add -n -R araflinux-repo.db.tar.gz calamares-*.pkg.tar.zst    

sleep 1

rm araflinux-repo.db

rm araflinux-repo.files

mv araflinux-repo.db.tar.gz araflinux-repo.db

mv araflinux-repo.files.tar.gz araflinux-repo.files

echo "####################################"
echo "Repo Updated!!"
echo "####################################"
