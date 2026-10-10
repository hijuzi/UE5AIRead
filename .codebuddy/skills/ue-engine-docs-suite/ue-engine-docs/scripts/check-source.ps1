<#
.SYNOPSIS
  Check whether an Unreal Engine source tree contains implementation files.

.DESCRIPTION
  A Launcher-installed engine may ship headers only, with every .cpp stripped.
  On such a tree, implementation-layer work (call-chain tracing) cannot run, and
  any zero-hit search result must be reported as "not determinable" rather than
  "the thing does not exist".

  Reports header, implementation and inline-file counts plus a verdict.

  Read-only. Kept pure ASCII on purpose: Windows PowerShell 5.1 decodes BOM-less
  script files as ANSI, so non-ASCII literals get mangled and can swallow the
  quotes that follow them. Chinese notes belong in SKILL.md, not here.

.PARAMETER SourceRoot
  Path to the engine 'Source' folder.
  Example: E:\EpicGames\UE_5.8\Engine\Source

.PARAMETER AsJson
  Emit JSON instead of a formatted report.

.EXAMPLE
  .\check-source.ps1 -SourceRoot "E:\EpicGames\UE_5.8\Engine\Source"

.EXAMPLE
  .\check-source.ps1 -SourceRoot "E:\EpicGames\UE_5.8\Engine\Source" -AsJson
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $SourceRoot,

    [switch] $AsJson
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    Write-Error "Source root not found: $SourceRoot"
    exit 1
}

$root = (Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')

# Marketplace / Fab / Bridge ship user-installed plugin code, not engine source.
# Counting them inflates the .cpp number and would produce a false "Complete".
$noise = '\\(Marketplace|Fab|Bridge)\\'

$files = @(
    Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $noise }
)

$headers = @($files | Where-Object { $_.Extension -ieq '.h' }).Count
$impl    = @($files | Where-Object { $_.Extension -ieq '.cpp' }).Count
$inline  = @($files | Where-Object { $_.Extension -ieq '.inl' }).Count

$verdict = if ($impl -gt 0) { 'Complete' } else { 'HeadersOnly' }

$report = [pscustomobject]@{
    SourceRoot     = $root
    Headers        = $headers
    Implementation = $impl
    InlineFiles    = $inline
    Verdict        = $verdict
}

if ($AsJson) {
    $report | ConvertTo-Json -Depth 3
    exit 0
}

Write-Host ("Source root                : {0}" -f $report.SourceRoot)
Write-Host ("Headers (.h)               : {0}" -f $report.Headers)
Write-Host ("Implementation (.cpp)      : {0}" -f $report.Implementation)
Write-Host ("Inline implementation (.inl): {0}" -f $report.InlineFiles)
Write-Host ("Verdict                    : {0}" -f $report.Verdict)
Write-Host ''

if ($verdict -eq 'HeadersOnly') {
    Write-Host 'WARNING: no .cpp file found under the source root.'
    Write-Host '         This is a headers-only engine install.'
    Write-Host '         The following are NOT supported on this tree:'
    Write-Host '           - call-chain tracing / execution order / algorithms'
    Write-Host '           - module entry point discovery'
    Write-Host '         Any zero-hit search result must be reported as'
    Write-Host '         "not determinable", NOT as "does not exist".'
}
