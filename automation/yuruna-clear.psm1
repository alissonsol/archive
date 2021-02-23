<#PSScriptInfo
.VERSION 0.1
.GUID 06e8bceb-f7aa-47e8-a633-1fc36173d278
.AUTHOR Alisson Sol
.COMPANYNAME None
.COPYRIGHT (c) 2021 Alisson Sol et al.
.TAGS yuruna-clear
.LICENSEURI https://www.yuruna.com
.PROJECTURI https://www.yuruna.com
.ICONURI
.EXTERNALMODULEDEPENDENCIES powershell-yaml
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.PRIVATEDATA
#>

$yuruna_root = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..")
$modulePath = Join-Path -Path $yuruna_root -ChildPath "automation/import-yaml"
Import-Module -Name $modulePath

function Clear-Configuration {
    param (
        $project_root,
        $config_subfolder
    )

    if (!(Confirm-ResourceList $project_root $config_subfolder)) { return $false; }
    Write-Debug "---- Destroying Resources"

    $resourcesFile = Join-Path -Path $project_root -ChildPath "config/$config_subfolder/resources.yml"
    if (-Not (Test-Path -Path $resourcesFile)) { Write-Information "File not found: $resourcesFile"; return $false; }
    $yaml = ConvertFrom-File $resourcesFile

    # For each resource in resources.yml
    if ($null -eq $yaml.resources) { Write-Information "resources cannot be null or empty in file: $resourcesFile"; return $false; }
    foreach ($resource in $yaml.resources) {
        $resourceName = $resource['name']
        $resourceTemplate = $resource['template']
        Write-Debug "resource: $resourceName - template: $resourceTemplate"
        if ([string]::IsNullOrEmpty($resourceName)) { Write-Information "resource without name in file: $resourcesFile"; return $false; }
        # resource template can be empty: just naming already existing resource
        if (![string]::IsNullOrEmpty($resourceTemplate)) {
            # go to work folder under .yuruna
            $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/$config_subfolder/resources/$resourceName"
            if (-Not ([string]::IsNullOrEmpty($workFolder))) {
                $workFolder = Resolve-Path -Path $workFolder -ErrorAction "SilentlyContinue"
                if (-Not ([string]::IsNullOrEmpty($workFolder))) {
                    # execute terraform destroy from work folder
                    Push-Location $workFolder
                    Write-Information "Executing terraform destroy from $workFolder"
                    $result = terraform destroy -auto-approve -refresh=false
                    Write-Debug "Terraform destroy: $result"
                    Pop-Location
                    Remove-Item -Path $workFolder -Force -Recurse -ErrorAction "SilentlyContinue"
                }
            }
        }
    }

    return $true;
}

Export-ModuleMember -Function * -Alias *
