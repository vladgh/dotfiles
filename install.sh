#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# DEBUG
[ -z "${DEBUG:-}" ] || set -x

# VARs
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_LIST=(
  .zprofile
  .zshrc
  .aliases
  .functions
  .tmux.conf
  .gitconfig
  .gitignore.global
)

# Check if command exists
is_cmd() { command -v "$@" >/dev/null 2>&1 ;}

# Logging
e_ok()    { printf "  ✔  %s\\n" "$@" ;}
e_warn()  { printf "    %s\\n" "$@" ;}
e_error() { printf "  ✖  %s\\n" "$@" ;}
e_abort() { e_error "$1"; return "${2:-1}" ;}

# Creates links for the specified dotfile
dotfiles_link(){
  src_file="${DOTFILES}/${dotfile}"
  dst_file="${HOME}/${dotfile}"

  if [[ -s "$dst_file" ]]; then # Old file exists
    if [[ -L "$dst_file" ]]; then # Old file is a symlink
      if [[ "$(readlink "$dst_file")" != "$src_file" ]]; then # Symlink is not the same
        rm "$dst_file"
        ln -sfn "$src_file" "$dst_file"
        e_ok "Replaced link for ${dst_file} to ${src_file}"
      fi
    else # Backup old file if it's not a symlink
      mv "$dst_file" "${bakdir}/"
      e_ok "${dst_file} saved at ${bakdir}"
      ln -s "$src_file" "$dst_file"
      e_ok "Linked ${dst_file} to ${src_file}"
    fi
  else # Create symlink if the oldfile doesn't exist
    ln -sfn "$src_file" "$dst_file" && e_ok "Linked ${dst_file} to ${src_file}"
  fi
}

# Iterate dotfiles and creates links for each of them
dotfiles_install(){
  bakdir="${HOME}/backups/dotfiles.$(date "+%Y_%m_%d-%H_%M_%S").bak"
  [[ -d "$bakdir" ]] || mkdir -p "$bakdir"

  (
  cd "$HOME" || exit
  for dotfile in "${DOTFILES_LIST[@]}"; do
    dotfiles_link "$dotfile"
  done
  )
}

# Cleans broken symlinks in the $HOME directory
dotfiles_delete_broken_symlinks(){
  if [[ -n "$(find -L "$HOME" -maxdepth 1 -mindepth 1 -type l)" ]]; then
    find -L "$HOME" -maxdepth 1 -mindepth 1 -type l -exec rm {} +
    e_ok 'Deleted broken symlinks'
  fi
}

# Script's logic
main(){
  dotfiles_install
  dotfiles_delete_broken_symlinks
}

main "$@"
