#!/bin/bash

#==============================================================================
# RESTIC REPOSITORY VERIFICATION SCRIPT
# Verify integrity of Google Drive and MEGA repositories
#==============================================================================

# CONFIGURATION
REPO_PRIMARY="rclone:gdrive_union:/restic-backup"
REPO_MIRROR="rclone:mega_union:/restic-backup"
KEYCHAIN_SERVICE="restic-backup"
LOG_DIR="$HOME/.local/share/restic-backup/logs"

# Timestamp for log
TIMESTAMP=$(date +"%Y%m%d")
LOG_FILE="$LOG_DIR/verify-$TIMESTAMP.log"

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

#==============================================================================
# VERIFICATION START
#==============================================================================

log "=========================================="
log "STARTING REPOSITORY INTEGRITY VERIFICATION"
log "=========================================="
log "Primary repository: $REPO_PRIMARY"
log "Mirror repository: $REPO_MIRROR"

# Retrieve password from Keychain
log ""
log "Retrieving password from Keychain..."
export RESTIC_PASSWORD=$(security find-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" -w 2>&1)

if [ $? -ne 0 ]; then
    log "❌ ERROR: Unable to retrieve password from Keychain"
    notify "Verification Failed" "Error retrieving password from Keychain"
    exit 1
fi

log "✅ Password retrieved successfully"

# Variables to track verification status
GDRIVE_CHECK_OK=false
MEGA_CHECK_OK=false

#==============================================================================
# VERIFY GOOGLE DRIVE REPOSITORY
#==============================================================================

log ""
log "=========================================="
log "VERIFYING GOOGLE DRIVE REPOSITORY"
log "=========================================="

START_TIME=$(date +%s)

restic -r "$REPO_PRIMARY" check 2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    log "✅ Google Drive repository: INTACT (verified in ${ELAPSED}s)"
    GDRIVE_CHECK_OK=true
else
    log "❌ Google Drive repository: ERRORS DETECTED"
    GDRIVE_CHECK_OK=false
fi

#==============================================================================
# VERIFY MEGA REPOSITORY
#==============================================================================

log ""
log "=========================================="
log "VERIFYING MEGA REPOSITORY"
log "=========================================="

START_TIME=$(date +%s)

restic -r "$REPO_MIRROR" check 2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    log "✅ MEGA repository: INTACT (verified in ${ELAPSED}s)"
    MEGA_CHECK_OK=true
else
    log "❌ MEGA repository: ERRORS DETECTED"
    MEGA_CHECK_OK=false
fi

#==============================================================================
# FINAL SUMMARY AND NOTIFICATIONS
#==============================================================================

log ""
log "=========================================="
log "VERIFICATION SUMMARY"
log "=========================================="
log "Google Drive: $([ "$GDRIVE_CHECK_OK" = true ] && echo "✅ INTACT" || echo "❌ ERRORS")"
log "MEGA: $([ "$MEGA_CHECK_OK" = true ] && echo "✅ INTACT" || echo "❌ ERRORS")"
log "Log saved in: $LOG_FILE"
log "=========================================="

# Final notifications based on result
if [ "$GDRIVE_CHECK_OK" = true ] && [ "$MEGA_CHECK_OK" = true ]; then
    log "✅ VERIFICATION COMPLETED: All repositories are intact"
    notify "✅ Verification Completed" "All repositories are intact"
    exit 0
elif [ "$GDRIVE_CHECK_OK" = true ] || [ "$MEGA_CHECK_OK" = true ]; then
    log "⚠️  WARNING: Some repositories have errors"
    notify "⚠️ Verification: Partial Errors" "Check log for details"
    exit 1
else
    log "🔴 ERROR: Both repositories have errors"
    notify "🔴 Verification: Critical Errors" "Both repositories have errors!"
    exit 2
fi

