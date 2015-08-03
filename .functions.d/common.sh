#!/usr/bin/env bash
#
# Vlad's Common Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/common.sh) || true

# OS detection
is_root()   { [[ $EUID == 0 ]] ;}
is_cmd()    { command -v "$@" >/dev/null 2>&1 ;}
is_osx()    { [[ $(uname) == Darwin ]] ;}
is_linux()  { [[ $(uname) == Linux ]] ;}
is_ubuntu() { is_cmd lsb_release && [[ "$(lsb_release -si)" =~ Ubuntu ]] ;}
get_dist()  { lsb_release -cs ;}

# Logging stuff.
is_color()  { [[ $TERM =~ xterm ]] ;}
is_silent() { [[ $SILENT == true ]] ;}
e_header() {
  is_silent || { is_color && echo -e "\n\033[1m$*\033[0m" || echo -e "\n$*" ;}
}
e_ok() {
  is_silent || \
    { is_color && echo -e "  \033[1;32m✔\033[0m  $*" || echo "  ✔  $*" ;}
}
e_error() {
  is_silent || \
    { is_color && echo -e "  \033[1;31m✖\033[0m  $*" || echo "  ✖  $*" ;}
}
e_warn() {
  is_silent || \
    { is_color && echo -e "  \033[1;33m  $*\033[0m" || echo "    $*" ;}
}
e_arrow() {
  is_silent || \
    { is_color && echo -e "  \033[0;34m➜\033[0m  $*" || echo "  ➜  $*" ;}
}
e_footer() {
  is_silent || \
    { is_color && echo -e "\n\033[1m$*\033[0m\n" || echo -e "\n$*\n" ;}
}
e_abort() {
  is_silent || \
    { is_color && echo -e "  \033[1;31m✖\033[0m  ${1}" || echo "  ✖  ${1}" ;}
  return "${2:-1}"
}
e_ok() {
  is_silent || \
    { is_color && echo -e "  \033[1;32m✔\033[0m  $*" || echo "  ✔  $*" ;}
}
e_finish() { e_ok "Finished $(basename "$0") at $(/bin/date "+%F %T")"; }

# APT NOTE:
# On some versions apt breaks a bash script by reading from standard input
# when it shouldn't (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=746434
apt_update() { echo 'Updating APT' && sudo apt-get -qy update < /dev/null ;}
apt_upgrade(){ echo 'Upgrading system' && sudo apt-get -qy upgrade < /dev/null ;}
apt_install(){ echo "Installing '$*'" && sudo apt-get -qy install "$@" < /dev/null ;}

# NAME: install_ppa_repo
# DESCRIPTION: Installs a Launchpad repository
# USAGE:
#   install_ppa_repo {name}
# PARAMETERS:
#   1) The repository name; Ex: 'user/ppa-name'
install_ppa_repo(){
  local repo="$1"
  is_cmd add-apt-repository || apt_install python-software-properties software-properties-common
  sudo add-apt-repository -y "ppa:${repo}"
}

# NAME: upgrade_system
# DESCRIPTION: Updates APT and upgrades packages
upgrade_system() {
  apt_update && apt_upgrade
}

# NAME: wait_for
# DESCRIPTION: Waits for the given command to return true
# USAGE: wait_for {Command} {Message}
# PARAMETERS:
#   1) The command to wait for (required).
#   2) The Initial message (optional; EX: 'Waiting to start...')
wait_for() {
  local cmd=$1
  local msg=$2
  if [ -z "$msg" ]; then
    printf "Waiting for '%s'..." "$cmd"
  else
    printf "%s" "$msg"
  fi
  until $cmd; do printf '.' && sleep 5; done
  echo ' Done.'
}

# NAME: load_remote_vgh_functions
# DESCRIPTION: Loads the scripts in this repository by name
# USAGE:
#   load_remote_vgh_functions {Script Name}
# PARAMETERS:
#   1) One or more script names, without the '.sh' (required)
# Load remote scripts
load_remote_vgh_functions(){
  local url='https://vladgh.s3.amazonaws.com/functions'
  for script in "$@"; do
    . <(wget -qO- "${url}/${script}.sh") || true
  done
}

# NAME: user_exists
# DESCRIPTION: Returns true if a user exists.
# USAGE:
#   user_exists {name}
# PARAMETERS:
#   1) The user name
user_exists(){
  local user="$1"
  if id -u "$user" >/dev/null 2>&1; then
    echo "User '${user}' exists"; return 0
  else
    echo "User '${user}' does not exist"; return 1
  fi
}

# NAME: add_user_to_group
# DESCRIPTION: Adds a user to a group.
# USAGE: add_user_to_group {user} {group}
# PARAMETERS:
#   1) User name
#   2) Group name
add_user_to_group(){
  local user=$1
  local group=$2
  user_exists "$@" || return
  if groups "$user" | grep &>/dev/null "\b${group}\b"; then
    echo "User '${user}' is already part of the '${group}' group"
  else
    echo "Adding '${user}' user to the '${group}' group"
    sudo usermod -aG "$group" "$user"
  fi
}

# NAME: install_jq
# DESCRIPTION: Installs JQ JSON Processor
install_jq(){
  local url='http://stedolan.github.io/jq/download/linux64/jq'
  local path='/usr/local/bin/jq'
  if is_cmd jq; then
    echo 'JQ JSON Processor is already installed'
  else
    echo 'Installing JQ JSON Processor' && \
    sudo wget -qO $path $url && sudo chmod +x $path
  fi
}

