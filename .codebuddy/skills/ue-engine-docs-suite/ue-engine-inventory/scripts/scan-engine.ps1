<#
.SYNOPSIS
  Inventory Unreal Engine source modules by scanning *.Build.cs marker files.

.DESCRIPTION
  Enumerates module directories under an engine root, counts files and headers,
  and classifies each module by its top-level source category.

  Read-only: never writes to the engine tree.

  Kept pure ASCII on purpose. Windows PowerShell 5.1 decodes BOM-less script
  files as ANSI, so non-ASCII literals get mangled and can swallow the quotes
  that follow them. Chinese notes belong in SKILL.md, not here.

.PARAMETER EngineRoot
  Path to the engine folder containing 'Source' and optionally 'Plugins'.
  Example: E:\EpicGames\UE_5.8\Engine

.PARAMETER AsJson
  Emit a JSON array instead of formatted tables.

.PARAMETER SkipFileCount
  Skip per-module file counting. Much faster, but Files and Headers stay 0.

.EXAMPLE
  .\scan-engine.ps1 -EngineRoot "E:\EpicGames\UE_5.8\Engine"

.EXAMPLE
  .\scan-engine.ps1 -EngineRoot "E:\EpicGames\UE_5.8\Engine" -AsJson
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $EngineRoot,

    [switch] $AsJson,

    [switch] $SkipFileCount
)

$ErrorActionPreference = 'Stop'

# --- Validate the engine root ------------------------------------------------
if (-not (Test-Path -LiteralPath $EngineRoot -PathType Container)) {
    Write-Error "Engine root not found: $EngineRoot"
    exit 1
}

$root = (Resolve-Path -LiteralPath $EngineRoot).Path.TrimEnd('\')

if (-not (Test-Path -LiteralPath (Join-Path $root 'Source') -PathType Container)) {
    Write-Error "'Source' folder not found under: $root  (pass the engine root, not a subfolder)"
    exit 1
}

# --- Collect module markers (*.Build.cs) ------------------------------------
# Case-insensitive on purpose. The engine ships both 'Core.Build.cs' and
# 'VirtualProduction.build.cs'. Nested module dirs also exist, for example
# 'Source\Runtime\Windows\WindowsD3D\WindowsD3D.Build.cs'.
$noise = '\\(Intermediate|Binaries|ThirdParty)\\'

$markers = @(
    Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -match '(?i)\.build\.cs$' -and $_.FullName -notmatch $noise
        }
)

if ($markers.Count -eq 0) {
    Write-Warning "No *.Build.cs marker found under: $root"
    exit 0
}

# --- Build the catalog -------------------------------------------------------
$catalog = foreach ($marker in $markers) {

    $moduleDir = $marker.DirectoryName

    # 'Core.Build.cs' -> 'Core.Build' -> 'Core'
    $moduleName = [System.IO.Path]::GetFileNameWithoutExtension(
        [System.IO.Path]::GetFileNameWithoutExtension($marker.Name))

    $relPath = $moduleDir.Substring($root.Length).TrimStart('\')

    $seg = $relPath -split '\\'
    if ($seg.Count -ge 2 -and $seg[0] -eq 'Source') {
        $category = $seg[1]
    }
    elseif ($seg[0] -eq 'Plugins' -and $seg.Count -ge 2) {
        $category = 'Plugins/' + $seg[1]
    }
    else {
        $category = $seg[0]
    }

    $files = 0
    $headers = 0
    if (-not $SkipFileCount) {
        $inner = @(
            Get-ChildItem -LiteralPath $moduleDir -Recurse -File -Force -ErrorAction SilentlyContinue
        )
        $files = $inner.Count
        $headers = @($inner | Where-Object { $_.Extension -ieq '.h' }).Count
    }

    [pscustomobject]@{
        Category = $category
        Module   = $moduleName
        Path     = $relPath
        Files    = $files
        Headers  = $headers
    }
}

$catalog = @($catalog | Sort-Object Category, Module)

# --- Output ------------------------------------------------------------------
if ($AsJson) {
    $catalog | ConvertTo-Json -Depth 3
    exit 0
}

$catalog | Format-Table -AutoSize

Write-Host ''
Write-Host ("{0,-20} {1,8} {2,10}" -f 'Category', 'Modules', 'Files')
Write-Host ("{0,-20} {1,8} {2,10}" -f ('-' * 20), ('-' * 8), ('-' * 10))

$summary = $catalog | Group-Object Category | Sort-Object Name
foreach ($group in $summary) {
    $sum = (@($group.Group | Measure-Object -Property Files -Sum).Sum)
    if ($null -eq $sum) { $sum = 0 }
    Write-Host ("{0,-20} {1,8} {2,10}" -f $group.Name, $group.Count, $sum)
}

Write-Host ''
Write-Host ("Engine root : {0}" -f $root)
Write-Host ("Modules     : {0}" -f $catalog.Count)
