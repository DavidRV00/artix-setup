#!/bin/sh

exec initonce &
exec setlayout &
exec dunst &
exec nitrogen --restore &
#exec picom &
exec unclutter --idle 2 --noevents &
exec redshift &
exec setupaudio &
exec setdate &
exec syncthing --no-browser &
#exec monerod &

exec dwm
