#!/usr/bin/env bash

# Load environment variables
[ -s "${HOME}/.env" ] && . "${HOME}/.env"

# Load .bashrc
[ -s "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# Load all functions from .functions.d
for func in ${HOME}/.functions.d/*.sh; do . "$func"; done

# Load .alias
[ -s "${HOME}/.alias" ] && . "${HOME}/.alias"

# Start directly in the PROJECTS directory if it exists
[ -d "$PROJECTS" ] && cd "$PROJECTS"

