#!/bin/sh

echo "sk ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/sk
sudo chmod 440 /etc/sudoers.d/sk

## Flatpak Setup
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo