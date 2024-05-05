#!/usr/bin/env zsh

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(
  colorize
  ansible
  dotenv
  docker
  docker-compose
  git
  github
  macos
  python
)
if command -v tmux >/dev/null 2>&1; then
  plugins+=( tmux )
fi
if [[ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
  plugins+=( zsh-autosuggestions )
fi
if [[ -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
  plugins+=( zsh-syntax-highlighting )
fi

# Themes
if [[ -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]]; then
  export ZSH_THEME='powerlevel10k/powerlevel10k'
  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
else
  export ZSH_THEME='robbyrussell'
fi

# Hide the "user@hostname" info prompt
export DEFAULT_USER="$(whoami)"
# Automatically upgrade oh-my-zsh without prompting
DISABLE_UPDATE_PROMPT=true
# Plugin settings
export ZSH_DOTENV_PROMPT=false

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

# Load oh-my-zsh
# shellcheck disable=1090
if [[ -s "${HOME}/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  . "${HOME}/.oh-my-zsh/oh-my-zsh.sh"
fi

# Set PATH to include  other standard locations
if [[ -d /usr/local/bin ]]; then
  PATH="/usr/local/bin:${PATH}"
fi
if [[ -d /usr/local/sbin ]]; then
  PATH="/usr/local/sbin:${PATH}"
fi
if [[ -d "${HOME}/.local/bin" ]] ; then
  PATH="${HOME}/.local/bin:${PATH}"
fi
if [[ -d "${HOME}/.bin" ]] ; then
  PATH="${HOME}/.bin:${PATH}"
fi
if [[ -d "${HOME}/bin" ]] ; then
  PATH="${HOME}/bin:${PATH}"
fi

# Load environment variables
# shellcheck disable=1090
if [[ -s "${HOME}/.env" ]]; then
  . "${HOME}/.env"
fi

# Load .functions
# shellcheck disable=1090
if [[ -s "${HOME}/.functions" ]]; then
  . "${HOME}/.functions"
fi

# Load .aliases
# shellcheck disable=1090
if [[ -s "${HOME}/.aliases" ]]; then
  . "${HOME}/.aliases"
fi
