# azure-ad-recovery-manager

## about_azure-ad-recovery-manager

# SHORT DESCRIPTION

azure-ad-recovery-manager is an opinionated solution for backup and restore of Azure Active Directory security groups. It helps to take the backup and upload it to storage account which can be scheduled in automation account for regular full backups.

# LONG DESCRIPTION

azure-ad-recovery-manager is an opinionated solution for backup and restore of Azure Active Directory security groups. As we know that once the security groups are deleted it can't be restored unless it is a Microsoft 365 account. Taking the backup in a csv file is and saving it locally is not a scalable and robust solution. We take the advantage of Azure services for storing the security groups in cloud, schedule it and segregate the full backups based on backup date. Then we can download the backup file, set the backup file path and restore the deleted security groups.

azure-ad-recovery-manager takes care of restoring the groups, adding members (could be another security group, spn, device, users, app registrations) and role assignments as when it takes the backup it gathers all the details and forms many-to-many relationship between the connected groups and members. So, if backup exists then it can be restored if the account that you're using to restore has necessary permissions.

## Optional Subtopics

- Create a storage account with GRS enabled - https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal
- Create an automation account - https://docs.microsoft.com/en-us/azure/automation/automation-create-standalone-account?tabs=azureportal
- Create a runas account - https://docs.microsoft.com/en-us/azure/automation/create-run-as-account?WT.mc_id=Portal-Microsoft_Azure_Automation
- Grant access to the runas service principal account to Azure Active Directory. It should have Directory.Reader and Directory.Writer permissions.

Then you can schedule it in automation account. If you are using automation account, you can use other solutions such as

1. CI/CD systems - E.g., Azure DevOps, Jenkins, Harness, Circleci, TravisCI, Gitlabs etc.
2. Function app

# EXAMPLES

```pwsh
C:\> Install-Module -Name azure-ad-recovery-manager -Force

# Login to desired tenant
C:\> Connect-AzAccount -TenantId 'xxxxxxxxxxxxxxxxxxxx'

# copy the script backup.ps1 in local-version from github
# Create a storage account and update the script with the details and run.
C:\> .\backup.ps1
```

# NOTE

This is an opinionated solution and you can take advantage of the functions in this module to define your own solution.


# SEE ALSO

- [Set-BackupPath](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Set-BackupPath.md)

# KEYWORDS

All cmdlets

- [Backup-AzADSecurityGroup](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Backup-AzADSecurityGroup.md)
- [Find-Group](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-Group.md)
- [Find-GroupMembership](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-GroupMembership.md)
- [Find-RoleAssignment](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-RoleAssignment.md)
- [Find-User](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-User.md)
- [Find-UserMemberShip](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-UserMemberShip.md)
- [Restore-AzADSecurityGroup](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Restore-AzADSecurityGroup.md)
- [Set-BackupPath](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Set-BackupPath.md)