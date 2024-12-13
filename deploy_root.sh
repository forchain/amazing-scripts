#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Check if username is provided as argument
if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

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