#!/bin/bash

echo "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

echo "Installing dependencies..."
sudo apt install -y curl git zsh ripgrep xclip tmux build-essential cmake unzip ninja-build fuse3

echo "Installing Zsh..."
if ! command -v zsh &> /dev/null; then
    sudo apt install -y zsh
fi

echo "Changing default shell to Zsh..."
sudo chsh -s $(which zsh) $USER

echo "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
fi

echo "Installing Zsh plugins..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k

# Update plugins section in .zshrc
sed -i '/^plugins=(git)$/c\plugins=(git zsh-syntax-highlighting zsh-autosuggestions)' ~/.zshrc

# Download and apply the Powerlevel10k configuration from the public repo
P10K_CONFIG_REPO="https://raw.githubusercontent.com/init5god/server_config/refs/heads/main/.pk10.zsh"
wget -O ~/.p10k.zsh $P10K_CONFIG_REPO

# Update .zshrc to source the Powerlevel10k configuration
echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo "Installing Neovim dependencies (FUSE)..."
sudo apt install -y fuse3
sudo apt install -y build-essential cmake unzip ninja-build


echo "Installing Neovim via PPA..."
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim

echo "Installing Neovim kickstart configuration..."
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim
fi

echo "Downloading Neovim init.lua configuration..."
NVIM_CONFIG_REPO="https://raw.githubusercontent.com/init5god/server_config/refs/heads/main/init.lua"
wget -O ~/.config/nvim/init.lua $NVIM_CONFIG_REPO

echo "Installing Tmux..."
if ! command -v tmux &> /dev/null; then
    sudo apt install -y tmux
fi

echo "Installing Tmux Plugin Manager (TPM)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Configuring Tmux with Catppuccin theme and custom keybindings..."
cat > ~/.tmux.conf <<EOL
set -g @plugin 'catppuccin/tmux'
set -g @catppuccin_flavour 'latte'  # Options: latte, frappe, macchiato, mocha
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'

set -g default-shell /bin/zsh

# Resize panes using Ctrl + Alt + arrow keys
bind -n C-M-Up resize-pane -U 5
bind -n C-M-Down resize-pane -D 5
bind -n C-M-Left resize-pane -L 5
bind -n C-M-Right resize-pane -R 5
set-option -sg escape-time 10

run '~/.tmux/plugins/tpm/tpm'
EOL

echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker $USER
fi

echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Applying changes..."
source ~/.zshrc
tmux source ~/.tmux.conf

echo "Installation completed. Restart your shell or reboot to apply changes."


