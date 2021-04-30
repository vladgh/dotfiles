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
alias ls='ls --color=auto'
alias ll='ls -lahpF' # Ubuntu & Mac compatible
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Set default editor
if command -v vim >/dev/null 2>&1; then
  export VISUAL=vim
  export EDITOR=$VISUAL
fi

# Set PATH to include other standard locations
if [[ -d /usr/local/bin ]]; then
  PATH="/usr/local/bin:${PATH}"
fi
if [[ -d /usr/local/sbin ]]; then
  PATH="/usr/local/sbin:${PATH}"
fi

# Set PATH to include user's private bin if it exists
if [[ -d "${HOME}/.local/bin" ]] ; then
  PATH="${HOME}/.local/bin:${PATH}"
fi
if [[ -d "${HOME}/.bin" ]] ; then
  PATH="${HOME}/.bin:${PATH}"
fi
if [[ -d "${HOME}/bin" ]] ; then
  PATH="${HOME}/bin:${PATH}"
fi

# Set PATH to include Ubuntu Snap packages
if command -v snap >/dev/null 2>&1; then
  export PATH="/snap/bin:${PATH}"
fi

# Load environment variables
# shellcheck disable=1090
if [[ -s "${HOME}/.env" ]]; then
  . "${HOME}/.env"
fi

# Load personal configuration files
# shellcheck disable=1090
if [[ -s "${HOME}/.localrc" ]]; then
  . "${HOME}/.localrc"
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

# END .BASHRC_MINIMAL ##########################################################

# MacOS
if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="$(brew --prefix)"

  # Add tab completion
  # shellcheck disable=1090,1091
  if [[ -f "${HOMEBREW_PREFIX}/etc/bash_completion" ]]; then
    source "${HOMEBREW_PREFIX}/etc/bash_completion";
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion;
  fi

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
  __python_bin_dir="${HOMEBREW_PREFIX}/opt/python/libexec/bin"
  if [[ -d "$__python_bin_dir" ]]; then
    PATH="${__python_bin_dir}:${PATH}"
  fi
  __python_site_pkg_bin_dir="$(python -m site --user-base)/bin"
  if [[ -d "$__python_site_pkg_bin_dir" ]]; then
    PATH="${__python_site_pkg_bin_dir}:${PATH}"
  fi

  # Other
  if [[ -d "${HOMEBREW_PREFIX}/opt/curl/bin" ]]; then
    PATH="${HOMEBREW_PREFIX}/opt/curl/bin:${PATH}"
  fi
  if [[ -d "${HOMEBREW_PREFIX}/opt/sqlite/bin" ]]; then
    PATH="${HOMEBREW_PREFIX}/opt/sqlite/bin:${PATH}"
  fi
  if [[ -d "${HOMEBREW_PREFIX}/opt/gettext/bin" ]]; then
    PATH="${HOMEBREW_PREFIX}/opt/gettext/bin:${PATH}"
  fi

  export PATH MANPATH
fi

# Export PS1 with the git info
if [[ -s /etc/bash_completion.d/git-prompt ]] || [ -s /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
  if [[ -s /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
    # shellcheck disable=SC1091
    . /usr/local/etc/bash_completion.d/git-prompt.sh
  elif [[ -s /etc/bash_completion.d/git-prompt ]]; then
    # shellcheck disable=SC1091
    . /etc/bash_completion.d/git-prompt
  fi
  export GIT_PS1_SHOWDIRTYSTATE=true
  export GIT_PS1_SHOWSTASHSTATE=true
  export GIT_PS1_SHOWUNTRACKEDFILES=true
  export GIT_PS1_SHOWCOLORHINTS=true
  export GIT_PS1_SHOWUPSTREAM="auto"
  # shellcheck disable=2154
  export PROMPT_COMMAND='__git_ps1 "\[$(tput bold)$(tput setaf 2)\]\u\[$(tput setaf 7)\]@\[$(tput setaf 4)\]\h:\[$(tput setaf 6)\]\w\[$(tput sgr0)\]" " \[$(tput setaf 1)\]\${?#0}\[$(tput sgr0)\]\$ "'
fi

# Ansible
if command -v ansible >/dev/null 2>&1; then
  export ANSIBLE_NOCOWS=1
  export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
fi

# Github
if command -v hub >/dev/null 2>&1; then
  eval "$(hub alias -s)"
fi

# Travis
# shellcheck disable=1090
if [[ -s "${HOME}/.travis/travis.sh" ]]; then
  . "${HOME}/.travis/travis.sh"
fi

# Puppet
if [[ -d /opt/puppetlabs/bin ]]; then
  export PATH="${PATH}:/opt/puppetlabs/bin"
fi

# ACME Shell script
if [[ -f "${HOME}/.acme.sh/acme.sh.env" ]]; then
  . "${HOME}/.acme.sh/acme.sh.env"
fi

# Serverless
# shellcheck disable=1091
# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
if [[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash ]]; then
  . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash
fi
# shellcheck disable=1091
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
if [[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash ]]; then
  . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash
fi
# shellcheck disable=1091
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
if [[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.bash ]]; then
  . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.bash
fi

# RVM
# Make sure this is the last PATH variable change.
if [[ -d "${HOME}/.rvm/bin" ]]; then
  export PATH="${PATH}:${HOME}/.rvm/bin" # Add RVM to PATH for scripting
fi
# shellcheck disable=1090
if [[ -s "${HOME}/.rvm/scripts/rvm" ]]; then
  . "${HOME}/.rvm/scripts/rvm"
fi
# shellcheck disable=1090
if [[ -r "${HOME}/.rvm/scripts/completion" ]]; then
  . "${HOME}/.rvm/scripts/completion"
fi
