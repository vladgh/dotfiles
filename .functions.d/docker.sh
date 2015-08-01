#!/usr/bin/env bash
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
