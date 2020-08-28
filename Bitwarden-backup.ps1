#	Bitwarden-Attachment-Exporter
#	Marviins, edited by justincswong

# Initialization Step
$username   = "REPLACE WITH USERNAME"			# keep the quotes, replace with your username
$server		= $null								# use quotes and only change if using a self-hosted server, e.g. $server = "https://vault.mydomain.com"
$extension  = "json"                     		# csv or json, keep the quotes, your output file format
$gpg        = $false                    		# $true or $false, true = gpg encrypt     false = skip gpg encrypt
$keyname    = "keyName"                 		# gpg recipient, only required if gpg encrypting
$securedlt  = $false                   		 	# $true or $false, true = secure delete   false = skip secure delete
$key        = $null                     		# don't change this

if($server){
	Write-Host "`nUsing self-hosted Bitwarden vault ($server)"
	bw config server $server
	write-host "`n"
}else{
	Write-Host "`nUsing default Bitwarden vault (https://vault.bitwarden.com)"
	bw config server https://vault.bitwarden.com
	write-host "`n"
}	
  
# Master Password Prompt
$masterPass = Read-Host -assecurestring "Please enter your master password"
$masterPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($masterPass))

# Attempt Login
while ($key -eq $null) {
    try {
        $key = bw login $username $masterPass --raw
        if ($key -eq $null) {
            throw "InvalidPasswordException"
        }
    }
    catch {
        $masterPass = Read-Host -assecurestring "`nPlease re-enter your master password"
        $masterPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($masterPass))
    }
}

Write-Host "You have logged in." -ForegroundColor Green
$env:BW_SESSION="$key"

# Specify directory and filenames
$backupFolder = 'Backup'
$backupFile = (get-date -Format "yyyyMMdd_hhmmss") + "_Bitwarden_backup.$extension"
$attachmentFolder = (get-date -Format "yyyyMMdd_hhmmss") + '_Attachments'

# Backup Vault
Write-Host "`nSyncing Bitwarden Vault"
bw sync
write-host "`n"
Write-Host "`nExporting Bitwarden Vault"
bw export --output "$backupFolder\$backupFile" --format $extension $masterPass

# Backup Attachments
$vault = bw list items | ConvertFrom-Json
foreach ($item in $vault){
	if($item.PSobject.Properties.Name -contains "Attachments"){
		foreach ($attachment in $item.attachments){
			$username = $item.Login.Username
            if($username -ne $null){
                $exportName = '[' + $item.name + ' - ' + $username + '] - ' + $attachment.fileName
            }else{
                $exportName = '[' + $item.name + '] - ' + $attachment.fileName
            }
			bw get attachment $attachment.id --itemid $item.id --output "$backupFolder\$attachmentFolder\$exportName"
			Write-Host "`n"
	    }
    }
}

# Backup Organization Vault (if exists)
Write-Host "`nSearching for Organization Vault(s)."
$orgVault = bw list items --organizationid notnull | ConvertFrom-Json
if($orgVault -ne $null){
    Write-Host "Organizations vaults found!" -ForegroundColor Green
	$orgIDs = $($orgVault.organizationid) | Sort-Object | Get-Unique
    $orgs = bw list organizations | ConvertFrom-Json
    foreach($orgID in $orgIDs){
        $organization = $orgs | Where-Object {$_.id -eq $orgId}
        $backupOrgFile = (get-date -Format "yyyyMMdd_hhmmss") + "_BitwardenOrg_" + $organization.name + "_backup.$extension"
        Write-Host "`nExporting Bitwarden Organization Vault:" $organization.name
        bw export --organizationid $orgID --output "$backupFolder\$backupOrgFile" --format $extension $masterPass
        Write-Host "`n"
    } 
}else{
	Write-Host "`nNo organizations vaults found!"
}

# Logging Out/Termination Prep
Write-Host "`nYour vault(s) has been successfully backed up." -ForegroundColor Green
Write-Host "`nLogging out vault."
bw logout
"`n"

# Terminate if not GPG encrypting
if(!$gpg){
    pause
    exit
}else{
    # GPG Encryption Prep
    $cdir = (Get-Item -Path '.\' -Verbose).FullName + "\$backupFolder"
    Set-Location $cdir

    # GPG Encryption Step
    Write-Host "Your backup file is now being encrypted with key: " -NoNewline
    Write-Host $keyname -ForegroundColor Yellow -NoNewline
    Write-Host "."

    try{
        gpg --output "$backupFile.gpg" --encrypt --recipient $keyname $backupFile
        if(!(Test-Path -path "$backupFile.gpg")){
            throw "InvalidRecipientException"
        }
        Write-Host "Your backup file has been successfully encrypted!" -ForegroundColor Green
    }
    catch{
        Write-Host "ERROR: Please open the script and review your recipient.`n" -ForegroundColor DarkRed
    }
    finally{
        # File Cleanup
        Write-Host "`nCleaning up the Backup folder. " -NoNewline
        Remove-Item -Path "$cdir\$backupFile" -Force
    
        # Secure File Cleanup
        if($securedlt){
            Write-Host "This will take some time."
            cipher /w:$cdir
        }
    }
}
Write-Host "`nFile cleanup completed." -ForegroundColor Green
pause 
exit