<#
.SYNOPSIS
    This script helps to restore the deleted security group in Azure Active Directory.
.DESCRIPTION
    This script helps to restore the deleted security group in Azure Active Directory. There are two options or two ways
    you can restore the security groups. One is to run the script with `Restore-AzADSecurityGroup -RestoreAll -Verbose`
    and let the azure-ad-recovery-manager module to determine the deleted security groups and restore it. Or a particular
    group can be restored by running `Restore-AzADSecurityGroup -GroupDisplayName 'name-of-the-group' -Verbose`.

    Please make sure that a run as account is created in automation account and the SPN of runas account has read and write
    access to Azure Active Directory for successful backup and restore of security groups.

    Azure automation runas account should have contributor level access to storage account for getting the storage
    account access keys and download the backup files.
#>

Import-Module azure-ad-recovery-manager

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