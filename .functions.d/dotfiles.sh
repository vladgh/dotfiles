## DOTFILES

# Create links for dotfiles
link_dotfiles(){
  [[ -n $@ ]] || return 1

  e_header 'Symlinks'
  bakdir="~/backups/dotfiles.$(date "+%Y_%m_%d-%H_%M_%S").bak"
  mkdir -p $bakdir && e_ok "Backups will be saved in '$bakdir'\n"

  (
  cd $HOME
  for dotfile in $@; do
    dot=$(basename $dotfile)
    old=~/${dot}

    if [[ -s $old ]]; then # IF old file exists
      if [[ -L $old ]]; then # Replace if old file is a symlink
        rm $old && \
          ln -sfn $dotfile $old && \
          e_ok "Replaced link for $old to $dotfile"
      else # Backup old file if it's not a symlink
        mv $old $bakdir/ && \
          e_ok "$old saved at $bakdir"
        ln -s $dotfile $old && \
          e_ok "Linked $old to $dotfile"
      fi
    else # Create symlink if the oldfile doesn't exist
      ln -sfn $dotfile $old && \
        e_ok "Linked $old to $dotfile"
    fi
  done
  )
}

# Set-up permissions for dotfiles
dotfiles_permissions(){
  e_header 'Permissions'
  find ~/bin/ -type f -exec chmod 755 {} \; && \
    e_ok '~/bin/* is set to 755'
  find ~/.ssh/ -type f -name 'id_*' -exec chmod 600 {} \; && \
    e_ok '~/.ssh/id* is set to 600'
}

# Clean up broken symlinks
dotfiles_delete_broken_symlinks(){
  e_header 'Clean-up'
  find -L ~/ -maxdepth 1 -type l -exec rm {} +
  e_ok 'Broken symlinks deleted'
}
