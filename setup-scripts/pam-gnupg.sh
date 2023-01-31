#!/bin/sh

for svc in login system-login system-local-login system-remote-login; do
	sudo cat << EOF | sudo tee -a "/etc/pam.d/$svc"
auth     optional  pam_gnupg.so store-only
session  optional  pam_gnupg.so
EOF
done

gnupgdir="$HOME/.gnupg"
mkdir -p "$gnupgdir"
echo "allow-preset-passphrase" | tee -a "$gnupgdir/gpg-agent.conf"

# Auto-populated upon installing pam-gnupg?
#keygripline="$(gpg -K --with-keygrip | fzf --layout=reverse)"
#keygrip="$(echo "$keygripline" | sed 's/.*Keygrip = //g')"
