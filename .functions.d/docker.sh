#!/usr/bin/env bash
# Docker Functions

# Kill all running containers.
docker_killall(){
  docker kill "$(docker ps -q)"
}

# Delete all stopped containers and untagged images.
docker_clean(){
  # shellcheck disable=SC2046
  docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
  # shellcheck disable=SC2046
  docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
}

docker_delstopped(){
  local name=$1
  local state; state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

  if [[ "$state" == "false" ]]; then
    docker rm "$name"
  fi
}

# Runs docker exec in the latest container
docker_exec_last(){
  docker exec -it "$(docker ps -a -q -l)" /bin/bash
}

# Backup files from a docker volume into /tmp/backup.tar.gz
docker_volume_backup(){
  docker run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie tar -czvf /backup/backup.tar.gz "${@:2}"
}

# Restore files from /tmp/backup.tar.gz into a docker volume
docker_volume_restore(){
  docker run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie tar -xzvf /backup/backup.tar.gz "${@:2}"
  echo "Double checking files..."
  docker run --rm -v /tmp:/backup --volumes-from "$1" debian:jessie ls -lh "${@:2}"
}
