#!/usr/bin/env bash
#
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Highlight section titles in manual pages
export LESS_TERMCAP_md="${yellow:-}";

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm) [ "$COLORTERM" == "gnome-terminal" ] && color_prompt=yes;; # Ubuntu
  *-256color) color_prompt=yes;;
esac

# check for color support
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  color_prompt=yes
else
  color_prompt=no
fi

if [ "$color_prompt" = yes ]; then
  PS1="\[$(tput bold)$(tput setaf 2)\]\u\[$(tput setaf 7)\]@\[$(tput setaf 4)\]\h:\[$(tput setaf 6)\]\w $ \[$(tput sgr0)\]"
else
  PS1='\u@\h:\w\$ '
fi
unset color_prompt

# enable color support of ls and also add handy aliases
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
if [ -x /usr/bin/dircolors ]; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Editor
export VISUAL=vim
export EDITOR=$VISUAL

# Load environment variables
# shellcheck disable=1090
[ -s "${HOME}/.env" ] && . "${HOME}/.env"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.bin" ] ; then
  PATH="$HOME/.bin:$PATH"
fi

# Load functions
for file in ${HOME}/.functions.d/*.sh; do
  # shellcheck disable=1090
  . "$file" || true
done

# Load .alias
# shellcheck disable=1090
[ -s "${HOME}/.aliases" ] && . "${HOME}/.aliases"

# MacOS
if which brew > /dev/null; then
  # Add tab completion for many Bash commands
  # shellcheck disable=1090,1091
  if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    source "$(brew --prefix)/etc/bash_completion";
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
  fi

  __gnubin_dir="$(brew --prefix coreutils)/libexec/gnubin"
  __gpgbin_dir="$(brew --prefix coreutils)/libexec/gpgbin"

  # GNU Core utilities
  if [ -d "$__gnubin_dir" ]; then
    PATH="${__gnubin_dir}:${PATH}"
    MANPATH="${__gnubin_dir}:${MANPATH}"
    export PATH MANPATH
  fi

  # GPG utilities
  if [ -d "$__gpgbin_dir" ]; then
    PATH="${__gpgbin_dir}:${PATH}"
    MANPATH="${__gpgbin_dir}:${MANPATH}"
    export PATH MANPATH
  fi
fi

# Github
command -v hub > /dev/null 2>&1 && eval "$(hub alias -s)"

# Travis
# shellcheck disable=1090
[ -s "${HOME}/.travis/travis.sh" ] && . "${HOME}/.travis/travis.sh"

# NodeJS Version Manager
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=1090
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
# shellcheck disable=1090
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# RVM
export PATH="${PATH}:${HOME}/.rvm/bin" # Add RVM to PATH for scripting
# shellcheck disable=1090
[ -s "${HOME}/.rvm/scripts/rvm" ] && . "${HOME}/.rvm/scripts/rvm"
# shellcheck disable=1090
[ -r "${HOME}/.rvm/scripts/completion" ] && . "${HOME}/.rvm/scripts/completion"
