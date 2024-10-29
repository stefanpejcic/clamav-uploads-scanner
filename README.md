# ClamAV Upload Scanner

Automatically scan newly uploaded or modified files with ClamAV, quarantining any detected threats in a user-specific directory—ideal for shared hosting environments.

You can configure which file extensions to scan and specify folders to monitor for changes.

-----

This script was initially developed for use with [OpenPanel](https://openpanel.com), but it can be used with any control panel as long as you provide a list of paths to monitor and have Docker and inotify installed.
