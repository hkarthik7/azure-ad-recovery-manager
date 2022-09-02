# azure-ad-recovery-manager

**azure-ad-recovery-manager** module is an opinionated solution for backup and restore of Azure Active Directory security groups. The module provides cmdlets to backup the users & security groups in a file. Then the file can be uploaded to storage account or any kind of storage solution for backup. 

## Recommended steps

The recommendation is to create a storage account with Geo-Replication enabled for storing the backup files and an automation account to create a runbook and schedule it.

- Runbook 1: **backup.ps1** - Schedule and point it to a storage account to run and store the backup files. (Schedule daily).
- Runbook 2: **restore.ps1** - This is on demand and can be edited before running the runbook. (On demand).

</br>

![azure-ad-recovery-manager](./azure-ad-recovery-manager.PNG)

We can also run the **recovery.ps1** locally and restore the deleted groups.

