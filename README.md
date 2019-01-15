# Bitwarden Attachment Export

## Requirements
Before you can use this Powershell script you'll have to download the official [Bitwarden CLI](https://github.com/bitwarden/cli)

## How to use
After installing the Bitwarden CLI you can login to your vault using the following commands:
```
bw login
```

If the login is succesful you'll get a session key. Put that session key in the `$key` variable of Bitwarden-backup.ps1 and start the script.