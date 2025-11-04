#!/bin/bash

#==============================================================================
# RESTIC BACKUP AUTOMATION SCRIPT
# Automatic backup of ~/Desktop to Google Drive and MEGA
#==============================================================================

# CONFIGURATION
BACKUP_PATH="$HOME/Desktop"
REPO_PRIMARY="rclone:gdrive_union:/restic-backup"
REPO_MIRROR="rclone:mega_union:/restic-backup"
KEYCHAIN_SERVICE="restic-backup"
LOG_DIR="$HOME/.local/share/restic-backup/logs"
DESKTOP="$HOME/Desktop"

# Retention Policy
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Timestamp for log
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_FILE="$LOG_DIR/backup-$TIMESTAMP.log"

#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================

# Function for logging (print to screen AND save to file)
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function for macOS notifications
notify() {
    osascript -e "display notification \"$2\" with title \"$1\""
}

# Function to copy log to desktop in case of error
copy_log_to_desktop() {
    cp "$LOG_FILE" "$DESKTOP/backup-error-$(date +%Y%m%d).log"
    log "⚠️  Log copied to Desktop for visibility"
}

#==============================================================================
# BACKUP START
#==============================================================================

log "=========================================="
log "STARTING RESTIC BACKUP"
log "=========================================="
log "Path to backup: $BACKUP_PATH"
log "Primary repository: $REPO_PRIMARY"
log "Mirror repository: $REPO_MIRROR"

# Retrieve password from Keychain
log ""
log "Retrieving password from Keychain..."
export RESTIC_PASSWORD=$(security find-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" -w 2>&1)

if [ $? -ne 0 ]; then
    log "❌ ERROR: Unable to retrieve password from Keychain"
    notify "Backup Failed" "Error retrieving password from Keychain"
    copy_log_to_desktop
    exit 1
fi

log "✅ Password retrieved successfully"

# Variables to track backup status
GDRIVE_SUCCESS=false
MEGA_SUCCESS=false

#==============================================================================
# BACKUP TO GOOGLE DRIVE (Primary)
#==============================================================================

log ""
log "=========================================="
log "BACKUP TO GOOGLE DRIVE (Primary)"
log "=========================================="

START_TIME=$(date +%s)

restic -r "$REPO_PRIMARY" backup "$BACKUP_PATH" \
    --verbose \
    2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    log "✅ Google Drive backup completed in ${ELAPSED}s"
    GDRIVE_SUCCESS=true

    # Apply retention policy
    log ""
    log "Applying retention policy on Google Drive..."
    log "   - Keep daily: $KEEP_DAILY"
    log "   - Keep weekly: $KEEP_WEEKLY"
    log "   - Keep monthly: $KEEP_MONTHLY"

    restic -r "$REPO_PRIMARY" forget \
        --keep-daily $KEEP_DAILY \
        --keep-weekly $KEEP_WEEKLY \
        --keep-monthly $KEEP_MONTHLY \
        --prune \
        2>&1 | tee -a "$LOG_FILE"

    if [ $? -eq 0 ]; then
        log "✅ Retention policy applied on Google Drive"
    else
        log "⚠️  Warning: Issues applying retention policy on Google Drive"
    fi
else
    log "❌ ERROR: Google Drive backup failed"
    GDRIVE_SUCCESS=false
fi

#==============================================================================
# BACKUP TO MEGA (Mirror)
#==============================================================================

log ""
log "=========================================="
log "BACKUP TO MEGA (Mirror)"
log "=========================================="

START_TIME=$(date +%s)

restic -r "$REPO_MIRROR" backup "$BACKUP_PATH" \
    --verbose \
    2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    log "✅ MEGA backup completed in ${ELAPSED}s"
    MEGA_SUCCESS=true

    # Apply retention policy
    log ""
    log "Applying retention policy on MEGA..."
    log "   - Keep daily: $KEEP_DAILY"
    log "   - Keep weekly: $KEEP_WEEKLY"
    log "   - Keep monthly: $KEEP_MONTHLY"

    restic -r "$REPO_MIRROR" forget \
        --keep-daily $KEEP_DAILY \
        --keep-weekly $KEEP_WEEKLY \
        --keep-monthly $KEEP_MONTHLY \
        --prune \
        2>&1 | tee -a "$LOG_FILE"

    if [ $? -eq 0 ]; then
        log "✅ Retention policy applied on MEGA"
    else
        log "⚠️  Warning: Issues applying retention policy on MEGA"
    fi
else
    log "❌ ERROR: MEGA backup failed"
    MEGA_SUCCESS=false
fi

#==============================================================================
# FINAL SUMMARY AND NOTIFICATIONS
#==============================================================================

log ""
log "=========================================="
log "BACKUP SUMMARY"
log "=========================================="
log "Google Drive (Primary): $([ "$GDRIVE_SUCCESS" = true ] && echo "✅ OK" || echo "❌ FAILED")"
log "MEGA (Mirror): $([ "$MEGA_SUCCESS" = true ] && echo "✅ OK" || echo "❌ FAILED")"
log "Log saved in: $LOG_FILE"
log "=========================================="

# Handle notifications and exit code based on result
if [ "$GDRIVE_SUCCESS" = true ] && [ "$MEGA_SUCCESS" = true ]; then
    # ✅ COMPLETE SUCCESS
    log "✅ BACKUP COMPLETED SUCCESSFULLY!"
    notify "✅ Backup Completed" "All backups completed successfully"
    exit 0

elif [ "$GDRIVE_SUCCESS" = true ] || [ "$MEGA_SUCCESS" = true ]; then
    # ⚠️  PARTIAL SUCCESS
    if [ "$GDRIVE_SUCCESS" = false ]; then
        log "⚠️  PARTIAL BACKUP: Google Drive failed, MEGA completed"
        notify "⚠️ Partial Backup" "Google Drive failed, MEGA completed successfully"
    else
        log "⚠️  PARTIAL BACKUP: MEGA failed, Google Drive completed"
        notify "⚠️ Partial Backup" "MEGA failed, Google Drive completed successfully"
    fi
    copy_log_to_desktop
    exit 1

else
    # 🔴 TOTAL ERROR
    log "🔴 TOTAL ERROR: Both backups failed"
    notify "🔴 Backup Failed" "ERROR: Both backups failed!"
    copy_log_to_desktop
    exit 2
fi

