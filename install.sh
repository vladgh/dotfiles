#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Dotfiles directory
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Secrets directory
SECRETS_DIR="${SECRETS_DIR:-}"

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
    if [ -d "$dir" ]; then
      find "$dir" -maxdepth 1 -mindepth 1 -name '.*' \
        ! -path '*/.git' \
        ! -path '*/.gitignore' \
        ! -path '*/.gitmodules' \
        ! -path '*/.DS_Store' \
        -o -name 'bin'
    else
      e_warn "'${dir}' does not exist!" >&2
    fi
  done
}

# Creates links for the specified dotfile
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

# Iterate public and private dotfiles and creates links for each of them
dotfiles_install(){
  local bakdir
  bakdir="${HOME}/backups/dotfiles.$(date "+%Y_%m_%d-%H_%M_%S").bak"
  [ -d "$bakdir" ] || mkdir -p "$bakdir"

  (
  cd "$HOME" || exit
  for dotfile in $(dotfiles_list "$DOTFILES" "$SECRETS_DIR"); do
    dotfiles_link "$dotfile"
  done
  )
}

# Sets permissions for dotfiles
dotfiles_permissions(){
  if find "${HOME}/bin/" -type f -exec chmod +x {} \; 2>/dev/null; then
    e_ok 'Made files in "bin" directory executable'
  fi
  if find "${HOME}/.ssh/" -type f -name 'id_*' -exec chmod 600 {} \; 2>/dev/null; then
    e_ok 'Hid ssh keys'
  fi
}

# Cleans broken symlinks in the $HOME directory
dotfiles_delete_broken_symlinks(){
  if find -L "${HOME}/" -maxdepth 1 -mindepth 1 -type l -exec rm {} +; then
    e_ok 'Deleted broken symlinks'
  fi
}

# Install VIM plugins
dotfiles_install_vim_plugins(){
  if [ ! -d "${HOME}/.vim/bundle/Vundle.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}/.vim/bundle/Vundle.vim"
    e_ok 'Cloned Vundle'
  fi
  if is_cmd vim; then
    vim +PluginInstall +qall
    e_ok 'Installed/Updated VIM plugins'
  else
    e_warn 'Vim is not installed! Skipped plugins installation' >&2
  fi
}

# Script's logic
main(){
  dotfiles_install
  dotfiles_permissions
  dotfiles_delete_broken_symlinks
  dotfiles_install_vim_plugins
}

main "$@"
