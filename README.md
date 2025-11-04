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
└── Pdf_files/
    └── [Same files in PDF format]
```

## Quick Start

1. **Setup**: Read [`ENG_Backup_Guide_Restic+Rclone.pdf`](Pdf_files/ENG_Backup_Guide_Restic+Rclone.pdf)
3. **Recovery**: Follow [`ENG_Disaster_Recovery_Guide.pdf`](Pdf_files/ENG_Disaster_Recovery_Guide.pdf) if needed

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

