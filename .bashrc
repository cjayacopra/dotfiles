#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# ALIASES
alias lampp="sudo /opt/lampp/lampp"


# ENVIRONMENT VARIABLES
export WEBKIT_DISABLE_COMPOSITING_MODE=1

export XDG_DATA_HOME="/home/shiraneko/.local/share"

