# --- START: OH MY FISH (OMF) SETUP ---

# Check if the Oh My Fish directory exists
if not test -d "$HOME/.local/share/omf"
    echo "Oh My Fish not found. Attempting to install..."
    
    if command -q curl
        echo "Running OMF standard installation..."
        # Use the standard curl install method for robustness
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
    omf install bobthefish
    
    # Set theme configurations (will automatically save to $HOME/.config/fish/config.fish)
    echo "Setting bobthefish configurations (Nerd Fonts and Nord color scheme)..."
    set -g theme_nerd_fonts yes
    set -g theme_color_scheme nord
    
    echo "OMF configuration complete."
    
end
# --- END: OH MY FISH (OMF) SETUP ---

# --- START: LAZYGIT SETUP ---

echo ""
echo "--- Lazygit Setup ---"

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

    echo "Fetching latest Lazygit version..."
    set LAZYGIT_VERSION (curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -oP '"tag_name": "v\K[^"]*')
    
    if test -z "$LAZYGIT_VERSION"
        echo "Error: Could not determine latest Lazygit version. Installation aborted."
    else
        echo "Found version: v$LAZYGIT_VERSION"
        set -l LAZYGIT_DOWNLOAD_URL "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_"$LAZYGIT_VERSION"_Linux_x86_64.tar.gz"
        
        echo "Downloading Lazygit..."
        curl -Lo /tmp/lazygit.tar.gz "$LAZYGIT_DOWNLOAD_URL"
        
        echo "Extracting binary..."
        tar -xzf /tmp/lazygit.tar.gz -C /tmp
        
        if test -f /tmp/lazygit
            # Using user-local install (common in remote environments)
            install /tmp/lazygit "$local_bin"
            echo "Lazygit installed successfully to $local_bin/lazygit"
        else
            echo "Error: Lazygit binary not found after extraction."
        end

        # Clean up
        rm /tmp/lazygit.tar.gz /tmp/lazygit 2>/dev/null
    end
end
# --- END: LAZYGIT SETUP ---

# --- START: FISH ALIAS & GIT CONFIGURATION ---

echo ""
echo "--- Fish Alias & Git Configuration Setup ---"

# 1. Add the fish alias (using `func` to make it persistent)
# The fish syntax for a persistent alias is using `func` and `-s` (save)
echo "Setting persistent fish alias: gitcommands -> 'git config --list --show-origin'"
func -f gitcommands 'git config --list --show-origin'
func -s gitcommands # This saves the function to $HOME/.config/fish/functions/gitcommands.fish

# 2. Apply all Git configuration settings using `git config --global`
echo "Applying global Git configurations to $HOME/.gitconfig..."

# Core settings
git config --global core.editor 'code --wait'
# The `pull.rebase` default is now `false` (old) or `true` (new). Setting explicitly.
git config --global pull.rebase false 
git config --global merge.conflictstyle diff3
# Note: The `instructionFormat` must be set with spaces and quotes for safety
git config --global rebase.instructionFormat '"(%an <%ae>) %s"'

# Credential helper
git config --global credential.helper '/usr/bin/gp credential-helper'

# LFS filter (Required if LFS is used)
git config --global filter.lfs.clean 'git-lfs clean -- %f'
git config --global filter.lfs.smudge 'git-lfs smudge -- %f'
git config --global filter.lfs.process 'git-lfs filter-process'
git config --global filter.lfs.required true

# Push and Help
git config --global push.default simple
git config --global help.autocorrect 20

# Aliases
# Note: Aliases starting with '!' are shell commands, they must be wrapped in quotes
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
git config --global alias.rip '!git reset HEAD~1 $1' # Changed to ! to handle arguments better
git config --global alias.ripout '!git reset HEAD~1 $1 && git checkout -- .' # Changed to !
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
echo ""
echo "🎉 Setup complete! Your fish shell is fully configured."

# --- END: FISH ALIAS & GIT CONFIGURATION ---
