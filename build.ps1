#Requires -Modules InstallPSModules

param(
  [Parameter(Position=0)]
	[string[]]$Tasks,
  $ApiKey
)

if ([System.IO.Path]::GetFileName($MyInvocation.ScriptName) -ne 'Invoke-Build.ps1') {
  Install-PSModules
  Invoke-Build -Task $Tasks $PSScriptRoot\build.ps1 $PSBoundParameters
  return
}

Enter-Build {
  Install-PSModules
}

task publish {
  if (-Not $ApiKey) {
    throw "-ApiKey parameter is required for publish"
  }
  Publish-Module -Path .\InstallPSModules -NuGetApiKey $ApiKey
}