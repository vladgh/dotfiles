#!/usr/bin/env bash

# Read dotfiles directory
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

# Default secrets directory
PRIVATE_DIR="${PRIVATE_DIR:-"${DOTFILES}/.private"}"

# Load functions
for file in ${DOTFILES}/.functions.d/*.sh; do
  # shellcheck disable=1090
  . "$file" || true
done

# Lists the dotfiles
dotfiles_list(){
  find "$DOTFILES" -maxdepth 1 -mindepth 1 -name '.*' \
    ! -path '*/.git' \
    ! -path '*/.gitignore' \
    ! -path '*/.gitmodules' \
    ! -path '*/.DS_Store' \
    -o -name 'bin'
}

# Lists the secret files
dotfiles_list_secrets(){
  if [ -d "${PRIVATE_DIR}" ]; then
    find "${PRIVATE_DIR}" -maxdepth 1 -mindepth 1 -name '.*' \
      ! -path '*/.git' \
      ! -path '*/.gitignore' \
      ! -path '*/.gitmodules' \
      ! -path '*/.DS_Store'
  fi
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
  for dotfile in $(dotfiles_list); do
    dotfiles_link "$dotfile"
  done
  for dotfile in $(dotfiles_list_secrets); do
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
    e_warn 'Vim is not installed! Skipped plugins installation'
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
