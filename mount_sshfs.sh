#!/bin/bash

# Enable command printing
set -x

# Default values
SERVER_IP="server.work"
SERVER_USER="tony"
SERVER_PORT="22"  # Add default port

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            SERVER_IP="$2"
            shift 2
            ;;
        -u|--user)
            SERVER_USER="$2"
            shift 2
            ;;
        -p|--port)
            SERVER_PORT="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 [-h|--host SERVER_IP] [-u|--user SERVER_USER] [-p|--port SERVER_PORT]"
            exit 1
            ;;
    esac
done

# Remote folder path
REMOTE_PATH="/home/$SERVER_USER/share"
# Local mount point
MOUNT_POINT="$HOME/share/$SERVER_IP"

# Check if running on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if macFUSE is installed (checking both old and new package names)
    if ! (pkgutil --pkgs | grep -q "com.github.osxfuse.pkg.MacFUSE" || \
          pkgutil --pkgs | grep -q "io.macfuse.installer.components" || \
          [ -d "/Library/Filesystems/macfuse.fs" ]); then
        echo "Error: macFUSE is not installed. Please install it first:"
        echo "brew install --cask macfuse"
        exit 1
    fi
    
    # Check SSHFS installation
    if ! command -v sshfs >/dev/null 2>&1; then
        echo "Error: SSHFS is not installed. Please install it first:"
        echo "brew install sshfs"
        exit 1
    fi
fi

# Check SSH connection and create remote directory if it doesn't exist
echo "Checking remote directory..."
if ! ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_IP" "[ -d \"$REMOTE_PATH\" ]"; then
    echo "Remote directory does not exist. Creating it..."
    if ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_IP" "mkdir -p \"$REMOTE_PATH\""; then
        echo "Remote directory created successfully."
    else
        echo "Failed to create remote directory. Please check your permissions."
        exit 1
    fi
fi

# Function to attempt mount
mount_remote() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS specific options
        sshfs -o allow_other,defer_permissions,volname=ServerShare,port="$SERVER_PORT" \
            "$SERVER_USER@$SERVER_IP:$REMOTE_PATH" "$MOUNT_POINT"
    else
        # Linux options
        sshfs -o allow_other,defer_permissions,port="$SERVER_PORT" \
            "$SERVER_USER@$SERVER_IP:$REMOTE_PATH" "$MOUNT_POINT"
    fi
}

# Create local mount point
mkdir -p "$MOUNT_POINT"

# First mount attempt
echo "Mounting $REMOTE_PATH from $SERVER_IP to $MOUNT_POINT"
mount_remote

# Check if mount was successful
if ! mount | grep -i "$MOUNT_POINT"; then
    echo "First mount attempt failed. Forcing unmount and trying again..."
    umount -f "$MOUNT_POINT" 2>/dev/null
    sleep 1
    mount_remote

    # Check second mount attempt
    if ! mount | grep -i "$MOUNT_POINT"; then
        echo "Failed to mount $REMOTE_PATH from $SERVER_IP to $MOUNT_POINT"
        echo "Please ensure:"
        echo "1. macFUSE is up to date (for macOS)"
        echo "2. The remote server is accessible"
        echo "3. You have the correct permissions"
        
        # Show basic debug information
        echo -e "\nDebug information:"
        echo "1. Testing SSH connection:"
        ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_IP" "echo 'SSH connection test successful'"
        
        echo -e "\n2. Checking remote directory:"
        ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_IP" "ls -la \"$REMOTE_PATH\""
        
        echo -e "\n3. Checking local mount point:"
        ls -la "$MOUNT_POINT"
    else
        echo "Successfully mounted $REMOTE_PATH from $SERVER_IP to $MOUNT_POINT"
    fi
else
    echo "Successfully mounted $REMOTE_PATH from $SERVER_IP to $MOUNT_POINT"
fi

# Show current mounts
echo "Current mounts:"
mount | grep -i "$MOUNT_POINT" || echo "Mount point not found in mount list"
