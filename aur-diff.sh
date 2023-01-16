#!/bin/sh

sudo pacman -Qqm | sort | uniq > /tmp/aur-installed

cat aur-pkgs.txt | sed 's/^#.*//g' | sed '/^$/d' | sort | uniq \
	> /tmp/aur-nexttime

diff /tmp/aur-nexttime /tmp/aur-installed
