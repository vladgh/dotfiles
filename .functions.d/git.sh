#!/usr/bin/env bash
#
# GIT Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/git.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# NAME: git_install_repo
# DESCRIPTION: Installs the official Launchpad PPA repository
git_install_repo(){
  if [ ! -s /etc/apt/sources.list.d/git-core-ppa-trusty.list ]; then
    install_ppa_repo 'git-core/ppa'
    apt_update
  fi
}

# NAME: git_install_latest
# DESCRIPTION: Installs Git from the official Launchpad PPA repository
git_install_latest(){
  git_install_repo
  apt_install git
}
