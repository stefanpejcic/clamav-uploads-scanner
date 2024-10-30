#!/bin/bash

DOMAINS_LIST="/etc/openpanel/clamav/domains.list"
EXTENSIONS_FILE="/etc/openpanel/clamav/extensions.txt"
CLAMAV_CONTAINER="clamav"
DOCKER_COMPOSE_FILE="/root/docker-compose.yml"
LOG_FILE="/var/log/openpanel/user/clamav.json"
SCAN_DELAY=60  # seconds to wait for load
BATCH_FILES=10 # number of files to start batch

# Create necessary directories and files
mkdir -p "$(dirname "$DOMAINS_LIST")"
touch "$DOMAINS_LIST"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Load extensions
load_extensions() {
    if [[ -f "$EXTENSIONS_FILE" ]]; then
        EXTENSIONS=$(tr '\n' '|' < "$EXTENSIONS_FILE" | sed 's/|$//')
        echo "Loaded extensions to scan: $EXTENSIONS"
    else
        echo "Extensions file not found at $EXTENSIONS_FILE. Exiting."
        exit 1
    fi
}

# Scan file
scan_file() {
    local file="$1"
    echo "Scanning file: $file"
    
    # Get user's home directory for quarantine path
    local user_home
    user_home=$(echo "$file" | awk -F'/' '{print "/"$2"/"$3}')
    local quarantine_dir="$user_home/.quarantine"

    mkdir -p "$quarantine_dir"

    scan_result=$(docker exec "$CLAMAV_CONTAINER" clamscan --infected --move="$quarantine_dir" "$file" 2>&1)
    
    if [[ $? -eq 0 ]]; then
        if [[ "$scan_result" =~ "FOUND" ]]; then
            local reason=$(echo "$scan_result" | grep "$file" | awk -F'FOUND' '{print $2}' | xargs)
            # Log it
            echo "{ \"timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\", \"file\": \"$file\", \"quarantine_path\": \"$quarantine_dir\", \"reason\": \"$reason\" }," >> "$LOG_FILE"
            echo "File quarantined: $file - Reason: $reason"
        else
            echo "File is clean: $file"
        fi
    else
        echo "Error scanning file: $file"
    fi
}

# Process events in batches
process_events() {
    local event_file="$1"
    while IFS= read -r file
    do
        if [[ -f "$file" && "$file" =~ \.($EXTENSIONS)$ ]]; then
            scan_file "$file" &
            sleep "$SCAN_DELAY"
        fi
    done < "$event_file"
}

# Run ClamAV container
start_clamav_service() {
    echo "Starting ClamAV Docker service..."
    if [[ -f "$DOCKER_COMPOSE_FILE" ]]; then
        echo "Starting ClamAV service for OpenPanel."
        docker compose -f "$DOCKER_COMPOSE_FILE" up -d clamav || { echo "Failed to start ClamAV service."; exit 1; }
    else
        echo "OpenPanel is not installed, starting standalone ClamAV service."
        if [[ -f "docker-compose.yml" ]]; then
            docker compose up -d clamav || { echo "Failed to start standalone ClamAV service."; exit 1; }
        else
            echo "Error: No docker-compose.yml file found in the current directory. Please follow the install instructions from README.md file."
            exit 1
        fi
    fi
}

# Trap signals for graceful exit
trap "exit" INT TERM
trap "kill 0" EXIT

# MAIN
load_extensions
start_clamav_service

while true; do
    if [[ -f "$DOMAINS_LIST" ]]; then
        while IFS= read -r dir_path; do
            if [[ -d "$dir_path" ]]; then
                inotifywait -m -e close_write,create "$dir_path" --format '%w%f' | while read file; do
                    if [[ -e "$file" ]]; then
                        echo "$file" >> /tmp/event_files.txt
                    fi

                    if (( $(wc -l < /tmp/event_files.txt) >= BATCH_FILES )); then
                        process_events /tmp/event_files.txt
                        > /tmp/event_files.txt  # Clear the temp file after processing
                    fi
                done &
            fi
        done < "$DOMAINS_LIST"
    else
        echo "File $DOMAINS_LIST does not exist. Waiting..."
        sleep 10  # Wait before checking again
    fi
done

wait  # Wait for all background jobs to finish before exiting
