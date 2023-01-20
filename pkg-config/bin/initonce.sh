#!/bin/sh

# KDE theme
lookandfeeltool -a org.kde.breezedark.desktop

sed -i 's/^exec initonce &/#exec initonce &/g' "$HOME/.xinitrc"
