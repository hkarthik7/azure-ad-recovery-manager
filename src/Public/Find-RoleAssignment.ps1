function Find-RoleAssignment {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', 
        Justification = 'Returning multiple output types and it does not have to be explicitly specified.')]
    [CmdletBinding(DefaultParameterSetName = "ByPattern",
        HelpUri = "https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-RoleAssignment.md")]
    param (
        [Parameter(Mandatory, ParameterSetName = "ByName")]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, ParameterSetName = "ByPattern", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $NamePattern,

        [Parameter(Mandatory, ParameterSetName = "ById")]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [Parameter(Mandatory, ParameterSetName = "All")]
        [switch] $All
    )

    process {
        try {
            if ((GetDatabasePath)) {
                $table = 'roleassignments'
                $roleAssignments = @()
    
                if ($PSCmdlet.ParameterSetName -eq 'ByName') {
                    [Group[]] $res = Find-Group -Name $Name
                    if ($res) {
                        $res | ForEach-Object {
                            $roleAssignments += Query -TableName $table -Condition "WHERE objectid = '$($_.Id)'"
                        }
                        return $roleAssignments
                    }
                }
    
                if ($PSCmdlet.ParameterSetName -eq 'ByPattern') {
                    [Group[]] $res = Find-Group -NamePattern $NamePattern
                    if ($res) {
                        $res | ForEach-Object {
                            $roleAssignments += Query -TableName $table -Condition "WHERE objectid = '$($_.Id)'"
                        }
                        return $roleAssignments
                    }
                }
    
                if ($PSCmdlet.ParameterSetName -eq 'ById') {
                    [Group] $res = Find-Group -Id $Id
                    if ($res) {
                        $roleAssignments += Query -TableName $table -Condition "WHERE objectid = '$($res.Id)'"
                        return $roleAssignments
                    }
                }
    
                if (($PSCmdlet.ParameterSetName -eq 'All') -or ($All.IsPresent)) {
                    return (Query $table)
                }
            }
            else {
                throw "Couldn't find the database in provided path. Please run 'Set-BackupPath' cmdlet to set the database path."
            }
        }
        catch {
            Write-Error "An error occurred: $($_.Exception.Message)."
        }
    }
}