# Clean, build, analyze, test and publish test results. (CI)
# Publish module (CD)

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string] $ModuleName = (Get-ProjectName),

    [Parameter(Mandatory = $false, Position = 1)]
    [ValidateSet("Major", "Minor", "Patch", "Build", "None")]
    # This can be controlled in build script or in Manifest file
    [string] $Version = "None"
)

$root = Split-Path $PSCommandPath

Task Clean {
    #region module refresh
    if (Get-Module $ModuleName) {
        Remove-Module $ModuleName
    }
    #endregion module refresh
}

Task Build {
    # import the merge function
    . .\Merge-Files.ps1

    # move all the functions to module file.
    Merge-Files `
        -InputDirectory .\src\Classes `
        -OutputDirectory .\bin\dist\azure-ad-recovery-manager\azure-ad-recovery-manager.classes.ps1 -Classes
    Merge-Files `
        -InputDirectory .\src\Private\, .\src\Public\ `
        -OutputDirectory .\bin\dist\azure-ad-recovery-manager\azure-ad-recovery-manager.functions.ps1 -Functions
    Copy-Item `
        -Path ("$($PWD.Path)\src\azure-ad-recovery-manager.psm1", "$($PWD.Path)\src\azure-ad-recovery-manager.psd1") `
        -Destination "$($PWD.Path)\bin\dist\azure-ad-recovery-manager\"
    Copy-Item -Path "$($PWD.Path)\src\en-US\" -Destination "$($PWD.Path)\bin\dist\azure-ad-recovery-manager\" -Recurse -Force
}

Task UpdateManifest {
    # import and copy only public functions to manifest file.
    Import-Module "$root\bin\dist\$ModuleName\$ModuleName.psm1" -Force
    $functions = (Get-Command -Module $ModuleName).Name | Where-Object {$_ -like "*-*"}

    # Bump the version of the module
    if ($Version -ne 'None') {
        Step-ModuleVersion -Path (Get-PSModuleManifest -Path "$($PWD.Path)\bin\dist\") -By $Version
    }
    if ($functions) {
        Set-ModuleFunction -Name (Get-PSModuleManifest -Path "$($PWD.Path)\bin\dist\") -FunctionsToExport $functions
    }
}

Task Analyze {
    # run PSScriptAnalyzer
    Write-Output "Running Static code analyzer"
    Invoke-ScriptAnalyzer -Path .\bin\dist\azure-ad-recovery-manager -Recurse -ReportSummary -ExcludeRule ("PSUseToExportFieldsInManifest")
}

Task Test {
    Write-Output "Running Pester tests"
    Invoke-Pester .\src\Tests -OutputFormat NUnitXml -OutputFile ".\src\Tests\results\test-results.xml" -Show All -WarningAction SilentlyContinue
}