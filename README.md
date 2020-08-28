# Bitwarden Exporter

## Requirements
Before you can use this Powershell script you'll have to download the official [Bitwarden CLI](https://github.com/bitwarden/cli)

Optional:   
If you choose to use the GPG encryption feature, you must already have an implementation of GPG.

## How to use
After installing the Bitwarden CLI, right click on BitwardenExporter.ps1 and select "Edit".  
```
-Change "REPLACE WITH USERNAME" with your Bitwarden username.  
-Replace $server with a self-hosted instance if needed. E.g. $server = "https://vault.mydomain.com"  
-Choose to export your vault in .csv or .json format. (json is the default)  
-Choose to enable GPG encryption or not. (It is not enabled by default)  
-If you enable GPG encryption, replace $keyname with the recipient. i.e. Your key's name or email address  
-Choose to enable secure deletion of files. (If enabled, process can take over 30 minutes)
```
1. Copy the BitwardenExporter.ps1 file to the directory where you'd like your backup to be.
	If you are using Veracrypt, I recommend for you to copy this into your mounted Veracrypt drive.
2. Right click on the file and select "Run with PowerShell".
3. Your backup will begin and will be in the folder "Backup".

![Screenshot](https://github.com/marviins87/BitwardenExporter/blob/master/screenshot.png)

## Output of the script
- Backup\
  - timestamp_Attachments\
	- [item1] - attachment1
	- [item1] - attachment2
	- [item1] - attachment3
	- [item2] - attachment
	- [item3 - Username1] - attachment
	- [item3 - Username2] - attachment
  - timestamp_Bitwarden_backup.json (default)
  - timestamp_Bitwarden_backup.csv
  - timestamp_Bitwarden_backup.csv.gpg
  - timestamp_Bitwarden_backup.json.gpg
  - timestamp_BitwardenOrg_OrganizationName_backup.json

## NOTE
1. Enabling $securedlt can cause the backup process to take over 30 minutes. It completely overwrites the empty space in your Backup folder  to ensure that your unencrypted vault backup cannot be recovered.

2. Currently, the GPG encryption only supports the encryption of the backed up vault file. It does not encrypt attachments yet.

## Credits & Special Thanks To
[justincswong](https://github.com/justincswong) for providing a very nice update to the script!

## LICENSE
This software is released under the terms of the MIT License, please see the [LICENSE file](https://github.com/marviins87/BitwardenExporter/blob/master/LICENSE).