# Load Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Load .aliases
# shellcheck disable=1090
if [[ -s "${HOME}/.zshrc" ]]; then
  . "${HOME}/.zshrc"
fi
