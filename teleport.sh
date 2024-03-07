#!/bin/bash

curl https://goteleport.com/static/install.sh | bash -s 15.1.1

clear

# Prompt for username
read -p "Enter the username for the Teleport user: " teleport_username

# Prompt for FQDN
read -p "Enter the FQDN for the Teleport cluster: " teleport_fqdn

# Define variables
teleport_host_privkey="/var/lib/teleport/privkey.pem"
teleport_host_fullchain="/var/lib/teleport/fullchain.pem"
teleport_cluster_name="$teleport_fqdn"
teleport_public_addr="$teleport_fqdn:443"

# Generate private key if not exists
if [ ! -f "$teleport_host_privkey" ]; then
    sudo openssl genpkey -algorithm RSA -out "$teleport_host_privkey" >/dev/null
fi

# Generate certificate if not exists
if [ ! -f "$teleport_host_fullchain" ]; then
    sudo openssl req -new -key "$teleport_host_privkey" -x509 -days 365 -out "$teleport_host_fullchain" -subj "/CN=*.${teleport_fqdn}" >/dev/null
fi

# Run teleport configure command
sudo teleport configure -o file \
    --cluster-name="$teleport_cluster_name" \
    --public-addr="$teleport_public_addr" \
    --cert-file="$teleport_host_fullchain" \
    --key-file="$teleport_host_privkey" >/dev/null

# Enable and start Teleport service
sudo systemctl enable teleport >/dev/null
sudo systemctl start teleport >/dev/null
