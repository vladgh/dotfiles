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

update_docker_images() {
  is_cmd docker || return
  for img in $(docker images 2>/dev/null | awk '$0 !~ /<none>/ {print $1":"$2}' | tail -n +2 | sort -u); do
    docker pull $img
  done
}

update_aws() {
  ( is_cmd aws && is_cmd eb ) || return
  sudo pip install --upgrade awscli awsebcli
}

update() {
  local command=$1
  local available='
    aws
    ubuntu
    brew
    vim
    ruby
    docker_images
  '

  if [[ "${available}" =~ "${command}" ]]; then
    update_$command
  else
    for cmd in $available; do update_${cmd}; done
  fi
}
