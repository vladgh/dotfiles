#!/usr/bin/env bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=5000000
HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help";

# Prefer US English and use UTF-8
# enable en_US locale w/ utf-8 encodings if not already configured
: "${LANG:="en_US.UTF-8"}"
: "${LANGUAGE:="en"}"
: "${LC_CTYPE:="en_US.UTF-8"}"
: "${LC_ALL:="en_US.UTF-8"}"
export LANG LANGUAGE LC_CTYPE LC_ALL

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X";

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Make less more friendly for non-text input files, see lesspipe(1)
if [[ -x /usr/bin/lesspipe ]]; then
  eval "$(SHELL=/bin/sh lesspipe)"
fi

# Highlight section titles in manual pages
export LESS_TERMCAP_md="${yellow:-}";

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm) if [[ "$COLORTERM" == "gnome-terminal" ]]; then color_prompt=yes; fi;;
  *-256color) color_prompt=yes;;
esac

# Check for color support
if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
  color_prompt=yes
else
  color_prompt=no
fi

if [[ "$color_prompt" == yes ]]; then
  PS1="\\[$(tput bold)$(tput setaf 2)\\]\\u\\[$(tput setaf 7)\\]@\\[$(tput setaf 4)\\]\\h:\\[$(tput setaf 6)\\]\\w\\[$(tput sgr0)\\] \\[$(tput setaf 1)\\]\${?#0}\\[$(tput sgr0)\\]\$ "
else
  PS1='\u@\h:\w\$ '
fi
unset color_prompt

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Enable color support of ls and also add handy aliases
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
if [[ -x /usr/bin/dircolors ]]; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

# Load extra configurarions
# shellcheck disable=1090
if [[ -s "${HOME}/.extrarc" ]]; then
  . "${HOME}/.extrarc"
fi
