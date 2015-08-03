#!/usr/bin/env bash
#
# Miscellaneous Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/misc.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# Create a directory and jump directly into it
mcd() { mkdir -p "$1" && cd "$1" ;}

# VMware
vmware_install() {
  (
  cd "$(mktemp -d)"
  sudo apt-get --quiet --yes install build-essential "linux-headers-$(uname -r)"
  tar zxvf "/media/$(whoami)/VMware\ Tools/VMwareTools-*.tar.gz"
  sudo ./vmware-tools-distrib/vmware-install.pl -d
  )
}
vmware_refresh() { sudo vmware-config-tools.pl -d ;}

# Start an HTTP server from a directory, optionally specifying the port
server() {
  local port="${1:-8000}";
  sleep 1 && open "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Extract most know archives with one command
extract () {
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
       echo "'$1' is not a valid file"
   fi
}

# CHROME
open_chrome(){
  local tmpdir chrome
  tmpdir="$(mktemp -d -t 'chrome-unsafe_data_dir')"
  chrome='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
  $chrome \
    --disable-sync \
    --disable-first-run-ui \
    --no-default-browser-check \
    --no-first-run \
    --proxy-server="${1}" \
    --user-data-dir="${tmpdir}" \
    'https://www.whatismyip.com' >/dev/null 2>&1 &
}
ssh_tunnel(){
  # shellcheck disable=SC2029
  ssh -vXNCD "$1" "$2"
}
chrome_virgin(){
  local remote=$1
  local port='8523'

  if [ -n "${remote}" ]; then
    echo "Opening Chrome in background with ssh tunnel to ${remote}"
    open_chrome "socks5://localhost:${port}"
    ssh_tunnel "$port" "$remote"
  else
    echo 'Opening Chrome in background without ssh tunnel'
    open_chrome
  fi
}

# SSH
add_public_key(){
  ssh "$@" "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys" \
    < ~/.ssh/id_rsa.pub
}

