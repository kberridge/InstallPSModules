<#
 .Synopsis
  Installs and imports PowerShell modules defined in psmodules.json.

 .Description
  Like `dotnet tool install` for PowerShell Modules.  psmodules.json file defines the modules to be installed.
  Modules are installed to the user scope.

  psmodules.json schema is:
  {
    "modules": [
      { "name": "Module Name", "version": "1.0.0" }
    ]
  }

 .Example
  Install-PSModules
#>

$manifestFileName = "psmodules.json"

function ReadManifest() {
  $manifest = Get-ChildItem $manifestFileName
  $data = Get-Content $manifest | ConvertFrom-Json
  $data
}

function InstallModules($data) {
  if (!(Test-Path ".\$modulesFolder")) {
    New-Item -ItemType "directory" ".\$modulesFolder" | out-null
  }

  $data.modules | `
    Where-Object { -Not (IsInstalled -packageName $_.name -version $_.version) } | `
    ForEach-Object { InstallModule -packageName $_.name -version $_.version }
}

function IsInstalled($packageName, $version) {
  $availableModule = get-module -ListAvailable -FullyQualifiedName @{ ModuleName = $packageName; RequiredVersion = $version }
  $availableModule -and @($availableModule).Length -eq 1
}

function InstallModule($packageName, $version) {
  Write-Host "Installing $packageName $version..."
  Install-Module $packageName -RequiredVersion $version -Scope CurrentUser
}

function ImportModules($data) {
  $data.modules | ForEach-Object { ImportModule -packageName $_.name -version $_.version }
}

function ImportModule($packageName, $version) {
  # to ensure there are not multiple versions of the same module loaded,
  # first remove the module (all versions), then import it.
  $m = get-module $packageName
  if ($m -and @($m).Length -eq 1) {
    remove-module $packageName
  }
  Import-Module -FullyQualifiedName @{ ModuleName = $packageName; RequiredVersion = $version } -Force
}

$data = ReadManifest
InstallModules $data
ImportModules $data