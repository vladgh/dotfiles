#!/usr/bin/env bash
#
# OSX Specific Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/osx.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# Boot2Docker
b2d() {
  is_osx || return 1
  [[ "$(boot2docker status)" == 'poweroff' ]] && boot2docker up
  eval "$(boot2docker shellinit 2>/dev/null)"

  local ip; ip=$(boot2docker ip)
  if grep -qF 'boot2docker' /etc/hosts; then
    echo "Modifying boot2docker ip (${ip}) in hosts"
    sudo sed -i "/boot2docker/ s/.*/${ip}  boot2docker/g" /etc/hosts
  else
    echo "Adding boot2docker (${ip}) to hosts"
    sudo sed -i "\$a${ip}  boot2docker" /etc/hosts
  fi
}

