# Sync to AWS S3

s3sync(){
  # Checks
  is_cmd aws || ( echo 'AWS CLI is not installed!' && return )
  [[ -n $SCRIPTS_S3 ]] || ( echo 'No SCRIPTS_S3 variable found!' && return )
  [[ -n $CLOUDFORMATION_S3 ]] || \
    ( echo 'No CLOUDFORMATION_S3 variable found!' && return )

  # sh.ghn.me
  aws s3 sync $SCRIPTS/ $SCRIPTS_S3/ \
    --delete --acl public-read \
    --exclude "*.tmp.*"
  e_ok "Synced $SCRIPTS to $SCRIPTS_S3"

  # Upload CloudFormation templates to AWS S3
  aws s3 sync $CLOUDFORMATION/ $CLOUDFORMATION_S3/ \
    --delete --acl public-read \
    --exclude "*" --include "*.json"
  e_ok "Synced $CLOUDFORMATION to $CLOUDFORMATION_S3"
}
