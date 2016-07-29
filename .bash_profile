#!/usr/bin/env bash

# Load environment variables
# shellcheck disable=1090
[ -s "${HOME}/.env" ] && . "${HOME}/.env"

# Load .bashrc
# shellcheck disable=1090
[ -s "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# Load functions
for file in ${HOME}/.functions.d/*.sh; do
  # shellcheck disable=1090
  . "$file" || true
done

# Load .alias
# shellcheck disable=1090
[ -s "${HOME}/.aliases" ] && . "${HOME}/.aliases"
