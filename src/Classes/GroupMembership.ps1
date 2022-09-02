class Member {
    [string] $UserId
    [string] $UserName
}

class GroupMembership {
    [string] $GroupId
    [string] $GroupName
    [Member[]] $Members
}