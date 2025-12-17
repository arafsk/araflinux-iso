#!/bin/sh

slstatus &

# polkit
lxpolkit &

# background
#feh --bg-scale /usr/share/backgrounds/wallpaper.png &

# sxhkd
# (re)load sxhkd for keybinds
if hash sxhkd >/dev/null 2>&1; then
	pkill sxhkd
	sleep 0.5
	sxhkd -c "$HOME/.config/sxhkd/sxhkdrc" &
fi

dunst -config ~/.config/dunst/dunstrc &

picom --config ~/.config/picom/picom.conf &
