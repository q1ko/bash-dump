#!/bin/bash

# Prompt for username
read -p "Enter the username for the Teleport user: " teleport_username

# Prompt for FQDN
read -p "Enter the FQDN for the Teleport cluster: " teleport_fqdn

echo "$teleport_username $teleport_fqdn"

curl https://goteleport.com/static/install.sh | bash -s 15.1.1

apt install systemctl openssl -y

# Define variables
teleport_host_privkey="/var/lib/teleport/privkey.pem"
teleport_host_fullchain="/var/lib/teleport/fullchain.pem"
teleport_cluster_name="$teleport_fqdn"
teleport_public_addr="$teleport_fqdn:443"

# Generate private key if not exists
if [ ! -f "$teleport_host_privkey" ]; then
    openssl genpkey -algorithm RSA -out "$teleport_host_privkey" 
fi

# Generate certificate if not exists
if [ ! -f "$teleport_host_fullchain" ]; then
    openssl req -new -key "$teleport_host_privkey" -x509 -days 365 -out "$teleport_host_fullchain" -subj "/CN=*.${teleport_fqdn}" 
fi

# Run teleport configure command
teleport configure -o file \
    --cluster-name="$teleport_cluster_name" \
    --public-addr="$teleport_public_addr" \
    --cert-file="$teleport_host_fullchain" \
    --key-file="$teleport_host_privkey" 

# Path to teleport.service file
teleport_service_file="/usr/lib/systemd/system/teleport.service"

# Check if the teleport.service file exists
if [ ! -f "$teleport_service_file" ]; then
    echo "Error: teleport.service file not found at $teleport_service_file"
    exit 1
fi

# Absolute path to pkill command
pkill_path="/usr/bin/pkill"

# Replace ExecReload directive with absolute path to pkill
sed -i "s|^ExecReload=.*|ExecReload=$pkill_path -HUP -L -F /run/teleport.pid|" "$teleport_service_file"

# Reload the Systemd daemon to apply changes
systemctl daemon-reload

echo "Fixed teleport.service file."

systemctl enable teleport
systemctl start teleport

clear

tctl users add $teleport_username --roles=editor,access --logins=root,ubuntu,ec2-user
