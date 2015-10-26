#!/usr/bin/env bash
# Update system

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

update_xcode() {
  is_osx || return
  xcode-select --install 2>/dev/null || xcode-select --version
}

update_ubuntu() {
  is_ubuntu || return
  apt_update && apt_upgrade
}

update_brew() {
  is_osx || return
  brew update
  brew upgrade --all
  brew doctor
  brew cleanup
}

update_vim() {
  (
  cd "${HOME}/.vim/bundle" || exit
  find .  -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;
  )
}

update_ruby() {
  is_cmd rvm || return
  rvm get master
  gem update --system
  gem update
}

update_docker() {
  if is_cmd boot2docker; then
    boot2docker stop && boot2docker upgrade
  fi
}

update_pip() {
  if is_osx; then
    pip install --upgrade pip setuptools awscli
  else
    sudo -H pip install --upgrade pip setuptools awscli
  fi
}

updt() {
  local command=$1
  local available='
    xcode
    ubuntu
    brew
    pip
    ruby
    docker
    vim
  '

  if [[ "${available}" =~ $command ]]; then
    "update_${command}"
  else
    for cmd in $available; do "update_${cmd}"; done
  fi
}
