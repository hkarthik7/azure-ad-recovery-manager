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

                            $job = Start-Job -Name 'role-assignment' -ScriptBlock {
                                param([object[]] $RoleAssignment, [string] $GroupId)

                                Start-Sleep -Seconds 60 # Wait for group to get reflected
                                $RoleAssignment | ForEach-Object {
                                    New-AzRoleAssignment -ObjectId $GroupId -RoleDefinitionId $_.RoleDefinitionId -Scope $_.Scope
                                }
                            } -ArgumentList ($roleAssignment, $newGroup.Id)
                        }
    
                        $allGroups += [Group]@{
                            Id = $newGroup.Id
                            DisplayName = $newGroup.DisplayName
                            MailNickname = $newGroup.MailNickname
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
                                Invoke-SqliteQuery -DataSource (GetDatabasePath) -Query "INSERT INTO usersandgroups (userid, groupid, odatatype, displayname) VALUES (
                                    (SELECT id FROM users WHERE id = '$userId'), '$($newGroup.Id)', '$($newGroup.odatatype)', '$($newGroup.DisplayName)'
                                )"
                            }
                        }
                    } else {
                        Write-Warning "Group $((Find-Group -Id $groupId).DisplayName) already exists."
                    }
                }

                $report = [RestoreReport]@{
                    RestoredDateTime = Get-Date
                    GroupsRestored = $allGroups.DisplayName -join ", "
                }

                if ($roleAssignment -and $job) {
                    $roleAssignmentResults = $job | Wait-Job | Receive-Job

                    if ($roleAssignmentResults) {
                        Write-Verbose "Successfully completed restoring the role assignment for group(s) [$($roleAssignmentResults.DisplayName -join ", ")]."
                        Add-Member -InputObject $report -MemberType NoteProperty -Name 'RoleAssignmentName' -Value ($roleAssignmentResults.RoleAssignmentName -join ", ") -TypeName RestoreReport -Force
                        Add-Member -InputObject $report -MemberType NoteProperty -Name 'RoleAssignmentId' -Value ($roleAssignmentResults.RoleAssignmentId -join ", ") -TypeName RestoreReport -Force
                        Add-Member -InputObject $report -MemberType NoteProperty -Name 'Scope' -Value ($roleAssignmentResults.Scope -join ", ") -TypeName RestoreReport -Force
                        Add-Member -InputObject $report -MemberType NoteProperty -Name 'DisplayName' -Value ($roleAssignmentResults.DisplayName -join ", ") -TypeName RestoreReport -Force
                        Add-Member -InputObject $report -MemberType NoteProperty -Name 'SignInName' -Value ($roleAssignmentResults.SignInName -join ", ") -TypeName RestoreReport -Force
                        Add-Member -InputObject $report -MemberType NoteProperty -Name 'RoleDefinitionName' -Value ($roleAssignmentResults.RoleDefinitionName -join ", ") -TypeName RestoreReport -Force
                        Add-Member -InputObject $report -MemberType NoteProperty -Name 'RoleDefinitionId' -Value ($roleAssignmentResults.RoleDefinitionId -join ", ") -TypeName RestoreReport -Force
                        Add-Member -InputObject $report -MemberType NoteProperty -Name 'ObjectId' -Value ($roleAssignmentResults.ObjectId -join ", ") -TypeName RestoreReport -Force
                    }
                }

                $report | Export-Csv -Path "$(Split-Path -Path (GetDatabasePath) -Parent)\Azure-AD-Restore-Report.csv" -Encoding utf8 -Force -NoTypeInformation -Append

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