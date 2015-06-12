latest_trusty_hvm64() {
  curl -Ls http://cloud-images.ubuntu.com/query/trusty/server/released.current.txt | awk '$5 == "ebs-ssd" && $6 == "amd64" && $7 == "us-east-1" && $9 == "hvm" { print $8 }'
}

launch_aws_instance() {
  local id=$(aws ec2 run-instances --image-id $(latest_trusty_hvm64) --instance-type t2.micro --key-name vgh --query Instances[].InstanceId --output text)

  aws ec2 create-tags --resources $id --tags Key=Name,Value=DEV
  echo "Instance '${id}' was created and named."

  echo 'Waiting to become available...'
  aws ec2 wait instance-running --instance-ids $id

  local ip=$(aws ec2 describe-instances --instance-ids $id --query 'Reservations[].Instances[].PublicDnsName' --output text)
  echo "Public DNS Name is '${ip}'"
}
