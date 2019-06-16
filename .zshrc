#!/usr/bin/env zsh

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="agnoster"
DEFAULT_USER='vlad' # Hide the "user@hostname" info prompt

# TMUX
export ZSH_TMUX_AUTOSTART=true

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
  tmux
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load oh-my-zsh
source "$ZSH/oh-my-zsh.sh"

# Load environment variables
# shellcheck disable=1090
if [[ -s "${HOME}/.env" ]]; then
  . "${HOME}/.env"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "${HOME}/bin" ]] ; then
  PATH="${HOME}/bin:${PATH}"
fi
if [[ -d "${HOME}/.bin" ]] ; then
  PATH="${HOME}/.bin:${PATH}"
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

# Load personal settings if they exist
[[ -s "${HOME}/.myrc" ]] && . "${HOME}/.myrc"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code'
fi

# MacOS
if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="$(brew --prefix)"

  # GNU Core utilities
  __gnubin_dir="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
  if [[ -d "$__gnubin_dir" ]]; then
    PATH="${__gnubin_dir}:${PATH}"
    MANPATH="${__gnubin_dir}:${MANPATH}"
  fi

  # GPG utilities
  __gpgbin_dir="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gpgbin"
  if [[ -d "$__gpgbin_dir" ]]; then
    PATH="${__gpgbin_dir}:${PATH}"
    MANPATH="${__gpgbin_dir}:${MANPATH}"
  fi

  # Other
  PATH="/usr/local/sbin:${PATH}"
  PATH="${HOMEBREW_PREFIX}/opt/curl/bin:${PATH}"
  PATH="${HOMEBREW_PREFIX}/opt/sqlite/bin:${PATH}"
  PATH="${HOMEBREW_PREFIX}/opt/gettext/bin:${PATH}"

  export PATH MANPATH
fi

# Ansible
export ANSIBLE_NOCOWS=1
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
