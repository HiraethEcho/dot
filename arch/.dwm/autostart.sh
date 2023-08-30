#!/bin/sh
feh --randomize --bg-fill --no-fehbg -z ~/Pictures/wallpapers/*

picom -b

killall fcitx5
fcitx5 &

killall blueman-applet 
blueman-applet &

killall nm-applet 
nm-applet &

# killall pa-applet 
# pa-applet &

# killall slstatus 
# slstatus &

 ~/.dwm/dwm_bar.sh &
