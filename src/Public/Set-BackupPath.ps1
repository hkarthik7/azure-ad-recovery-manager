function Set-BackupPath {
    [CmdletBinding()]
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