# Load Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Load .aliases
# shellcheck disable=1090
if [[ -s "${HOME}/.zshrc" ]]; then
  . "${HOME}/.zshrc"
fi
