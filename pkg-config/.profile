export PATH=$PATH:$HOME/bin:$HOME/.local/bin

export EDITOR="nvim"
export TERMINAL="terminal"
export BROWSER="browser"
export SHELL="zsh"

alias sudo='sudo ' # Let sudo use aliases
alias vim="nvim"
alias ls="exa"
alias top="htop"
alias pacman="pacman --color always"
alias yay="yay --color always"
alias config='git --git-dir=$HOME/src/bare-configs.git --work-tree=$HOME'
alias tree='tree -C'

export TERMINFO=/usr/share/terminfo

export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
export QT_STYLE_OVERRIDE=adwaita-dark

if [[ "$(tty)" = "/dev/tty1" ]]; then
	startx
fi
