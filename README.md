# ClamAV Upload Scanner 🔍📁

Automatically scan newly uploaded or modified files with [ClamAV](https://github.com/Cisco-Talos/clamav), quarantining any detected threats in a user-specific directory—ideal for shared hosting environments.

You can configure which file extensions to scan and specify folders to monitor for changes.

-----

## Install

This script was initially developed for use with [OpenPanel](https://openpanel.com), but it can be used with any control panel as long as you provide a list of paths to monitor (Docker and inotify will be installed).


1. clone this repo:
   ```bash
   git clone https://github.com/stefanpejcic/clamav-uploads-scanner /usr/local/clamav-uploads-scanner/
   ```
2. install the service by running:
   ```bash
   bash /usr/local/clamav-uploads-scanner/install.sh
   ```

The installation script will check if OpenPanel is in use. If it is, no additional configuration is necessary, as the document root for the domains will be automatically collected. However, if OpenPanel is not being used, you will need to specify the paths to monitor in the `domains.list` file and set the extensions to scan in the `extensions.txt` file.
