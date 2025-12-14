#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

### EXPORT ###
export EDITOR=nano
export VISUAL=nano
export HISTCONTROL=ignoreboth:erasedups
export PAGER=most

alias update="sudo apt update && sudo apt upgrade"
alias probe="sudo -E hw-probe -all -upload"
alias nenvironment="sudo $EDITOR /etc/environment"
alias sr="reboot"
