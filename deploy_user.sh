#!/bin/bash

# Default environment file
DEFAULT_ENV_FILE=".env"

# Source default environment file if it exists
if [ -f "$DEFAULT_ENV_FILE" ]; then
    source "$DEFAULT_ENV_FILE"
fi

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --network-id)
            ZEROTIER_NETWORK_ID="$2"
            shift
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 --network-id <zerotier_network_id>"
            exit 1
            ;;
    esac
    shift
done

# Validate network ID
if [ -z "$ZEROTIER_NETWORK_ID" ]; then
    echo "Error: ZeroTier network ID not provided"
    echo "Usage: $0 --network-id <zerotier_network_id>"
    echo "   or: Set ZEROTIER_NETWORK_ID in .env file"
    exit 1
fi

# Install required packages
sudo apt update
sudo apt install -y zsh vim curl git tmux

# Install ZeroTier
echo "Installing ZeroTier..."
curl -s https://install.zerotier.com | sudo bash

# Join ZeroTier network
echo "Joining ZeroTier network: $ZEROTIER_NETWORK_ID"
sudo zerotier-cli join "$ZEROTIER_NETWORK_ID"

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

echo "Installation completed!"
echo "Please check ZeroTier status with: sudo zerotier-cli status"
echo "Please log out and log back in for the shell changes to take effect."