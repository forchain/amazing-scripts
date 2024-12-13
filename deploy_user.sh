#!/bin/bash

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set ZSH theme to gentoo
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="gentoo"/' ~/.zshrc

# Change default shell to zsh
chsh -s $(which zsh)

# Configure tmux mouse support
echo "# Enable mouse support" > ~/.tmux.conf
echo "set -g mouse on" >> ~/.tmux.conf

echo "User environment setup completed!"
echo "Please log out and log back in for the shell changes to take effect."