class Table {
    [string] $TableName
    [string[]] $Columns
}

class Schema {
    [Table[]] $Tables
}
