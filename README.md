## Active Directory Group User Export Script

This PowerShell script automates the process of exporting user information from Active Directory groups to CSV files. Here's what it does:

1. **Module Check:** It checks if the Active Directory module is installed. If not, it installs it automatically.

2. **Folder Creation:** It creates "Export" and "Log" folders in the script directory if they don't exist already.

3. **CSV File Processing:** It specifies the CSV file containing group information and processes each group listed.

4. **User Export:** For each group, it retrieves users and nested groups, then exports their information to a new CSV file named with a timestamp.

5. **Logging:** It logs the export process, indicating which groups have been processed and where the corresponding CSV files are stored.

6. **Output Display:** Finally, it displays the log file content to the user.

---

This script simplifies the task of exporting user information from Active Directory groups, making it easier to manage and analyze group memberships.
