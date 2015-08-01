## Update

update_ubuntu() {
  is_ubuntu || return
  sudo apt-get --quiet --yes update
  sudo apt-get --quiet --yes upgrade
}

update_brew() {
  is_osx || return
  brew update
  brew upgrade --all
  brew doctor
  brew cleanup
}

update_vim() {
  local vimdir=${HOME}/.vim
  [[ -d $vimdir ]] && \
    ( [[ -d $vimdir/.git ]] || [[ -d $vimdir/../.git ]] ) || return
  (
    cd ${HOME}/.vim
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
    # TODO Parallel git submodule foreach "(git fetch && git reset --hard origin/master) &"
    git submodule foreach --recursive \
      "git fetch && git reset --hard origin/master"
  )
}

update_ruby() {
  is_cmd rvm || return
  rvm get stable
  gem update --system
  gem update
}

update_docker_compose(){
  is_cmd jq || install_jq
  local url='https://github.com/docker/compose/releases/download'
  local api='https://api.github.com/repos/docker/compose/releases/latest'
  local version; version=$(curl -s $api | jq ".name" | tr -d '"')
  local script; script="docker-compose-$(uname -s)-$(uname -m)"
  local cmd='/usr/local/bin/docker-compose'
  echo "Installing Docker Compose v${version}"
  sudo wget -qO $cmd "${url}/${version}/${script}"
  sudo chmod +x $cmd
  echo "Installing Docker Compose bash completion"
  if [[ -d /usr/local/etc/bash_completion.d ]]; then
    curl -sL "https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose" > /usr/local/etc/bash_completion.d/docker-compose
  elif [[ -d /etc/bash_completion.d ]]; then
    curl -sL "https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose" > /usr/local/etc/bash_completion.d/docker-compose
  else
    echo 'Could not install Docker Compose bash completion'
  fi
}

update_docker_machine(){
  is_cmd jq || install_jq
  local url='https://github.com/docker/machine/releases/download'
  local api='https://api.github.com/repos/docker/machine/releases'
  local version; version=$(curl -s $api | jq '.[0] | .name' | tr -d '"')
  local script; script="docker-machine_$(uname -s  | tr '[:upper:]' '[:lower:]')-amd64"
  local cmd='/usr/local/bin/docker-machine'
  echo "Installing Docker Machine ${version}"
  sudo wget -qO $cmd "${url}/${version}/${script}"
  sudo chmod +x $cmd
}

update_docker() {
  is_cmd docker || return
  if is_cmd boot2docker; then
    boot2docker stop && boot2docker upgrade
  fi
  update_docker_compose
  update_docker_machine
}

update_aws() {
  ( is_cmd aws && is_cmd eb ) || return
  if is_osx; then
    pip install --upgrade pip setuptools awscli awsebcli
  else
    sudo pip install --upgrade pip setuptools awscli awsebcli
  fi
}

updt() {
  local command=$1
  local available='
    aws
    docker
    ubuntu
    brew
    vim
    ruby
  '

  if [[ "${available}" =~ $command ]]; then
    "update_${command}"
  else
    for cmd in $available; do "update_${cmd}"; done
  fi
}
