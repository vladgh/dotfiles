#!/usr/bin/env bash

# MAC SPECIFIC
is_osx || return 1

# Boot2Docker
eval "$(boot2docker shellinit 2>/dev/null)"
b2d() {
  boot2docker up && eval "$(boot2docker shellinit 2>/dev/null)"
  local ip; ip=$(boot2docker ip)
  if grep -qF 'boot2docker' /etc/hosts; then
    echo "Modifying boot2docker ip (${ip}) in hosts"
    sudo sed -i "/boot2docker/ s/.*/${ip}  boot2docker/g" /etc/hosts
  else
    echo "Adding boot2docker (${ip}) to hosts"
    sudo sed -i "\$a${ip}  boot2docker" /etc/hosts
  fi
}

# ALIASES
# Reload DNS on OSX
alias flushdns="dscacheutil -flushcache"

# Suspend
alias away='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Boot2Docker
alias d2c='open http://$(boot2docker ip)'
