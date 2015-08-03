#!/usr/bin/env bash
#
# Ruby Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/ruby.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# NAME: ruby_install_rvm
# DESCRIPTION: Installs and configures RVM with the latest Ruby.
ruby_install_rvm(){
  load_rvm && return
  apt_update && apt_install curl gpgv build-essential
  gpg --keyserver hkp://keys.gnupg.net \
    --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | bash -s stable
}

# NAME: ruby_load_rvm
# DESCRIPTION: Loads RVM into a shell session *as a function*
ruby_load_rvm(){
  local rvm_user="$HOME/.rvm/scripts/rvm"
  local rvm_root="/usr/local/rvm/scripts/rvm"
  if [[ $(type rvm 2>/dev/null | head -1) == 'rvm is a function' ]]; then
    echo 'RVM is already loaded'
    return 0
  elif [[ -s $rvm_user ]] ; then
    # First try to load from a user install
    echo 'Loading user RVM'
    source "$rvm_user"
  elif [[ -s $rvm_root ]] ; then
    # Then try to load from a root install
    echo 'Loading global RVM'
    source $rvm_root
  else
    echo 'ERROR: An RVM installation was not found.' && return 1
  fi
}

# NAME: ruby_install_gem
# DESCRIPTION: Installs a gem without documentation
# USAGE: ruby_install_gem {Gem}
# PARAMETERS:
#   1) One or more gem names
ruby_install_gem(){
  gem install --no-rdoc --no-ri "$@"
}

# NAME: ruby_use
# DESCRIPTION: Use a specific ruby version (install it if missing)
# USAGE: ruby_use {Version}
# PARAMETERS:
#   1) Version number
# Use a specific ruby version (install it if missing)
ruby_use(){
  local version=$1
  rvm use "$version" || ( rvm install "$version" && rvm use "$version" )
}
