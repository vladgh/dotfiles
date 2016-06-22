#!/usr/bin/env bash

###############################################################################
# This script installs the dotfiles
# Ex: `PRIVATE_DIR=/path/to/secrets dotfiles/install.sh`
# @author Vlad Ghinea
###############################################################################

# Read dotfiles directory
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Default secrets directory
PRIVATE_DIR="${PRIVATE_DIR:-"$(pwd)/.private"}"

# Load system functions
# shellcheck source=/dev/null
. "${DOTFILES}/.functions.d/load" || true

# NAME: dotfiles_list
# DESCRIPTION: Lists the dotfiles
dotfiles_list(){
  find "$DOTFILES" -maxdepth 1 -mindepth 1 -name '.*' \
    ! -path '*/.git' \
    ! -path '*/.gitignore' \
    ! -path '*/.gitmodules' \
    ! -path '*/.DS_Store' \
    -o -name 'bin'
}

# NAME: dotfiles_list_secrets
# DESCRIPTION: Lists the secret files
dotfiles_list_secrets(){
  if [ -d "${PRIVATE_DIR}" ]; then
    find "${PRIVATE_DIR}" -maxdepth 1 -mindepth 1 -name '.*' \
      ! -path '*/.git' \
      ! -path '*/.gitignore' \
      ! -path '*/.gitmodules' \
      ! -path '*/.DS_Store'
  fi
}

dotfiles_link(){
  local name; name=$(basename "$dotfile")
  local prev="${HOME}/${name}"

  if [ -s "$prev" ]; then # Old file exists
    if [ -L "$prev" ]; then # Old file is a symlink
      if [ "$(readlink "$prev")" != "$dotfile" ]; then # Symlink is not the same
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

# NAME: dotfiles_link
# DESCRIPTION: Creates links for dotfiles
dotfiles_install(){
  local bakdir
  bakdir="${HOME}/backups/dotfiles.$(date "+%Y_%m_%d-%H_%M_%S").bak"
  [ -d "$bakdir" ] || mkdir -p "$bakdir"

  (
  cd "$HOME" || exit
  for dotfile in $(dotfiles_list); do
    dotfiles_link "$dotfile"
  done
  for dotfile in $(dotfiles_list_secrets); do
    dotfiles_link "$dotfile"
  done
  )
}

# NAME: dotfiles_permissions
# DESCRIPTION: Sets permissions for dotfiles
dotfiles_permissions(){
  if find "${HOME}/bin/" -type f -exec chmod +x {} \; 2>/dev/null; then
    e_ok 'Made files in "bin" directory executable'
  fi
  if find "${HOME}/.ssh/" -type f -name 'id_*' -exec chmod 600 {} \; 2>/dev/null; then
    e_ok 'Hid ssh keys'
  fi
}

# NAME: dotfiles_delete_broken_symlinks
# DESCRIPTION: Cleans broken symlinks in the $HOME directory
dotfiles_delete_broken_symlinks(){
  if find -L "${HOME}/" -maxdepth 1 -mindepth 1 -type l -exec rm {} +; then
    e_ok 'Deleted broken symlinks'
  fi
}

dotfiles_install
dotfiles_permissions
dotfiles_delete_broken_symlinks
