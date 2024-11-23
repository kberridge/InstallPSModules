<#
 .Synopsis
  Installs and imports PowerShell modules defined in psmodules.json within the local working directory.

 .Description
  Like `dotnet tool install` for PowerShell Modules.  psmodules.json file defines the modules to be installed.
  Modules are installed to a local PSModules folder and imported.

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
$modulesFolder = "PSModules"

function FindManifest() {
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
  Test-Path ".\$modulesFolder\$packageName\$version"
}

function InstallModule($packageName, $version, $repository = 'PSGallery') {
  Write-Host "Installing $packageName $version..."
  Find-Module -Name $packageName -RequiredVersion $version -Repository $repository `
    | Save-Module -Path ".\$modulesFolder"
}

function ImportModules($data) {
  $data.modules | ForEach-Object { ImportModule -packageName $_.name -version $_.version }
}

function ImportModule($packageName, $version) {
  $m = get-module $packageName
  if ($m -and @($m).Length -eq 1) {
    remove-module $packageName
  }
  $p = Expand-Path ".\$modulesFolder\$packageName\$version\*.psm1"
  Import-Module -name $p -Force
}

$data = FindManifest
InstallModules $data
ImportModules $data