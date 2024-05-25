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
  systemd
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
setopt EXTENDED_HISTORY         # record timestamp of command in HISTFILE
setopt SHARE_HISTORY            # share history across multiple zsh sessions
setopt APPEND_HISTORY           # append to history
setopt INC_APPEND_HISTORY       # adds commands as they are typed, not at shell exit
setopt HIST_EXPIRE_DUPS_FIRST   # expire duplicates first
setopt HIST_IGNORE_DUPS         # do not store duplications
setopt HIST_IGNORE_SPACE        # ignore commands that start with space
setopt HIST_FIND_NO_DUPS        # ignore duplicates when searching
setopt HIST_REDUCE_BLANKS       # removes blank lines from history
setopt HIST_VERIFY              # show command with history expansion to user before running it

# Load oh-my-zsh
# shellcheck disable=1090
if [[ -s "${HOME}/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  . "${HOME}/.oh-my-zsh/oh-my-zsh.sh"
fi

# Homebrew
if command -v brew >/dev/null 2>&1; then
  # Python
  if [[ -d "$(brew --prefix python)/libexec/bin" ]]; then
    export PATH="$(brew --prefix python)/libexec/bin:${PATH}"
  fi
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

# Load starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Set default editor
if command -v code >/dev/null 2>&1; then
  export VISUAL='code --wait'
  export EDITOR=$VISUAL
elif command -v vim >/dev/null 2>&1; then
  export VISUAL='vim'
  export EDITOR=$VISUAL
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
