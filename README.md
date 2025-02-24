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

# Proxy configuration
PROXY_HOST=proxy.example.com    # Default: empty (skip proxy configuration)
PROXY_PORT=1080                 # Default: 1080
PROXY_USERNAME=proxy_user       # Default: empty
PROXY_PASSWORD=proxy_pass       # Default: empty
```

Features:
- Creates new user with sudo privileges
- Configures passwordless sudo access
- Installs basic tools (zsh, vim, curl, git, tmux, proxychains4)
- Installs and configures Caddy web server
- Installs ZeroTier and joins network (if network ID provided)
- Configures proxychains with SOCKS5 proxy support

### deploy_user.sh

A user-level script for personal environment setup.

#### Usage

Must be run as a user

```bash
./deploy_user.sh
```

### convert_encoding.sh

A script to convert file encodings in a directory and its subdirectories.

#### Usage

```bash
# Convert files with default settings (gb2312 to utf-8)
./convert_encoding.sh -d /path/to/directory

# Convert files with custom encodings and extensions
./convert_encoding.sh -f gbk -t utf-8 -d /path/to/directory -e "txt,md,json"

# Show help
./convert_encoding.sh --help
```

Options:
- `-f, --from`: Source encoding (default: gb2312)
- `-t, --to`: Target encoding (default: utf-8)
- `-d, --dir`: Target directory (default: current directory)
- `-e, --extensions`: Comma-separated list of file extensions (default: txt,md,json,yml,yaml,xml,csv)

### file_stats.sh

A script to analyze file types and their disk usage in a directory.

#### Usage

```bash
# Analyze current directory
./file_stats.sh

# Analyze specific directory with options
./file_stats.sh -d /path/to/directory -i "node_modules|.git" -m 1M -s count

# Show help
./file_stats.sh --help
```

Options:
- `-d, --dir`: Target directory (default: current directory)
- `-i, --ignore`: Ignore pattern (e.g., 'node_modules|.git')
- `-m, --min-size`: Minimum file size to include (e.g., '1M', '500K')
- `-s, --sort`: Sort by 'size' or 'count' (default: size)

Features:
- Groups files by extension
- Shows file count and total size for each type
- Supports size filtering
- Configurable directory ignoring
- Human-readable size output
- Sorting by size or count
=======
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
