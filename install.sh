#!/bin/bash

# 1. Install Fish if it's missing
if ! command -v fish &> /dev/null; then
    echo "Fish not found. Installing..."
    sudo apt-get update && sudo apt-get install -y fish
fi

# 2. Get the current directory (Simpler method)
DOTFILES_DIR=$(dirname "$0")
DOTFILES_DIR=$(cd "$DOTFILES_DIR" && pwd)

# 3. Run the Fish configuration
echo "Running Fish configuration from $DOTFILES_DIR..."
fish "$DOTFILES_DIR/fish_remote_config.fish" "$DOTFILES_DIR"
