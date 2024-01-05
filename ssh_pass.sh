#!/bin/bash

read -p "Do you want to enable SSH password authentication? (y/n): " enable_password_auth

read -p "Do you want to enable root login via password? (y/n): " enable_root_login

if [ "$enable_password_auth" = "y" ]; then
    echo "Enabling SSH password authentication..."
    
    # Enable Password Authentication in SSH Config
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
fi

if [ "$enable_root_login" = "y" ]; then
    echo "Enabling root login via password..."

    # Enable Root Login with Password in SSH Config
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
fi

# Restart SSH Service if changes were made
if [ "$enable_password_auth" = "y" ] || [ "$enable_root_login" = "y" ]; then
    sudo systemctl restart sshd
    ec
