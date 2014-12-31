# Load environment variables
[[ -s $HOME/.vlad ]] && source $HOME/.vlad

# System functions and aliases
[[ -s $HOME/.functions ]] && source $HOME/.functions
[[ -s $HOME/.aliases ]] && source $HOME/.aliases
[[ -s $HOME/.osx ]] && source $HOME/.osx

# Load bash
[[ -s $HOME/.profile ]] && source $HOME/.profile
[[ -s $HOME/.bashrc ]] && source $HOME/.bashrc

# vim: ft=sh
