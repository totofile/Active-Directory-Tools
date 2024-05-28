# Active Directory Group Membership Settlement
## Active Directory Group Membership Management Script

This Script Create &amp; Fill Groups Automatically from an csv file 

---
This PowerShell script facilitates the management of group memberships in Active Directory. It automates the process of creating groups, adding users to groups, and logs the operation for auditing purposes.

## Prerequisites

Before running this script, ensure you have the following:

- **CSV File**: You need to have a CSV file named `mail_group.csv`(you can easily change this name in script) containing at least the following columns:
  - **mail**: Email addresses of the users to be added to groups.(the user have to exist)
  - **group**: Names of the groups to which users will be added.(if the group doesn't exist it will be created)
  - **description**: Description of the groups (optional).

## How to Use

1. **Prepare CSV File**: Ensure you have prepared the required CSV file with the necessary user emails and group names.

2. **Specify OU and DC**: Open the script and specify the Organizational Unit (OU) where you want to create the groups ($ouPath) and the Domain Controller (DC) for the OU ($ouDC).

3. **Run the Script**: Execute the PowerShell script `ManageGroupMembers.ps1`.

4. **Review Log**: After the script execution, review the log file located in the "Log" directory for details about the operation.

## Output

- **Log File**: The script generates a log file (`ScriptLogyyyyMMdd_HHmmss.txt`) in the "Log" directory, containing information about the execution process, including success and error messages.

## Notes

- Ensure that you have necessary permissions to perform Active Directory operations.
- Review the log file for any errors or warnings after script execution.

---

This README provides clear instructions on how to use the script, prerequisites, and output details, ensuring smooth execution and understanding for users there is also comments in the code.
