# Schedule Azure Active Directory Backup job

## Azure Automation Account

Script `backup.ps1` is intended to run in azure automation account on schedule basis to have the full backup of Azure Active Directory security groups.
The script `restore.ps1` helps to restore the deleted security group(s). This is a version for automation account and expects the storage account, backup file details to restore the deleted security groups.

### How to run

The first step is to [create an automation account](https://docs.microsoft.com/en-us/azure/automation/automation-create-standalone-account?tabs=azureportal) and a [RunAs](https://docs.microsoft.com/en-us/azure/automation/create-run-as-account?WT.mc_id=Portal-Microsoft_Azure_Automation) account in automation account. Then you can create a Powershell v7.x [runbook](https://docs.microsoft.com/en-us/azure/automation/manage-runbooks) and schedule it.

- Once the prerequisites are completed, please grant access `Service Principal Account` that was created as a part of `RunAs` account to Azure Active Directory. To do so, add the `Service Principal Account` to `Directory Reader and Directory Writer` Azure AD roles in Azure Active Directory.
- Create a storage account with Geo-Replication for saving the backup files.
- You can then navigate to modules section in automation account and browse the gallery for `azure-ad-recovery-manager` and `PSSQLite` modules and import it.
- Create a PowerShell runbook and call it `backup` and copy the contents of `backup.ps1` and edit it according to your environment.
  - Please note that you should specify the `RunAs` account name and storage account details.

## Others

Please modify and use the scripts under **local-version** and schedule the backup in `CI/CD` pipeline system(s) or if you are using [PowerShell Universal](https://docs.powershelluniversal.com/) dashboard, you can use the script to backup and restore the groups.

### NOTE

Before running or scheduling the scripts please make sure to check if all the necessary dependencies are installed/imported.