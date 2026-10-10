<#
.SYNOPSIS
    List Unreal Engine installations managed by the Epic Games Launcher.

.DESCRIPTION
    Reads the Launcher manifest files, keeps only engine installations
    (TechnicalType 'engines/ue5,engines') and prints each engine's version
    and install directory. Plugin entries ('plugins/engine,codeproject') are
    filtered out, so folders that merely look like engine folders - for
    example a UE_5.6 folder created by plugin installs - are not reported.

    Only the top-level manifest folder is scanned. Pending\ is skipped because
    those entries are installs that have not been applied yet.

    IMPORTANT: keep this file pure ASCII. Windows PowerShell 5.1 reads script
    files as ANSI when they have no BOM, which corrupts non-ASCII literals and
    can swallow the closing quote of a string.

.PARAMETER Verify
    Also check whether <InstallLocation>\Engine\Binaries\Win64\UnrealEditor.exe
    exists. Use this to spot manifests that no longer match the disk.

.PARAMETER AsJson
    Emit JSON instead of a formatted table.

.EXAMPLE
    .\list-engines.ps1

.EXAMPLE
    .\list-engines.ps1 -Verify

.EXAMPLE
    .\list-engines.ps1 -AsJson
#>
[CmdletBinding()]
param(
    [switch]$Verify,
    [switch]$AsJson
)

$ErrorActionPreference = 'Stop'

$manifestDir = Join-Path $env:ProgramData 'Epic\EpicGamesLauncher\Data\Manifests'
$editorExeRelative = 'Engine\Binaries\Win64\UnrealEditor.exe'
$engineTechnicalType = 'engines/ue5,engines'

if (-not (Test-Path -LiteralPath $manifestDir)) {
    Write-Error "Epic manifest directory not found: $manifestDir"
    return
}

$engines = @(
    Get-ChildItem -LiteralPath $manifestDir -Filter '*.item' -File |
        ForEach-Object {
            # Capture the file before try/catch: inside a catch block $_ is the
            # ErrorRecord, not the pipeline item, so $_.Name would be empty.
            $manifestFile = $_
            try {
                Get-Content -LiteralPath $manifestFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            }
            catch {
                Write-Warning "Skipping unparsable manifest: $($manifestFile.Name)"
                $null
            }
        } |
        Where-Object { $null -ne $_ -and $_.TechnicalType -eq $engineTechnicalType }
)

if ($engines.Count -eq 0) {
    Write-Warning 'No engine installation found in the manifest list (plugin entries only).'
    return
}

$result = @(
    $engines |
        ForEach-Object {
            # AppVersionString looks like "5.8.2-56702186+++UE5+Release-5.8-Windows".
            # The part before the first '+' is the version.
            $row = [PSCustomObject][ordered]@{
                Engine          = $_.AppName
                Version         = ($_.AppVersionString -split '\+')[0]
                InstallLocation = $_.InstallLocation
            }

            if ($Verify) {
                $row | Add-Member -NotePropertyName Usable -NotePropertyValue (
                    Test-Path -LiteralPath (Join-Path $_.InstallLocation $editorExeRelative)
                )
            }

            $row
        } |
        Sort-Object Engine
)

if ($AsJson) {
    $result | ConvertTo-Json -Depth 3
}
else {
    $result | Format-Table -AutoSize | Out-String -Width 250
}
