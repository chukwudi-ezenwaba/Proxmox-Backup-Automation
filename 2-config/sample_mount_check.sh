#!/bin/bash
# Helper script to verify SSD mount status

MOUNT_POINT="/mnt/external_ssd"

if mountpoint -q "$MOUNT_POINT"; then
    echo "SSD mounted at $MOUNT_POINT"
else
    echo "SSD not mounted. Please check connections or fstab."
fi