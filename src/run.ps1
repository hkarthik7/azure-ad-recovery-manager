$module = 'azure-ad-recovery-manager'
$backupPath = "$($PWD.Path)\Azure-AD-Backup_$(Get-Date -Format yyyyMMdd_HHmmss)"

if (Get-Module -Name $module) {
    Remove-Module $module -Force
}

if (!(Test-Path $backupPath)) {
    $backupPath = New-Item -Path $backupPath -ItemType Directory | Select-Object -ExpandProperty FullName
}

Import-Module -Name ".\bin\dist\$module" -Force

Set-BackupPath -FilePath $backupPath

Backup-AzADSecurityGroup -Verbose -ShowOutput