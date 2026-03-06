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
# Ensure ~/.local/bin is permanently in the PATH right away
set -l local_bin "$HOME/.local/bin"
if not test -d "$local_bin"
    mkdir -p "$local_bin"
end
fish_add_path "$local_bin"

# If Homebrew is installed but not in PATH, add it
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
    # 1. Standard APT packages
    sudo apt-get install -y ranger zoxide btop chafa

    # 2. Glow (via Charmbracelet APT repo)
    if not command -q glow
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt-get update; and sudo apt-get install -y glow
    end

    # 3. Eza (via official APT repo)
    if not command -q eza
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://apt.fury.io/eza/ /" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo apt-get update; and sudo apt-get install -y eza
    end
end

# 4. CSVLens (Pre-compiled Binary)
if not command -q csvlens
    echo "Installing CSVLens..."
    set -l CSVLENS_URL (curl -s https://api.github.com/repos/YS-L/csvlens/releases/latest | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.xz" | head -n 1 | cut -d '"' -f 4)
    if test -n "$CSVLENS_URL"
        curl -sL "$CSVLENS_URL" -o /tmp/csvlens.tar.xz
        tar -xf /tmp/csvlens.tar.xz -C /tmp
        find /tmp -name "csvlens" -type f -executable -exec mv {} "$local_bin/" \;
        rm -rf /tmp/csvlens*
    end
end

# 5. llmfit (Custom Script)
if not command -q llmfit
    echo "Installing llmfit..."
    curl -fsSL https://llmfit.axjns.dev/install.sh | sh
end

# 6. models (via Homebrew)
if not command -q models
    if command -q brew
        echo "Installing models via Homebrew..."
        brew install arimxyer/tap/models
    else
        echo "⚠️ Homebrew not found. Skipping 'models'."
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
set -l lazygit_target
