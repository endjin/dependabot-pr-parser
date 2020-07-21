[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $Title,

    [Parameter()]
    [string]
    $PackageNamePatternsJsonArray = '[]',

    [Parameter()]
    [string[]]
    $PackageNamePatterns = @()
)

$ErrorActionPreference = 'Stop'

try {
    # Import-Module ./module/dependabot-pr-parser.psm1 -DisableNameChecking

    # github actions can only pass strings, so this handles the JSON deserialization
    if ($PackageNamePatternsJsonArray -ne '[]') {
        $PackageNamePatterns = ConvertFrom-Json $PackageNamePatternsJsonArray
    }

    # parse the PR title
    $dependencyName,$fromVersion,$toVersion,$folder = ParsePrTitle -Title $Title

    # set github action output variables
    SetOutputVariable 'dependency_name' $dependencyName
    SetOutputVariable 'version_from' $fromVersion
    SetOutputVariable 'version_to' $toVersion
    SetOutputVariable 'folder' $folder

    # is the dependency name match the wildcard pattern?
    $matchFound = IsPackageInteresting -PackageName $dependencyName -PackageNamePatterns $PackageNamePatterns
    SetOutputVariable 'is_interesting_package' $matchFound

    if ($matchFound) {
        $upgradeType = GetUpgradeType -FromVersion $fromVersion -ToVersion $toVersion
        SetOutputVariable 'update_type' $upgradeType
    }
}
catch {
    exit 1
}