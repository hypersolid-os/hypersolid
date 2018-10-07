#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# chroot info
CHR_INFO=${debian_chroot:+($debian_chroot)}

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
if [[ $EUID -eq 0 ]]; then
  # root user
  PS1='\n${CHR_INFO}\e[31m\e[1m\u@\h\e[0m \e[94m\w\n \e[31m\e[1m#\e[0m\e[0m\e[39m\e[49m '

else
  # non root
  PS1='\n${CHR_INFO}\e[92m\e[1m\u@\h\e[0m \e[94m\w\n \e[92m\e[1m$\e[0m\e[0m\e[39m\e[49m '

fi

# shortcuts
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias la='ls $LS_OPTIONS -all -h'
