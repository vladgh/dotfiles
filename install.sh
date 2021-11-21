#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# DEBUG
[ -z "${DEBUG:-}" ] || set -x

# VARs
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SECRETS_S3_PATH="${SECRETS_S3_PATH:-}" # Optional S3 location for the secret files (no trailing slash)
SECRETS_LOCAL_PATH="${SECRETS_LOCAL_PATH:-}" # Optional directory to save secret files (no trailing slash)
TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmp')

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
        ! -path '*/.DS_Store' \
        -o -name 'bin'
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

# Download and decrypt secrets
dotfiles_download_secrets(){
  if [[ -n "$SECRETS_S3_PATH" ]] && [[ -n "$SECRETS_LOCAL_PATH" ]] && is_cmd aws; then
    # Download the files to a temporary directory (to preserve AWS settings for the next step)
    mkdir -p "$TMPDIR"
    aws s3 sync "${SECRETS_S3_PATH}" "${TMPDIR}" --sse --delete --quiet --exact-timestamps || true ;
    e_ok "Secret files downloaded from ${SECRETS_S3_PATH}"

    # Back up originals
    if [[ -d "$SECRETS_LOCAL_PATH" ]]; then
      mv "$SECRETS_LOCAL_PATH" "${bakdir}/"
      e_ok "Backed up original ${SECRETS_LOCAL_PATH} directory to ${bakdir}"
    fi

    # Replace originals
    mv "$TMPDIR" "$SECRETS_LOCAL_PATH"
    e_ok "Secret files installed at ${SECRETS_LOCAL_PATH}"
  fi
}

# Iterate public and private dotfiles and creates links for each of them
dotfiles_install(){
  bakdir="${HOME}/backups/dotfiles.$(date "+%Y_%m_%d-%H_%M_%S").bak"
  [[ -d "$bakdir" ]] || mkdir -p "$bakdir"

  dotfiles_download_secrets

  (
  cd "$HOME" || exit
  for dotfile in $(dotfiles_list "$DOTFILES" "$SECRETS_LOCAL_PATH"); do
    dotfiles_link "$dotfile"
  done
  )
}

# Sets permissions for dotfiles
dotfiles_permissions(){
  if find "${HOME}/bin/" -type f -exec chmod +x {} \; 2>/dev/null; then
    e_ok 'Made files in "bin" directory executable'
  fi
  if find "$SECRETS_LOCAL_PATH" -type f -exec chmod 600 {} \; 2>/dev/null; then
    e_ok "Fixed permissions on secret files"
  fi
  if find "$SECRETS_LOCAL_PATH" -type d -exec chmod 700 {} \; 2>/dev/null; then
    e_ok "Fixed permissions on secret folders"
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
  if [[ ! -d "${HOME}/.vim/bundle/Vundle.vim" ]]; then
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
