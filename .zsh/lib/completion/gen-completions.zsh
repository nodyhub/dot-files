# Completion cache generator
#
# Generates static completion files from dynamic CLI tools and stores them
# in ~/.zsh/completions/. These are picked up by compinit via fpath.
#
# Requires: tools.zsh to be sourced first (provides COMPLETION_TOOLS array)

COMPLETION_CACHE_DIR="${HOME}/.zsh/completions"
COMPLETION_CACHE_MAX_AGE_DAYS=7

# Ensure the cache directory exists
[[ -d "$COMPLETION_CACHE_DIR" ]] || mkdir -p "$COMPLETION_CACHE_DIR"

# Generate or regenerate cached completion files.
# Only processes tools that are installed and whose cache is missing or stale.
# Args:
#   --force   Regenerate all completions regardless of age
_zsh_gen_completions() {
  local force=0
  [[ "${1:-}" = "--force" ]] && force=1

  # Ensure registry is loaded
  if (( ! ${#COMPLETION_TOOLS[@]} )); then
    echo "No tools registered in COMPLETION_TOOLS." >&2
    return 1
  fi

  local tool cmd cache_file regenerated=0 skipped=0 missing=0

  for tool cmd in "${(@kv)COMPLETION_TOOLS}"; do
    cache_file="${COMPLETION_CACHE_DIR}/_${tool}"

    # Skip if binary is not available
    if ! (( ${+commands[$tool]} )); then
      (( missing++ ))
      continue
    fi

    # Skip if cache exists and is fresh (unless --force)
    if [[ $force -eq 0 && -f "$cache_file" ]]; then
      # Check if file is younger than max age
      if [[ -z ${cache_file}(#qN.md+${COMPLETION_CACHE_MAX_AGE_DAYS}) ]]; then
        (( skipped++ ))
        continue
      fi
    fi

    # Generate completion to a temp file first to avoid partial writes
    local tmpfile="${cache_file}.tmp.$$"
    if eval "$cmd" > "$tmpfile" 2>/dev/null; then
      if [[ -s "$tmpfile" ]]; then
        mv -f "$tmpfile" "$cache_file"
        (( regenerated++ ))
      else
        # Command succeeded but output was empty
        rm -f "$tmpfile"
      fi
    else
      rm -f "$tmpfile"
    fi
  done

  # Clean up completions for tools that are no longer installed
  for cache_file in "${COMPLETION_CACHE_DIR}"/_*(N); do
    local name="${${cache_file:t}#_}"
    if (( ${+COMPLETION_TOOLS[$name]} )) && ! (( ${+commands[$name]} )); then
      rm -f "$cache_file"
    fi
  done

  if [[ -t 1 ]]; then
    echo "Completions: ${regenerated} generated, ${skipped} fresh, ${missing} not installed."
  fi
}

# Run a background staleness check (called async after first prompt)
_zsh_regen_completions_bg() {
  _zsh_gen_completions &>/dev/null &!
}

# User-facing command
zsh-regen-completions() {
  echo "Regenerating all completions (forced)..."
  _zsh_gen_completions --force
  echo "Restart your shell or run 'compinit' to pick up changes."
}
