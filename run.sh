#!/bin/bash

DOMAINS_LIST="/etc/openpanel/clamav/domains.list"
EXTENSIONS_FILE="/etc/openpanel/clamav/extensions.txt"
CLAMAV_CONTAINER="clamav"
DOCKER_COMPOSE_FILE="/root/docker-compose.yml"
LOG_FILE="/var/log/openpanel/user/clamav.json"
SCAN_DELAY=60  # seconds to wait for load
BATCH_FILES=10 # no of files to start batch



mkdir -p "$(dirname "$DOMAINS_LIST")"
touch "$DOMAINS_LIST"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# read extensions 
load_extensions() {
    if [[ -f "$EXTENSIONS_FILE" ]]; then
        EXTENSIONS=$(tr '\n' '|' < "$EXTENSIONS_FILE" | sed 's/|$//')
        echo "Loaded extensions to scan: $EXTENSIONS"
    else
        echo "Extensions file not found at $EXTENSIONS_FILE. Exiting."
        exit 1
    fi
}

# scan file
scan_file() {
    local file="$1"
    echo "Scanning file: $file"
    
    # get user's home directory for quarantine path
    local user_home
    user_home=$(echo "$file" | awk -F'/' '{print "/"$2"/"$3}')
    local quarantine_dir="$user_home/.quarantine"

    mkdir -p "$quarantine_dir"

    scan_result=$(docker exec "$CLAMAV_CONTAINER" clamscan --infected --move="$quarantine_dir" "$file" 2>&1)
    
    if [[ ! -f "$file" ]]; then
        # get signature
        local reason=$(echo "$scan_result" | grep "$file" | awk -F'FOUND' '{print $2}' | xargs)
        
        # log it
        echo "{ \"timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\", \"file\": \"$file\", \"quarantine_path\": \"$quarantine_dir\", \"reason\": \"$reason\" }," >> "$LOG_FILE"
        echo "File quarantined: $file - Reason: $reason"
    else
        echo "File is clean: $file"
    fi
}

# in batches
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


# run clamav container
start_clamav_service() {
    echo "Starting ClamAV Docker service..."
    if [[ -f "$DOCKER_COMPOSE_FILE" ]]; then
        echo "Starting ClamAV service for OpenPanel."
        docker compose -f "$DOCKER_COMPOSE_FILE" up -d clamav
    else
        echo "OpenPanel is not installed, starting standalone ClamAV service."
        if [[ -f "docker-compose.yml" ]]; then
            docker compose up -d clamav
        else
            echo "Error: No docker-compose.yml file found in the current directory. Please follow the install instructions from README.md file."
            exit 1
        fi
    fi
}



# MAIN

load_extensions
start_clamav_service


while true; do
    if [[ -f "$DOMAINS_LIST" ]]; then
        # Prepare a list of directories to monitor
        dirs_to_monitor=()
        
        while IFS= read -r dir_path; do
            if [[ -d "$dir_path" ]]; then
                dirs_to_monitor+=("$dir_path")
            fi
        done < "$DOMAINS_LIST"

        # Start inotifywait on all directories
        if [ ${#dirs_to_monitor[@]} -gt 0 ]; then
            inotifywait -m -r -e close_write,create "${dirs_to_monitor[@]}" --format '%w%f' | while read file; do
                if [[ -e "$file" ]]; then
                    echo "$file" >> /tmp/event_files.txt
                fi
        
                # Process in batches to avoid hitting limits
                if (( $(wc -l < /tmp/event_files.txt) >= BATCH_FILES )); then
                    process_events /tmp/event_files.txt
                    > /tmp/event_files.txt  # Clear the temp file after processing
                fi
            done &
        fi
    else
        echo "File $DOMAINS_LIST does not exist. Waiting..."
        sleep 10
    fi
done

