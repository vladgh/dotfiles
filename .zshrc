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
  safe-paste
  zsh-autosuggestions
  zsh-syntax-highlighting
)

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

# Load personal configuration files
if [[ -s "${HOME}/.vgrc" ]]; then
  . "${HOME}/.vgrc"
fi

# Load TMUX
# shellcheck disable=1090
if command -v tmux >/dev/null 2>&1 && [[ -s "${HOME}/.tmux.conf" ]] ; then
  tmux source-file "${HOME}/.tmux.conf"
fi

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

  # Python
  alias python=/usr/local/bin/python3
  alias pip=/usr/local/bin/pip3

  # Other
  PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
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

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh
