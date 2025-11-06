# Git related functions and variables

# Cache variables for git status
ZSH_GIT_BRANCH=""
ZSH_GIT_DIRTY=0
ZSH_GIT_LAST_WORKING_DIR=""
ZSH_GIT_LAST_CHECK_TIME=0

# Clear git cache when directory changes or after a timeout
function zsh_git_invalidate_cache() {
  ZSH_GIT_BRANCH=""
  ZSH_GIT_DIRTY=0
}

# Hook to auto-update git info when directory changes
autoload -Uz add-zsh-hook
add-zsh-hook chpwd zsh_git_invalidate_cache

# Get git branch name with caching for performance
function git_branch_name () {
  local current_dir=$(pwd)
  local current_time=$(date +%s)
  
  # Check if we need to refresh the git info
  # Refresh if: directory changed, or 30 seconds elapsed since last check
  if [[ "$current_dir" != "$ZSH_GIT_LAST_WORKING_DIR" ]] || \
     [[ $(($current_time - $ZSH_GIT_LAST_CHECK_TIME)) -gt 30 ]]; then
  
    # Check if we're in a git repo
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      # Get branch name or commit hash
      ZSH_GIT_BRANCH=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git show -s --format=%h 2>/dev/null)
      
      # Check for dirty status - much faster than git diff --stat
      if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
        ZSH_GIT_DIRTY=1
      else
        ZSH_GIT_DIRTY=0
      fi
    else
      # Not in a git repo
      ZSH_GIT_BRANCH=""
      ZSH_GIT_DIRTY=0
    fi
    
    # Update cache metadata
    ZSH_GIT_LAST_WORKING_DIR="$current_dir"
    ZSH_GIT_LAST_CHECK_TIME=$current_time
  fi
  
  # Display branch info from cache
  if [[ -n "$ZSH_GIT_BRANCH" ]]; then
    if [[ "$ZSH_GIT_DIRTY" -eq 0 ]]; then
      echo -n "($ZSH_GIT_BRANCH)"
    else
      echo -n "($ZSH_GIT_BRANCH*)"
    fi
  fi
}

# More efficient git status update using proper caching
# We don't need true async for this - just efficient caching
function precmd_update_git_vars() {
  # Update git vars only when needed, not on every prompt
  local current_dir=$(pwd)
  local current_time=$(date +%s)
  
  # Skip update if we're not in a git repo (fast check)
  if [[ ! -d .git ]] && ! git rev-parse --git-dir &>/dev/null; then
    ZSH_GIT_BRANCH=""
    ZSH_GIT_DIRTY=0
    return
  fi
  
  # Check if we need to refresh: new dir or cache expired (5 sec)
  if [[ "$current_dir" != "$ZSH_GIT_LAST_WORKING_DIR" || \
        $(( current_time - ZSH_GIT_LAST_CHECK_TIME )) -gt 5 ]]; then
    
    # Get branch name efficiently (single git call)
    ZSH_GIT_BRANCH=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || \
                     git rev-parse --short HEAD 2>/dev/null)
    
    # Fast dirty check (no submodule status)
    if [[ -z "$(git status --porcelain -uno 2>/dev/null)" ]]; then
      ZSH_GIT_DIRTY=0
    else
      ZSH_GIT_DIRTY=1
    fi
    
    # Update cache
    ZSH_GIT_LAST_WORKING_DIR="$current_dir"
    ZSH_GIT_LAST_CHECK_TIME=$current_time
  fi
}

# Add the precmd hook to update git vars
autoload -Uz add-zsh-hook
add-zsh-hook precmd precmd_update_git_vars

# Open GitHub repository in browser
function ghopen() {
  REMOTE_ORIGIN_URL=$(git config remote.origin.url | sed "s/\.git$//")

  # Get remote url
  case $REMOTE_ORIGIN_URL in
    *"@"*)
      URL="https://github.com/$(echo -n $REMOTE_ORIGIN_URL | cut -d ":" -f 2 | cut -d "." -f 1)"
      ;;
    "")
      echo "Not in GitHub repo"
      return 0
      ;;
    *)
      URL=$REMOTE_ORIGIN_URL
  esac

  # branch or hash
  case "$(git symbolic-ref --quiet --short HEAD)" in
    "")
      BOC=$(git show -s --format=%H)
      ;;
    *)
      BOC=$(git symbolic-ref --quiet --short HEAD)
      ;;
  esac

  URL="$URL/tree/$BOC/$(git rev-parse --show-prefix)"
  echo "Opening $URL"
  open $URL
}

# Open GitHub PR in browser
function ghpr() {
   # Get PR ID
   PR_ID=$(git ls-remote origin 'pull/*/head' | grep -F -f <(git rev-parse HEAD) | awk -F'/' '{print $3}' 2>&1)
   if [[ -z "$PR_ID" ]]; then
      echo "No PR found"
      return 0
   fi

  # Get remote url
  REMOTE_ORIGIN_URL=$(git config remote.origin.url | sed "s/\.git$//")
  case $REMOTE_ORIGIN_URL in
    *"@"*)
      URL="https://github.com/$(echo -n $REMOTE_ORIGIN_URL | cut -d ":" -f 2 | cut -d "." -f 1)"
      ;;
    "")
      echo "Not in GitHub repo"
      return 0
      ;;
    *)
      URL=$REMOTE_ORIGIN_URL
  esac
  URL="$URL/pull/$PR_ID"

  echo "Opening $URL"
  open $URL
}

# Export GitHub token
function export_github_token() {
  local token_type=${1:-user}
  local token_file=~/.ssh/github_token_$token_type
  
  if [[ -f $token_file ]]; then
    export GITHUB_TOKEN=$(cat $token_file)
    echo "GITHUB_TOKEN loaded from $token_file"
  else
    echo "GITHUB_TOKEN not found in $token_file"
  fi
}