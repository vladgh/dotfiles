# Sync to AWS S3

s3sync(){
  # Checks
  is_cmd aws || ( echo 'AWS CLI is not installed!' && return )
  [[ -n $SCRIPTS ]] || ( echo 'No SCRIPTS variable found!' && return )
  [[ -n $SCRIPTS_S3 ]] || ( echo 'No SCRIPTS_S3 variable found!' && return )

  # sh.ghn.me
  aws s3 sync $SCRIPTS/ $SCRIPTS_S3/ \
    --delete --acl public-read \
    --exclude "*" --include "*.sh"
  e_ok "Synced $SCRIPTS to $SCRIPTS_S3"
}
