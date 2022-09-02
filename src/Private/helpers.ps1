function CreateDatabase {
    $dbPath = "$($PWD.Path)\Azure-AD-Backup.db"
    if (-not (Test-Path $dbPath)) {
        $database = New-Item -Path $dbPath -ItemType File | Select-Object -ExpandProperty FullName
    }
    else { $database = $dbPath }

    [System.Environment]::SetEnvironmentVariable('AZURE_AD_BACKUP_DATABASE', $database, [System.EnvironmentVariableTarget]::Process)

    return $database
}

function GetDatabasePath {
    if (!([string]::IsNullOrEmpty($env:AZURE_AD_BACKUP_DATABASE))) {
        return $env:AZURE_AD_BACKUP_DATABASE
    } else {
        return (CreateDatabase)
    }
}

function DropTable([string] $TableName) {
    Invoke-SqliteQuery -DataSource (GetDatabasePath) -Query "DROP TABLE IF EXISTS $TableName"
}

function CreateTable([string] $TableName, [string[]] $Columns) {
    $table = [System.Text.StringBuilder]::new("CREATE TABLE IF NOT EXISTS $TableName (")
    $null = $Columns | ForEach-Object {
        if ($_ -eq $Columns[-1]) {
            $table.Append("$_")
        }
        else { $table.Append("$_, ") }
    }
    $tableToCreate = $table.Append(")").ToString()
    Invoke-SqliteQuery -DataSource (GetDatabasePath) -Query "$tableToCreate"
}

function GetConfigFile {
    return (Get-ChildItem -Filter "config.json" | Select-Object -ExpandProperty FullName)
}

function Query([string] $TableName, [string] $Condition) {
    return Invoke-SqliteQuery -DataSource (GetDatabasePath) -Query "SELECT * FROM $TableName $Condition" -ErrorAction SilentlyContinue
}

function IsGroupExists([string] $GroupId) {
    return ([bool] (Get-AzADGroup -ObjectId $GroupId -ErrorAction SilentlyContinue))
}