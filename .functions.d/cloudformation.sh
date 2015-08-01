#!/usr/bin/env bash
# Thanks to https://github.com/realestate-com-au/bash-my-aws

# Show all events for CF stack until update completes or fails.
cf_tail() {
  if [ -z "$1" ] ; then echo "Usage: $FUNCNAME stack"; return 1; fi
  local stack
  stack="$(basename "$1" .json)"
  local current
  local final_line
  local output
  local previous
  until echo "$current" | tail -1 | egrep -q "${stack}.*_(COMPLETE|FAILED)"
  do
    if ! output=$(cf_events "$stack"); then
      # Something went wrong with cf_events (like stack not known)
      return 1
    fi
    if [ -z "$output" ]; then sleep 1; continue; fi

    current=$(echo "$output" | sed '$d')
    final_line=$(echo "$output" | tail -1)
    if [ -z "$previous" ]; then
      echo "$current"
    elif [ "$current" != "$previous" ]; then
      comm -13 <(echo "$previous") <(echo "$current")
    fi
    previous="$current"
    sleep 1
  done
  echo "$final_line"
}

cf_events() {
  if [ -z "$1" ] ; then echo "Usage: $FUNCNAME stack"; return 1; fi
  local stack
  stack="$(basename "$1" .json)"
  shift
  local output
  if output=$(aws --color on cloudformation describe-stack-events --stack-name "$stack" --query 'sort_by(StackEvents, &Timestamp)[].{Resource: LogicalResourceId, Type: ResourceType, Status: ResourceStatus}' --output table "$@"); then
    echo "$output" | uniq -u
  else
    return $?
  fi
}

