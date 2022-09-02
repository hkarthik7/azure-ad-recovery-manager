function Restore-AzADSecurityGroup {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [ValidateNotNullOrEmpty()]
        [string] $GroupDisplayName,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $RestoreAll
    )
    
    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'ByName') {
                $groupsToRestore = (Find-Group -Name $GroupDisplayName).Id
            }

            if (($PSCmdlet.ParameterSetName -eq 'All') -or ($RestoreAll.IsPresent)) {
                $groups = Get-AzADGroup
                $groups = $groups | Where-Object { !$_.MailEnabled }

                $backupGroups = Find-Group -All
                $groupsToRestore = Compare-Object -ReferenceObject $groups.Id -DifferenceObject $backupGroups.Id | Select-Object -ExpandProperty InputObject
            }

            if ($groupsToRestore) {
                [Group[]] $allGroups = @()

                foreach ($groupId in $groupsToRestore) {
                    if (!(IsGroupExists -GroupId $groupId)) {
                        $members = Find-GroupMemberShip -Id $groupId
                        $roleAssignment = Get-AzRoleAssignment -ObjectId $groupId
                        $group = Find-Group -Id $groupId
    
                        Write-Verbose "Restoring group [$($group.DisplayName)]"
    
                        $newGrp = New-AzADGroup `
                            -DisplayName $group.DisplayName `
                            -Description $group.Description `
                            -MailNickname $group.MailNickname
    
                        $newGroup = Get-AzADGroup -ObjectId $newGrp.Id
    
                        if ($roleAssignment) {
                            Write-Verbose "Waiting for group to get reflected"
                            Start-Sleep -Seconds 30 # Wait for group to get reflected

                            $roleAssignment | ForEach-Object {
                                $null = New-AzRoleAssignment `
                                    -ObjectId $newGroup.Id `
                                    -RoleDefinitionName $_.RoleDefinitionName `
                                    -Scope $_.Scope
                            }
                        }
    
                        $allGroups += [Group]@{
                            Id = $newGroup.Id
                            DisplayName = $newGroup.DisplayName
                            MailNickname = $_.MailNickname
                            Description = $newGroup.Description
                            CreatedDateTime = $newGroup.CreatedDateTime
                            IsAssignableToRole = $newGroup.IsAssignableToRole
                            Owner = $newGroup.Owner
                            RenewedDateTime = $newGroup.RenewedDateTime
                            SecurityEnabled = $newGroup.SecurityEnabled
                            SecurityIdentifier = $newGroup.SecurityIdentifier
                        }
    
                        Invoke-SqliteQuery -DataSource (GetDatabasePath) -Query "DELETE FROM groups WHERE id = '$groupId'"
                        Invoke-SqliteBulkCopy -DataTable ($allGroups| Out-DataTable) -DataSource (GetDatabasePath) -Table 'groups' -ConflictClause Ignore -Force
    
                        if ($members) {
                            Add-AzADGroupMember -TargetGroupObjectId $newGroup.Id -MemberObjectId $members.Members.UserId -WarningAction SilentlyContinue
                            foreach ($userId in $members.Members.UserId) {
                                Invoke-SqliteQuery -DataSource (GetDatabasePath) -Query "INSERT INTO usersandgroups (userid, groupid, displayname) VALUES (
                                    (SELECT id FROM users WHERE id = '$userId'), '$($newGroup.Id)', '$($newGroup.DisplayName)'
                                )"
                            }
                        }
                    } else {
                        Write-Warning "Group $((Find-Group -Id $groupId).DisplayName) already exists."
                    }
                }

                return $allGroups
                
            } else {
                Write-Warning "No groups found to restore."
            }
        }
        catch {
            Write-Error "An Error Occurred at line $($_.InvocationInfo.ScriptLineNumber). Message: $($_.Exception.Message)."
        }
    }
}