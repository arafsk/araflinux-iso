#!/bin/sh
set -e

sudo pacman -S wget curl bat bat-extras fastfetch micro zsh zsh-autosuggestions zsh-syntax-highlighting-y
sudo apt install -y git wget curl bat bat-extras zsh fastfetch micro zsh-autosuggestions zsh-syntax-highlighting
sudo dnf install -y git wget curl bat bat-extras zsh fastfetch micro zsh-autosuggestions zsh-syntax-highlighting
sudo zypper install -y git wget curl bat bat-extras zsh fastfetch micro zsh-autosuggestions zsh-syntax-highlighting
chsh -s $(which zsh)

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
source ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate

source ~/.zshrc
exec zsh

log "✅ All done! Open a new terminal to enjoy your setup."
