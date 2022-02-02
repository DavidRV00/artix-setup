#!/bin/sh

# TODO:
#   - manual setups
#		- displays, wallpapers
#		- organize configs better
#			- maintain branches: base, custom(/branches per computer)
#		- reinstall laptop

set -x

alias sudo="sudo "
alias pacman="pacman --noconfirm"
alias makepkg="makepkg --noconfirm"
alias yay="yay --noconfirm"

srcdir="$(pwd)"

mkdir -p $HOME/src

sudo pacman -Sy sed grep awk fzf git artools-base gnupg libssh2 openssh

# Interactively mount drives
set +x
get_part() {
	prompt="$1"
	part="$(lsblk -n --list | grep "^...[0-9]\+.*" | fzf --prompt="$prompt" | awk '{print $1}')"
	echo "$part"
}

while true; do
	part=$( get_part "Select a partition to mount (esc to stop): " )
	[ "$part" != "" ] || break

	echo "Enter mount location for $part: "
	read loc

	set -x
	mkdir -p "$loc"
	mount /dev/"$part" "$loc"
	set +x
	sleep 0.5
	clear
done

lsblk
echo

echo "Writing to fstab:"
sudo fstabgen -U / | sudo tee /etc/fstab

set -euxo pipefail

# GPG keys
# TODO: pam gnupg setup
gpg --full-gen-key

set +x
echo "Enter gpg location to import (empty to stop): "
read secretfile
while [ "$secretfile" != "" ]; do
	set -x
	gpg --import $secretfile
	set +x

	clear
	key="$(gpg --list-keys | fzf --layout=reverse)"

	clear
	echo "************************************************************************"
	echo "Edit the gpg key to trust it"
	echo
	echo "Hints:"
	echo "  trust: trust the key"
	echo "  q: quit"
	echo
	echo "Guidelines:"
	echo "  1. trust"
	echo "  2. 5 (ultimate)"
	echo "  3. y (confirm)"
	echo "  4. q"
	echo "************************************************************************"
	echo

	gpg --edit-key $key
	clear

	echo "Enter gpg location to import (empty to stop): "
	read secretfile
done
gpgconf --kill gpg-agent

# SSH keys
mkdir -p $HOME/.ssh
echo "Enter ssh key location to copy: "
read sshfile
while [ "$sshfile" != "" ]; do
	cp $sshfile $HOME/.ssh

	echo "Enter ssh key location to copy: "
	read sshfile
done
chmod 600 ~/.ssh/*

# Password store
GIT_SSH_COMMAND="ssh -i ~/.ssh/passgit -F /dev/null" git clone ssh://git@davidv.xyz:/home/git/pass-repo $HOME/.password-store

# Git config
echo "Enter git email: "
read gitemail
git config --global user.email "$gitemail"
echo

echo "Enter git name: "
read gitname
git config --global user.name "$gitname"

# Set up package settings
sudo pacman -S artix-archlinux-support

cd "$srcdir"
sudo cp /etc/pacman.conf pacman.conf-bkp
sudo cp pacman.conf-sample /etc/pacman.conf
sudo pacman-key --populate archlinux

sudo cp /etc/makepkg.conf makepkg.conf-bkp
sudo cp makepkg.conf-sample /etc/makepkg.conf

sudo pacman -Syu

# Install official packages
cat pacman-pkgs.txt | sed 's/^#.*//g' | sed '/^$/d' | sudo pacman -S -

# Install yay
sudo pacman -S base-devel
cd $HOME/src
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
cd $srcdir

# Install AUR packages
cat aur-pkgs.txt | sed 's/^#.*//g' | sed '/^$/d' | yay -S -

sudo rm pacman.conf-bkp
sudo rm makepkg.conf-bkp

# Retrieve source-based tools
cd $HOME/src
git clone https://github.com/DavidRV00/dwm-fork
cd dwm-fork
make
sudo make install

cd $HOME/src
git clone https://github.com/DavidRV00/dmenu-fork
cd dmenu-fork
make
sudo make install

# Retrieve configs + scripts / interfaces
cd $HOME/src
git clone --bare https://github.com/davidrv00/bare-configs.git

alias config='git --git-dir=$HOME/src/bare-configs.git --work-tree=$HOME'
config config --local status.showUntrackedFiles no
config restore --staged $HOME
config restore $HOME

echo "alias config='git --git-dir=$HOME/src/bare-configs.git --work-tree=$HOME'" >> ~/.zshrc

# TODO
# Perform manual setups (
# 	starship,
# 	conda (+packages),
# 	mutt-wizard,
# 	vundle + vim plugin-install + netrw,
# 	fonts,
# 	plex,
# 	rss-bridge,
# 	etc)
# echo "[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc
# mw -a david@davidv.xyz
# mail sync

# Set up audio
sudo usermod -a -G realtime,audio "$USER"

sudo sed -i '/^# End of file/d' /etc/security/limits.conf

sudo cat << EOF | sudo tee -a /etc/security/limits.conf
# audio group
@audio		-	rtprio		95
@audio		-	memlock		unlimited
EOF

# TODO: Use some kind of spec file
# Pull in templates and special data and stuff

# Set up runit autostarts
set +x
for svc in bluetoothd cronie ntpd wpa_supplicant; do
	set -x
	sudo ln -s /etc/runit/sv/"$svc" /run/runit/service/
	set +x
done

# TODO: set up cron jobs

# TODO: interactively set up displays + wallpaper

