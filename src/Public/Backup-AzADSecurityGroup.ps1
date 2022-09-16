function Backup-AzADSecurityGroup {
    [CmdletBinding(HelpUri = "https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Backup-AzADSecurityGroup.md")]
    param (
        [switch] $AsJob,
        
        [switch] $Incremental,

        [switch] $ShowOutput,

        [ValidateRange(1,20)]
        [int] $NumberOfJobs
    )

    begin {
        $functionName = $MyInvocation.MyCommand.Name
        SetNumberOfJobs $NumberOfJobs

        Write-Verbose "[$(Get-Date -Format s)] : $functionName : Begin function.."

        $schema = [Schema]@{
            Tables = @(
                [Table]@{
                    TableName = 'users'
                    Columns   = @(
                        "id VARCHAR(50) PRIMARY KEY",
                        "displayname TEXT",
                        "mail TEXT",
                        "odatatype TEXT",
                        "userprincipalname TEXT"
                    )
                },
                [Table]@{
                    TableName = 'groups'
                    Columns   = @(
                        "id VARCHAR(50) PRIMARY KEY",
                        "displayname TEXT",
                        "description TEXT",
                        "mailnickname TEXT",
                        "mailenabled INTEGER",
                        "createddatetime TEXT",
                        "isassignabletorole INTEGER",
                        "owner TEXT",
                        "reneweddatetime TEXT",
                        "securityenabled INTEGER",
                        "securityidentifier TEXT"
                    )
                },
                [Table]@{
                    TableName = 'usersandgroups'
                    Columns   = @(
                        "groupid VARCHAR(50)",
                        "displayname TEXT",
                        "odatatype TEXT",
                        "userid VARCHAR(50) REFERENCES users(id)",
                        "PRIMARY KEY (groupid, userid)"
                    )
                },
                [Table]@{
                    TableName = 'roleassignments'
                    Columns   = @(
                        "roleassignmentName TEXT",
                        "roleassignmentId TEXT VARCHAR(50) PRIMARY KEY",
                        "scope TEXT",
                        "displayname TEXT",
                        "signinname TEXT",
                        "roledefinitionname TEXT",
                        "roledefinitionid TEXT",
                        "objectid TEXT",
                        "objecttype TEXT",
                        "candelegate TEXT",
                        "description TEXT",
                        "conditionversion TEXT",
                        "condition TEXT"                    
                    )
                }
            )
        }
    }

    process {
        try {
            if ((GetDatabasePath)) {
                if ($Incremental.IsPresent) {
                    if ($AsJob.IsPresent) {
                        $backupOutput = GetUsersAndGroups -AsJob -Incremental
                    }
                    else { $backupOutput = GetUsersAndGroups -Incremental }
                }
                else {
                    if ($AsJob.IsPresent) {
                        $backupOutput = GetUsersAndGroups -AsJob
                    }
                    else { $backupOutput = GetUsersAndGroups }
                }
                    
                # 1) Create database
                $database = CreateDatabase
                
                # 2) Create tables (users, groups and usersandgroups)
                foreach ($table in $schema.Tables) {
                    if (!$Incremental.IsPresent) { DropTable -TableName $table.TableName }
                    CreateTable -TableName $table.TableName -Columns $table.Columns
                
                    if ($table.TableName -eq 'users') {
                        # insert data
                        if ($backupOutput.Users) {
                            $usersDataTable = $backupOutput.Users | ForEach-Object {
                                [User]@{
                                    Id                = $_.Id
                                    DisplayName       = $_.DisplayName
                                    Mail              = if (!([string]::IsNullOrEmpty($_.Mail))) { $_.Mail } else { $null }
                                    UserPrincipalName = if (!([string]::IsNullOrEmpty($_.UserPrincipalName))) { $_.UserPrincipalName } else { $null }
                                    OdataType         = $_.OdataType
                                }
                            } | Out-DataTable
                            
                            Invoke-SqliteBulkCopy -DataTable $usersDataTable -DataSource $database -Table $table.TableName -ConflictClause Ignore -Force
                        }
                    }
                
                    if ($table.TableName -eq 'groups') {
                        if ($backupOutput.Groups) {
                            $groupsDataTable = $backupOutput.Groups | ForEach-Object {
                                [Group]@{
                                    Id                 = $_.Id
                                    DisplayName        = $_.DisplayName
                                    MailNickname       = $_.MailNickname
                                    Description        = $_.Description
                                    MailEnabled        = $_.MailEnabled
                                    CreatedDateTime    = if (!([string]::IsNullOrEmpty($_.CreatedDateTime))) { (Get-Date $_.CreatedDateTime -Format s) } else { $null }
                                    IsAssignableToRole = $_.IsAssignableToRole
                                    Owner              = $_.Owner
                                    RenewedDateTime    = if (!([string]::IsNullOrEmpty($_.RenewedDateTime))) { (Get-Date $_.RenewedDateTime -Format s) } else { $null }
                                    SecurityEnabled    = $_.SecurityEnabled
                                    SecurityIdentifier = $_.SecurityIdentifier
                                }
                            } | Out-DataTable
                            
                            Invoke-SqliteBulkCopy -DataTable $groupsDataTable -DataSource $database -Table $table.TableName -ConflictClause Ignore -Force
                        }
                    }

                    if ($table.TableName -eq 'roleassignments') {
                        $roleAssignments = Get-AzRoleAssignment | Out-DataTable
                        Invoke-SqliteBulkCopy -DataTable $roleAssignments -DataSource $database -Table $table.TableName -ConflictClause Ignore -Force
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
                                    GroupId     = $_.GroupId
                                    DisplayName = $_.GroupName
                                    OdataType   = @($_.Users.OdataType)
                                    UserId      = @($_.Users.Id)
                                }
                            }
    
                            # A group can contain security group(s), device(s), spn(s) and user(s).
                            # Adding the group memebers id to users table to form many to many relationship.
                            $usersTable = $schema.Tables | Where-Object { $_.TableName -eq 'users' }
                            $userTableQueryBuilder = [System.Text.StringBuilder]::new()
                            $null = $userTableQueryBuilder.AppendLine("INSERT OR IGNORE INTO $($usersTable.TableName) (id, odatatype, displayname) ")
                            $null = $userTableQueryBuilder.AppendLine("VALUES ")
    
                            foreach ($entry in $backupOutput.UsersAndGroups) {
                                foreach ($user in $entry.Users) {
                                    if ($user.Name.Contains("'")) {
                                        $null = $userTableQueryBuilder.AppendLine("('$($user.Id)', '$($user.OdataType)', '$($user.Name.Replace("'", "''"))'), ")
                                    }
                                    else {
                                        $null = $userTableQueryBuilder.AppendLine("('$($user.Id)', '$($user.OdataType)', '$($user.Name)'), ")
                                    }
                                }
                            }
    
                            Invoke-SqliteQuery -DataSource $database -Query ($userTableQueryBuilder.ToString().Trim().TrimEnd(","))
                            
                            $queryBuilder = [System.Text.StringBuilder]::new()
                            $null = $queryBuilder.AppendLine("INSERT OR IGNORE INTO $($table.TableName) (userid, groupid, odatatype, displayname) ")
                            $null = $queryBuilder.AppendLine("VALUES ")
                            
                            foreach ($value in $relationship) {
                                for ($i = 0; $i -lt $value.UserId.Count; $i++) {
                                    $null = $queryBuilder.AppendLine("((SELECT id FROM users WHERE id = '$($value.UserId[$i])'), '$($value.groupid)', '$($value.odatatype[$i])', '$($value.displayname)'), ")
                                }
                            }
                            
                            Invoke-SqliteQuery -DataSource $database -Query ($queryBuilder.ToString().Trim().TrimEnd(","))
                        }
                    }
                }
    
                $report = [BackupReport]@{
                    ScannedDateTime                = Get-Date
                    NumberOfUsersScanned           = $backupOutput.Users.Count
                    NumberOfGroupsScanned          = $backupOutput.Groups.Count
                    NumberOfGroupMembersScanned    = ($backupOutput.UsersAndGroups.Users.Id | Select-Object -Unique).Count
                    NumberOfRoleAssignmentsScanned = $roleAssignments.Rows.Count
                }
    
                Write-Verbose "[$(Get-Date -Format s)] : $functionName : Generating backup report.."
    
                $report | Export-Csv -Path "$(Split-Path -Path (GetDatabasePath) -Parent)\Azure-AD-Backup-Report.csv" -Encoding utf8 -Force -NoTypeInformation -Append
                
                if ($ShowOutput.IsPresent) { return $backupOutput }
            }
            else {
                throw "Database path is empty. Run 'Set-BackupPath' cmdlet and set the backup path."
            }
        } 
        catch {
            Write-Error "An Error Occurred at line $($_.InvocationInfo.ScriptLineNumber). Message: $($_.Exception.Message)."
        }
    }

    end {
        Write-Verbose "[$(Get-Date -Format s)] : $functionName : End function.."
    }
}