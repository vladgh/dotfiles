#!/usr/bin/env bash
#
# Loggly Functions
# . <(wget -qO- https://vladgh.s3.amazonaws.com/functions/loggly.sh) || true

# Load Common Functions
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh" 2>/dev/null || \
  . <(wget -qO- 'https://vladgh.s3.amazonaws.com/functions/common.sh') || true

# NAME: loggly_config
# DESCRIPTION: Returns Loggly configuration
loggly_config(){
  local dist='41058'
  local url='logs-01.loggly.com'
  local port='514'
  cat << CFG
# Setup disk assisted queues
\$WorkDirectory /var/spool/rsyslog # where to place spool files
\$ActionQueueFileName fwdRule1     # unique name prefix for spool files
\$ActionQueueMaxDiskSpace 1g       # 1gb space limit (use as much as possible)
\$ActionQueueSaveOnShutdown on     # save messages to disk on shutdown
\$ActionQueueType LinkedList       # run asynchronously
\$ActionResumeRetryCount -1        # infinite retries if host is down

template(name="LogglyFormat" type="string"
 string="<%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [${token}@${dist} tag=\"${tag}\"] %msg%\n")

# Send messages to Loggly over TCP using the template.
action(type="omfwd" protocol="tcp" target="${url}" port="${port}" template="LogglyFormat")
CFG
}

# NAME: loggly_modify_config
# DESCRIPTION: Modifies RSysLog config (if necessary)
loggly_modify_config(){
  if [[ "$(cat "$conf")" == "$(loggly_config)" ]]; then
    echo 'Loggly configuration has not changed'
  else
    echo 'Modifying RSysLog config...'
    loggly_config | sudo tee "$conf" > /dev/null
    echo 'Restarting RSysLog'
    sudo restart rsyslog
  fi
}

# NAME: loggly_install
# DESCRIPTION: Installs Loggly
# USAGE: loggly_install {Authentication Token} {TAG}
# PARAMETERS:
#   1) The Loggly authentication token (required)
#   2) A tag to identify this log stream (optional)
loggly_install(){
  local token=$1
  local tag=${2:-$(hostname)}
  local conf='/etc/rsyslog.d/22-loggly.conf'
  if [[ -z "$token" ]]; then
    echo 'WARNING: Loggly will not be installed' \
      'because LOGGLY_TOKEN is not set!'
    return
  else
    loggly_modify_config
  fi
}
