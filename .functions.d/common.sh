#!/usr/bin/env bash
# Common Functions

# OS detection
is_root()   { [[ $EUID == 0 ]] ;}
is_cmd()    { command -v "$@" >/dev/null 2>&1 ;}
is_osx()    { [[ $(uname) == Darwin ]] ;}
is_linux()  { [[ $(uname) == Linux ]] ;}
is_ubuntu() { is_cmd lsb_release && [[ "$(lsb_release -si)" =~ Ubuntu ]] ;}
get_dist()  { lsb_release -cs ;}
