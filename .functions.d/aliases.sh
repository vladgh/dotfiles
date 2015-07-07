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

# DOCKER #######################################################################

# Aliases
alias dl='docker ps -lq'
alias dlc='docker ps'
alias dli='docker images'
alias dru='docker run -it --rm ubuntu bash'

# Kill all running containers.
alias docker_killall='docker kill $(docker ps -q)'

# Delete all stopped containers except for the data only ones (Names *-data).
alias docker_clean_containers='printf "\n>>> Deleting stopped containers\n\n" &&  docker rm $(docker ps -aq)'

# Delete all untagged images.
alias docker_clean_images='printf "\n>>> Deleting untagged images\n\n" && docker images -q --filter "dangling=true" | xargs docker rmi'

# Delete all stopped containers and untagged images.
alias docker_clean='docker_clean_containers; docker_clean_images'

# TODO Temporary fix for docker until version 1.7.1 is out
alias fix_docker='boot2docker ssh "sudo /etc/init.d/docker restart"'

################################################################################

# vim: ft=sh

