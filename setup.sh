#!/bin/bash

# TODO first:
# option for full-disk encryption

# TODO:
#		- organize configs better
#			- maintain branches: base, custom(/branches per computer)
#		- make modular, idempotent setup scripts that can be simply slotted in
# 		- plex
# 		- rss-bridge
# 		- mail sync
#			- pass git alias / command
#			- pam gnupg
#				- follow the instructions in https://github.com/cruegge/pam-gnupg
#					- login, system-local-login, ...

set -x
shopt -s expand_aliases

alias sudo="sudo "
alias pacman="pacman --noconfirm"
alias makepkg="makepkg --noconfirm"
alias yay="yay --noconfirm"

srcdir="$(pwd)"

mkdir -p "$HOME/src"
mkdir -p "$HOME/projects"
mkdir -p "$HOME/current"

sudo pacman -Syu

sudo pacman -S sed grep wget awk fzf git artools-base gnupg libssh2 openssh ntfs-3g cryptsetup

# Set up package settings
cd "$srcdir"
sudo cp /etc/pacman.conf pacman.conf-bkp
sudo cp setup-config/pacman.conf-sample /etc/pacman.conf
sudo cp setup-config/mirrorlist-arch-sample /etc/pacman.d/mirrorlist-arch
sudo pacman -Sy artix-archlinux-support

sudo sed -i 's/^# after-universe: //g' /etc/pacman.conf

sudo pacman-key --populate archlinux
sudo pacman -Syu

sudo pacman -S reflector
reflector --verbose --country 'United States' -l 20 -f 5 --sort rate --save /etc/pacman.d/mirrorlist-arch

sudo pacman -S lf

sudo cp /etc/makepkg.conf makepkg.conf-bkp
sudo cp setup-config/makepkg.conf-sample /etc/makepkg.conf

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
	devloc="$part"

	clear

	echo "Enter a name for the mountpoint for $part: "
	read -r mntloc

	read -p "Is this a LUKS-encrypted drive? [y/n] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		sudo cryptsetup open "/dev/$part" "$mntloc"
		devloc="mapper/$mntloc"
	fi

	set -x
	sudo mkdir -p "/media/$mntloc"
	sudo mount "/dev/$devloc" "/media/$mntloc"
	set +x
	sleep 0.5
	clear
done

lsblk
echo

# TODO: write encrypted volumes to crypttab?
echo "Writing to fstab:"
sudo fstabgen -U / | sudo tee /etc/fstab

set -euxo pipefail

# GPG keys
read -p "Generate a new GPG key? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	gpg --full-gen-key
fi

set +x
echo "Enter gpg location(s) to import (empty to stop): "
#read -r secretfile
secretfiles=$(lf -command "set hidden\!" -selection-path /dev/stdout)
while [ "$secretfiles" != "" ]; do
	set -x
	gpg --import "$secretfiles"
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

	echo "Enter gpg location(s) to import (empty to stop): "
	#read -r secretfile
	secretfiles=$(lf -command "set hidden\!" -selection-path /dev/stdout)
done
gpgconf --kill gpg-agent

# SSH keys
mkdir -p "$HOME/.ssh"
ssh-keygen
echo "Enter ssh key location(s) to copy: "
#read -r sshfile
sshfiles=$(lf -command "set hidden\!" -selection-path /dev/stdout)
while [ "$sshfiles" != "" ]; do
	cp "$sshfiles" "$HOME/.ssh/"

	echo "Enter ssh key location(s) to copy: "
	#read -r sshfile
	sshfiles=$(lf -command "set hidden\!" -selection-path /dev/stdout)
done
if [ "$(ls ~/.ssh)" != "" ]; then
	chmod 600 ~/.ssh/*
fi

# Password store
rm -rf "$HOME/.password-store"
if test -f ~/.ssh/passgit; then
	GIT_SSH_COMMAND="ssh -i ~/.ssh/passgit -F /dev/null" \
		git clone ssh://git@davidv.xyz:/home/git/pass-repo "$HOME/.password-store"
fi

# Git config
echo "Enter git email: "
read -r gitemail
git config --global user.email "$gitemail"
echo

echo "Enter git name: "
read -r gitname
git config --global user.name "$gitname"

# Install official packages
cat pacman-pkgs.txt | sed 's/^#.*//g' | sed '/^$/d' | sudo pacman -S -

# Install yay
sudo pacman -S base-devel
cd "$HOME/src"
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
cd "$srcdir"

# Install AUR packages
cat aur-pkgs.txt | sed 's/^#.*//g' | sed '/^$/d' | yay -S -

sudo rm pacman.conf-bkp
sudo rm makepkg.conf-bkp

# Retrieve configs + scripts / interfaces
cd "$HOME/src"
git clone --bare https://github.com/davidrv00/bare-configs.git

# TODO: Fix this
#git init --bare "$HOME/src/bare-configs.git"
#git subtree --prefix=pkg-config push "$HOME/src/bare-configs.git"

alias config='git --git-dir="$HOME/src/bare-configs.git" --work-tree="$HOME"'
config config --local status.showUntrackedFiles no
config restore --staged "$HOME"
config restore "$HOME"

touch "$HOME/.vim_noport.vim"
touch "$HOME/.vim_vundle_noport.vim"

# Retrieve source-based tools
cd "$HOME/src"
git clone https://github.com/DavidRV00/dwm-fork
cd dwm-fork
make
sudo make install

cd "$HOME/src"
git clone https://github.com/DavidRV00/dmenu-fork
cd dmenu-fork
make
sudo make install

cd "$HOME/src"
git clone https://github.com/DavidRV00/vim-jupyter-run
cd vim-jupyter-run
./install
export PATH="/opt/miniconda3/bin:$PATH"
pip install nbformat
pip install nbconvert

git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
vim +PluginInstall +qall

cd "$HOME"
wget http://www.drchip.org/astronaut/vim/vbafiles/netrw.vba.gz
vim netrw.vba.gz +"packadd vimball" +"so %" +qall
rm "$HOME/netrw.vba*"

cd "$HOME/src"
git clone https://github.com/brummer10/pajackconnect
cp pajackconnect/pajackconnect "$HOME/bin/"

cd "$HOME/src"
git clone https://github.com/DavidRV00/bookmarks
cd bookmarks
./install

# Set up email
echo
set +x
echo "Enter email address to set up (empty to stop): "
read -r email
while [ "$email" != "" ]; do
	mw -a "$email"

	echo
	echo "Enter email address to set up (empty to stop): "
	read -r email
done
set -x

# Set up audio
sudo usermod -a -G realtime,audio "$USER"

sudo sed -i '/^# End of file/d' /etc/security/limits.conf

sudo cat << EOF | sudo tee -a /etc/security/limits.conf
# audio group
@audio		-	rtprio		95
@audio		-	memlock		unlimited
EOF

# Pull in templates and special data and stuff
# TODO: Use some kind of spec file

# Set up runit autostarts
set +x
for svc in bluetoothd cronie ntpd wpa_supplicant syncthing; do
	set -x
	sudo ln -s /etc/runit/sv/"$svc" /run/runit/service/
	set +x
done

# Default applications
xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop

# KDE theme
kpackagetool5 --install LookAndFeel
lookandfeeltool -a org.kde.breezedark.desktop

# Xorg config
sudo cat << EOF | sudo tee -a /etc/X11/xorg.conf.d/20-intel-gpu.conf
Section "Device"
	Identifier	"Intel Graphics"
	Driver		"intel"
	Option		"TearFree"	"true"
EndSection
EOF

# Posix shell
sudo ln -sfT dash /usr/bin/sh

# TODO: set up cron jobs

# TODO: Setup audio output(s)
