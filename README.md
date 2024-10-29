# clamav-uploads-scanner
This script watches for changes in your domains files and will scan set extensions for malware using ClamAV docker contianer. Malicious files are quarantined in per-user directories.


- extensions.txt contains extensions to scan
- docker-compose.yml starts ClamAV container
- domains.list is a list of paths to eatch for changes
- run.sh is the script itself
