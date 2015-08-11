#!/usr/bin/env bash

# Load environment variables
[ -s "${HOME}/.env" ] && . "${HOME}/.env"

# Load .bashrc
[ -s "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# Load all functions from .functions.d
for function in ${HOME}/.functions.d/*.sh; do . "$function"; done

# Load .alias
[ -s "${HOME}/.aliases" ] && . "${HOME}/.aliases"

# Start directly in the PROJECTS directory if it exists
[ -d "$PROJECTS" ] && cd "$PROJECTS"

