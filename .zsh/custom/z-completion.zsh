# z completion setup - automatically generated
# This file runs after compinit to ensure completions work correctly

# Add plugin directory to fpath if not already there
if [[ -d "${ZSH:-$HOME/.zsh}/plugins/zsh-z" ]]; then
  fpath=("${ZSH:-$HOME/.zsh}/plugins/zsh-z" $fpath)
fi

# Load the completion function
autoload -Uz _zshz 2>/dev/null || true

# Register the completion with compdef
(( $+functions[compdef] )) && compdef _zshz ${ZSHZ_CMD:-${_Z_CMD:-z}} 2>/dev/null || true
