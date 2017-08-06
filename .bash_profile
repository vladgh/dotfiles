#!/usr/bin/env bash
# shellcheck disable=1090

# Load .profile
[[ -s "${HOME}/.profile" ]] && . "${HOME}/.profile"

# Load .bashrc
[[ -s "${HOME}/.bashrc" ]] && . "${HOME}/.bashrc"
