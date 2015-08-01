#!/usr/bin/env bash
# Sync to AWS S3

s3sync(){
  # Checks
  is_cmd aws || ( echo 'AWS CLI is not installed!' && return )
  s3sync_scripts
  s3sync_private
  s3sync_cloudformation
  s3sync_bootstrap
}

s3sync_scripts(){
  [[ -n "$SCRIPTS" ]] || ( echo 'No SCRIPTS variable found!' && return )
  [[ -n "$SCRIPTS_S3" ]] || ( echo 'No SCRIPTS_S3 variable found!' && return )
  aws s3 sync "$SCRIPTS/" "$SCRIPTS_S3/" \
    --delete --acl public-read \
    --exclude "*" --include "*.sh"
  e_ok "Synced $SCRIPTS to $SCRIPTS_S3"
}

s3sync_private(){
  [[ -n $PRIVATE ]] || ( echo 'No PRIVATE variable found!' && return )
  [[ -n $PRIVATE_S3 ]] || ( echo 'No PRIVATE_S3 variable found!' && return )
  aws s3 sync "$PRIVATE/" "$PRIVATE_S3/" \
    --delete --acl private
  e_ok "Synced $PRIVATE to $PRIVATE_S3"
}

s3sync_cloudformation(){
  [[ -n $CLOUDFORMATION ]] || ( echo 'No CLOUDFORMATION variable found!' && return )
  [[ -n $CLOUDFORMATION_S3 ]] || ( echo 'No CLOUDFORMATION_S3 variable found!' && return )
  aws s3 sync "$CLOUDFORMATION/" "$CLOUDFORMATION_S3/" \
    --exclude "*" --include "*.json" \
    --delete --acl private
  e_ok "Synced $CLOUDFORMATION to $CLOUDFORMATION_S3"
}

s3sync_bootstrap(){
  [[ -n $BOOTSTRAP ]] || ( echo 'No BOOTSTRAP variable found!' && return )
  [[ -n $BOOTSTRAP_S3 ]] || ( echo 'No BOOTSTRAP_S3 variable found!' && return )
  aws s3 sync "$BOOTSTRAP/" "$BOOTSTRAP_S3/" \
    --delete --acl public-read \
    --exclude "*" --include "*.sh"
  e_ok "Synced $BOOTSTRAP to $BOOTSTRAP_S3"
}
