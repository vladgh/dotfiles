#!/usr/bin/env bash
#
# PuppetLabs Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/puppet.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# NAME: puppet_install_release_package
# DESCRIPTION: Ensure Release Package for the Official Repository
puppet_install_release_package(){
  local collection='pc1'
  local deb; deb="puppetlabs-release-${collection}-$(get_dist).deb"
  local tmp; tmp=$(mktemp)
  if [ -s /etc/apt/sources.list.d/puppetlabs-${collection}.list ]; then
    echo 'The Official PuppetLabs Repository is already configured' && return
  else
    echo "Installing the Official PuppetLabs Repository"
    wget -qO "$tmp" "https://apt.puppetlabs.com/${deb}"
    sudo dpkg -i "$tmp" && apt_update
  fi
}

# NAME: puppet_install_agent
# DESCRIPTION: Installs Puppet Agent
puppet_install_agent(){
  puppet_install_release_package
  apt_install puppet-agent
}

# NAME: puppet_install_server
# DESCRIPTION: Installs Puppet Server
puppet_install_server(){
  puppet_install_release_package
  apt_install puppetserver
}
