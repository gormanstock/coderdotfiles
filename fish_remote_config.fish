# --- START: OH MY FISH (OMF) SETUP ---

# Check if the Oh My Fish directory exists
if not test -d "$HOME/.local/share/omf"
    echo "Oh My Fish not found. Attempting installation using temporary file..."
    
    if command -q curl
        
        # 1. Download the OMF installer script to a temp file
        set -l omf_installer_url "https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install"
        set -l temp_install_script "/tmp/omf_install.fish"
        
        echo "Downloading OMF installer..."
        # Use -L to follow redirects, and -o to save the output to the temp file
        curl -sS -L -o $temp_install_script $omf_installer_url

        if test -s $temp_install_script
            echo "OMF installer downloaded. Running installation..."
            
            # 2. Execute the installer script using 'fish'
            # Note: The OMF install script is meant to be executed directly, not sourced,
            # so we run it as a separate fish process.
            fish $temp_install_script
            
            # 3. Clean up the temporary file
            rm $temp_install_script 2>/dev/null
            
            echo "Oh My Fish installation initiated. Please run the setup command again to ensure theme/config is applied after installation is complete."
        else
            echo "Error: Failed to download the OMF installer script."
        end
    else
        echo "Error: 'curl' command not found. Cannot install Oh My Fish."
    end
    
else
    # ... (Rest of your script for theme/config execution remains here)
    # ... (Theme and Configuration Block)
    
    echo "Oh My Fish found."
    
    # Source OMF init script if available, to make 'omf' command available
    set -l omf_init_path "$HOME/.local/share/omf/init.fish"
    if test -f "$omf_init_path"
        source "$omf_init_path"
    end
    
    echo "Installing 'bobthefish' theme..."
    omf install bobthefish
    
    echo "Setting bobthefish configurations..."
    set -g theme_nerd_fonts yes
    set -g theme_color_scheme nord
    
    echo "OMF configuration complete."
    
end
# --- END: OH MY FISH (OMF) SETUP ---
