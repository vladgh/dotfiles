#!/usr/bin/env bash
# Docker Functions

# Kill all running containers.
docker_killall(){
  docker kill "$(docker ps -q)"
}

# Delete all stopped containers and untagged images.
docker_clean(){
  docker rm -v "$(docker ps --filter status=exited -q 2>/dev/null)" 2>/dev/null
  docker rmi "$(docker images --filter dangling=true -q 2>/dev/null)" 2>/dev/null
}

docker_delstopped(){
  local name=$1
  local state; state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

  if [[ "$state" == "false" ]]; then
    docker rm "$name"
  fi
}
