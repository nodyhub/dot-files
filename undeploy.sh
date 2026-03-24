#!/usr/bin/env bash

echo "🧹 Cleaning up dotfile symlinks from home directory..."

# 1. Remove the top-level symlinks and .hushlogin
# NOTE: Do NOT use a trailing slash on directories like .vim or .zsh
# `rm ~/.zsh` deletes the symlink. `rm -rf ~/.zsh/` would delete the contents!
rm -f ~/.dir_colors \
      ~/.tmux.conf \
      ~/.vimrc \
      ~/.zlogin \
      ~/.zlogout \
      ~/.zprofile \
      ~/.zshrc \
      ~/.vim \
      ~/.zsh \
      ~/.hushlogin

# 2. Remove the .config app symlinks
rm -f ~/.config/ghostty ~/.config/nvim

# 3. Unset the global Git hooks path
echo "🔄 Reverting global Git hooks configuration..."
git config --global --unset core.hooksPath

echo "✅ Revert complete! Your home directory is clean."