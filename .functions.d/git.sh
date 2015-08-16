#!/usr/bin/env bash
# Git Functions

# Find if directory is a git repository
git_is_repo() {
  git rev-parse 2>/dev/null
}

# Prints '*' if working directory is not clean
git_dirty() {
  if [[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]];then
    printf "*"
  fi
}

# Prints current git branch
git_branch() {
  git symbolic-ref --short HEAD | tr -d '\n'
}

# Returns git prompt info
git_prompt(){
  if git_is_repo; then
    printf "[" && git_branch && git_dirty && printf "]" | tr -d '\n'
  fi
}

# Export PS1 with the git info
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  PS1="\[$(tput bold)$(tput setaf 2)\]\u\[$(tput setaf 7)\]@\[$(tput setaf 4)\]\h:\[$(tput setaf 6)\]\W\[$(tput setaf 4)\]\$(git_prompt)\[$(tput setaf 6)\]$ \[$(tput sgr0)\]"
fi

