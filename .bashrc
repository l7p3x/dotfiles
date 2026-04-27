#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --width=80 --color=auto'
alias grep='grep --color=auto'
alias update='sudo pacman -Syu'
alias ..='cd ..'
alias ~='cd ~'
alias c='clear'

# Prompt
PS1='\[\e[97m\]ふあん \[\e[37m\]❰ \w ❱ \[\e[97m\]➜ \[\e[37m\] '

export PATH="$HOME/Scripts:$PATH"

# --- Configurações Iniciais que você já tem ---
source ~/.local/share/blesh/ble.sh --noattach
[[ ! ${BLE_VERSION-} ]] || ble-attach
