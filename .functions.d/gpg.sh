#!/usr/bin/env bash
# Miscellaneous GPG Functions

# Load GPG Agent
gpg_agent_load(){
  # Do not load if the agent is not installed
  if ! is_cmd gpg-agent; then return; fi

  # Do not load if gpg-connect-agent is not installed
  if ! is_cmd gpg-connect-agent; then return; fi

  # Do not load if gpg-connect-agent is not installed
  if ! is_cmd gpgconf; then return; fi

  # GPG TTY Settings
  GPG_TTY="$(tty)"; export GPG_TTY
  gpg-connect-agent updatestartuptty /bye >/dev/null

  # Start the agent
  gpgconf --launch gpg-agent
}

# Unload GPG Agent
gpg_agent_unload(){
  gpgconf --kill gpg-agent
}

# Restart GPG Agent
gpg_agent_restart(){
  echo 'Stopping GPG Agent...'
  gpg_agent_unload
  echo 'Starting GPG Agent...'
  gpg_agent_load
}

# Reload GPG Agent
gpg_agent_reload(){
  echo 'Reloading GPG Agent...'
  gpgconf --reload gpg-agent
}

# Test encryption and decryption of phrase
gpg_agent_test(){
  echo 'hello world' | gpg -e -r "$(whoami)" | gpg -d
}
