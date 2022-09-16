function CreateDatabase {
    $dbPath = (GetDatabasePath)
    if (-not (Test-Path $dbPath)) {
        $database = New-Item -Path $dbPath -ItemType File | Select-Object -ExpandProperty FullName
    }
    else { $database = $dbPath }
    
    return $database
}

function GetDatabasePath {
    if (!([string]::IsNullOrEmpty($env:AZURE_AD_BACKUP_DATABASE))) {
        return $env:AZURE_AD_BACKUP_DATABASE
    }
    else {
        throw "Please set the backup path first by running 'Set-BackupPath' cmdlet."
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

function SetNumberOfJobs([int] $NumberOfJobs) {
    if ($NumberOfJobs -le 0) { $NumberOfJobs = 10 }
    [System.Environment]::SetEnvironmentVariable('AZURE_AD_BACKUP_JOBS_COUNT', $NumberOfJobs, [System.EnvironmentVariableTarget]::Process)    
}

function ValidateLogin() {
    try {
        Get-AzTenant -ErrorAction Stop | Out-Null
    }
    catch {
        if ($_.Exception.Message.Contains('is not recognized as a name of a cmdlet')) {
            throw "An error occurred: Couldn't find the Azure module 'Az' in the current session. Please install the module or import it if already installed and try again."
        }

        if ($_.Exception.Message.Contains('Run Connect-AzAccount to login.')) {
            throw "An error occurred: Please login to your azure tenant to perform the backup or restore operation. Run Connect-AzAccount -TenantId <TenantId> to login."
        }
    }
}