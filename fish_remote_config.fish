# This script is designed for single-run execution via:
# curl -sS -o /tmp/remote_config.fish YOUR_RAW_FISH_CONFIG_URL
# source /tmp/remote_config.fish

echo "--- Starting Remote Fish Configuration Setup ---"
echo ""

# --- START: OH MY FISH (OMF) SETUP ---

# Check if the Oh My Fish directory exists
if not test -d "$HOME/.local/share/omf"
    echo "Oh My Fish not found. Attempting manual installation..."
    
    if command -q git
        set -l temp_omf_dir "/tmp/oh-my-fish-temp"
        set -l omf_install_bin "$temp_omf_dir/bin/install"

        # 1. Clone the repository to a temporary location
        echo "Cloning OMF repository to $temp_omf_dir..."
        # Use 2>/dev/null to suppress common git output that might confuse the user
        git clone https://github.com/oh-my-fish/oh-my-fish $temp_omf_dir 2>/dev/null

        if test -d $temp_omf_dir
            # 2. Run the install script from the cloned repo
            echo "Running OMF install script..."
            # Use --offline to avoid external downloads, and run directly
            fish $omf_install_bin --offline
            
            # 3. Clean up the temporary clone directory
            rm -rf $temp_omf_dir
            
            echo "Oh My Fish installation initiated. Run this setup command again to apply the theme and config."
        else
            echo "Error: Failed to clone the OMF repository."
        end
    else
        echo "Error: 'git' command not found. Cannot install Oh My Fish."
    end
    
else
    # --- (OMF Found Block - Run on second execution) ---
    echo "Oh My Fish found. Proceeding with theme and config setup."
    
    # Source OMF init script if available, to make 'omf' command available
    set -l omf_init_path "$HOME/.local/share/omf/init.fish"
    if test -f "$omf_init_path"
        source "$omf_init_path"
    end
    
    echo "Installing 'bobthefish' theme..."
    omf install bobthefish 2>/dev/null
    
    # Set theme configurations (will automatically save to $HOME/.config/fish/config.fish)
    echo "Setting bobthefish configurations (Nerd Fonts and Nord color scheme)..."
    set -g theme_nerd_fonts yes
    set -g theme_color_scheme nord
    
    echo "OMF configuration complete."
    
end

# --- END: OH MY FISH (OMF) SETUP ---

echo "--------------------------------------------------------"

# --- START: LAZYGIT SETUP ---

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
    # Ensure this path is in the user's permanent path list
    if not contains "$local_bin" $fish_user_paths
        set -U fish_user_paths $fish_user_paths "$local_bin"
        echo "Added $local_bin to your PATH for persistence."
    end

    echo "Fetching latest Lazygit version..."
    set LAZYGIT_VERSION (curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -oP '"tag_name": "v\K[^"]*')
    
    if test -z "$LAZYGIT_VERSION"
        echo "Error: Could not determine latest Lazygit version. Installation aborted."
    else
        echo "Found version: v$LAZYGIT_VERSION"
        set -l LAZYGIT_DOWNLOAD_URL "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_"$LAZYGIT_VERSION"_Linux_x86_64.tar.gz"
        
        # 2. Download the tarball to a temporary location using -o
        echo "Downloading Lazygit..."
