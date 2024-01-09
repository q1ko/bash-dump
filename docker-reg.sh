#!/bin/bash

# Specify the registry to add
registry="nexus.lan:8082"

# Path to the Docker daemon configuration file
daemon_config="/etc/docker/daemon.json"

# Check if the daemon.json file exists, create if it doesn't
if [ ! -f "$daemon_config" ]; then
    sudo touch "$daemon_config"
    echo "{}" | sudo tee "$daemon_config"
fi

# Add the registry to the list of insecure registries in daemon.json
sudo jq -e --arg reg "$registry" '. += { "insecure-registries": [ $reg ] }' "$daemon_config" | sudo tee "$daemon_config" > /dev/null

# Restart Docker daemon to apply the changes
sudo systemctl restart docker
