# Run the script locally
$module = 'azure-ad-recovery-manager'
$storageAccountName = ''
$resourceGroupName = ''
$container = ''

$backupPath = "$($PWD.Path)\Azure-AD-Backup_$(Get-Date -Format yyyyMMdd_HHmmss)"
$folderName = Split-Path -Path $backupPath -Leaf

if (Get-Module -Name $module) {
    Remove-Module $module -Force
}

if (!(Test-Path $backupPath)) {
    $backupPath = New-Item -Path $backupPath -ItemType Directory | Select-Object -ExpandProperty FullName
}

Import-Module -Name $module -Force

Set-BackupPath -FilePath $backupPath

Backup-AzADSecurityGroup -Verbose -AsJob

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

(Get-ChildItem -Path $backupPath) | ForEach-Object {
    Set-AzStorageBlobContent -File $_.FullName -Context $storageAccount.Context -Container $container -Blob "$folderName/$($_.Name)"
}
