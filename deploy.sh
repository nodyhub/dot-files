#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_FILE="dfiles.tar.gz"

# =========================================================
# 1. Initialize and Update Submodules
# =========================================================
echo "[+] Initializing and updating git submodules..."
cd "$BASEDIR"
git submodule update --init --recursive

# =========================================================
# 2. Define Symlink Function
# =========================================================
setup_symlinks() {
    local target_dir="$1"
    echo "[+] Setting up symlinks in $target_dir..."

    # Array of top-level files/folders to link
    local linkables=(
        ".dir_colors" ".tmux.conf" ".vimrc" ".zlogin" 
        ".zlogout" ".zprofile" ".zshrc" ".vim" ".zsh"
    )

    # Link top level files
    for item in "${linkables[@]}"; do
        # -s: symbolic, -f: force overwrite, -n: treat dest as normal file if it's a symlink to a dir
        ln -sfn "$BASEDIR/$item" "$target_dir/$item"
        echo "  -> Linked $item"
    done

    # Safely handle .config apps without overwriting the whole .config folder
    mkdir -p "$target_dir/.config"
    ln -sfn "$BASEDIR/.config/ghostty" "$target_dir/.config/ghostty"
    ln -sfn "$BASEDIR/.config/nvim" "$target_dir/.config/nvim"
    echo "  -> Linked .config apps"

    # Set up global Git hooks to use the tracked folder
    echo "[+] Configuring global Git hooks..."
    git config --global core.hooksPath "$BASEDIR/.githooks"

    # Disable "Last login" message
    touch "$target_dir/.hushlogin"
}

# =========================================================
# 3. Handle Remote Deployment
# =========================================================
if [ -f "$BASEDIR/remote-hosts" ]; then
    echo "[+] Packaging repo for remote deployment..."
    rm -f "$BASEDIR/$DOT_FILE"
    
    # Pack everything, following exclude.lst, but omit the .git directory to save space/bandwidth
    tar -czf "$BASEDIR/$DOT_FILE" --exclude-from="$BASEDIR/exclude.lst" --exclude=".git" -C "$BASEDIR" .

    echo "[+] Iterating over destinations in remote-hosts..."
    hosts=()
    while IFS='' read -r line || [[ -n "$line" ]]; do
        [[ ! -z "$line" ]] && hosts+=("$line")
    done < "$BASEDIR/remote-hosts"

    for host in "${hosts[@]}"; do
        echo "[+] Deploying to $host..."
        
        # Define the remote destination for the repo
        REMOTE_REPO_DIR="~/.dotfiles"
        
        # 1. Create the .dotfiles directory on remote
        ssh "$host" "mkdir -p $REMOTE_REPO_DIR"
        
        # 2. Copy the tarball over
        scp "$BASEDIR/$DOT_FILE" "$host:$REMOTE_REPO_DIR/$DOT_FILE"
        
        # 3. Extract, cleanup tarball, and run the symlink function via the copied deploy script
        # Note: We pass a flag '--remote-run' so the script knows to execute the symlinks on the remote
        ssh "$host" "cd $REMOTE_REPO_DIR && tar -xzf $DOT_FILE && rm $DOT_FILE && bash deploy.sh --remote-run"
        
        echo "[+] Successfully deployed and linked on $host."
    done

    # Clean up local tarball after pushing
    rm -f "$BASEDIR/$DOT_FILE"
fi

# =========================================================
# 4. Handle Local Deployment Execution
# =========================================================
if [[ "$1" == "--remote-run" ]]; then
    # If this script was triggered by the SSH command above, just run the links
    setup_symlinks "$HOME"
else
    # If run normally on your machine, deploy locally
    echo "[+] Deploying locally..."
    setup_symlinks "$HOME"
    echo "[+] Local deployment finished successfully!"
fi

exit 0