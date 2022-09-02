function Backup-AzADSecurityGroup {
    [CmdletBinding()]
    param (
        [switch] $Incremental,

        [switch] $ShowOutput
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$(Get-Date -Format s)] : $functionName : Begin function.."

        $schema = [PSCustomObject]@{
            Tables = @(
                [PSCustomObject]@{
                    TableName = 'users'
                    Columns = @(
                        "id VARCHAR(50) PRIMARY KEY",
                        "displayname TEXT",
                        "mail TEXT",
                        "userprincipalname TEXT"
                    )
                },
                [PSCustomObject]@{
                    TableName = 'groups'
                    Columns = @(
                        "id VARCHAR(50) PRIMARY KEY",
                        "displayname TEXT",
                        "description TEXT",
                        "mailnickname TEXT"
                        "createddatetime TEXT",
                        "isassignabletorole INTEGER",
                        "owner TEXT",
                        "reneweddatetime TEXT",
                        "securityenabled INTEGER",
                        "securityidentifier TEXT"
                    )
                },
                [PSCustomObject]@{
                    TableName = 'usersandgroups'
                    Columns = @(
                        "groupid VARCHAR(50)",
                        "displayname TEXT",
                        "userid VARCHAR(50) REFERENCES users(id)",
                        "PRIMARY KEY (groupid, userid)"
                    )
                }
            )
        }
    }

    process {
        try {
            if ($Incremental.IsPresent) { $backupOutput = GetUsersAndGroups -AsJob -Incremental }
            else { $backupOutput = GetUsersAndGroups -AsJob }
                
            # 1) Create database
            $database = CreateDatabase
            
            # 2) Create tables (users, groups and usersandgroups)
            foreach ($table in $schema.Tables) {
                CreateTable -TableName $table.TableName -Columns $table.Columns
            
                if ($table.TableName -eq 'users') {
                    # insert data
                    if ($backupOutput.Users) {
                        $usersDataTable = $backupOutput.Users | ForEach-Object {
                            [User]@{
                                Id = $_.Id
                                DisplayName = $_.DisplayName
                                Mail = if (!([string]::IsNullOrEmpty($_.Mail))) { $_.Mail } else { $null }
                                UserPrincipalName = if (!([string]::IsNullOrEmpty($_.UserPrincipalName))) { $_.UserPrincipalName } else { $null }
                            }
                        } | Out-DataTable
                        
                        Invoke-SqliteBulkCopy -DataTable $usersDataTable -DataSource $database -Table $table.TableName -ConflictClause Ignore -Force
                    }
                }
            
                if ($table.TableName -eq 'groups') {
                    if ($backupOutput.Groups) {
                        $groupsDataTable = $backupOutput.Groups | Where-Object { !($_.MailEnabled) } | ForEach-Object {
                            [Group]@{
                                Id = $_.Id
                                DisplayName = $_.DisplayName
                                MailNickname = $_.MailNickname
                                Description = $_.Description
                                CreatedDateTime = if (!([string]::IsNullOrEmpty($_.CreatedDateTime))) { (Get-Date $_.CreatedDateTime -Format s) } else { $null }
                                IsAssignableToRole = $_.IsAssignableToRole
                                Owner = $_.Owner
                                RenewedDateTime = if (!([string]::IsNullOrEmpty($_.RenewedDateTime))) { (Get-Date $_.RenewedDateTime -Format s) } else { $null }
                                SecurityEnabled = $_.SecurityEnabled
                                SecurityIdentifier = $_.SecurityIdentifier
                            }
                        } | Out-DataTable
                        
                        Invoke-SqliteBulkCopy -DataTable $groupsDataTable -DataSource $database -Table $table.TableName -ConflictClause Ignore -Force
                    }
                }
            
                if ($table.TableName -eq 'usersandgroups') {
                    $results = Query -TableName $table.TableName
                    if ($results) {
                        $backupOutput.UsersAndGroups = $backupOutput.UsersAndGroups | ForEach-Object {
                            if ($_.GroupId -notin $results.groupid) {
                                $_
                            }
                        }
                    }

                    if ($backupOutput.UsersAndGroups) {
                        $relationship = $backupOutput.UsersAndGroups | ForEach-Object {
                            [UserAndGroup]@{
                                GroupId = $_.GroupId
                                DisplayName = $_.GroupName
                                UserId = @($_.Users.Id)
                            }
                        } | Select-Object * -Unique
                        
                        $queryBuilder = [System.Text.StringBuilder]::new()
                        $null = $queryBuilder.AppendLine("INSERT INTO $($table.TableName) (userid, groupid, displayname) ")
                        $null = $queryBuilder.AppendLine("VALUES ")
                        
                        foreach ($value in $relationship) {
                            foreach ($userId in $value.UserId) {
                                $null = $queryBuilder.AppendLine("((SELECT id FROM users WHERE id = '$userId'), '$($value.groupid)', '$($value.displayname)'), ")
                            }
                        }
                        
                        Invoke-SqliteQuery -DataSource $database -Query ($queryBuilder.ToString().Trim().TrimEnd(","))
                    }
                }
            }
            
            if ($ShowOutput.IsPresent) { return $backupOutput }
        } 
        catch {
            Write-Error "An Error Occurred at line $($_.InvocationInfo.ScriptLineNumber). Message: $($_.Exception.Message)."
        }
    }

    end {
        Write-Verbose "[$(Get-Date -Format s)] : $functionName : End function.."
    }
}