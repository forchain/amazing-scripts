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
