# Bitwarden Attachment Exporter

## Requirements
Before you can use this Powershell script you'll have to download the official [Bitwarden CLI](https://github.com/bitwarden/cli)

## How to use
After installing the Bitwarden CLI, right click on Bitwarden-backup.ps1 and select "Edit".
Change "REPLACE USERNAME HERE" to be your Bitwarden username.

1. Copy the Bitwarden-backup.ps1 file to the directory where you'd like your backup to be.
2. Right click on the file and select "Run with PowerShell".
3. Your backup will begin and will be in the folder "Backup".

![Screenshot](https://github.com/justincswong/Bitwarden-Attachment-Exporter/blob/master/screenshot.png)


## Output of the script
- Backup\
  - Attachments\
	- [itemname1] - attachmentname1
	- [itemname1] - attachmentname2
	- [itemname2] - attachmentname1 
  - Bitwarden_backup.csv
