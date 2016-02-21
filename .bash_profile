#!/usr/bin/env bash

# Load environment variables
[ -s "${HOME}/.env" ] && . "${HOME}/.env"

# Load .bashrc
[ -s "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# Load functions
[ -s "${HOME}/.functions.d/load" ] && . "${HOME}/.functions.d/load"

# Load .alias
[ -s "${HOME}/.aliases" ] && . "${HOME}/.aliases"
