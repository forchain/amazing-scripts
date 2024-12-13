# amazing-scripts

A collection of useful scripts for development and system administration.

## Scripts

### mount_sshfs.sh

A bash script to mount remote directories using SSHFS. 

#### Usage

Specify server and user

```bash
./mount_sshfs.sh -h example.com -u username
./mount_sshfs.sh --host example.com --user username
```

### deploy_root.sh

A root-level script for creating and configuring new system users.

#### Usage

Must be run as root

```bash
./deploy_root.sh username password
```

### deploy_user.sh

A user-level script for setting up development environment.  

#### Usage

Must be run as a user

```bash
# Using network ID directly
./deploy_user.sh --network-id <zerotier_network_id>
```

The script will automatically read from `.env` file in the current directory if it exists.

Environment file example (.env):
```bash
ZEROTIER_NETWORK_ID=your_network_id
```

Features:
- Installs basic tools (zsh, vim, curl, git, tmux)
- Installs and configures Oh My Zsh
- Configures tmux mouse support
- Installs ZeroTier and joins specified network
