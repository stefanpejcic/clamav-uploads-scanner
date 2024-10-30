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


remove_files(){
    scanner_dir="/usr/local/clamav-uploads-scanner"
    echo "Deleting $scanner_dir" 
    rm -rf $scanner_dir
}

remove_monitoring(){
    echo "Removing service from OpenAdmin > Services Status" 
    service_to_remove="clamav_monitor"
    services_file="/etc/openpanel/openadmin/config/services.json"
    jq "del(.[] | select(.real_name == \"$service_to_remove\"))" "$services_file" > tmp.$$.json && mv tmp.$$.json "$services_file"
    echo "Service '$service_to_remove' removed from $services_file."
}


remove_service
remove_files
remove_monitoring

echo "DONE"
