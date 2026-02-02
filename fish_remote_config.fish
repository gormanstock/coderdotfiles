# This script is designed for single-run execution via:
# curl -sS -o /tmp/remote_config.fish YOUR_RAW_FISH_CONFIG_URL
# source /tmp/remote_config.fish
# Capture the argument passed from install.sh (the repo path)
set -l DOTFILES_REPO_PATH $argv[1]

echo "--- Starting Remote Fish Configuration Setup ---"
echo ""

# 🐠 Oh My Fish (OMF) Setup
# --------------------------------------------------------

# Define the expected OMF data directory explicitly
set -l OMF_DATA_DIR "$HOME/.local/share/omf"
set -l OMF_CONFIG_DIR "$HOME/.config/omf"
set -l config_file "$HOME/.config/fish/config.fish"
set -l omf_init_path "$OMF_DATA_DIR/init.fish"

# 1. Install OMF (Direct Clone Method)
if not test -d "$OMF_DATA_DIR"
    echo "Oh My Fish not found. Bootstrapping via direct clone..."
    
    if not command -q git
        echo "Error: 'git' command not found. Cannot install Oh My Fish."
        exit 1
    end

    if not test -d "$OMF_CONFIG_DIR"
        mkdir -p "$OMF_CONFIG_DIR"
        echo "default" > "$OMF_CONFIG_DIR/theme"
    end

    echo "Cloning OMF repository..."
    git clone --depth 1 https://github.com/oh-my-fish/oh-my-fish "$OMF_DATA_DIR"

    if test $status -eq 0
        echo "OMF Core cloned successfully."
    else
        echo "Error: Git clone failed."
        exit 1
    end
else
    echo "OMF directory found. Skipping install."
end

# 🐠 Oh My Fish (OMF) Setup
# --------------------------------------------------------

# Define the expected OMF data directory explicitly
set -l OMF_DATA_DIR "$HOME/.local/share/omf"
set -l OMF_CONFIG_DIR "$HOME/.config/omf"
set -l config_file "$HOME/.config/fish/config.fish"
set -l omf_init_path "$OMF_DATA_DIR/init.fish"

# 1. Install OMF (Direct Clone Method)
if not test -d "$OMF_DATA_DIR"
    echo "Oh My Fish not found. Bootstrapping via direct clone..."
    
    if not command -q git
        echo "Error: 'git' command not found. Cannot install Oh My Fish."
        exit 1
    end

    if not test -d "$OMF_CONFIG_DIR"
        mkdir -p "$OMF_CONFIG_DIR"
        echo "default" > "$OMF_CONFIG_DIR/theme"
    end

    echo "Cloning OMF repository..."
    git clone --depth 1 https://github.com/oh-my-fish/oh-my-fish "$OMF_DATA_DIR"

    if test $status -eq 0
        echo "OMF Core cloned successfully."
    else
        echo "Error: Git clone failed."
        exit 1
    end
else
    echo "OMF directory found. Skipping install."
end

# 2. Configure OMF
if test -f "$omf_init_path"
    echo "Initializing Oh My Fish from $omf_init_path..."

    # Set OMF paths as Global variables so the script sees them right now
    set -gx OMF_PATH "$OMF_DATA_DIR"
    set -gx OMF_CONFIG "$OMF_CONFIG_DIR"

    # Manually source the library that defines 'require' (For this script's session)
    if test -f "$OMF_PATH/lib/require.fish"
        source "$OMF_PATH/lib/require.fish"
    end

    # Source the main init file
    source "$omf_init_path"

    # 3. Verify 'omf' command loaded
    if functions -q omf
        echo "OMF command loaded successfully."

        # Install Theme
        echo "Installing 'bobthefish' theme..."
        omf install bobthefish 2>/dev/null

        # --- CRITICAL FIX: Ensure OMF loads correctly in future sessions ---
        # We must define OMF_PATH in config.fish BEFORE sourcing init.fish
        if not grep -q "set -gx OMF_PATH" "$config_file"
            echo "Adding OMF startup code to config.fish..."
            
            # We append the robust startup block
            echo "" >> "$config_file"
            echo "# Path to Oh My Fish install." >> "$config_file"
            echo "set -gx OMF_PATH \"$OMF_DATA_DIR\"" >> "$config_file"
            echo "set -gx OMF_CONFIG \"$OMF_CONFIG_DIR\"" >> "$config_file"
            echo "source \"\$OMF_PATH/init.fish\"" >> "$config_file"
        end
        # ---------------------------------------------------------

        echo "Writing theme activation commands to $config_file..."
        set -l config_updated false

        # Define theme variables
        set -l theme_commands \
            "set -g theme_nerd_fonts yes" \
            "set -g theme_color_scheme nord" \
            "set -g theme_show_project_parent no" \
            "set -g theme_display_user no"   \
            "set -g theme_display_hostname no" \
            "set -g theme_display_ruby no"

        for command_to_add in $theme_commands
            if not grep -qF "$command_to_add" "$config_file"
                echo "$command_to_add" >> "$config_file"
                set config_updated true
            end
        end

        if $config_updated
            echo "Theme configurations added to config.fish."
        end
        
        # Source config.fish to apply changes
        source "$config_file"
        echo "OMF configuration loaded."
    else
        echo "⚠️  Error: 'omf' function not found after sourcing init.fish."
    end
else
    echo "⚠️  OMF init file not found at $omf_init_path."
end

# --------------------------------------------------------
# 💻 Lazygit Setup
# --------------------------------------------------------

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
        curl -Lo /tmp/lazygit.tar.gz "$LAZYGIT_DOWNLOAD_URL"
        
        # 3. Extract the binary
        echo "Extracting binary..."
        tar -xzf /tmp/lazygit.tar.gz -C /tmp
        
        # 4. Install the binary to the local bin path
        if test -f /tmp/lazygit
            install /tmp/lazygit "$local_bin"
            echo "Lazygit installed successfully to $local_bin/lazygit"
        else
            echo "Error: Lazygit binary not found after extraction."
        end

        # 5. Clean up
        rm /tmp/lazygit.tar.gz /tmp/lazygit 2>/dev/null
    end
end

# --------------------------------------------------------
# ⚙️ Lazygit Config (Updated for Local Repo)
# --------------------------------------------------------
echo "Updating Lazygit configuration..."

set -l lazygit_config_dir "$HOME/.config/lazygit"
set -l lazygit_target_file "$lazygit_config_dir/config.yml"
set -l lazygit_source_file "lazygit_config.yml"

# Ensure config directory exists
if not test -d "$lazygit_config_dir"
    mkdir -p "$lazygit_config_dir"
end

# Check if we are running from the cloned repo (Local Mode)
if test -n "$DOTFILES_REPO_PATH"; and test -f "$DOTFILES_REPO_PATH/$lazygit_source_file"
    echo "🔗 Symlinking local Lazygit config..."
    ln -sf "$DOTFILES_REPO_PATH/$lazygit_source_file" "$lazygit_target_file"

# Fallback: If running via curl (Remote Mode), download the file
else
    echo "☁️ Downloading Lazygit config from GitHub..."
    curl -sL -o "$lazygit_target_file" "https://raw.githubusercontent.com/gormanstock/coderdotfiles/main/lazygit_config.yml"
end

echo "Lazygit config updated."

# --------------------------------------------------------
# 🛠️ Fish Alias & Git Configuration
# --------------------------------------------------------

echo "--- Fish Alias & Git Configuration Setup ---"

# 1. Add the persistent fish alias
echo "Setting persistent fish alias: gitcommands -> 'git config --list --show-origin'"

# FIXED: Direct config.fish write for alias persistence
set -l alias_definition "alias gitcommands='git config --list --show-origin'"

# Check if the alias already exists in the config file before appending
if not grep -qF "$alias_definition" "$config_file" 
    echo $alias_definition >> "$config_file"
    echo "Alias added to config.fish for persistence."
    set config_updated true
else
    echo "Alias already exists in config.fish."
end


# 2. Apply all Git configuration settings using `git config --global`

# Core settings
git config --global core.editor 'code --wait'
git config --global pull.rebase false 
git config --global merge.conflictstyle diff3
git config --global rebase.instructionFormat '"(%an <%ae>) %s"'

# Credential helper
git config --global credential.helper '/usr/bin/gp credential-helper'

# LFS filter
git config --global filter.lfs.clean 'git-lfs clean -- %f'
git config --global filter.lfs.smudge 'git-lfs smudge -- %f'
git config --global filter.lfs.process 'git-lfs filter-process'
git config --global filter.lfs.required true

# Push and Help
git config --global push.default simple
git config --global help.autocorrect 20

# Aliases
git config --global alias.fixup '!git add . && git commit --fixup=${1:-$(git rev-parse HEAD)} && GIT_EDITOR=true git rebase --interactive --autosquash ${1:-$(git rev-parse HEAD~2)}~1'
git config --global alias.fileschanged 'diff HEAD^ HEAD --name-only'
git config --global alias.fc 'diff --name-only HEAD~1 HEAD'
git config --global alias.to 'commit -a --amend --no-edit'
git config --global alias.tackon 'commit -a --amend --no-edit'
git config --global alias.st 'status'
git config --global alias.dt 'difftool HEAD^ HEAD --no-prompt'
git config --global alias.temp 'checkout temp'
git config --global alias.sd 'branch --delete'
git config --global alias.safedelete 'branch --delete'
git config --global alias.sami 'clean -dn'
git config --global alias.druggedfox 'clean -df'
git config --global alias.morning 'commit -a'
git config --global alias.remessage 'commit --amend'
git config --global alias.rip '!git reset HEAD~1 $1' 
git config --global alias.ripout '!git reset HEAD~1 $1 && git checkout -- .'
git config --global alias.ro 'reset HEAD~1'
git config --global alias.nored 'checkout -- .'
git config --global alias.nogreen 'reset HEAD .'
git config --global alias.lg 'log --color --graph --pretty=format:%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset --abbrev-commit'
git config --global alias.cane 'commit --amend --no-edit'
git config --global alias.cod 'checkout `git branch --contains HEAD --no-merged | head -1`'
git config --global alias.fcs 'diff --name-only'
git config --global alias.us 'submodule update --recursive --remote'
git config --global alias.updatesubmodules 'submodule update --recursive --remote'

echo "All Git configurations applied to $HOME/.gitconfig."

# 3. Source the config file if any change was made (resourcing the config.fish file)
if set -q config_updated
    echo "Sourcing updated config.fish to apply changes to the current session."
    source "$config_file"
    echo "Configuration reloaded."
end

echo ""
echo "🎉 Setup run complete!"
