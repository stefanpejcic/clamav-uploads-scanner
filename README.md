# ClamAV Upload Scanner

Automatically scan newly uploaded or modified files with ClamAV, quarantining any detected threats in a user-specific directory—ideal for shared hosting environments.

You can configure which file extensions to scan and specify folders to monitor for changes.

-----

## Install

This script was initially developed for use with [OpenPanel](https://openpanel.com), but it can be used with any control panel as long as you provide a list of paths to monitor (Docker and inotify will be installed).


1. clone this repo:
   ```bash
   git clone https://github.com/stefanpejcic/clamav-uploads-scanner
   ```
2. enter 📁, set extensions in `extensions.txt` file and paths in `domains.list`.
3. install the service by running:
   ```bash
   bash install.sh
   ```

