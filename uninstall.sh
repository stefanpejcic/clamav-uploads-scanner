#!/bin/bash

# Paths
PANEL_DIR="/usr/local/panel/"
SERVICE_FILE="/etc/systemd/system/clamav_monitor.service"

# Function to remove the ClamAV monitoring service
remove_service() {
    echo "Removing ClamAV monitoring service..."
    
    # Stop and disable the service
    sudo systemctl stop clamav_monitor.service
    sudo systemctl disable clamav_monitor.service
    
    # Remove the service file
    if [[ -f "$SERVICE_FILE" ]]; then
        sudo rm "$SERVICE_FILE"
        echo "ClamAV monitoring service removed."
    else
        echo "ClamAV monitoring service file does not exist."
    fi
    
    # Reload systemd to reflect changes
    sudo systemctl daemon-reload
}


remove_service() {
    echo "Removing ClamAV monitoring service..."
    
    # Stop and disable the service
    sudo systemctl stop clamav_monitor.service
    sudo systemctl disable clamav_monitor.service
    
    # Remove the service file
    if [[ -f "$SERVICE_FILE" ]]; then
        sudo rm "$SERVICE_FILE"
        echo "ClamAV monitoring service removed."
    else
        echo "ClamAV monitoring service file does not exist."
    fi
    
    # Reload systemd to reflect changes
    sudo systemctl daemon-reload
}


remove_service
scanner_dir="/usr/local/clamav-uploads-scanner"
echo "Deleting $scanner_dir" 
rm -rf $scanner_dir

echo "DONE"
