function Find-Group {
    [CmdletBinding(DefaultParameterSetName = "ByPattern")]
    param (
        [Parameter(Mandatory, ParameterSetName = "ByName")]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, ParameterSetName = "ByPattern", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $NamePattern,

        [Parameter(Mandatory, ParameterSetName = "ById")]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [Parameter(Mandatory, ParameterSetName = "All")]
        [switch] $All
    )

    process {
        try {
            $table = 'groups'

            if ($PSCmdlet.ParameterSetName -eq 'ByName') {
                [Group[]] $res = Query -TableName $table -Condition "WHERE displayname = '$Name'"
                if ($res) { return $res }
                Write-Warning "Couldn't find group with name '$Name'"
            }

            if ($PSCmdlet.ParameterSetName -eq 'ByPattern') {
                [Group[]] $res = Query -TableName $table -Condition "WHERE displayname LIKE '$NamePattern%'"
                if ($res) { return $res }
                Write-Warning "Couldn't find group with name '$NamePattern'. If the name is valid, try using the pattern like %$NamePattern."
            }

            if ($PSCmdlet.ParameterSetName -eq 'ById') {
                [Group] $res = Query -TableName $table -Condition "WHERE id = '$Id'"
                if ($res) { return $res }
                Write-Warning "Couldn't find group with id '$Id'"
            }

            if (($PSCmdlet.ParameterSetName -eq 'All') -or ($All.IsPresent)) {
                return ([group[]] (Query $table))
            }
        }
        catch {
            Write-Error "An error occurred: $($_.Exception.Message)."
        }
    }
}