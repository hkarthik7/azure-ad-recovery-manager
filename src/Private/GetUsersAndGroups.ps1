function GetUsersAndGroups {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseUsingScopeModifierInNewRunspaces', '', Justification = 'Using ArgumentList')]
    [CmdletBinding()]
    param (
        [switch] $Incremental,
        [switch] $AsJob
    )
    
    begin {
        # Initialize function variables
        $WarningPreference = 'SilentlyContinue'
        $functionName = $MyInvocation.MyCommand.Name
        $usersAndGroups = @()

        Write-Verbose "[$(Get-Date -Format s)] : $functionName : Begin function.."
    }
    
    process {
        try {
            Write-Verbose "[$(Get-Date -Format s)] : $functionName : Determining users and groups.."
            $users = Get-AzADUser
            $groups = Get-AzADGroup
            $groups = $groups | Where-Object { !($_.MailEnabled) }

            if ($Incremental.IsPresent) {
                $backupUsers = Find-User -All
                $backupGroups = Find-Group -All
    
                $usersObject = Compare-Object -ReferenceObject $users.Id -DifferenceObject $backupUsers.Id | Select-Object -ExpandProperty InputObject
                $groupsObject = Compare-Object -ReferenceObject $groups.Id -DifferenceObject $backupGroups.Id | Select-Object -ExpandProperty InputObject

                $groupsToAdd = @()
                $usersToAdd = @()
    
                if ($usersObject) {
                    foreach ($obj in $usersObject) {
                        $usersToAdd += $users | Where-Object { $_.Id -eq $obj }
                    }
                }
    
                if ($groupsObject) {
                    foreach ($obj in $groupsObject) {
                        $groupsToAdd += $groups | Where-Object { $_.Id -eq $obj }
                    }                    
                }

                $backupOutput = [BackupOutput]@{
                    Users  = $usersToAdd
                    Groups = $groupsToAdd
                }   
            } else {
                $backupOutput = [BackupOutput]@{
                    Users  = $users
                    Groups = $groups
                }
            }

            if ($AsJob.IsPresent) {
                $path = "$($PWD.Path)\Job-Results"
                if (-not (Test-Path $path)) {
                    $exportPath = New-Item -Path $path -ItemType Directory | Select-Object -ExpandProperty FullName
                }
                else {
                    $exportPath = $path
                }

                # $numberOfJobs = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty NumberOfLogicalProcessors
                $numberOfJobs = 10
                if ($backupOutput.Groups.Count -le $numberOfJobs) {
                    $numberOfJobs = 1
                }

                $groupsPerBatch = [System.Math]::Round($backupOutput.Groups.Count / $numberOfJobs)
                $totalGroups = $backupOutput.Groups.Count

                $counter = 0
                $batchNameCounter = 0
                $batches = $groupsPerBatch

                while ($counter -lt $totalGroups) {
                    $groupsSet = $backupOutput.Groups[$counter..$groupsPerBatch]
                    
                    $job = Start-Job -Name "Batch-$batchNameCounter" -ScriptBlock {
                        param([object[]] $Groups, [string] $FilePath)

                        $result = @()

                        foreach ($group in $Groups) {
                            Write-Verbose "[$(Get-Date -Format s)] : $functionName : Working with [$($group.DisplayName)].."
                        
                            $members = Get-AzADGroupMember -GroupObjectId $group.Id
                            if ($members) {
                                Write-Verbose "[$(Get-Date -Format s)] : $functionName : Retrieving members from [$($group.DisplayName)].."
                                Write-Verbose "[$(Get-Date -Format s)] : $functionName : Found [$($members.Count)] users in [$($group.DisplayName)].."
                        
                                $memberList = @()
                                $h = [PSCustomObject]@{
                                    GroupName = $group.DisplayName
                                    GroupId   = $group.Id
                                }
                        
                                $members | ForEach-Object {            
                                    $memberList += [PSCustomObject]@{
                                        DeletedDateTime = $_.DeletedDateTime
                                        Name            = $_.DisplayName
                                        Id              = $_.Id
                                        OdataType       = $_.OdataType
                                    }
                                }
                        
                                Add-Member -InputObject $h -MemberType NoteProperty -Name Users -Value $memberList -TypeName PSCustomObject -Force
                        
                                $result += $h

                                $result | ConvertTo-Json -Depth 99 | Set-Content -Path $FilePath -Encoding utf8
                            }
                        }
                    } -ArgumentList @($groupsSet, "$exportPath\Batch-$batchNameCounter.json")

                    Write-Verbose "[$(Get-Date -Format s)] : $functionName : Initiated job in background [$($job.Id) - $($job.Name)].."

                    $counter = $groupsPerBatch
                    $groupsPerBatch = $counter + $batches
                    $batchNameCounter++
                }

                $null = Get-Job | Where-Object { $_.Name -match 'Batch' } | Wait-Job

                Write-Verbose "[$(Get-Date -Format s)] : $functionName : Merging Json files.."
                $files = Get-ChildItem -Path $exportPath -Filter "*.json" | Select-Object -ExpandProperty FullName
                foreach ($file in $files) {
                    Write-Verbose "[$(Get-Date -Format s)] : $functionName : Working with [$(Split-Path -Path $file -Leaf)].."
                    $results += Get-Content -Path $file | ConvertFrom-Json
                }

                $results | ConvertTo-Json -Depth 99 | Out-File -FilePath "$exportPath\UsersAndGroups.json" -Encoding utf8
                $res = Get-Content -Path "$exportPath\UsersAndGroups.json" -Raw | ConvertFrom-Json
                Add-Member -InputObject $backupOutput -MemberType NoteProperty -Name UsersAndGroups -Value $res -TypeName PSCustomObject -Force
                
                return $backupOutput
            }

            else {
                foreach ($group in $backupOutput.Groups) {
                    Write-Verbose "[$(Get-Date -Format s)] : $functionName : Working with [$($group.DisplayName)].."
                
                    $members = Get-AzADGroupMember -GroupObjectId $group.Id
                    if ($members) {
                        Write-Verbose "[$(Get-Date -Format s)] : $functionName : Retrieving members from [$($group.DisplayName)].."
                        Write-Verbose "[$(Get-Date -Format s)] : $functionName : Found [$($members.Count)] users in [$($group.DisplayName)].."
                
                        $memberList = @()
                        $h = [PSCustomObject]@{
                            GroupName = $group.DisplayName
                            GroupId   = $group.Id
                        }
                
                        $members | ForEach-Object {            
                            $memberList += [PSCustomObject]@{
                                DeletedDateTime = $_.DeletedDateTime
                                Name            = $_.DisplayName
                                Id              = $_.Id
                                OdataType       = $_.OdataType
                            }
                        }
                
                        Add-Member -InputObject $h -MemberType NoteProperty -Name Users -Value $memberList -TypeName PSCustomObject -Force
                
                        $usersAndGroups += $h
                    }
                }
    
                Add-Member -InputObject $backupOutput -MemberType NoteProperty -Name UsersAndGroups -Value $usersAndGroups -TypeName PSCustomObject -Force
    
                return $backupOutput
            }
        }
        catch {
            if ($_.Exception.Message.Contains('DifferenceObject')) {
                Write-Error "An Error Occurred at line $($_.InvocationInfo.ScriptLineNumber). Incremental Operation is supported only to add new groups. Check if database exists and not empty."
            }
            else { Write-Error "An Error Occurred at line $($_.InvocationInfo.ScriptLineNumber). Message: $($_.Exception.Message)." }
        }
    }
    
    end {
        Write-Verbose "[$(Get-Date -Format s)] : $functionName : End function.."
        # clean up
        Get-Job | Where-Object { $_.Name -match 'Batch' } | Remove-Job -ErrorAction SilentlyContinue
        if ((![string]::IsNullOrEmpty($exportPath)) -and (Test-Path $exportPath)) {
            Remove-Item $exportPath -Recurse -Force
        }
    }
}