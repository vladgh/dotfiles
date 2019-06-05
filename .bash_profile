#!/usr/bin/env bash

# shellcheck disable=1090
[[ -s "${HOME}/.profile" ]] && . "${HOME}/.profile"
[[ -s "${HOME}/.bashrc" ]] && . "${HOME}/.bashrc"
[[ -s "${HOME}/.bashrc_personal" ]] && . "${HOME}/.bashrc_personal"
