#!/usr/bin/env zsh

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(
  colorize
  dotenv
  git
  github
  osx
  python
  ruby
  rvm
)
if command -v tmux >/dev/null 2>&1; then
  plugins+=( tmux )
fi
if [[ -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
  plugins+=( zsh-autosuggestions )
fi
if [[ -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
  plugins+=( zsh-syntax-highlighting )
fi

# Set name of the theme to load
export ZSH_THEME="agnoster"
export DEFAULT_USER="$(whoami)" # Hide the "user@hostname" info prompt

# Plugin settings
export ZSH_DOTENV_PROMPT=false

# Load oh-my-zsh
# shellcheck disable=1090
if [[ -s "$ZSH/oh-my-zsh.sh" ]]; then
  . "$ZSH/oh-my-zsh.sh"
fi

# case-insensitive globbing
setopt NO_CASE_GLOB

# history
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY
# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST
# do not store duplications
setopt HIST_IGNORE_DUPS
#ignore duplicates when searching
setopt HIST_FIND_NO_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS

# Fix slow paste from clipboard in ZSH (https://github.com/zsh-users/zsh-syntax-highlighting/issues/295)
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# Load extra configurarions
# shellcheck disable=1090
if [[ -s "${HOME}/.extrarc" ]]; then
  . "${HOME}/.extrarc"
fi
