param(
  $ApiKey
)

task publish {
  if (-Not $ApiKey) {
    throw "-ApiKey parameter is required for publish"
  }
  Publish-Module -Path .\InstallPSModules -NuGetApiKey $ApiKey
}