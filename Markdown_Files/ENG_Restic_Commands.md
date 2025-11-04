## BASIC CONFIGURATION

### Useful environment variables

```bash
# Set password for current session
export RESTIC_PASSWORD="your-30-character-password"

# Set default repository
export RESTIC_REPOSITORY="rclone:gdrive_union:/restic-backup"

# After these variables you can use commands without -r and without password
restic snapshots
```

---

## 1. SNAPSHOT VISUALIZATION

### List snapshots

```bash
# List all snapshots
restic -r rclone:gdrive_union:/restic-backup snapshots

# List with extended details
restic -r rclone:gdrive_union:/restic-backup snapshots --verbose

# List snapshots of a specific path
restic -r rclone:gdrive_union:/restic-backup snapshots --path ~/Desktop/Documents

# Output in JSON format (for scripting)
restic -r rclone:gdrive_union:/restic-backup snapshots --json

# List snapshots with grouping by host/path
restic -r rclone:gdrive_union:/restic-backup snapshots --group-by host,paths
```

### Specific snapshot information

```bash
# Complete details of a snapshot
restic -r rclone:gdrive_union:/restic-backup snapshots <snapshot-id>

# List all files in a snapshot
restic -r rclone:gdrive_union:/restic-backup ls <snapshot-id>

# List with details (permissions, sizes, dates)
restic -r rclone:gdrive_union:/restic-backup ls <snapshot-id> --long

# List only a specific directory
restic -r rclone:gdrive_union:/restic-backup ls <snapshot-id> /Users/<your-username>/Desktop/Photos
```

---

## 2. FILE SEARCH

### Find files by name

```bash
# Search for specific file
restic -r rclone:gdrive_union:/restic-backup find "document.pdf"

# Search with pattern
restic -r rclone:gdrive_union:/restic-backup find "*.jpg"
restic -r rclone:gdrive_union:/restic-backup find "*.mp4"

# Search in specific path
restic -r rclone:gdrive_union:/restic-backup find "*.pdf" --path /Users/<your-username>/Desktop/Documents

# Case-insensitive search
restic -r rclone:gdrive_union:/restic-backup find "document" --ignore-case

# Output: tells you which snapshots contain the file and the full path
```

---

## 3. REPOSITORY STATISTICS

### General info

```bash
# General repository statistics
restic -r rclone:gdrive_union:/restic-backup stats

# Specific snapshot statistics
restic -r rclone:gdrive_union:/restic-backup stats <snapshot-id>

# Latest snapshot statistics
restic -r rclone:gdrive_union:/restic-backup stats latest

# Used space (raw data on cloud)
restic -r rclone:gdrive_union:/restic-backup stats --mode raw-data

# Space after deduplication
restic -r rclone:gdrive_union:/restic-backup stats --mode restore-size
```

---

## 4. SNAPSHOT COMPARISON

### Differences between versions

```bash
# Compare latest snapshot with previous
restic -r rclone:gdrive_union:/restic-backup diff <snapshot-old> <snapshot-new>

# Compare with metadata (also shows changed permissions)
restic -r rclone:gdrive_union:/restic-backup diff <snapshot-old> <snapshot-new> --metadata

# Output shows:
# + added files
# - removed files
# M modified files
```

---

## 5. BACKUP

### Basic backup

```bash
# Backup directory
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop

# Backup with tag
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop --tag important

# Backup with verbose
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop --verbose

# Dry-run (shows what it would do WITHOUT doing it)
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop --dry-run --verbose
```

### Backup with exclusions

```bash
# Exclude specific patterns
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop \
  --exclude="*.tmp" \
  --exclude="*.cache" \
  --exclude=".DS_Store" \
  --exclude="node_modules" \
  --exclude=".git"

# Exclude from file
echo "*.tmp" > ~/.restic-exclude.txt
echo "*.cache" >> ~/.restic-exclude.txt
echo ".DS_Store" >> ~/.restic-exclude.txt
echo "node_modules" >> ~/.restic-exclude.txt

restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop \
  --exclude-file=~/.restic-exclude.txt

# Exclude specific directories
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop \
  --exclude="/Users/<your-username>/Desktop/Cache" \
  --exclude="/Users/<your-username>/Desktop/Temp"
```

### Backup with limits

```bash
# Limit upload bandwidth (example: 10MB/s)
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop --limit-upload 10240

# Limit download bandwidth (for restore)
restic -r rclone:gdrive_union:/restic-backup restore latest --target ~/restore --limit-download 10240
```

---

## 6. RESTORE

### Full restore

```bash
# Restore latest snapshot
restic -r rclone:gdrive_union:/restic-backup restore latest --target ~/Desktop/restore

# Restore specific snapshot
restic -r rclone:gdrive_union:/restic-backup restore <snapshot-id> --target ~/Desktop/restore

# Restore with integrity verification
restic -r rclone:gdrive_union:/restic-backup restore latest --target ~/Desktop/restore --verify
```

### Selective restore

```bash
# Restore single file
restic -r rclone:gdrive_union:/restic-backup restore latest \
  --target ~/Desktop/restore \
  --include /Users/<your-username>/Desktop/document.pdf

# Restore entire directory
restic -r rclone:gdrive_union:/restic-backup restore latest \
  --target ~/Desktop/restore \
  --include /Users/<your-username>/Desktop/Photos

# Restore with pattern
restic -r rclone:gdrive_union:/restic-backup restore latest \
  --target ~/Desktop/restore \
  --include "*.jpg"

# Restore multiple patterns
restic -r rclone:gdrive_union:/restic-backup restore latest \
  --target ~/Desktop/restore \
  --include "*.jpg" \
  --include "*.png" \
  --include "*.pdf"

# Restore excluding patterns
restic -r rclone:gdrive_union:/restic-backup restore latest \
  --target ~/Desktop/restore \
  --exclude "*.tmp" \
  --exclude "*.cache"
```

### Restore in-place (WARNING: overwrites)

```bash
# WARNING: overwrites existing files!
restic -r rclone:gdrive_union:/restic-backup restore latest \
  --target / \
  --include /Users/<your-username>/Desktop/document.pdf

# Safer: restore to temp and then manually copy
restic -r rclone:gdrive_union:/restic-backup restore latest \
  --target /tmp/restore \
  --include /Users/<your-username>/Desktop/document.pdf

# Then manually copy
cp /tmp/restore/Users/<your-username>/Desktop/document.pdf ~/Desktop/
```

---

## 7. SNAPSHOT MANAGEMENT (RETENTION)

### View policy

```bash
# Dry-run: shows what would be deleted
restic -r rclone:gdrive_union:/restic-backup forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --dry-run

# Show in detail
restic -r rclone:gdrive_union:/restic-backup forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --dry-run \
  --verbose
```

### Apply retention policy

```bash
# Apply policy (delete snapshots)
restic -r rclone:gdrive_union:/restic-backup forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --prune

# More aggressive policy (example)
restic -r rclone:gdrive_union:/restic-backup forget \
  --keep-last 3 \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --keep-yearly 2 \
  --prune

# Keep all snapshots with specific tag
restic -r rclone:gdrive_union:/restic-backup forget \
  --keep-daily 7 \
  --keep-tag important \
  --prune
```

### Manual deletion

```bash
# Delete specific snapshot
restic -r rclone:gdrive_union:/restic-backup forget <snapshot-id>

# Delete and free space (prune)
restic -r rclone:gdrive_union:/restic-backup forget <snapshot-id> --prune

# Delete all snapshots of a host
restic -r rclone:gdrive_union:/restic-backup forget --host <hostname> --prune

# Delete all snapshots of a path
restic -r rclone:gdrive_union:/restic-backup forget --path /Users/<your-username>/Desktop --prune
```

---

## 8. REPOSITORY MAINTENANCE

### Integrity verification

```bash
# Quick check (structure only)
restic -r rclone:gdrive_union:/restic-backup check

# Full check (reads ALL data - VERY SLOW)
restic -r rclone:gdrive_union:/restic-backup check --read-data

# Partial check (10% of data)
restic -r rclone:gdrive_union:/restic-backup check --read-data-subset=10%

# Check with parallelism
restic -r rclone:gdrive_union:/restic-backup check --read-data --read-data-subset=20%
```

### Cleanup and optimization

```bash
# Prune: removes unreferenced data
restic -r rclone:gdrive_union:/restic-backup prune

# Prune with statistics
restic -r rclone:gdrive_union:/restic-backup prune --verbose

# Rebuild index (if corrupted)
restic -r rclone:gdrive_union:/restic-backup rebuild-index

# Unlock repository (if locked)
restic -r rclone:gdrive_union:/restic-backup unlock

# List active locks
restic -r rclone:gdrive_union:/restic-backup list locks
```

### Cache management

```bash
# Local cache info
restic cache --no-size

# Clean cache
restic cache --cleanup
```

---

## 9. ADVANCED OPERATIONS

### Mount repository

```bash
# Mount as filesystem (read-only)
mkdir ~/restic-mount
restic -r rclone:gdrive_union:/restic-backup mount ~/restic-mount

# Now you can navigate:
ls ~/restic-mount/snapshots/
ls ~/restic-mount/snapshots/latest/
ls ~/restic-mount/snapshots/<snapshot-id>/

# To unmount (in another shell)
umount ~/restic-mount
# or on macOS
diskutil unmount ~/restic-mount
```

### Dump and export

```bash
# Dump entire snapshot as tar
restic -r rclone:gdrive_union:/restic-backup dump latest / > ~/backup.tar

# Dump specific directory
restic -r rclone:gdrive_union:/restic-backup dump latest /Users/<your-username>/Desktop/Photos > ~/photos.tar

# Dump single file
restic -r rclone:gdrive_union:/restic-backup dump latest /Users/<your-username>/Desktop/document.pdf > ~/document.pdf
```

### Copy/migrate repository

```bash
# Copy all snapshots from one repo to another
restic -r rclone:gdrive_union:/restic-backup copy \
  --repo2 rclone:new-provider:/restic-backup

# Copy specific snapshot
restic -r rclone:gdrive_union:/restic-backup copy <snapshot-id> \
  --repo2 rclone:new-provider:/restic-backup
```

### Tag management

```bash
# Add tag to existing snapshot
restic -r rclone:gdrive_union:/restic-backup tag <snapshot-id> --add important

# Remove tag
restic -r rclone:gdrive_union:/restic-backup tag <snapshot-id> --remove test

# List snapshots by tag
restic -r rclone:gdrive_union:/restic-backup snapshots --tag important
```

---

## 10. REPOSITORY INFORMATION

### General info

```bash
# List all data packs
restic -r rclone:gdrive_union:/restic-backup list packs

# List all indexes
restic -r rclone:gdrive_union:/restic-backup list index

# List encryption keys
restic -r rclone:gdrive_union:/restic-backup list keys

# Info on specific key
restic -r rclone:gdrive_union:/restic-backup key list
```

### Password change

```bash
# Change repository password
restic -r rclone:gdrive_union:/restic-backup key passwd

# Add new key
restic -r rclone:gdrive_union:/restic-backup key add

# Remove old key
restic -r rclone:gdrive_union:/restic-backup key remove <key-id>
```

---

## 11. DEBUGGING

### Verbose output

```bash
# Level 1 (basic)
restic -r rclone:gdrive_union:/restic-backup snapshots --verbose

# Level 2 (detailed)
restic -r rclone:gdrive_union:/restic-backup snapshots --verbose=2

# JSON for scripting
restic -r rclone:gdrive_union:/restic-backup snapshots --json | jq .
```

### Logging

```bash
# Log operations to file
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop 2>&1 | tee backup.log

# Separate error log
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop 2> error.log
```

---

## 12. USEFUL COMBINED COMMANDS

### Typical weekly workflow

```bash
# 1. Backup
restic -r rclone:gdrive_union:/restic-backup backup ~/Desktop --verbose

# 2. Apply retention
restic -r rclone:gdrive_union:/restic-backup forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --prune

# 3. Check integrity (10%)
restic -r rclone:gdrive_union:/restic-backup check --read-data-subset=10%
```

### Find and restore specific file

```bash
# 1. Search for file
restic -r rclone:gdrive_union:/restic-backup find "important-document.pdf"

# Output will tell you snapshot-id

# 2. Restore
restic -r rclone:gdrive_union:/restic-backup restore <snapshot-id> \
  --target ~/restore \
  --include /Users/<your-username>/Desktop/important-document.pdf
```

### Verify recent backup

```bash
# 1. List last 5 snapshots
restic -r rclone:gdrive_union:/restic-backup snapshots | tail -5

# 2. Verify latest snapshot
restic -r rclone:gdrive_union:/restic-backup ls latest

# 3. Latest statistics
restic -r rclone:gdrive_union:/restic-backup stats latest
```

---

## QUICK REFERENCE

### Snapshot IDs

- `latest` = latest snapshot
- `<snapshot-id>` = specific ID (e.g., 1a2b3c4d)
- You can use short-id: first 8 characters are enough

### Path format

- Always use absolute paths: `/Users/<your-username>/Desktop/file.txt`
- Don't use `~`, always expand: `/Users/<your-username>/`

### Pattern matching

- `*.jpg` = all jpg files
- `**/*.pdf` = all pdf files recursively
- Use `--iname` for case-insensitive

### Exit codes

- `0` = success
- `1` = warning/non-fatal errors
- `2` = fatal error

---

## PERFORMANCE TIPS

```bash
# Use aggressive cache
export RESTIC_CACHE_DIR=~/.cache/restic

# Parallelize
restic backup ~/Desktop --pack-size 16

# Compress less for speed
restic backup ~/Desktop --compression off
```