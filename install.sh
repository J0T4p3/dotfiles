#!/bin/bash

# Get the absolute path of the current directory (where this script lives)
DOTFILES_DIR=$(pwd)

# Create config directory if it doesn't exist
mkdir -p ~/.config

# Create symlinks using absolute paths
ln -sfn "$DOTFILES_DIR/nvim" ~/.config/nvim
ln -sfn "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf

echo "Dotfiles symlinked from $DOTFILES_DIR"
