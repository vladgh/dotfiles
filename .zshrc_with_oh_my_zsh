#!/usr/bin/env zsh

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(
  colorize
  dotenv
  docker
  docker-compose
  git
  github
  macos
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

# Plugin settings
export ZSH_DOTENV_PROMPT=false

# Themes
if [[ -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
  export ZSH_THEME='powerlevel10k/powerlevel10k'
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
else
  export ZSH_THEME='robbyrussell'
fi

# Hide the "user@hostname" info prompt
export DEFAULT_USER="$(whoami)"

# Automatically upgrade oh-my-zsh without prompting
DISABLE_UPDATE_PROMPT=true

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
