function Find-GroupMemberShip {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Output type varies for each return value')]
    [CmdletBinding(DefaultParameterSetName = "ByPattern")]
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
                [GroupMembership[]] $results = @()
    
                if ($PSCmdlet.ParameterSetName -eq 'ByName') { $group = Find-Group -Name $Name }
                if ($PSCmdlet.ParameterSetName -eq 'ByPattern') { $group = Find-Group -NamePattern $NamePattern }
                if ($PSCmdlet.ParameterSetName -eq 'ById') { $group = Find-Group -Id $Id }
    
                if ($group) {
                    $group | ForEach-Object {
                        $result = Query -TableName $table -Condition "WHERE groupid = '$($_.Id)'"
                        if ($result) {
                            [Member[]] $members = @()
    
                            $groupObject = [PSCustomObject]@{
                                GroupId = $result.groupid | Select-Object -First 1
                                GroupName = $result.displayname | Select-Object -First 1
                            }
    
                            $result | ForEach-Object {
                                $members += [Member]@{
                                    UserId = $_.userid
                                    UserName = Find-User -Id $_.userid | Select-Object -ExpandProperty DisplayName
                                }
                            }
    
                            Add-Member -InputObject $groupObject -MemberType NoteProperty -Name "Members" -Value $members -TypeName PSCustomObject
                            $results += $groupObject
    
                        } else { Write-Warning "Couldn't find any results for group: $($_.DisplayName)." }
                    }
        
                    return $results
                }
            } else {
                throw "Couldn't find the database in provided path. Please run 'Set-BackupPath' cmdlet to set the database path."
            }
        }
        catch {
            Write-Error "An error occurred: $($_.Exception.Message)."
        }
    }
}