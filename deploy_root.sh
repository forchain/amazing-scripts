#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Default values
DEFAULT_USERNAME="dev"
DEFAULT_PASSWORD="password123"
DEFAULT_ZEROTIER_NETWORK_ID=""

# Source environment variables if .env exists
if [ -f ".env" ]; then
    source ".env"
fi

# Use environment variables or defaults
USERNAME=${USERNAME:-$DEFAULT_USERNAME}
PASSWORD=${PASSWORD:-$DEFAULT_PASSWORD}
ZEROTIER_NETWORK_ID=${ZEROTIER_NETWORK_ID:-$DEFAULT_ZEROTIER_NETWORK_ID}

# Function to check if a package is installed
is_installed() {
    dpkg -l "$1" &> /dev/null
    return $?
}

# Flag to track if we need to run apt update
NEED_APT_UPDATE=false

# Check and install basic tools
BASIC_TOOLS="zsh vim curl git tmux"
TOOLS_TO_INSTALL=""
for tool in $BASIC_TOOLS; do
    if ! is_installed $tool; then
        TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL $tool"
        NEED_APT_UPDATE=true
    fi
done

# Check Caddy installation
if ! is_installed caddy; then
    NEED_APT_UPDATE=true
    INSTALL_CADDY=true
else
    echo "Caddy is already installed, skipping..."
fi

# Check ZeroTier installation
if [ ! -z "$ZEROTIER_NETWORK_ID" ] && ! is_installed zerotier-one; then
    NEED_APT_UPDATE=true
    INSTALL_ZEROTIER=true
else
    [ ! -z "$ZEROTIER_NETWORK_ID" ] && echo "ZeroTier is already installed, skipping installation..."
fi

# Run apt update if needed
if [ "$NEED_APT_UPDATE" = true ]; then
    echo "Updating package list..."
    apt update
fi

# Install basic tools if needed
if [ ! -z "$TOOLS_TO_INSTALL" ]; then
    echo "Installing missing tools: $TOOLS_TO_INSTALL"
    apt install -y $TOOLS_TO_INSTALL
else
    echo "All basic tools are already installed, skipping..."
fi

# Install Caddy if needed
if [ "$INSTALL_CADDY" = true ]; then
    echo "Installing Caddy..."
    apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt update
    apt install -y caddy
    
    # Enable and start Caddy service
    systemctl enable caddy
    systemctl start caddy
fi

# Install and configure ZeroTier if needed
if [ "$INSTALL_ZEROTIER" = true ]; then
    echo "Installing ZeroTier..."
    curl -s https://install.zerotier.com | bash
    
    # Join ZeroTier network
    echo "Joining ZeroTier network: $ZEROTIER_NETWORK_ID"
    zerotier-cli join "$ZEROTIER_NETWORK_ID"
elif [ ! -z "$ZEROTIER_NETWORK_ID" ]; then
    # If ZeroTier is installed but we need to join the network
    if ! zerotier-cli listnetworks | grep -q "$ZEROTIER_NETWORK_ID"; then
        echo "Joining ZeroTier network: $ZEROTIER_NETWORK_ID"
        zerotier-cli join "$ZEROTIER_NETWORK_ID"
    else
        echo "Already joined to ZeroTier network: $ZEROTIER_NETWORK_ID"
    fi
fi

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists, skipping user creation"
else
    echo "Creating user $USERNAME..."
    # Create user with home directory
    useradd -m "$USERNAME"
    
    # Set password for the user
    echo "$USERNAME:$PASSWORD" | chpasswd
    
    # Add user to sudo group
    usermod -aG sudo "$USERNAME"
    
    # Configure sudo without password for the user
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
    chmod 440 "/etc/sudoers.d/$USERNAME"
    
    echo "User $USERNAME has been created successfully:"
    echo "- Home directory: /home/$USERNAME"
    echo "- Added to sudo group"
    echo "- Sudo access configured without password"
fi

echo "System setup completed:"
[ ! -z "$TOOLS_TO_INSTALL" ] && echo "- Installed missing tools: $TOOLS_TO_INSTALL"
[ "$INSTALL_CADDY" = true ] && echo "- Caddy newly installed and running" || echo "- Caddy was already installed"
[ "$INSTALL_ZEROTIER" = true ] && echo "- ZeroTier newly installed and joined network" || \
    ([ ! -z "$ZEROTIER_NETWORK_ID" ] && echo "- ZeroTier was already installed")
echo "- Check Caddy status with: systemctl status caddy"
[ ! -z "$ZEROTIER_NETWORK_ID" ] && echo "- Check ZeroTier status with: zerotier-cli status"