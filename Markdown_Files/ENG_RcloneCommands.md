## BASIC CONFIGURATION

### Environment variables

```bash
# Set configuration file location
export RCLONE_CONFIG=/path/to/custom/rclone.conf

# Set default remote
export RCLONE_REMOTE=gdrive1:

# After setting these, you can use shorter commands
rclone ls $RCLONE_REMOTE
```

---

## 1. REMOTE MANAGEMENT

### List remotes

```bash
# List all configured remotes
rclone listremotes

# Show complete configuration
rclone config show

# Show configuration of specific remote
rclone config show gdrive1
```

### Create new remote

```bash
# Interactive configuration
rclone config

# Create remote non-interactively (Google Drive example)
rclone config create gdrive1 drive scope drive

# Create union remote
rclone config create gdrive_union union upstreams "gdrive1: gdrive2: gdrive3:"
```

### Modify existing remote

```bash
# Edit remote interactively
rclone config update gdrive1

# Reconnect (reauthorize) remote
rclone config reconnect gdrive1:

# Delete remote
rclone config delete gdrive1
```

### Test remote connection

```bash
# Test connection and show stats
rclone about gdrive1:

# List top-level directories
rclone lsd gdrive1:

# Check if remote is accessible
rclone check gdrive1: gdrive1: --one-way
```

---

## 2. LISTING AND BROWSING

### List files and directories

```bash
# List all files (recursive)
rclone ls gdrive1:

# List with sizes and dates
rclone lsl gdrive1:

# List directories only
rclone lsd gdrive1:

# Tree view (recursive directory structure)
rclone tree gdrive1: --level 3
```

### Size and statistics

```bash
# Show detailed statistics
rclone size gdrive1: --json

# Storage usage and quota
rclone about gdrive1:
```