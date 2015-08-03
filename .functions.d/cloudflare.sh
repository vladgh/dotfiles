#!/usr/bin/env bash
#
# CloudFlare Funcions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/cloudflare.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# NAME: cloudflare_zone_id
# DESCRIPTION: Returns the zone id
cloudflare_zone_id(){
  curl -sX GET "${api}/zones?name=${domain}&status=active" \
    -H "Content-Type:application/json" \
    -H "X-Auth-Key:${CLOUDFLARE_TOKEN}" \
    -H "X-Auth-Email:${CLOUDFLARE_EMAIL}" | jq -r '.result[0].id'
}

# NAME: cloudflare_record_id
# DESCRIPTION: Returns the record id
cloudflare_record_id(){
  curl -sX GET "${api}/zones/${zone_id}/dns_records?type=${r_type}&name=${name}.${domain}" \
    -H "Content-Type:application/json" \
    -H "X-Auth-Key:${CLOUDFLARE_TOKEN}" \
    -H "X-Auth-Email:${CLOUDFLARE_EMAIL}" | jq -r '.result[0].id'
}

# NAME: cloudflare_record_data
# DESCRIPTION: Returns the update parameters
cloudflare_record_data(){
  local ip; ip=$(dig +short myip.opendns.com @resolver1.opendns.com.)
  cat << EOD
{
  "id": "${rec_id}",
  "type": "${r_type}",
  "name": "${name}.${domain}",
  "content": "${ip}",
  "proxiable": true,
  "proxied": false,
  "ttl": 120,
  "locked": false,
  "zone_id": "${zone_id}",
  "zone_name": "${domain}"
}
EOD
}

# NAME: update_dns
# DESCRIPTION: Updates CloudFlare DNS records
# USAGE: update_dns {name} {domain} {type}
# PARAMETERS:
#   1) The record name
#   2) The domain
#   3) The type of record (A, CNAME)
cloudflare_update_dns(){
  local name=$1
  local domain=$2
  local r_type=$3
  local api='https://api.cloudflare.com/client/v4'
  local zone_id; zone_id=$(cloudflare_zone_id)
  local rec_id; rec_id=$(cloudflare_record_id)
  local rec_data; rec_data=$(cloudflare_record_data)
  curl -sX PUT "${api}/zones/${zone_id}/dns_records/${rec_id}" \
    -H "Content-Type:application/json" \
    -H "X-Auth-Key:${CLOUDFLARE_TOKEN}" \
    -H "X-Auth-Email:${CLOUDFLARE_EMAIL}" \
    --data "$rec_data" | \
    jq -c -M '. | {dns: .result.name, ip: .result.content, success}'
}
