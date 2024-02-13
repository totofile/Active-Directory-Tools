# Check if Module is installed 
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Output "Module exists"
} else {
    Write-Output "Module does not exist"
    # Install module Active Directory
    Install-Module -Name ActiveDirectory -Force -Confirm:$false
}

# Get the full path of the script directory
$scriptDirectory = $PSScriptRoot

# Create "Export" folder if it doesn't exist
$exportDirectory = Join-Path -Path $scriptDirectory -ChildPath "Export"
if (-not (Test-Path -Path $exportDirectory -PathType Container)) {
    New-Item -Path $scriptDirectory -Name "Export" -ItemType Directory
    Write-Output "The Export directory has been created."
}

# Create "Log" folder if it doesn't exist
$logDirectory = Join-Path -Path $scriptDirectory -ChildPath "Log"
if (-not (Test-Path -Path $logDirectory -PathType Container)) {
    New-Item -Path $scriptDirectory -Name "Log" -ItemType Directory
    Write-Output "The Log directory has been created."
}

# Specify the CSV file name in the same directory
$csvFileName = "groups.csv"

# Specify and build the CSV file path
$csvFilePath = Join-Path -Path $scriptDirectory -ChildPath $csvFileName

# Retrieve the groups line in the CSV
$groups = Import-Csv -Path $csvFilePath

# Get the current date and time in "yyyy-MM-dd_HHmmss" format
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

# Initialize the log file content
$logFile = Join-Path -Path $logDirectory -ChildPath "ScriptLog$timestamp.txt"
$logContent = @()

foreach ($line in $groups) {
    try {
        $group = $line.group

        # Check if the group exists
        $existingGroup = Get-ADGroup -Filter { Name -eq $group }

        # Retrieve users from the group
        $users = Get-ADGroupMember -Identity $group -Recursive | ForEach-Object {
            Get-ADUser $_.SamAccountName | Select-Object objectClass, SamAccountName, name
        }
        $groupsInGroup = Get-ADGroupMember -Identity $group | where {$_.objectclass -eq "group"} | Select-Object objectClass, SamAccountName, name

        # Specify the path of the new CSV file for this group with the timestamp
        $exportCsvFilePath = Join-Path -Path $exportDirectory -ChildPath "$($group)_Users_$timestamp.csv"

        # Export user information to the new CSV file
        $users | Export-Csv -Path $exportCsvFilePath -NoTypeInformation

        $groupsInGroup.objectClass + ',"' + $groupsInGroup.SamAccountName + '"' | Add-Content -Path $exportCsvFilePath 

        $logContent += "User information of group '$group' has been exported to: $exportCsvFilePath"
    } catch {
        # The group doesn't exist
        $logContent += "The group '$group' does not exist."
    }
}

# Save the log file content
$logContent | Out-File -FilePath $logFile -Encoding UTF8

# Display the log file content
Get-Content -Path $logFile
