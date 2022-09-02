function Find-User {
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
        [string] $Id,

        [Parameter(Mandatory, ParameterSetName = "ByEmail")]
        [ValidateNotNullOrEmpty()]
        [string] $Email,

        [Parameter(Mandatory, ParameterSetName = "ByUPN")]
        [ValidateNotNullOrEmpty()]
        [string] $UserPrincipalName,

        [Parameter(Mandatory, ParameterSetName = "All")]
        [switch] $All
    )

    process {
        try {
            $table = 'users'

            if ($PSCmdlet.ParameterSetName -eq 'ByName') {
                [User[]] $res = Query -TableName $table -Condition "WHERE displayname = '$Name'"
                if ($res) { return $res }
                Write-Warning "Couldn't find user with name '$Name'"
            }

            if ($PSCmdlet.ParameterSetName -eq 'ByPattern') {
                [User[]] $res = Query -TableName $table -Condition "WHERE displayname LIKE '$NamePattern%'"
                if ($res) { return $res }
                Write-Warning "Couldn't find user with name '$NamePattern'. If the name is valid, try using the pattern like %$NamePattern or try running cmdlet with -Email and pass the email id."
            }

            if ($PSCmdlet.ParameterSetName -eq 'ById') {
                [User] $res = Query -TableName $table -Condition "WHERE id = '$Id'"
                if ($res) { return $res }
                Write-Warning "Couldn't find user with id '$Id'"    
            }

            if ($PSCmdlet.ParameterSetName -eq 'ByEmail') {
                [User] $res = Query -TableName $table -Condition "WHERE mail = '$Email'"
                if ($res) { return $res }
                Write-Warning "Couldn't find user with email '$Email'"    
            }

            if ($PSCmdlet.ParameterSetName -eq 'ByUPN') {
                [User] $res = Query -TableName $table -Condition "WHERE userprincipalname = '$UserPrincipalName'"
                if ($res) { return $res }
                Write-Warning "Couldn't find user with email '$Email'"    
            }

            if (($PSCmdlet.ParameterSetName -eq 'All') -or ($All.IsPresent)) {
                return ([User[]] (Query $table))
            }
        }
        catch {
            Write-Error "An error occurred: $($_.Exception.Message)."
        }
    }
}