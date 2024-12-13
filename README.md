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

A root-level script for system setup and user creation.

#### Usage

Must be run as root

```bash
./deploy_root.sh
```

The script will read configuration from `.env` file if it exists, otherwise use default values.

Environment variables (.env):
```bash
USERNAME=dev              # Default: dev
PASSWORD=your_password    # Default: password123
ZEROTIER_NETWORK_ID=id   # Default: empty (skip ZeroTier installation)
```

Features:
- Creates new user with sudo privileges
- Configures passwordless sudo access
- Installs basic tools (zsh, vim, curl, git, tmux)
- Installs and configures Caddy web server
- Installs ZeroTier and joins network (if network ID provided)

### deploy_user.sh

A user-level script for personal environment setup.

#### Usage

Must be run as a user

```bash
./deploy_user.sh
```

Features:
- Installs and configures Oh My Zsh
- Sets ZSH as default shell
- Configures tmux mouse support

### caddy.sh

A script to configure Caddy reverse proxy.

#### Usage

Must be run as root

```bash
./caddy.sh --domain <domain> --target <target_url> [--port <port>]
```

Example:
```bash
# Using default port 443
./caddy.sh --domain web.api.example.com --target http://192.168.1.2:34567

# Using custom port 4433
./caddy.sh --domain web.api.example.com --target http://192.168.1.2:34567 --port 4433
```

Features:
- Configures Caddy reverse proxy
- Supports custom HTTPS port
- Automatically handles HTTPS certificates
- Validates configuration before applying
- Reloads Caddy service
