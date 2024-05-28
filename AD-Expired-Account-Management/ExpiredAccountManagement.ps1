$dateNow = Get-Date -Format 'yyyy-MM-dd'
$dateNow2 = Get-Date -Format 'yyyy-MM'
$dateNow3 = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

# Get the full path of the script directory
$scriptDirectory = $PSScriptRoot


# Créer le dossier "Export" s'il n'existe pas
$exportDirectory = Join-Path -Path $scriptDirectory -ChildPath "logsExpiredAccount"
if (-not (Test-Path -Path $exportDirectory -PathType Container)) {
    New-Item -Path $scriptDirectory -Name "logsExpiredAccount" -ItemType Directory
    Write-Output "Log Export Folder Has Been Created"
}

# Créer le dossier "Log" s'il n'existe pas
$logDirectory = Join-Path -Path $scriptDirectory -ChildPath "csvExpiredAccount"
if (-not (Test-Path -Path $logDirectory -PathType Container)) {
    New-Item -Path $scriptDirectory -Name "csvExpiredAccount" -ItemType Directory
    Write-Output "CSV Export Folder Has Been Created"
}


# Path of the script execution log file
$logFile = "$scriptDirectory\logsExpiredAccount\execution_log_$dateNow2.txt"

# Path of the CSV file
$csvFile = "$scriptDirectory\csvExpiredAccount\account_expiry_$dateNow.csv"

####################### Function to Remove Old Log Files #########################
function RemoveOldLogFiles($daysToKeep) {
    $oldFiles = Get-ChildItem -Path $scriptDirectory\logsExpiredAccount -Filter "execution_log_*.txt" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$daysToKeep)}
    
    if ($oldFiles.Count -gt 0) {
        $oldFiles | Remove-Item -Force
        "[$dateNow3] Log files older than $daysToKeep days have been deleted." | Out-File -FilePath $logFile -Append
        "[$dateNow3] Deleted log files: $($oldFiles.Name -join ', ')" | Out-File -FilePath $logFile -Append
    }
    else {
        "[$dateNow3] No log files older than $daysToKeep days to delete." | Out-File -FilePath $logFile -Append
    }
}

################################################################################

#################### MAIN ######################################################
try {
    "[$dateNow3] Start of the script." | Out-File -FilePath $logFile -Append

    # Get all users whose account is enabled and has expired
    $expiredUsers = Get-ADUser -Filter {Enabled -eq $true -and AccountExpirationDate -lt $dateNow} -Properties AccountExpirationDate

    $i = 0
    # Disable each expired user account
    $disableUsers = foreach ($user in $expiredUsers) {
        if ($user.Enabled) {
            Disable-ADAccount -Identity $user.DistinguishedName
            $user

            # Export disabled users to CSV file
            $user | Select-Object UserPrincipalName, @{Name="Status"; Expression={if($_.Enabled){"Disabled"}else{"Disabled"}}} | Export-Csv -Path $csvFile -NoTypeInformation -Append
            $i+=1
        }
    }

    # Number of days for log files deletion
    $daysToKeep = 1  # Replace 365 with desired number of days

    # Call the function to remove old log files
    RemoveOldLogFiles -daysToKeep $daysToKeep

    # Number of disabled accounts via $i index -> in logs 
    "[$dateNow3] Number of disabled accounts: $i " | Out-File -FilePath $logFile -Append

    # End of the script
    "[$dateNow3] End of the script. " | Out-File -FilePath $logFile -Append
} catch {
    # Error handling
    $errorMessage = $_.Exception.Message
    "[$dateNow3] Error encountered: $errorMessage" | Out-File -FilePath $logFile -Append
}
