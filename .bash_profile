#!/usr/bin/env bash

# shellcheck disable=1090
if [[ -s "${HOME}/.profile" ]]; then
  . "${HOME}/.profile"
fi
if [[ -s "${HOME}/.bashrc" ]]; then
  . "${HOME}/.bashrc"
fi
if [[ -s "${HOME}/.vgrc" ]]; then
  . "${HOME}/.vgrc"
fi
