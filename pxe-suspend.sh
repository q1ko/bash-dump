#!/bin/bash

# Shut down all running VMs
for vmid in $(qm list | grep running | awk '{print $1}')
do
    echo "Shutting down VM $vmid"
    qm shutdown $vmid
done

# Stop all running containers
for ctid in $(pct list | grep running | awk '{print $1}')
do
    echo "Stopping CT $ctid"
    pct stop $ctid
done

# Suspend the Proxmox host
echo "Suspending Proxmox host..."
systemctl suspend
