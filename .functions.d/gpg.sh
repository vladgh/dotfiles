#!/usr/bin/env bash
# Miscellaneous GPG Functions

# Load GPG Agent
gpg_agent_load(){
  # Do not load if the agent is not installed
  if ! is_cmd gpg-agent; then return; fi

  # Pin entry program
  if is_osx; then
    pin_entry='/usr/local/bin/pinentry-mac'
  elif is_ubuntu; then
    pin_entry='/usr/bin/pinentry-gtk-2'
  fi

  # shellcheck disable=1090
  eval "$(gpg-agent --daemon --log-file /tmp/gpg.log --pinentry-program ${pin_entry})"
  export GPG_TTY; GPG_TTY=$(tty)
}

# Unload GPG Agent
gpg_agent_unload(){
  unset GPG_AGENT_INFO GPG_TTY
  [ -f ~/.gnupg/gpg-agent.env ] && rm ~/.gnupg/gpg-agent.env
  sudo killall gpg-agent
}

# Reload GPG Agent
gpg_agent_reload(){
  echo 'Stopping GPG Agent...'
  gpg_agent_unload
  echo 'Starting GPG Agent...'
  gpg_agent_load
}

# Test encryption and decryption of phrase
gpg_agent_test(){
  echo 'hello world' | gpg -e -r "$(whoami)" | gpg -d
}
