# Active-Directory-Expired-Account-Management

This PowerShell script automates the process of disabling expired user accounts in Active Directory. It helps in managing account expirations, especially in environments with hybrid synchronization between on-premises Active Directory and Azure Active Directory (AD) via Azure AD Connect.

## Purpose

In hybrid environments, user account expiration settings may not synchronize perfectly between on-premises Active Directory and Azure AD. This script addresses this issue by regularly checking for expired accounts in on-premises Active Directory and disabling them as needed.

## Configuration

- **Log Rotation**: The script includes a log rotation feature to manage log files efficiently. You can modify the number of days before log files are deleted by adjusting the `$daysToKeep` variable in the script.

## How to Use

1. **Run the Script**: Execute the PowerShell script `ExpiredAccountManagement.ps1`.

2. **Review Log**: After the script execution, review the log file located in the "logsExpiredAccount" directory for details about the operation.

## Output

- **Log Files**: The script generates log files (`execution_log_YYYY-MM.txt`) in the "logsExpiredAccount" directory, containing information about the execution process, including success and error messages.

- **CSV Output**: The script automatically creates a CSV file (`account_expiry_YYYY-MM-DD.csv`) in the "csvExpiredAccount" directory, containing information about disabled user accounts for auditing purposes.

## Notes

- Ensure that you have necessary permissions to perform Active Directory operations.
- Review the log file for any errors or warnings after script execution.
