function Find-UserMemberShip {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Output type varies for each return value')]
    [CmdletBinding(DefaultParameterSetName = "ByPattern",
        HelpUri = "https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-UserMemberShip.md")]
    param (
        [Parameter(Mandatory, ParameterSetName = "ByName")]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "ByPattern")]
        [ValidateNotNullOrEmpty()]
        [string] $NamePattern,

        [Parameter(Mandatory, ParameterSetName = "ById")]
        [ValidateNotNullOrEmpty()]
        [string] $Id
    )

    process {
        try {
            if ((GetDatabasePath)) {
                $table = 'usersandgroups'
                [UserMembership[]] $results = @()
    
                if ($PSCmdlet.ParameterSetName -eq 'ByName') { $user = Find-User -Name $Name }
                if ($PSCmdlet.ParameterSetName -eq 'ByPattern') { $user = Find-User -NamePattern $NamePattern }
                if ($PSCmdlet.ParameterSetName -eq 'ById') { $user = Find-User -Id $Id }
    
                if ($user) {
                    $user | ForEach-Object {
                        $result = Query -TableName $table -Condition "WHERE userid = '$($_.Id)'"
                        $obj = [PSCustomObject]@{
                            UserName = $_.DisplayName
                            UserId   = $_.Id
                        }
            
                        $groups = [PSCustomObject]@{
                            GroupName = $result.DisplayName
                            GroupId   = $result.GroupId
                        }
                        Add-Member -InputObject $obj -MemberType NoteProperty -Name "Membership" -Value $groups -TypeName PSCustomObject
                        $results += $obj
                    }
        
                    return $results
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