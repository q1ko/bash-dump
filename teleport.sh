#!/bin/bash

# Prompt for username
read -p "Enter the username for the Teleport user: " teleport_username

# Prompt for FQDN
read -p "Enter the FQDN for the Teleport cluster: " teleport_fqdn

# Prompt for ACME email
read -p "Enter the email for ACME: " teleport_email

apt update && apt install curl -y
curl https://goteleport.com/static/install.sh | bash -s 15.1.1


# Define variables
teleport_cluster_name="$teleport_fqdn"
teleport_public_addr="$teleport_fqdn:443"

# Run teleport configure command
teleport configure -o file \
    --acme --acme-email=$teleport_email \
    --cluster-name=$teleport_fqdn

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

sleep 3

tctl users add $teleport_username --roles=editor,access --logins=root,ubuntu,ec2-user
