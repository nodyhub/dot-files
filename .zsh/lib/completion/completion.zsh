# ZSH Completion configuration - Optimized for performance
#
# How it works:
#   1. Static completion files from package managers are picked up via fpath
#      automatically (Homebrew, apt, system zsh, etc.)
#   2. Dynamic completions (Cobra-style CLIs like kubectl, helm, ...) are
#      generated once, cached as static files in ~/.zsh/completions/, and
#      picked up via fpath. A background job checks for stale caches.
#   3. To add/remove tools, edit: ~/.zsh/lib/completion/tools.zsh
#   4. To force-regenerate all: run `zsh-regen-completions`

# --- Directories -----------------------------------------------------------
[[ -d ~/.zsh/cache ]] || mkdir -p ~/.zsh/cache
[[ -d ~/.zsh/completions ]] || mkdir -p ~/.zsh/completions

# --- fpath: add cached completions + platform completion dirs --------------
# Custom cached completions (generated from tools.zsh registry)
fpath=(~/.zsh/completions $fpath)

# Platform-specific system completion directories
local _comp_dirs=(
  /usr/share/zsh/vendor-completions        # Debian/Ubuntu
  /usr/share/zsh/site-functions             # Fedora/Arch/generic Linux
  /usr/local/share/zsh/site-functions       # macOS Intel Homebrew / FreeBSD
  /opt/homebrew/share/zsh/site-functions    # macOS Apple Silicon Homebrew
)
for _d in "${_comp_dirs[@]}"; do
  # Add only if directory exists and isn't already in fpath
  if [[ -d "$_d" ]] && (( ! ${fpath[(Ie)$_d]} )); then
    fpath=("$_d" $fpath)
  fi
done
unset _d _comp_dirs

# --- compinit --------------------------------------------------------------
ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zsh/cache/zcompdump-${HOST}-${ZSH_VERSION}"

if [[ "$_COMPINIT_LOADED" != "true" ]]; then
  autoload -Uz compinit

  # Full rebuild if dump is older than 24 hours, otherwise use cache
  if [[ -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
    compinit -d "$ZSH_COMPDUMP"
  else
    compinit -C -d "$ZSH_COMPDUMP"
  fi

  export _COMPINIT_LOADED="true"
fi

# --- promptinit ------------------------------------------------------------
if [[ "$_PROMPTINIT_LOADED" != "true" ]]; then
  autoload -U promptinit
  promptinit
  export _PROMPTINIT_LOADED="true"
fi

# --- Completion styles -----------------------------------------------------
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:commands' rehash 1

# --- bashcompinit (needed for terraform-style completions) -----------------
if [[ "$_BASH_COMPLETION_LOADED" != "true" ]]; then
  autoload -U +X bashcompinit && bashcompinit
  export _BASH_COMPLETION_LOADED="true"
fi

# --- Load tools registry and generator, then schedule background regen -----
source "${0:A:h}/tools.zsh"
source "${0:A:h}/gen-completions.zsh"

# After the first prompt is drawn, check for stale completions in background
_zsh_completion_precmd_hook() {
  _zsh_regen_completions_bg
  # Remove hook after first run — only need to trigger once per session
  add-zsh-hook -d precmd _zsh_completion_precmd_hook
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_completion_precmd_hook

# --- z plugin completion ---------------------------------------------------
if [[ -d "${ZSH:-$HOME/.zsh}/plugins/zsh-z" && ! -f "${ZSH:-$HOME/.zsh}/custom/z-completion.zsh" ]]; then
  mkdir -p "${ZSH:-$HOME/.zsh}/custom"
  cat > "${ZSH:-$HOME/.zsh}/custom/z-completion.zsh" <<EOT
# z completion setup - automatically generated
if [[ -d "\${ZSH:-\$HOME/.zsh}/plugins/zsh-z" ]]; then
  fpath=("\${ZSH:-\$HOME/.zsh}/plugins/zsh-z" \$fpath)
fi
autoload -Uz _zshz 2>/dev/null || true
(( \$+functions[compdef] )) && compdef _zshz \${ZSHZ_CMD:-\${_Z_CMD:-z}} 2>/dev/null || true
EOT
fi