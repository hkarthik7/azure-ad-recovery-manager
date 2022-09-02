if (Get-Module -Name azure-ad-recovery-manager) {
    Remove-Module azure-ad-recovery-manager -Force
}

Import-Module -Name .\bin\dist\azure-ad-recovery-manager -Force

$backupResult = Backup-AzADSecurityGroup -Verbose -ShowOutput