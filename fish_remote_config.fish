# --- START: OH MY FISH (OMF) SETUP ---

# Check if the Oh My Fish directory exists
if not test -d "$HOME/.local/share/omf"
    echo "Oh My Fish not found. Attempting to install..."
    
    # Use the standard curl install method for robustness
    if command -q curl
        echo "Running OMF standard installation..."
        curl -L https://get.oh-my.fish | fish
        echo "Oh My Fish installation initiated. Please run the setup command again to apply themes."
    else
        echo "Error: 'curl' command not found. Cannot install Oh My Fish."
    end
    
else
    echo "Oh My Fish found."
    
    # Source OMF init script if available, to make 'omf' command available
    set -l omf_init_path "$HOME/.local/share/omf/init.fish"
    if test -f "$omf_init_path"
        source "$omf_init_path"
    end
    
    echo "Installing 'bobthefish' theme..."
    
    # 1. Install bobthefish theme
    omf install bobthefish
    
    # 2. Set theme configurations (will automatically save to $HOME/.config/fish/config.fish)
    echo "Setting bobthefish configurations (Nerd Fonts and Nord color scheme)..."
    set -g theme_nerd_fonts yes
    set -g theme_color_scheme nord
    
    echo "OMF configuration complete."
    
end

# --- END: OH MY FISH (OMF) SETUP ---

# --- START: LAZYGIT SETUP ---

echo ""
echo "--- Lazygit Setup ---"

# 1. Check if lazygit is already installed and runnable
if command -q lazygit
    echo "Lazygit is already installed."
else
    echo "Lazygit not found. Attempting user-local installation..."
    
    # Ensure the local bin directory exists and is in the PATH
    set -l local_bin "$HOME/.local/bin"
    if not test -d "$local_bin"
        mkdir -p "$local_bin"
    end
    if not contains "$local_bin" $fish_user_paths
        set -U fish_user_paths $fish_user_paths "$local_bin"
        echo "Added $local_bin to your PATH for persistence."
    end

    # 2. Get the latest version tag from GitHub API
    echo "Fetching latest Lazygit version..."
    set LAZYGIT_VERSION (curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -oP '"tag_name": "v\K[^"]*')
    
    if test -z "$LAZYGIT_VERSION"
        echo "Error: Could not determine latest Lazygit version. Installation aborted."
    else
        echo "Found version: v$LAZYGIT_VERSION"
        set -l LAZYGIT_DOWNLOAD_URL "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_"$LAZYGIT_VERSION"_Linux_x86_64.tar.gz"
        
        # 3. Download the tarball to a temporary location
        echo "Downloading Lazygit from $LAZYGIT_DOWNLOAD_URL"
        curl -Lo /tmp/lazygit.tar.gz "$LAZYGIT_DOWNLOAD_URL"
        
        # 4. Extract the binary
        echo "Extracting binary..."
        # tar xf /tmp/lazygit.tar.gz lazygit
        tar -xzf /tmp/lazygit.tar.gz -C /tmp # Extract all contents to /tmp
        
        # 5. Install the binary to the local bin path
        # Note: If you have write access to /usr/local/bin and can use sudo, replace this line:
        # sudo install /tmp/lazygit -D -t /usr/local/bin/
        
        # This is the user-local installation:
        if test -f /tmp/lazygit
            install /tmp/lazygit "$local_bin"
            echo "Lazygit installed successfully to $local_bin/lazygit"
        else
            echo "Error: Lazygit binary not found after extraction. Check download URL."
        end

        # 6. Clean up
        rm /tmp/lazygit.tar.gz /tmp/lazygit 2>/dev/null
    end
end

echo ""
echo "🎉 Remote environment personalized and ready! Run 'lazygit' to start."

# --- END: LAZYGIT SETUP ---
