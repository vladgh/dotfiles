#!/usr/bin/env bash
# Output Functions

# BASH Colors
fgblk="$(tput setaf 0)"     # Black - Regular
fgred="$(tput setaf 1)"     # Red
fggrn="$(tput setaf 2)"     # Green
fgylw="$(tput setaf 3)"     # Yellow
fgblu="$(tput setaf 4)"     # Blue
fgpur="$(tput setaf 5)"     # Purple
fgcyn="$(tput setaf 6)"     # Cyan
fgwht="$(tput setaf 7)"     # White

bfgblk="$(tput setaf 8)"    # Black - Bright
bfgred="$(tput setaf 9)"    # Red
bfggrn="$(tput setaf 10)"   # Green
bfgylw="$(tput setaf 11)"   # Yellow
bfgblu="$(tput setaf 12)"   # Blue
bfgpur="$(tput setaf 13)"   # Purple
bfgcyn="$(tput setaf 14)"   # Cyan
bfgwht="$(tput setaf 15)"   # White

bgblk="$(tput setab 0)"     # Black - Background
bgred="$(tput setab 1)"     # Red
bggrn="$(tput setab 2)"     # Green
bgylw="$(tput setab 3)"     # Yellow
bgblu="$(tput setab 4)"     # Blue
bgpur="$(tput setab 5)"     # Purple
bgcyn="$(tput setab 6)"     # Cyan
bgwht="$(tput setab 7)"     # White

bbgblk="$(tput setab 8)"    # Black - Background - Bright
bbgred="$(tput setab 9)"    # Red
bbggrn="$(tput setab 10)"   # Green
bbgylw="$(tput setab 11)"   # Yellow
bbgblu="$(tput setab 12)"   # Blue
bbgpur="$(tput setab 13)"   # Purple
bbgcyn="$(tput setab 14)"   # Cyan
bbgwht="$(tput setab 15)"   # White

normal="$(tput sgr0)"       # text reset
mkbold="$(tput bold)"       # make bold
undrln="$(tput smul)"       # underline
noundr="$(tput rmul)"       # remove underline
mkblnk="$(tput blink)"      # make blink
revers="$(tput rev)"        # reverse

# Logging stuff.
is_color()  { [[ $TERM =~ color ]] ;}
is_silent() { [[ $SILENT == true ]] ;}
e_header()  { is_silent || { is_color && printf "\n${mkbold}${bfgwht}%s${normal}" "$@" || printf "\n%s\n" "$@" ;} ;}
e_footer()  { is_silent || { is_color && printf "\n${mkbold}${bfgwht}%s${normal}" "$@" || printf "  ➜  %s" "$@";} ;}
e_ok()      { is_silent || { is_color && printf "  ${bfggrn}✔${normal}  %s\n" "$@" || printf "  ✔  %s" "$@" ;} ;}
e_error()   { is_silent || { is_color && printf "  ${fgred}✖${normal}  %s\n" "$@" || printf "  ✖  %s" "$@";} ;}
e_warn()    { is_silent || { is_color && printf "  ${fgylw}${normal}  %s\n" "$@" || printf "    %s" "$@";} ;}
e_arrow()   { is_silent || { is_color && printf "  ${fgcyn}➜${normal}  %s\n" "$@" || printf "  ➜  %s" "$@";} ;}
e_abort()   { e_error "$1"; return "${2:-1}" ;}
e_finish()  { e_ok "Finished ${BASH_SOURCE[0]} at $(/bin/date "+%F %T")"; }
