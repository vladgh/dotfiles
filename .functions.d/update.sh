#!/usr/bin/env bash
# Update system

update_osx() {
  is_osx || return
  #sudo softwareupdate -i -a
}

update_xcode() {
  is_osx || return
  xcode-select --install 2>/dev/null || xcode-select --version
}

update_ubuntu() {
  is_ubuntu || return
  sudo apt-get -qy update
  sudo apt-get -qy dist-upgrade
  sudo apt-get -qy autoremove
  sudo apt-get -qy autoclean
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
  rvm get head
  gem update --system
  gem update
}

update_pip() {
  is_cmd pip || return
  if is_osx; then
    pip install --upgrade pip setuptools awscli awsebcli aws-shell ssh2
  else
    sudo -H pip install --upgrade pip setuptools awsebcli awscli aws-shell ssh2
  fi
}

updt() {
  local command=$1
  local available='
    osx
    xcode
    ubuntu
    brew
    pip
    ruby
    vim
  '

  if [[ -n "$command" ]] && [[ "${available}" =~ $command ]]; then
    "update_${command}"
  else
    for cmd in $available; do "update_${cmd}"; done
  fi
}
