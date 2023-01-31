#!/bin/bash

grep -vxFf <(sudo pacman -Qqm) <(sudo pacman -Qqe) | sort | uniq \
	> /tmp/pacman-installed

cat pacman-pkgs.txt | sed 's/^#.*//g' | sed '/^$/d' | sort | uniq \
	> /tmp/pacman-nexttime

diff /tmp/pacman-nexttime /tmp/pacman-installed

