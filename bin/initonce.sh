#!/bin/sh

donefile="$HOME/.config/.initoncedone"
if [ -e "$donefile" ]; then
	exit
fi

# KDE theme
lookandfeeltool -a org.kde.breezedark.desktop &

# Setup reminders
terminal -e sh -c "vim $HOME/.cache/setupreminder" &

touch "$donefile"
