# Aliases ######################################################################

# List
alias ll='ls -lahpF' # Ubuntu & Mac compatible

# Reload the shell (i.e. invoke as a login shell)
alias reload="echo 'Reloading BASH' && . ~/.bash_profile"

# Network
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# Vim
alias gvim="gvim 2>/dev/null"

# Temp Dir
alias tmp="cd `mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`"
alias tmpf="vim `mktemp 2>/dev/null || mktemp -t 'mytmpfile'`"

# Tmux
alias ta="tmux attach-session -t"
alias tc="tmux new-session -s"
alias tl="tmux list-sessions"

# Screen
alias sc="screen -S" # Create
alias sl="screen -ls" # List
alias sr="screen -r" # Resume

# Generate Salt
alias genSalt='openssl rand -base64 32'

# vim: ft=sh

