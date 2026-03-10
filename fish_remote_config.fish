# This script is designed for single-run execution via:
# curl -sS -o /tmp/remote_config.fish YOUR_RAW_FISH_CONFIG_URL
# source /tmp/remote_config.fish
# Capture the argument passed from install.sh (the repo path)
set -l DOTFILES_REPO_PATH $argv[1]

echo "--- Starting Remote Fish Configuration Setup ---"
echo ""

# --------------------------------------------------------
# 🔧 Global Path Setup
# --------------------------------------------------------
set -l local_bin "$HOME/.local/bin"
if not test -d "$local_bin"
    mkdir -p "$local_bin"
end
# Instantly add local bin to PATH for this session and future ones
fish_add_path "$local_bin"

# If Homebrew is installed but not in PATH, add it cleanly (Fish syntax)
if test -f /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# --------------------------------------------------------
# 🐠 Oh My Fish (OMF) Setup
# --------------------------------------------------------
set -l OMF_DATA_DIR "$HOME/.local/share/omf"
set -l OMF_CONFIG_DIR "$HOME/.config/omf"
set -l config_file "$HOME/.config/fish/config.fish"
set -l omf_init_path "$OMF_DATA_DIR/init.fish"

if not test -d "$OMF_DATA_DIR"
    echo "Oh My Fish not found. Bootstrapping via direct clone..."
    if not command -q git; echo "Error: 'git' command not found."; exit 1; end

    mkdir -p "$OMF_CONFIG_DIR"
    echo "default" > "$OMF_CONFIG_DIR/theme"
    git clone --depth 1 https://github.com/oh-my-fish/oh-my-fish "$OMF_DATA_DIR"
else
    echo "OMF directory found. Skipping install."
end

if test -f "$omf_init_path"
    set -gx OMF_PATH "$OMF_DATA_DIR"
    set -gx OMF_CONFIG "$OMF_CONFIG_DIR"
    if test -f "$OMF_PATH/lib/require.fish"; source "$OMF_PATH/lib/require.fish"; end
    source "$omf_init_path"

    if functions -q omf
        omf install bobthefish 2>/dev/null

        if not grep -q "set -gx OMF_PATH" "$config_file"
            echo "" >> "$config_file"
            echo "# Path to Oh My Fish install." >> "$config_file"
            echo "set -gx OMF_PATH \"$OMF_DATA_DIR\"" >> "$config_file"
            echo "set -gx OMF_CONFIG \"$OMF_CONFIG_DIR\"" >> "$config_file"
            echo "source \"\$OMF_PATH/init.fish\"" >> "$config_file"
        end

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
            end
        end
    end
end

# --------------------------------------------------------
# 📦 Additional Packages Setup
# --------------------------------------------------------
echo "--- Installing Additional Packages ---"

if command -q apt-get
    sudo apt-get update
    # 1. Standard APT packages (Zoxide removed to avoid buggy v0.4.3)
    sudo apt-get install -y ranger btop chafa fzf bat

    # Debian/Ubuntu installs bat as 'batcat'. Link it to 'bat' in our local bin.
    if command -v batcat > /dev/null; and not command -v bat > /dev/null
        ln -s (which batcat) "$local_bin/bat"
    end

    # 2. Glow (via Charmbracelet APT repo)
    if not command -q glow
        echo "Installing Glow..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt-get update; and sudo apt-get install -y glow
    end
end

# 3. Zoxide (Latest version via official script to prevent _z_cd loop)
if not command -q zoxide
    echo "Installing latest Zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
end

# 4. Eza (Direct Binary Download)
if not command -q eza
    echo "Installing Eza directly..."
    set -l EZA_URL (curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.gz" | head -n 1 | cut -d '"' -f 4)
    if test -n "$EZA_URL"
        curl -sL "$EZA_URL" -o /tmp/eza.tar.gz
        tar -xzf /tmp/eza.tar.gz -C /tmp
        mv /tmp/eza "$local_bin/"
        rm /tmp/eza.tar.gz
    end
end

# 5. CSVLens (Direct Binary Download)
if not command -q csvlens
    echo "Installing CSVLens directly..."
    set -l CSVLENS_URL (curl -s https://api.github.com/repos/YS-L/csvlens/releases/latest | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.xz" | head -n 1 | cut -d '"' -f 4)
    if test -n "$CSVLENS_URL"
        curl -sL "$CSVLENS_URL" -o /tmp/csvlens.tar.xz
        tar -xf /tmp/csvlens.tar.xz -C /tmp
        find /tmp -name "csvlens" -type f -executable -exec mv {} "$local_bin/" \;
        rm -rf /tmp/csvlens*
    end
end

# 6. llmfit (Direct Binary Download)
if not command -q llmfit
    echo "Installing llmfit directly..."
    set -l LLMFIT_URL (curl -s https://api.github.com/repos/AlexsJones/llmfit/releases/latest | grep "browser_download_url.*x86_64-unknown-linux-musl.tar.gz" | head -n 1 | cut -d '"' -f 4)
    if test -n "$LLMFIT_URL"
        curl -sL "$LLMFIT_URL" -o /tmp/llmfit.tar.gz
        tar -xzf /tmp/llmfit.tar.gz -C /tmp
        find /tmp -name "llmfit" -type f -executable -exec mv {} "$local_bin/" \;
        rm -rf /tmp/llmfit*
    end
end

# 7. models (Direct Binary Download)
if not command -q models
    echo "Installing models directly..."
    set -l MODELS_URL (curl -s https://api.github.com/repos/arimxyer/models/releases/latest | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.gz" | head -n 1 | cut -d '"' -f 4)
    if test -n "$MODELS_URL"
        curl -sL "$MODELS_URL" -o /tmp/models.tar.gz
        tar -xzf /tmp/models.tar.gz -C /tmp
        find /tmp -name "models" -type f -executable -exec mv {} "$local_bin/" \;
        rm -rf /tmp/models*
    end
end

# --------------------------------------------------------
# 💻 Lazygit Setup
# --------------------------------------------------------
echo "--- Lazygit Setup ---"
if not command -q lazygit
    set -l LAZYGIT_VERSION (curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -oP '"tag_name": "v\K[^"]*')
    if test -n "$LAZYGIT_VERSION"
        set -l LAZYGIT_DOWNLOAD_URL "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_"$LAZYGIT_VERSION"_Linux_x86_64.tar.gz"
        curl -Lo /tmp/lazygit.tar.gz "$LAZYGIT_DOWNLOAD_URL"
        tar -xzf /tmp/lazygit.tar.gz -C /tmp
        install /tmp/lazygit "$local_bin"
        rm /tmp/lazygit.tar.gz /tmp/lazygit 2>/dev/null
    end
end

# Lazygit Config Symlink
set -l lazygit_config_dir "$HOME/.config/lazygit"
set -l lazygit_target_file "$lazygit_config_dir/config.yml"
set -l lazygit_source_file "lazygit_config.yml"
mkdir -p "$lazygit_config_dir"
if test -n "$DOTFILES_REPO_PATH"; and test -f "$DOTFILES_REPO_PATH/$lazygit_source_file"
    ln -sf "$DOTFILES_REPO_PATH/$lazygit_source_file" "$lazygit_target_file"
else
    curl -sL -o "$lazygit_target_file" "https://raw.githubusercontent.com/gormanstock/coderdotfiles/main/lazygit_config.yml"
end

# --------------------------------------------------------
# 🛠️ Fish Aliases, Zoxide & Environment Setup (conf.d method)
# --------------------------------------------------------
echo "--- Setting up clean Aliases & Zoxide ---"
mkdir -p "$HOME/.config/fish/conf.d"

# 1. Zoxide Initialization (Ensures it loads exactly once)
echo "if command -v zoxide > /dev/null; zoxide init fish --cmd cd | source; end" > "$HOME/.config/fish/conf.d/zoxide_init.fish"

# 2. Aliases and Welcome Message
set -l user_env_file "$HOME/.config/fish/conf.d/user_env.fish"
echo "alias gitcommands='git config --list --show-origin'" > "$user_env_file"
echo "alias lg='lazygit'" >> "$user_env_file"
echo "alias ls='eza'" >> "$user_env_file"
echo "alias cat='bat'" >> "$user_env_file"
echo "
function fish_greeting
    set_color cyan
    echo '🚀 Welcome to your Workspace!'
    set_color yellow
    echo '🛠️  Available Tools: lazygit (lg), glow, llmfit, models, ranger, zoxide (cd), btop, chafa, csvlens, eza (ls), bat (cat), fzf'
    set_color normal
end" >> "$user_env_file"

# --------------------------------------------------------
# 🔧 Git Configuration
# --------------------------------------------------------
git config --global core.editor 'code --wait'
git config --global pull.rebase false 
git config --global merge.conflictstyle diff3
git config --global rebase.instructionFormat '"(%an <%ae>) %s"'
git config --global credential.helper '/usr/bin/gp credential-helper'
git config --global filter.lfs.clean 'git-lfs clean -- %f'
git config --global filter.lfs.smudge 'git-lfs smudge -- %f'
git config --global filter.lfs.process 'git-lfs filter-process'
git config --global filter.lfs.required true
git config --global push.default simple
git config --global help.autocorrect 20

# Git Aliases
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

# --------------------------------------------------------
# 🤖 Workspace Agents Configuration
# --------------------------------------------------------
echo "alias deploy_agents 'for workspace in beeline cetus coyote dsl falco falco-web-lite gemini lyra pdf-render-service platform; set target /home/coder/workspace/\$workspace/AGENTS.md; set vscode_dir /home/coder/workspace/\$workspace/.vscode; if test -d /home/coder/workspace/\$workspace; echo \"Setting up \$workspace...\"; curl -sL --fail -o \$target https://raw.githubusercontent.com/gormanstock/coderdotfiles/main/agents/\$workspace.md 2>/dev/null; or curl -sL --fail -o \$target https://raw.githubusercontent.com/gormanstock/coderdotfiles/main/agents/default.md 2>/dev/null; mkdir -p \$vscode_dir; curl -sL --fail -o \$vscode_dir/settings.json https://raw.githubusercontent.com/gormanstock/coderdotfiles/main/vscode-settings-template.json 2>/dev/null; end; end; echo \"✅ Agent configs deployed to all workspaces\"'" >> "$user_env_file"

echo ""
echo "🎉 Setup run complete!"
