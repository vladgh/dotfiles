#!/usr/bin/env bash
# Docker Functions

# Kill all running containers.
docker_killall(){
  for c in $(docker ps -q 2>/dev/null); do docker kill "$c"; done
}

# Delete all stopped containers, untagged images, volumes, networks, etc.
docker_clean(){
  docker system prune --force
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

docker_compact_disk(){
  cd ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux || return
  /Applications/Docker.app/Contents/MacOS/qemu-img convert -p -O qcow2 Docker.qcow2 Docker2.qcow2
  mv Docker2.qcow2 Docker.qcow2
}
