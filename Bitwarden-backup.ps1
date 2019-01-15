#Marviins Bitwarden-backup.ps1

#copy/paste your session key here
$key = 'sv0Jn8gjYaL1QCyZnmaobZDHEZQ=============================================='

#Specify directory and filenames
$backupFolder = 'Backup'
$backupFile = (get-date -Format "yyyyMMdd_hhmmss") + '_Bitwarden-backup.json'
$attachmentFolder = (get-date -Format "yyyyMMdd_hhmmss") + '_Attachments'

#Backup Vault
Write-Host "The masterpassword is required to export the vault"
$masterPass = Read-Host -assecurestring "Please enter your masterpassword"
$masterPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($masterPass))

Write-Host "Exporting Bitwarden Vault"
.\bw.exe export --output "$backupFolder\$backupFile" --format json --session $key $masterPass


#Backup Attachments
$vault = .\bw.exe list items --session $key | ConvertFrom-Json

foreach ($item in $vault){
    if($item.PSobject.Properties.Name -contains "Attachments"){
       foreach ($attachment in $item.attachments){
           $exportName = '[' + $item.name + '] - ' + $attachment.fileName
           write-host "Exporting attachments of item: " $item.name
         .\bw get attachment $attachment.id --itemid $item.id --output "$backupFolder\$attachmentFolder\$exportName" --session $key
       }
    }
}