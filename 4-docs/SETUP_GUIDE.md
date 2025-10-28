1. Clone the repo:
   ```bash
   git clone https://github.com/<yourusername>/proxmox-backup-automation.git
   cd proxmox-backup-automation

2. Configure your environment
    Edit config/sample_env.conf to match your SSD and backup paths.

3. Make script executable
    ```bash
    chmod +x scripts/proxmox_daily_backup.sh

4. Test run manually
    ```bash
    sudo bash scripts/proxmox_daily_backup.sh

5. Schedule daily run
Add this cron job:
0 3 * * * /usr/local/bin/proxmox_daily_backup.sh >> /var/log/proxmox_backup.log 2>&1
