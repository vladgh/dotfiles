#!/usr/bin/env bash

# Load environment variables
[[ -s "$HOME/.env" ]] && . "$HOME/.env"

# Load .bashrc
[[ -s "$HOME/.bashrc" ]] && . "$HOME/.bashrc"

# Load all functions from .functions.d
function_files="$(ls "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.functions.d" \
  2>/dev/null && pwd -P )"/*.sh 2>/dev/null)"
for file in $function_files; do
  [[ -s "$file" ]] && . "$file"
done

# Go directly to the projects directory
[[ -d "$PROJECTS" ]] && cd "$PROJECTS"
