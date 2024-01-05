#!/bin/bash

echo "This script will enable SSH password authentication."
read -p "Do you want to proceed? (y/n): " choice

if [ "$choice" = "y" ]; then
    # Enable Password Authentication in SSH Config
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    
    # Restart SSH Service
    sudo systemctl restart sshd
    
    echo "SSH password authentication has been enabled."
else
    echo "SSH password authentication has NOT been modified."
fi
