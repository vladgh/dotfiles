#!/usr/bin/env zsh

# Clean prompt
PS1='%n@%m %~$ '

# Case insensitive completion
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ZSH options
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt NO_CASE_GLOB

# Plugins
if [[ -s "${HOME}/zsh-autosuggestions.zsh" ]]; then
  source "${HOME}/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -s "${HOME}/zsh-syntax-highlighting.zsh" ]]; then
  source "${HOME}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Load extra configurarions
# shellcheck disable=1090
if [[ -s "${HOME}/.extrarc" ]]; then
  . "${HOME}/.extrarc"
fi
