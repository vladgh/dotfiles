#!/usr/bin/env bash
# Vlad's Common Functions

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
e_finish() { e_ok "Finished ${BASH_SOURCE[0]} at $(/bin/date "+%F %T")"; }

