#	Bitwarden-Attachment-Exporter
#	Marviins, edited by justinc.s.wong

    # Enter Master Password
    $username   = "REPLACE USERNAME HERE" #keep the quotes
    $masterPass = Read-Host -assecurestring "Please enter your master password"
    $masterPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($masterPass))
    $key = $null
    

while ($key -eq $null) {
    try {
        $key = bw login $username $masterPass --raw
        "`n"
        if ($key -eq $null) {
            throw "Invalid Password Exception"
        }
    }
    catch {
        $masterPass = Read-Host -assecurestring "`nPlease re-enter your master password"
        $masterPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($masterPass))
    }
}

Write-Host "You have logged in." -ForegroundColor Green
$env:BW_SESSION="$key"

#Specify directory and filenames
$backupFolder = 'Backup'
$backupFile = (get-date -Format "yyyyMMdd_hhmmss") + '_Bitwarden_backup.csv'
$attachmentFolder = (get-date -Format "yyyyMMdd_hhmmss") + '_Attachments'

    #Backup Vault
    Write-Host "`nExporting Bitwarden Vault"
    bw export --output "$backupFolder\$backupFile" --format csv $masterPass
    write-host "`n"

    #Backup Attachments
    $vault = bw list items | ConvertFrom-Json

    foreach ($item in $vault){
        if($item.PSobject.Properties.Name -contains "Attachments"){
           foreach ($attachment in $item.attachments){
              $exportName = '[' + $item.name + '] - ' + $attachment.fileName
            bw get attachment $attachment.id --itemid $item.id --output "$backupFolder\$attachmentFolder\$exportName"
	    	write-host "`n"
	     }
      }
    }

    write-host "`nThe Vault has been successfully backed up."
    bw logout
    "`n"
    pause
