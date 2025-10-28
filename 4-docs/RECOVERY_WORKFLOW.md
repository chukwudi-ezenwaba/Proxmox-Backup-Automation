In case of disaster, you can restore your Proxmox environment as follows:

 1. Restore Proxmox Configuration.
    ```bash
    tar -xzf /mnt/external_ssd/proxmox_backups/<date>/proxmox_config_<date>.tar.gz -C /

 2. Restore Virtual Machines
    ```bash
    qmrestore /mnt/external_ssd/proxmox_backups/<date>/vzdump-qemu-<vmid>-<date>.vma.zst <vmid>

3. Verify Restored VMs
Start each VM and check services