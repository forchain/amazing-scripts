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
