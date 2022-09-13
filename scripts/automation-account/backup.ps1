<#
.SYNOPSIS
    This runbook takes the backup of Azure Active Directory security groups and users and stores in storage account.
.DESCRIPTION
    This runbooks takes the backup of Azure Active Directory security groups and users and stores in storage account.
    This must be scheduled in automation account for regular/frequent backups. Recommendation is to schedule it on daily
    basis and let it to take the full backup of security groups and users. Check the restore.ps1 runbook for restoring
    the deleted security groups.
    
    Please make sure that a run as account is created in automation account and the SPN of runas account has read and write
    access to Azure Active Directory for successful backup and restore of security groups.

    Azure automation runas account should have contributor level access to storage account for storing the backup files.
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
$WarningPreference = 'SilentlyContinue'

# Date and time differs in Automation account and it has to be consistent with the local date and time.
$date = Get-Date -AsUTC

# Change the time zone as per your location. Run Get-TimeZone -ListAvailable to get the list of available time zone and pass the Id
$systemTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("GMT Standard Time")
$currentDateTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($date, $systemTimeZone)

$backupPath = "$($PWD.Path)\Azure-AD-Backup_$(Get-Date -Date $currentDateTime -Format yyyyMMdd_HHmmss)"
$folderName = Split-Path -Path $backupPath -Leaf

if (!(Test-Path $backupPath)) {
    $backupPath = New-Item -Path $backupPath -ItemType Directory | Select-Object -ExpandProperty FullName
}

# Start backup
Set-BackupPath -FilePath $backupPath

Backup-AzADSecurityGroup -Verbose -WarningAction SilentlyContinue

# Copy backup files to storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

(Get-ChildItem -Path $backupPath) | ForEach-Object {
    Set-AzStorageBlobContent -File $_.FullName -Context $storageAccount.Context -Container $container -Blob "$folderName/$($_.Name)" -Force
}