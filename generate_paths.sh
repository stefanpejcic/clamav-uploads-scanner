# ONLY TO BE USED ON OP SERVER TO ADD EXISTING DOMAINS!

# Get all domains
all_domains=$(opencli domains-all)
domains_list="/etc/openpanel/clamav/domains.list"

echo > $domains_list


# Loop through each domain
for domain in $all_domains; do
    # Get the ownership information for the domain
    whoowns_output=$(opencli domains-whoowns "$domain")
    
    # Extract the owner from the output
    owner=$(echo "$whoowns_output" | awk -F "Owner of '$domain': " '{print $2}')
    
    # Check if the owner is not empty
    if [ -n "$owner" ]; then
        # Define the path for the domain
        path_for_domain="/home/$owner/$domain"
        
        # Append the path to the domains_list file
        echo "$path_for_domain" >> domains_list
    fi
done
