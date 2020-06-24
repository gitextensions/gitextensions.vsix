[CmdletBinding(PositionalBinding=$false)]
Param(
  [string] $version,
  [string] $logFileName = "build.binlog",
  [string][Alias('c')] $configuration = "Debug",
  [string][Alias('v')] $verbosity = "minimal",
  [switch] $restore,
  [switch][Alias('b')]$build,
  [switch] $rebuild,
  [switch] $clean,
  [switch] $publish,
  [switch] $ci,
  [switch][Alias('bl')] $binaryLog,
  [switch] $help,
  [Parameter(ValueFromRemainingArguments=$true)][String[]]$properties
)

. $PSScriptRoot\tools.ps1

# break on errors
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

$env:SKIP_PAUSE=1
$toolsetBuildProj = Resolve-Path 'scripts\tools\Build.proj'
 
function Build {

  # build the solution
  $bl = if ($binaryLog) { "/bl:" + (Join-Path $LogDir $logFileName) } else { "" }
  $platformArg = '' # if ($platform) { "/p:Platform=$platform" } else { "" }

  MSBuild $toolsetBuildProj `
    $bl `
    $platformArg `
    /p:Configuration=$configuration `
    /p:RepoRoot=$RepoRoot `
    /p:Restore=$restore `
    /p:Build=$build `
    /p:Rebuild=$rebuild `
    /p:Publish=$publish `
    /p:ContinuousIntegrationBuild=$ci `
    @properties;

  $exitCode = $LastExitCode;
  if ($exitCode -ne 0) {
    Exit $exitCode
  }
}

try {
  Push-Location $PSScriptRoot\..\

  if ($clean) {
    if (Test-Path $ArtifactsDir) {
      Remove-Item -Recurse -Force $ArtifactsDir
      Write-Host 'Artifacts directory deleted.'
    }

    MSBuild $toolsetBuildProj `
      /p:RepoRoot=$RepoRoot `
      /p:Clean=$clean `
      @properties;

    Exit 0
  }

  Build
}
catch {
  Write-Error $_.Exception
  Exit -1
}
finally {
  Pop-Location
}
