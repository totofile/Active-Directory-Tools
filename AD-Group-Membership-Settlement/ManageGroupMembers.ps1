######################### Module Import + File ###########

# Check if required modules are installed, if not install them
$requiredModules = @("ActiveDirectory")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable | Where-Object { $_.Name -eq $module })) {
        Install-Module -Name $module -Force -Confirm:$false
    }
}

# Get the full path of the script directory
$scriptDirectory = $PSScriptRoot

# Create "Log" folder if it doesn't exist
$logDirectory = Join-Path -Path $scriptDirectory -ChildPath "Log"
if (-not (Test-Path -Path $logDirectory -PathType Container)) {
    New-Item -Path $scriptDirectory -Name "Log" -ItemType Directory
    Write-Output "The Log directory has been created."
}

# Get the current date and time in "yyyyMMdd_HHmmss" format
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Initialize the log file content
$logFile = Join-Path -Path $logDirectory -ChildPath "ScriptLog$timestamp.txt"

# Check if log file exists, if not create it
if (-not (Test-Path -Path $logFile)) {
    $null | Out-File -FilePath $logFile
    Write-Output "The Log file has been created."
}

# Specify the CSV file path
$csvFileName = "mail_group.csv"
$csvFilePath = Join-Path -Path $scriptDirectory -ChildPath $csvFileName

# Specify the full path of the Organizational Unit (OU) where you want to create the group
$ouPath = "OU=<Your-OU>,DC=<Your-DC>,DC=<local>"

############################# MAIN #############################

# Start session recording in the log file
Start-Transcript -Path $logFile 

# Load the contents of the CSV file
$csvContent = Import-Csv -Path $csvFilePath -Delimiter ';'

# Iterate through each line of the CSV
foreach ($line in $csvContent) {
    # Access the values of the Email and Group properties
    $email = $line.mail
    $group = $line.group 
    $description = $line.description

    # Check if the group already exists
    $existingGroup = Get-ADGroup -Filter { SamAccountName -eq $group }

    if (!$existingGroup) {
        # Group doesn't exist, create it
        New-ADGroup -Name $group -GroupScope Global -Path $ouPath -GroupCategory Security -Description $description
            if ($existingGroup) {
                Write-Output "Success : Group $group created successfully."
            } else {
                Write-Output "Error : Failed to create group $group."
            }
    } else {
        # Group already exists, do nothing
        Write-Host "Pass : Group $group already exists, no need to create."
    }

    # Retrieve user's samAccountName
    $user = Get-ADUser -Filter { EmailAddress -eq $email } 
    $samAccountName = $user.SamAccountName

    if ($samAccountName) {
        # Check if the user is a member of the group
        $isMember = Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.SamAccountName -eq $samAccountName }

        if ($isMember) {
            # Check if the user exists based on UPN, if user is not a member of the group then add
            Write-Output "Pass :  User $samAccountName is already a member of group $group."
        } else {
            Add-ADGroupMember -Identity $group -Members $samAccountName
            Write-Host "Success : User $samAccountName has been added to group $group."
        }
    } else {
        Write-Output "Error : No user found with email $email."
    }
}

# Stop session recording
Stop-Transcript

Write-Host "Operation completed. See the log file at: $logFile" -ForegroundColor Cyan
