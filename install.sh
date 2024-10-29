#!/bin/bash

# Paths
PANEL_DIR="/usr/local/panel/"
SERVICE_FILE="/etc/systemd/system/clamav_monitor.service"

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    # Update package index and install required packages
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Add Docker's official APT repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Update package index again and install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce
}

# Function to install inotify-tools
install_inotify() {
    echo "Installing inotify-tools..."
    sudo apt-get install -y inotify-tools
}

# Function to add the ClamAV monitoring service
add_service() {
    echo "Adding ClamAV monitoring service..."
    
    cp ./clamav-scanner.service $SERVICE_FILE
    sudo systemctl daemon-reload
    sudo systemctl enable clamav_monitor.service
    sudo systemctl start clamav_monitor.service

    echo "ClamAV monitoring service added and started."
}

# Check if /usr/local/panel/ exists
if [[ -d "$PANEL_DIR" ]]; then
    echo "$PANEL_DIR exists."
    add_service
else
    echo "$PANEL_DIR does not exist. Installing Docker and inotify-tools..."
    install_docker
    install_inotify
    add_service
fi
