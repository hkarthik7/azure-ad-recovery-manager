<#
.SYNOPSIS
    This runbook helps to restore the deleted security group in Azure Active Directory.
.DESCRIPTION
    This runbook helps to restore the deleted security group in Azure Active Directory. There are two options or two ways
    you can restore the security groups. One is to run the runbook with `Restore-AzADSecurityGroup -RestoreAll -Verbose`
    and let the azure-ad-recovery-manager module to determine the deleted security groups and restore it. Or a particular
    group can be restored by running `Restore-AzADSecurityGroup -GroupDisplayName 'name-of-the-group' -Verbose`.

    Please make sure that a run as account is created in automation account and the SPN of runas account has read and write
    access to Azure Active Directory for successful backup and restore of security groups.

    Azure automation runas account should have contributor level access to storage account for getting the storage
    account access keys and download the backup files.

.NOTES
    Before running the restore runbook please make sure that the SPN has all access required, Contributor level
    access is required in Azure Active Directory, Azure Role Assignments for successful restoration of role assignment
    and access on subscritption level. If unsure please run it locally and test the access first.

    Reference for Role Assignment:
    https://stackoverflow.com/questions/66970160/how-do-you-set-up-app-with-permissions-to-azure-compute-api/66970727#66970727    
#>

#region module refresh

Import-Module PSSQlite
Import-Module Az.Accounts
Import-Module Az.Storage
Import-Module Az.Resources
Import-Module azure-ad-recovery-manager

#endregion module refresh

$connection = Get-AutomationConnection -Name 'AzureRunAsConnection' # change the name of runas account if needed.

$connectionResult = Connect-AzAccount `
    -ServicePrincipal `
    -Tenant $connection.TenantID `
    -ApplicationId $connection.ApplicationID `
    -CertificateThumbprint $connection.CertificateThumbprint

# Initialise variables
$storageAccountName = ''
$resourceGroupName = ''
$container = ''
$blobName = 'Azure-AD-Backup_20220913_151336/Azure-AD-Backup.db'

#Download the latest backup file
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$blob = Get-AzStorageBlob -Blob $blobName -Container $container -Context $storageAccount.Context
Get-AzStorageBlobContent -CloudBlob $blob.ICloudBlob -Destination $PWD.Path -Context $storageAccount.Context

$backupPath = Get-ChildItem -Filter $blobName | Select-Object -ExpandProperty DirectoryName
$folderName = Split-Path -Path $backupPath -Leaf

Set-BackupPath -FilePath $backupPath

#Restore all deleted security groups
# Restore-AzADSecurityGroup -RestoreAll -Verbose

#Restore a single security group
Restore-AzADSecurityGroup -GroupDisplayName 'test-group' -Verbose

(Get-ChildItem -Path $backupPath) | ForEach-Object {
    Set-AzStorageBlobContent -File $_.FullName -Context $storageAccount.Context -Container $container -Blob "$folderName/$($_.Name)" -Force
}