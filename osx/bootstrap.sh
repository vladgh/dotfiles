#!/usr/bin/env bash

# Immediately exit on errors
set -euo pipefail

# Check for Homebrew
if test ! "$(which brew)"; then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew bundle
brew update
brew upgrade
brew doctor

# Install Bash 4.
# This is where brew stores its binary symlinks
binroot="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin
if type -P "${binroot}/bash" >/dev/null && ! grep -q "$binroot/bash" /etc/shells; then
  echo "Adding $binroot/bash to the list of acceptable shells"
  echo "$binroot/bash" | sudo tee -a /etc/shells >/dev/null
fi
if [[ "$(dscl . -read ~ UserShell | awk '{print $2}')" != "$binroot/bash" ]]; then
  echo "Making $binroot/bash your default shell"
  sudo chsh -s "$binroot/bash" "$USER" >/dev/null 2>&1
fi

# Ruby
curl -sSL https://get.rvm.io | bash -s -- --ruby --with-gems='bundler'
bundle config specific_platform true

# Python
pip install --upgrade pip setuptools virtualenv \
                      awscli awsebcli aws-shell \
                      ssh2

# Node.js
npm install npm -g

# Tweaks
echo 'prevent .DS_Store file creation over network connections'
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

echo "Please exit and restart all your shells."
exit 0
