#!/usr/bin/env bash
# OSX Specific Functions

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

# Boot2Docker
dms() {
  is_osx || return 1
  . /Applications/Docker/Docker\ Quickstart\ Terminal.app/Contents/Resources/Scripts/start.sh

  local ip; ip=$(docker-machine ip "$DOCKER_MACHINE_NAME")
  if grep -qF "${ip}  docker" /etc/hosts; then
    echo "Docker machine ip (${ip}) is already present in hosts"
  elif grep -qF 'docker' /etc/hosts; then
    echo "Modifying docker machine ip (${ip}) in hosts"
    sudo sed -i "/docker/ s/.*/${ip}  docker/g" /etc/hosts
  else
    echo "Adding docker-machine (${ip}) to hosts"
    sudo sed -i "\$a${ip}  docker" /etc/hosts
  fi
}

