
# Proxmox Daily Backup Automation Script

This project provides an automated backup solution for Proxmox VE.  
It’s designed to back up Proxmox configuration files and all virtual machines daily, helping maintain a disaster recovery routine for home labs and small environments.

## Overview
The script performs the following:
1. Mounts an external SSD for backup storage.
2. Backs up Proxmox configuration files.
3. Backs up all VMs using `vzdump` in snapshot mode with Zstandard compression.
4. Cleans up old backups automatically.
5. Logs all actions and errors.

## Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/<yourusername>/proxmox-backup-automation.git
   cd proxmox-backup-automation

2. Copy the script to your server
sudo cp scripts/proxmox_daily_backup.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/proxmox_daily_backup.sh

3. Update the config file:
nano config/sample_env.conf

4. (Optional) Schedule with cron:
0 3 * * * /usr/local/bin/proxmox_daily_backup.sh >> /var/log/proxmox_backup.log 2>&1

## Recovery
See docs/RECOVERY_WORKFLOW.md for how to restore Proxmox configs or VMs.
