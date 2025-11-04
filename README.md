# Restic + Rclone Backup System

Complete backup solution using **Restic** and **Rclone** for encrypted, deduplicated backups across multiple cloud providers.

## Repository Structure

```
├── Assets/
│   └── BackupStructure.jpg          # System architecture diagram
├── Markdown_Files/
│   ├── ENG_Backup_Guide_Restic+Rclone.md       # Complete setup guide
│   ├── ENG_Disaster_Recovery_Guide.md          # Recovery procedures
│   ├── ENG_Restic_Commands.md                  # Restic command reference
│   └── ENG_RcloneCommands.md                   # Rclone command reference
└── Pdf_Files/
    └── [Same files in PDF format]
```

## Quick Start

1. **Setup**: Read [`ENG_Backup_Guide_Restic+Rclone.pdf`](Pdf_Files/ENG_Backup_Guide_Restic+Rclone.pdf)
3. **Recovery**: Follow [`ENG_Disaster_Recovery_Guide.pdf`](Pdf_Files/ENG_Disaster_Recovery_Guide.pdf) if needed

## What This System Does

- **Encrypts** all data client-side before upload
- **Deduplicates** data to save storage space
- **Mirrors** backups across Google Drive (45GB) and MEGA (40GB) (for free)
- **Automates** daily backups with integrity checks
- **Retains** 7 daily, 4 weekly, 6 monthly snapshots

## Documentation

All guides are available in both Markdown and PDF format:

- **Complete Setup Guide** - Install and configure everything from scratch
- **Disaster Recovery Guide** - 8 recovery scenarios with step-by-step solutions
- **Restic Commands** - Essential commands for backup, restore, and maintenance
- **Rclone Commands** - Essential commands for cloud storage management

## Prerequisites

- macOS (tested on macOS 14+)
- Homebrew
- Google Drive accounts (I use 3 × 15GB but you can use more)
- MEGA accounts (I use 2 × 20GB but you can use more)

## ⚠️ Security & Important Notes

### Critical: Restic Password

**If you lose the Restic encryption password, ALL backup data will be permanently lost.** There is no recovery mechanism - the data is encrypted client-side and cannot be decrypted without the password.

**Backup your password in multiple secure locations:**
- Password manager (primary)
- Offline USB drive (secondary)
- Physical safe or bank deposit box (tertiary)

Consider adding a second recovery key using `restic key add` as shown in the Disaster Recovery Guide.

### Platform Compatibility

The automation scripts use **macOS-specific features**:
- LaunchAgent (~/Library/LaunchAgents/)
- macOS Keychain for password storage
- macOS notifications via osascript

Manual backup/restore commands work on any platform, but automation requires macOS or script adaptation for Linux/Windows.

### Configuration Required

All scripts contain placeholders that **must be replaced** before use:
- `<your-username>` - Your actual macOS username
- `<your-password-manager>` - Your password manager name
- Repository names (gdrive1, gdrive2, etc.) - Match your rclone configuration

The scripts will fail if placeholders are not replaced.
