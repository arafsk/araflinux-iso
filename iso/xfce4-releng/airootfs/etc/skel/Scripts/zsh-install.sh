#!/usr/bin/env bash

echo "Building DoTis..."

sudo pacman -S --noconfirm --needed base-devel git \
	wget curl bat bat-extras fastfetch micro \
	zsh zsh-autosuggestions zsh-syntax-highlighting

# 1. Download and setup Oh-My-Zsh
#git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 2. Add all ZSH plugins
export ZSH="$HOME/.oh-my-zsh"

source ~/.zshrc

git clone https://github.com/romkatv/powerlevel10k.git "$ZSH/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH/plugins/zsh-syntax-highlighting"
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH/plugins/fast-syntax-highlighting"

source ~/.zshrc

log "~/.zshrc Setup Done..✅"
