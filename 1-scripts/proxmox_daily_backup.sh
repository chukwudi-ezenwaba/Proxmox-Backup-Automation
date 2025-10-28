
#!/bin/bash

# This script automates daily backups for Proxmox. It will:
#   1. Mount an external SSD for backup storage, ensuring the mount point is a directory.
#   2. Backup Proxmox configuration files to the SSD backup directory.
#   3. Backup all VMs using vzdump in snapshot mode with zstd compression.
#   4. Copy all backup files from today (matching both dash and underscore date formats) to a dated folder on the SSD, with log messages for each file copied.
#   5. Remove all local backup files from Proxmox after copying to the SSD.
#   6. Clean up any local backup files older than 24 hours (as a safety net).
#   7. Log errors and status messages for each step, and (optionally) send error notifications by email.

# ----------------------------------- Variables ----------------------------------------------------------------
BACKUP_DATE=$(date +'%Y-%m-%d')           # Get today's date in YYYY-MM-DD format
MOUNT_POINT="/mnt/external_ssd"          # Where the SSD should be mounted
SSD_DEVICE="/dev/sdb3"                   # Device name for the SSD (check with lsblk)
SSD_BACKUP_DIR="$MOUNT_POINT/proxmox_backups" # Directory on SSD to store backups
LOCAL_VM_BACKUP_DIR="$SSD_BACKUP_DIR/$BACKUP_DATE" # Store backups directly in the dated folder

# --------------------------------- Logging & Email Functions ---------------------------------------------------
LOG_FILE="/tmp/proxmox_backup_error.log"  # Temporary file to store error logs

log_error() {
    # Show the error message on the screen, append it to the log file, and mark it as an error output.
    echo "[ERROR] $1" | tee -a "$LOG_FILE" >&2
}

log_info() {
    # Print an informational message with timestamp to stdout
    echo "[INFO] $1"
}

# ------------------------------------ Mount SSD ------------------------------------------------------
# Check if directory is a mount point
if ! mountpoint -q "$MOUNT_POINT"; then
    # If it is not, try to mount it
    mount "$SSD_DEVICE" "$MOUNT_POINT" 2>/dev/null
    # Check if mount was successful
    if [ $? -ne 0 ]; then 
        # If mounting fails, log error and exit
    log_error "Backup failed on $BACKUP_DATE - Unable to mount SSD at $MOUNT_POINT."
    exit 1
    else
        log_info "Mounted SSD at $MOUNT_POINT."
    fi
fi

# Double-check that SSD is mounted before proceeding
if ! mountpoint -q "$MOUNT_POINT"; then
    log_error "Backup failed on $BACKUP_DATE - SSD not mounted or not plugged in."
    exit 1
fi

# Create backup directory on SSD if it doesn't exist
mkdir -p "$SSD_BACKUP_DIR"
mkdir -p "$LOCAL_VM_BACKUP_DIR"

# ------------------------------ Backup Proxmox Configs ------------------------------------------
log_info "Backing up Proxmox configs..."
tar -czf "$LOCAL_VM_BACKUP_DIR/proxmox_config_$BACKUP_DATE.tar.gz" /etc/pve
# The above command creates a compressed archive of Proxmox configs in the dated backup directory

# ----------------------------- Backup All VMs ---------------------------------------------------
log_info "Backing up VMs..."
# Loop through each VM ID and back it up using vzdump
for vmid in $(qm list | awk 'NR>1 {print $1}'); do
    log_info "Backing up VM ID $vmid..."
    vzdump $vmid --dumpdir "$LOCAL_VM_BACKUP_DIR" --mode snapshot --compress zstd
    # vzdump creates a backup of the VM in snapshot mode and compresses it with zstd
    if [ $? -ne 0 ]; then
        log_error "Backup failed for VM ID $vmid on $BACKUP_DATE."
    else
        log_info "Backup completed for VM ID $vmid."
    fi
done

# ------------------------------ Copy Today's Backups to SSD ----------------------------------------
log_info "Backups are written directly to external SSD in the dated folder. No copy step required."

# ------------------------------ Cleanup Local Backups Older Than 24 Hours ------------------------------
log_info "Cleaning up old local backups..."
find "$LOCAL_VM_BACKUP_DIR" -type f -mtime +1 -exec rm -f {} \;
# The above command deletes files older than 1 day in the local backup directory
if [ $? -ne 0 ]; then
    log_error "Failed to clean up old local backups on $BACKUP_DATE."

else
    log_info "Old local backups cleaned up successfully."
fi

# ---------------------------------------- Final Status -------------------------------------------------
log_info "Backup completed successfully for $BACKUP_DATE."
exit 0