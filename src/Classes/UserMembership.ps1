class Membership {
    [string[]] $GroupName
    [string[]] $GroupId
}

class UserMembership {
    [string] $UserName
    [string] $UserId
    [Membership] $Membership
}