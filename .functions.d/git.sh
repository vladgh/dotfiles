#!/usr/bin/env bash
# Git Functions

# Export PS1 with the git info
if [ -s /etc/bash_completion.d/git-prompt ] || [ -s /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
  if [ -s /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
    # shellcheck disable=SC1091
    . /usr/local/etc/bash_completion.d/git-prompt.sh
  elif [ -s /etc/bash_completion.d/git-prompt ]; then
    # shellcheck disable=SC1091
    . /etc/bash_completion.d/git-prompt
  fi
  export GIT_PS1_SHOWDIRTYSTATE=true
  export GIT_PS1_SHOWSTASHSTATE=true
  export GIT_PS1_SHOWUNTRACKEDFILES=true
  export GIT_PS1_SHOWCOLORHINTS=true
  export GIT_PS1_SHOWUPSTREAM="auto"
  export PROMPT_COMMAND='__git_ps1 "\[${fgblu}\]\u\[${fgpur}\]@\h\[${reset}\]:\W" "\\\$ "'
fi

