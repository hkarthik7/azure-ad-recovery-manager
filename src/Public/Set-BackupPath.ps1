function Set-BackupPath {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'No state changing functions')]
    [CmdletBinding(HelpUri = "https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Set-BackupPath.md")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string] $FilePath
    )
    
    process {
        try {
            $path = Resolve-Path -Path $FilePath.TrimEnd("\")
            [System.Environment]::SetEnvironmentVariable('AZURE_AD_BACKUP_DATABASE', "$path\Azure-AD-Backup.db", [System.EnvironmentVariableTarget]::Process)
        }
        catch {
            Write-Error "An Error Occurred at line $($_.InvocationInfo.ScriptLineNumber). Message: $($_.Exception.Message)."
        }   
    }
}