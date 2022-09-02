Describe 'azure-ad-recovery-manager' {

    BeforeAll {
        Import-Module -Name '.\bin\dist\azure-ad-recovery-manager\azure-ad-recovery-manager.psm1' -Force
    }

    Context 'azure-ad-recovery-manager' {
        It 'Should test the end to end functionality of the module' {

            if ($null -eq (Find-User -All)) {
                $backup = Backup-AzADSecurityGroup -ShowOutput
                $backup | Should -Not -Be $null
            }

            $users = Find-User -All
            $users | Should -Not -Be $null

            $groups = Find-Group -All
            $groups | Should -Not -Be $null

            $relationship = Find-UserMemberShip -Id $users[0].Id
            $relationship | Should -Not -Be $null

            Find-GroupMemberShip -Id $relationship[0].Membership.GroupId[0] | Should -Not -Be $null
        }
    }
}