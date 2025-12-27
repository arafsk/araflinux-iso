#!/bin/bash
amixer -D pulse sset Master 5%- ;
d1=$(pactl list sinks | awk '/Volume.*right/{gsub(/%/,"");print $5}');
yad --title=Volume --no-buttons --timeout=1 --close-on-unfocus  --skip-taskbar --undecorated --center --width=300 --text-align=center --bold  --no-taskbar --text=Volume --scale --value=$d1
