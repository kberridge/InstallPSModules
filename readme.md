# InstallPSModules
This is a PowerShell module that installs PowerShell modules!

I'm a big fan of using PowerShell for build and deployment automation.  But if you have multiple repos and you want to use the same scripts in each of them, it can be annoying to share those scripts.  At the worst you might be copying and pasting script files into repos, and then dealing with them getting out of sync as changes inevitably need to be made.  At best you can package your scripts into a PowerShell module that can be versioned and installed.  But now there are more challenges:

1. How do you install the modules your repo needs?  Every developer just has to do it manually?
2. How do you know what modules are needed?  What versions?
2. How do you deal with different repos that need different versions?

What I want is a "tools"-like system similar to `dotnet tool install` and npm so you can define all the modules and versions a project needs and install and load them with a single command when you need them.  And that's what InstallPSModules is for!

## Installation

`Install-Module InstallPSModules -Scope CurrentUser`

## How To
In your repo, define a psmodules.json file:

```
{
  modules: [
    { "name": "InvokeBuild", "version": "5.12.0" }
  ]
}
```

Install and load the modules:

```
Install-PSModules
```

All modules defined in the psmodules.json file are now installed and loaded.  If other versions of the same module were previously loaded, they have now been replaced.  You can run `get-module` to see them.  And the modules are loaded, so you can now execute their commandlets.

## With Invoke-Build
I love [Invoke-Build](https://github.com/nightroman/Invoke-Build).  You can use Install-PSModules together with Invoke-Build to load your own scripts when Invoke-Build is executed.  You can also use Install-PSModules to bootstrap Invoke-Build itself when you use the self executing pattern!

Example build.ps1:
```ps1
#Requires -Modules InstallPSModules

param(
  [Parameter(Position=0)]
	[string[]]$Tasks
)

# This is the self-invocation pattern, so you can call `.\build` instead of `invoke-build`.
if ([System.IO.Path]::GetFileName($MyInvocation.ScriptName) -ne 'Invoke-Build.ps1') {
  # Will install and load Invoke-Build if it's in your psmodules.json
  Install-PSModules
  Invoke-Build -Task $Tasks $PSScriptRoot\build.ps1 $PSBoundParameters
  return
}

# This runs before every build, so all your modules will be installed and loaded.
Enter-Build {
  Install-PSModules
}

task test {
  "hello!"
  # Call any of your own shared module scripts!
}
```