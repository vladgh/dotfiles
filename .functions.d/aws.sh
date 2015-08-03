#!/usr/bin/env bash
#
# Amazon Web Services Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/aws.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# NAME: aws_system_checks
# DESCRIPTION: Checks the system
aws_system_checks(){
  if ! is_ubuntu; then echo 'Currently only ubuntu is supported' && return; fi
  if ! is_cmd pip; then echo 'Installing Python PIP' && apt_install python-pip; fi
}

# NAME: aws_install_cli
# DESCRIPTION: Installs AWS Command Line Interface
aws_install_cli(){
  aws_system_checks
  is_cmd aws && aws --version 2>/dev/null
  if [ $? != 0 ]; then
    echo 'Installing AWS CLI' && sudo -H pip install --upgrade awscli
  fi
}

# NAME: aws_install_cfn
# DESCRIPTION: Installs AWS CloudFormation helper scripts
aws_install_cfn(){
  aws_system_checks
  is_cmd cfn-init && is_cmd cfn-signal
  if [ $? != 0 ]; then
    echo 'Installing AWS CloudFormation helper scripts'
    sudo -H pip install --upgrade https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
  fi
}

# NAME: aws_install_cw_logs
# DESCRIPTION: Installs AWS CloudWatch Logs Agent
# USAGE: aws_install_cw_logs {Config File}
# PARAMETERS:
#   1) The path to the configuration file (required; it can be local or S3 Path)
#      Ex: s3://mybucket/mykey.conf
aws_install_cw_logs(){
  local cfg=$1
  local url='https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py'

  aws_system_checks
  wget -qO- "$url" | sudo python - \
    --non-interactive \
    --region "$(aws_get_instance_region)" \
    --configfile "$cfg" || \
    echo 'Could not install AWS CloudWatch Agent'
}

# NAME: aws_get_metadata
# DESCRIPTION: AWS MetaData Service
aws_get_metadata(){
  wget --timeout=2 --tries=2 -qO- "http://instance-data/latest/meta-data/${*}"
}

# NAME: aws_get_instance_id
# DESCRIPTION: Returns the EC2 instance ID for the local instance
aws_get_instance_id() {
  if [ -z "${INSTANCE_ID}" ]; then
    export INSTANCE_ID; INSTANCE_ID=$(aws_get_metadata instance-id || true)
  fi
  echo "$INSTANCE_ID"
}

# NAME: aws_get_instance_region
# DESCRIPTION: Returns the the AWS region (defaults to us-east-1)
aws_get_instance_region() {
  if [ -z "${AWS_REGION}" ]; then
    local az; az=$(aws_get_metadata placement/availability-zone || true)
    export AWS_REGION="${az%?}"
  fi
  echo "${AWS_REGION:-us-east-1}"
}

# AWS CLI Command
aws_cmd(){
  /usr/local/bin/aws --region "$(aws_get_instance_region)" "${@}"
}

# NAME: list_all_tags
# DESCRIPTION: Returns all EC2 tags associated with the current instance
list_all_tags(){
  aws_cmd --output text ec2 describe-tags \
    --filters "Name=resource-id,Values=$(aws_get_instance_id)" \
    --query "Tags[*].[join(\`=\`,[Key,Value])]" 2>/dev/null | \
    awk '{print tolower($0)}' | \
    sed 's/.*/ec2_tag_&/'
}

# NAME: aws_get_tag
# DESCRIPTION: Gets the value of an ec2 tag.
# USAGE: aws_get_tag {Key Name} {Resource ID}
# PARAMETERS:
#   1) The key name (defaults to 'Name')
#   2) The resource id (defaults to the current instance id)
aws_get_tag(){
  local name=${1:-'Name'}
  local instance_id; instance_id=$(aws_get_instance_id)
  local resource=${2:-$instance_id}

  aws_cmd --output text ec2 describe-tags \
    --filters "Name=resource-id,Values=${resource}" "Name=key,Values=$name" \
    --query "Tags[*].[Value]" 2>/dev/null
}

# NAME: aws_get_instance_state_asg
# DESCRIPTION: Gets the state of the given <EC2 instance ID> as known by the AutoScaling
# group it's a part of.
# USAGE: aws_get_instance_state_asg {EC2 instance ID}
# PARAMETERS:
#   1) The instance id
aws_get_instance_state_asg() {
  local instance_id=$1
  local state; state=$(aws_cmd autoscaling describe-auto-scaling-instances \
    --instance-ids "$instance_id" \
    --query "AutoScalingInstances[?InstanceId == \`$instance_id\`].LifecycleState | [0]" \
    --output text)
  if [ $? != 0 ]; then
    return 1
  else
    echo "$state"
    return 0
  fi
}

# NAME: aws_get_autoscaling_group_name
# DESCRIPTION: Returns the name of the AutoScaling group this instance is a
# part of.
# USAGE: aws_get_autoscaling_group_name {EC2 instance ID}
# PARAMETERS:
#   1) The instance id
aws_get_autoscaling_group_name() {
  local instance_id=$1
  local autoscaling_name; autoscaling_name=$(aws_cmd autoscaling \
    describe-auto-scaling-instances \
    --instance-ids "$instance_id" \
    --output text \
    --query AutoScalingInstances[0].AutoScalingGroupName)

  if [ $? != 0 ]; then
    return 1
  else
    echo "$autoscaling_name"
  fi

  return 0
}

# NAME: aws_autoscaling_enter_standby
# DESCRIPTION: Move the instance into the Standby state in AutoScaling group
aws_autoscaling_enter_standby(){
  local instance_id; instance_id=$(aws_get_instance_id)
  local asg_name; asg_name=$(aws_get_autoscaling_group_name "$instance_id")

  echo "Checking if this instance has already been moved in the Standby state"
  local instance_state
  instance_state=$(aws_get_instance_state_asg "$instance_id")
  if [ $? != 0 ]; then
    echo "Unable to get this instance's lifecycle state."
    return 1
  fi

  if [ "$instance_state" == "Standby" ]; then
    echo "Instance is already in Standby; nothing to do."
    return 0
  elif [ "$instance_state" == "Pending" ]; then
    echo "Instance is Pending; nothing to do."
    return 0
  elif [ "$instance_state" == "Pending:Wait" ]; then
    echo "Instance is Pending:Wait; nothing to do."
    return 0
  fi

  echo "Putting instance $instance_id into Standby"
  aws_cmd autoscaling enter-standby \
    --instance-ids "$instance_id" \
    --auto-scaling-group-name "$asg_name" \
    --should-decrement-desired-capacity
  if [ $? != 0 ]; then
    echo "Failed to put instance $instance_id into Standby for ASG $asg_name."
    return 1
  fi

  printf "Waiting for instance to reach state Standby..."
  while [ "$(aws_get_instance_state_asg "$instance_id")" != "Standby" ]; do
    printf '.' && sleep 5
  done
  echo ' Done.'

  return 0
}

# NAME: aws_autoscaling_exit_standby
# DESCRIPTION: Attempts to move instance out of Standby and into InService.
aws_autoscaling_exit_standby(){
  local instance_id; instance_id=$(aws_get_instance_id)
  local asg_name; asg_name=$(aws_get_autoscaling_group_name "$instance_id")

  echo "Checking if this instance has already been moved out of Standby state"
  local instance_state
  instance_state=$(aws_get_instance_state_asg "$instance_id")
  if [ $? != 0 ]; then
    echo "Unable to get this instance's lifecycle state."
    return 1
  fi

  if [ "$instance_state" == "InService" ]; then
    echo "Instance is already in InService; nothing to do."
    return 0
  elif [ "$instance_state" == "Pending" ]; then
    echo "Instance is Pending; nothing to do."
    return 0
  elif [ "$instance_state" == "Pending:Wait" ]; then
    echo "Instance is Pending:Wait; nothing to do."
    return 0
  fi

  echo "Moving instance $instance_id out of Standby"
  aws_cmd autoscaling exit-standby \
    --instance-ids "$instance_id" \
    --auto-scaling-group-name "$asg_name"
  if [ $? != 0 ]; then
    echo "Failed to put instance $instance_id back into InService for ASG $asg_name."
    return 1
  fi

  printf "Waiting for instance to reach state InService..."
  while [ "$(aws_get_instance_state_asg "$instance_id")" != "InService" ]; do
    printf '.' && sleep 5
  done
  echo ' Done.'

  return 0
}

# NAME: aws_deploy_list_running_deployments
# DESCRIPTION: Returns the a list of running deployments for the given
# CodeDeploy application and group.
# USAGE: aws_deploy_list_running_deployments {App} {Group}
# PARAMETERS:
#   1) The application name
#   2) The deployment group name
aws_deploy_list_running_deployments() {
  local app=$1
  local group=$2

  aws_cmd deploy list-deployments \
    --output text \
    --query 'deployments' \
    --application-name "$1" \
    --deployment-group-name "$2" \
    --include-only-statuses Queued InProgress
}

# NAME: aws_deploy_group_exists
# DESCRIPTION: Returns true if the given deployment group exists.
# USAGE: aws_deploy_group_exists {App} {Group}
# PARAMETERS:
#   1) The application name
#   2) The deployment group name
aws_deploy_group_exists() {
  local app=$1
  local group=$2

  aws_cmd deploy get-deployment-group \
    --query 'deploymentGroupInfo.deploymentGroupId' --output text \
    --application-name "$1" \
    --deployment-group-name "$2" >/dev/null
}

# NAME: aws_deploy_wait
# DESCRIPTION: Waits until there are no other deployments in progress for the
# given CodeDeploy application and group.
# USAGE: aws_deploy_wait {App} {Group}
# PARAMETERS:
#   1) The application name
#   2) The deployment group name
aws_deploy_wait() {
  local app=$1
  local group=$2

  echo 'Waiting for other deployments to finish ...'
  until [[ -z "$(aws_deploy_list_running_deployments "$app" "$group")" ]]; do
    sleep 5
  done
  echo ' Done.'
}

# NAME: aws_deploy_create_deployment
# DESCRIPTION: Creates a CodeDeploy revision.
# USAGE: aws_deploy_create_deployment {App} {Group} {Bucket} {Key} {Bundle} {Config}
# PARAMETERS:
#   1) The application name
#   2) The deployment group name
#   3) The S3 bucket name
#   4) The S3 key name
#   5) The bundle type ("tar"|"tgz"|"zip")
#   6) The deployment config name
aws_deploy_create_deployment(){
  local app=$1
  local group=$2
  local bucket=$3
  local key=$4
  local bundle=$5
  local config=$6

  if aws_deploy_group_exists "$@"; then
    aws_deploy_wait "$@"

    echo "Creating deployment for application '${app}', group '${group}'"
    aws_cmd deploy create-deployment \
      --application-name "$app" \
      --s3-location bucket="${bucket}",key="${key}",bundleType="${bundle}" \
      --deployment-group-name "$group" \
      --deployment-config-name "$config"
  else
    echo "The '${group}' group does not exist in the '${app}' application"
  fi
}

# NAME: aws_codedeploy_is_running
# DESCRIPTION: Returns true if the CodeDeploy Agent is running
aws_codedeploy_is_running(){
  sudo service codedeploy-agent status >/dev/null 2>&1
  return $?
}

# NAME: aws_codedeploy_dependencies
# DESCRIPTION: Install CodeDeploy Agent dependencies
aws_codedeploy_dependencies(){
  if ! is_ubuntu; then echo 'Currently only Ubuntu is supported!' && return; fi
  echo 'Installing AWS Code Deploy dependencies'
  is_cmd ruby2.0 || apt_install ruby2.0
  is_cmd gdebi || apt_install gdebi-core
}

# NAME: aws_codedeploy_dependencies
# DESCRIPTION: Installs the CodeDeploy Agent
aws_codedeploy_install_agent(){
  local url='https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/codedeploy-agent_all.deb'
  local deb; deb=$(mktemp)
  aws_codedeploy_is_running && return
  aws_codedeploy_dependencies
  echo 'Installing AWS Code Deploy package'
  wget -qO "$deb" "$url" && sudo dpkg -i "$deb"
}

# NAME: aws_get_private_env
# DESCRIPTION: Retrieves a private file from AWS S3, saves it to a .env file
# in the current directory, and applies strict read-only permissions. The file
# is sourced afterwards. This function fails silently, and returns 0.
# USAGE: aws_get_private_env {S3 Path}
# PARAMETERS:
#   1) The S3 path to the file (required)
aws_get_private_env(){
  local src=$1
  local file; file="$(pwd)/.env"
  if [ -z "$src" ]; then
    echo "Usage: $FUNCNAME {S3 Path}" && return
  fi
  if [ -s "$file" ]; then
    echo "File '${file}' already exists. Replacing"
    sudo rm "$file"
  fi
  aws_cmd s3 cp "$src" "$file" || echo "Failed to get ${src}"
  if [ -s "$file" ]; then
    echo "Setting permissions for ${file}"
    sudo chmod 400 "$file"
    echo "Loading ${file}"
    . "$file" || echo "Failed to load ${file}"
  else
    echo "'${file}' does not exist" && return
  fi
}

# NAME: aws_get_ubuntu_official_ami_id
# DESCRIPTION: Retrieves the latest AMI ID for the official Ubuntu image.
# The region should be exported separately as part of the awscli instalation
# (Defaults to us-east-1).
# USAGE: aws_get_ubuntu_official_ami_id {Distribution} {Type} {Arch} \
#          {Virtualization}
# PARAMETERS:
#   1) Distribution code name (defaults to 'trusty')
#   2) Root device type (defaults to 'ebs-ssd')
#   3) Architecture (defaults to 'amd64')
#   4) Virtualization (defaults to 'hvm')
aws_get_ubuntu_official_ami_id() {
  local dist=${1:-trusty}
  local dtyp=${2:-ebs-ssd}
  local arch=${3:-amd64}
  local virt=${4:-hvm}
  local region=${AWS_REGION:-us-east-1}

  curl -Ls "http://cloud-images.ubuntu.com/query/${dist}/server/released.current.txt" | \
    awk -v region="$region" \
        -v dist="$dist" \
        -v dtyp="$dtyp" \
        -v arch="$arch" \
        -v virt="$virt" \
    '$5 == dtyp && $6 == arch && $7 == region && $9 == virt { print $8 }'
}

# NAME: aws_cf_tail
# DESCRIPTION: Show all events for CF stack until update completes or fails.
# USAGE: aws_cf_tail {Stack name}
# PARAMETERS:
#   1) Stack name (required)
aws_cf_tail() {
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

# NAME: aws_cf_events
# DESCRIPTION: Show all events for CF stack until update completes or fails.
# USAGE: aws_cf_events {Stack name}
# PARAMETERS:
#   1) Stack name (required)
aws_cf_events() {
  if [ -z "$1" ] ; then echo "Usage: $FUNCNAME stack"; return 1; fi
  local stack
  stack="$(basename "$1" .json)"
  shift
  local output
  if output=$(aws_cmd --color on cloudformation describe-stack-events --stack-name "$stack" --query 'sort_by(StackEvents, &Timestamp)[].{Resource: LogicalResourceId, Type: ResourceType, Status: ResourceStatus}' --output table "$@"); then
    echo "$output" | uniq -u
  else
    return $?
  fi
}

