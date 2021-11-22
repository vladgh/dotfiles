#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# DEBUG
[ -z "${DEBUG:-}" ] || set -x

# VARs
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Check if command exists
is_cmd() { command -v "$@" >/dev/null 2>&1 ;}

# Logging
e_ok()    { printf "  ✔  %s\\n" "$@" ;}
e_warn()  { printf "    %s\\n" "$@" ;}
e_error() { printf "  ✖  %s\\n" "$@" ;}
e_abort() { e_error "$1"; return "${2:-1}" ;}

# Lists the dotfiles
dotfiles_list(){
  for dir in "${@:?}"; do
    if [[ -d "$dir" ]]; then
      find "$dir" -maxdepth 1 -mindepth 1 -name '.*' \
        ! -path '*/.git' \
        ! -path '*/.gitignore' \
        ! -path '*/.gitmodules' \
        ! -path '*/.DS_Store'
    fi
  done
}

# Creates links for the specified dotfile
dotfiles_link(){
  name=$(basename "$dotfile")
  prev="${HOME}/${name}"

  if [[ -s "$prev" ]]; then # Old file exists
    if [[ -L "$prev" ]]; then # Old file is a symlink
      if [[ "$(readlink "$prev")" != "$dotfile" ]]; then # Symlink is not the same
        rm "$prev"
        ln -sfn "$dotfile" "$prev"
        e_ok "Replaced link for ${prev} to ${dotfile}"
      fi
    else # Backup old file if it's not a symlink
      mv "$prev" "${bakdir}/"
      e_ok "${prev} saved at ${bakdir}"
      ln -s "$dotfile" "$prev"
      e_ok "Linked ${prev} to ${dotfile}"
    fi
  else # Create symlink if the oldfile doesn't exist
    ln -sfn "$dotfile" "$prev" && e_ok "Linked ${prev} to ${dotfile}"
  fi
}

# Iterate dotfiles and creates links for each of them
dotfiles_install(){
  bakdir="${HOME}/backups/dotfiles.$(date "+%Y_%m_%d-%H_%M_%S").bak"
  [[ -d "$bakdir" ]] || mkdir -p "$bakdir"

  (
  cd "$HOME" || exit
  for dotfile in $(dotfiles_list "$DOTFILES"); do
    dotfiles_link "$dotfile"
  done
  )
}

# Cleans broken symlinks in the $HOME directory
dotfiles_delete_broken_symlinks(){
  if [[ -n "$(find "$HOME" -maxdepth 1 -mindepth 1 -xtype l)" ]]; then
    find "$HOME" -maxdepth 1 -mindepth 1 -xtype l -exec rm {} +
    e_ok 'Deleted broken symlinks'
  fi
}

# Script's logic
main(){
  dotfiles_install
  dotfiles_delete_broken_symlinks
}

main "$@"
