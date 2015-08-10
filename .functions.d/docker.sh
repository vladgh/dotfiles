#!/usr/bin/env bash
#
# Docker Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/docker.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# NAME: docker_install
# DESCRIPTION: Installs Docker unless already installed
docker_install(){
  if is_cmd docker && [ -e /var/run/docker.sock ]; then
    echo 'Docker is already installed; Version:' && docker version
  else
    echo 'Installing Docker'
    wget -qO- https://get.docker.com/ | sh
  fi
}

# NAME: docker_install_compose
# DESCRIPTION: Installs Docker and Docker Compose unless already installed
docker_install_compose(){
  if ! is_ubuntu; then echo 'Currently only ubuntu is supported' && return; fi
  if ! is_cmd pip; then echo 'Installing Python PIP' && apt_install python-pip; fi
  docker_install
  if is_cmd docker-compose; then
    echo 'Docker Compose is already installed; Version:'
    docker-compose --version
  else
    echo 'Installing Docker Compose'
    sudo -H pip install --upgrade docker-compose
  fi
}

# NAME: docker_install_machine
# DESCRIPTION: Ensure Docker Machine is installed. Tries to get the latest
# tagged release from GitHub API.
# USAGE:
#   docker_install_machine {version}
# PARAMETERS:
#   1) The version number (optional; defaults to the latest GitHub release)
docker_install_machine(){
  is_cmd jq || install_jq
  local url='https://github.com/docker/machine/releases/download'
  local api='https://api.github.com/repos/docker/machine/releases/latest'
  local latest; latest=$(curl -s $api | jq ".name" | tr -d '"')
  local version=${1:-$latest}
  local script; script="docker-machine_$(uname -s  | tr '[:upper:]' '[:lower:]')-amd64"
  local cmd='/usr/local/bin/docker-machine'
  docker_install
  if [ -s $cmd ] && [ -x $cmd ]; then
    echo "'${cmd}' is present."
  else
    echo "Installing Docker Machine v${version}"
    sudo wget -qO $cmd "${url}/v${version}/${script}"
    sudo chmod +x $cmd
  fi
}

# NAME: docker_container_is_running
# DESCRIPTION: Returns true if the given containers are running
# USAGE: docker_container_is_running {Container}
# PARAMETERS:
#   1) One or more container names or ids
docker_container_is_running() {
  for container in "${@}"; do
    if [[ $(docker inspect --format='{{.State.Running}}' "${container}" 2>/dev/null) == true ]]; then
      echo "'$container' is running."
    else
      e_abort "'$container' container is not running!"
    fi
  done
}

# NAME: docker_container_exited_clean
# DESCRIPTION: Returns true if the given containers returned a 0 exit code
# USAGE: docker_container_exited_clean {Container}
# PARAMETERS:
#   1) One or more container names or ids
docker_container_exited_clean() {
  for container in "${@}"; do
    [[ $(docker inspect --format='{{.State.ExitCode}}' "${container}" 2>/dev/null) == 0 ]] || \
      e_abort "'$container' container did not exit cleanly!"
  done
}

# NAME: docker_load_image
# DESCRIPTION: Loads a docker image from a local archive.
# USAGE: docker_load_image {path}
# PARAMETERS:
#   1) The path to the archive
docker_load_image(){
  local path=$1
  if [[ -e $path ]]; then
    echo "Loading image from '${path}'"
    docker load -i "$path"
  else
    echo "The Docker image '${path}' does not exist"
  fi
}

# NAME: docker_save_image
# DESCRIPTION: Saves a compressed docker image to a local archive.
# USAGE: docker_save_image {name} {path}
# PARAMETERS:
#   1) Image name (Ex: user/image:tag)
#   2) The path to the archive (Ex: /tmp/test.tgz)
docker_save_image(){
  local name=$1
  local path=$2
  echo "Saving image '${name}' to '${path}'"
  mkdir -p "$(dirname "$path")"
  docker save "$name" | gzip -c > "$path"
}

# NAME: docker_refresh_cached_image
# DESCRIPTION: Refresh a cached docker image.
# USAGE: docker_refresh_cached_image {path}
# PARAMETERS:
#   1) Image name
#   2) The path to the archive
docker_refresh_cached_image(){
  local name=$1
  local path=$2
  docker_load_image "$path"
  docker pull "$name"
  docker_save_image "$@"
}

# NAME: docker_compose_latest_version
# DESCRIPTION: Retrieves the latest compose version from GitHub api.
docker_compose_latest_version(){
  curl -s https://api.github.com/repos/docker/compose/releases/latest | \
    jq ".assets[] | .browser_download_url | select(endswith(\"$(uname -s)-$(uname -m)\"))" | \
    tr -d '"'
}
