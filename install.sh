#!/bin/bash

# 1. Install Fish if it's missing (optional, but good safety)
if ! command -v fish &> /dev/null; then
    echo "Fish not found. Installing..."
    sudo apt-get update && sudo apt-get install -y fish
fi

# 2. Get the directory where this script is running
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 3. Run the Fish configuration script using the LOCAL file
# We pass the directory path to the fish script so it knows where to find other files
echo "Running Fish configuration from $DOTFILES_DIR..."
fish "$DOTFILES_DIR/fish_remote_config.fish" "$DOTFILES_DIR
