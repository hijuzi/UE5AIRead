<#
.SYNOPSIS
  ue-doc-verify machine screening: referenced-file existence, line-range bounds,
  artifact header fields, path-format violations, mtime snapshot.

.DESCRIPTION
  Screens every artifact under <DocsRoot>/modules, <DocsRoot>/types and
  <DocsRoot>/flows. Machine-checkable only; semantic checks (whether the text
  at a cited line range matches the description) stay manual.

  Checks:
    [1] artifact header fields present (5 fields within first 6 lines)
    [2] path-format violations (drive-letter / backslash engine paths)
    [3] referenced files exist under the engine root
    [4] cited line ranges do not exceed file length
        - block form:   "\u6587\u4EF6\uFF1A<path>" followed by "\u884C A-B: ..."
        - inline form:  "<short-name> \u884C A-B" resolved via the artifact's
          short-name -> full-path table, or by unique basename match
    [5] newest mtimes among referenced files (manual review vs install time)

  Read-only. Pure ASCII on purpose: Windows PowerShell 5.1 decodes BOM-less
  script files as ANSI, so non-ASCII literals get mangled (same policy as
  check-source.ps1). CJK characters of the artifact format are matched through
  .NET regex \uXXXX escapes.

.PARAMETER DocsRoot
  Path to the docs root containing modules/, types/, flows/. Default: docs

.PARAMETER EngineRoot
  UE installation root containing the Engine/ folder.
  Example: E:\EpicGames\UE_5.8

.EXAMPLE
  .\verify-refs.ps1 -DocsRoot "docs" -EngineRoot "E:\EpicGames\UE_5.8"
#>
[CmdletBinding()]
param(
    [string] $DocsRoot = 'docs',

    [Parameter(Mandatory = $true)]
    [string] $EngineRoot
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $DocsRoot -PathType Container)) {
    Write-Error "Docs root not found: $DocsRoot"
    exit 1
}
if (-not (Test-Path -LiteralPath $EngineRoot -PathType Container)) {
    Write-Error "Engine root not found: $EngineRoot"
    exit 1
}

$docsRootResolved = (Resolve-Path -LiteralPath $DocsRoot).Path.TrimEnd('\')
$engRoot          = (Resolve-Path -LiteralPath $EngineRoot).Path.TrimEnd('\')

# --- CJK fragments of the artifact format (kept as regex escapes) ---
$P_FILE_COLON = '\u6587\u4EF6\uFF1A'                                     # "file:"
$P_LINE       = '\u884C'                                                 # "line"
$HEADER_FIELDS = @(
    @{ Key = 'engine-version'; Pat = '\u5F15\u64CE\u7248\u672C\uFF1A' }  # version
    @{ Key = 'source-root';    Pat = '\u6E90\u7801\u6839\uFF1A' }        # source root
    @{ Key = 'skill';          Pat = '\u751F\u6210\u6280\u80FD\uFF1A' }  # generating skill
    @{ Key = 'date';           Pat = '\u751F\u6210\u65F6\u95F4\uFF1A' }  # generated date
    @{ Key = 'status';         Pat = '\u6821\u9A8C\u72B6\u6001\uFF1A' }  # verify status
)

$PATH_PAT      = 'Engine/[A-Za-z0-9_\-./]+\.(?:h|cpp|cs|inl)'
$BLOCK_FILE    = '^\s*' + $P_FILE_COLON + '\s*`?([^`\s]+)`?'
$BLOCK_LINE    = '^\s*' + $P_LINE + '\s*(\d+)(?:\s*-\s*(\d+))?'
$INLINE_REF    = '([A-Za-z0-9_]+\.(?:h|cpp|cs|inl))`?\s*' + $P_LINE + '\s*(\d+)(?:\s*-\s*(\d+))?'
$SHORTMAP_ROW  = '^\|\s*`([^`]+)`\s*\|\s*`(Engine/[^`]+)`\s*\|'
$DRIVE_PAT     = '(?<![A-Za-z])[A-Za-z]:[\\/]'
$BACKSLASH_PAT = 'Engine\\'

# --- collect artifacts ---
$artifactDirs = @('modules', 'types', 'flows')
$artifacts = @()
foreach ($d in $artifactDirs) {
    $p = Join-Path $docsRootResolved $d
    if (Test-Path -LiteralPath $p -PathType Container) {
        $artifacts += @(Get-ChildItem -LiteralPath $p -File -Filter *.md | Sort-Object Name)
    }
}

Write-Host 'ue-doc-verify :: machine screening'
Write-Host ("Docs root   : {0}" -f $docsRootResolved)
Write-Host ("Engine root : {0}" -f $engRoot)
Write-Host ("Artifacts   : {0}" -f $artifacts.Count)
Write-Host ''

if ($artifacts.Count -eq 0) {
    Write-Host 'No artifacts found under modules/ types/ flows/.'
    exit 0
}

# --- pass 1: scan each artifact ---
$headerLines   = New-Object System.Collections.ArrayList   # pscustomobject Artifact, Missing
$pathViolations= New-Object System.Collections.ArrayList   # strings
$rawBlocks     = New-Object System.Collections.ArrayList   # Artifact, File, Start, End, Line
$rawInlines    = New-Object System.Collections.ArrayList   # Artifact, Name, Start, End, Line
$shortMaps     = @{}                                       # artifact -> hashtable name->path
$allRefs       = @{}                                       # full path -> $true

foreach ($a in $artifacts) {
    $rel   = $a.FullName.Substring($docsRootResolved.Length + 1).Replace('\', '/')
    $lines = [System.IO.File]::ReadAllLines($a.FullName)

    # [1] header
    $head = ($lines | Select-Object -First 6) -join "`n"
    $missing = @()
    foreach ($f in $HEADER_FIELDS) {
        if ($head -notmatch $f.Pat) { $missing += $f.Key }
    }
    [void]$headerLines.Add([pscustomobject]@{ Artifact = $rel; Missing = $missing })

    # short-name table
    $map = @{}
    $currentRefFile = $null
    $lineNo = 0
    foreach ($line in $lines) {
        $lineNo++

        # referenced paths (any occurrence)
        foreach ($m in [regex]::Matches($line, $PATH_PAT)) {
            $allRefs[$m.Value] = $true
        }

        # short-name -> full path rows
        if ($line -match $SHORTMAP_ROW) {
            $sn = $matches[1]; $fp = $matches[2]
            if (-not $map.ContainsKey($sn)) { $map[$sn] = $fp }
        }

        # [2] path-format violations
        if ($line -match $DRIVE_PAT) {
            [void]$pathViolations.Add(("{0}:{1}: drive-letter path" -f $rel, $lineNo))
        }
        if ($line -match $BACKSLASH_PAT) {
            [void]$pathViolations.Add(("{0}:{1}: backslash engine path" -f $rel, $lineNo))
        }

        # [4] block form: file line followed by "line A-B" lines
        if ($line -match $BLOCK_FILE) {
            $currentRefFile = $matches[1].Trim()
            $allRefs[$currentRefFile] = $true
            continue
        }
        if ($currentRefFile -and ($line -match $BLOCK_LINE)) {
            $s = [int]$matches[1]; $e = $s
            if ($matches[2]) { $e = [int]$matches[2] }
            [void]$rawBlocks.Add([pscustomobject]@{
                Artifact = $rel; File = $currentRefFile; Start = $s; End = $e; Line = $lineNo
            })
            continue
        }

        # [4] inline form: "<short-name> line A-B"
        foreach ($m in [regex]::Matches($line, $INLINE_REF)) {
            $s = [int]$m.Groups[2].Value; $e = $s
            if ($m.Groups[3].Success) { $e = [int]$m.Groups[3].Value }
            [void]$rawInlines.Add([pscustomobject]@{
                Artifact = $rel; Name = $m.Groups[1].Value
                Start = $s; End = $e; Line = $lineNo
            })
        }
    }
    $shortMaps[$rel] = $map
}

# --- pass 2: resolve inline refs (short-name table, then unique basename) ---
$baseMap = @{}
foreach ($k in $allRefs.Keys) {
    $bn = ($k -replace '\\', '/' -split '/')[-1]
    if (-not $baseMap.ContainsKey($bn)) { $baseMap[$bn] = New-Object System.Collections.ArrayList }
    [void]$baseMap[$bn].Add($k)
}

$refPoints  = New-Object System.Collections.ArrayList   # resolved: Artifact, File, Start, End, Kind, Line
$unresolved = New-Object System.Collections.ArrayList   # strings
foreach ($bp in $rawBlocks) {
    [void]$refPoints.Add([pscustomobject]@{
        Artifact = $bp.Artifact; File = $bp.File; Start = $bp.Start; End = $bp.End; Kind = 'block'; Line = $bp.Line
    })
}
foreach ($ip in $rawInlines) {
    $target = $null
    $map = $shortMaps[$ip.Artifact]
    if ($map.ContainsKey($ip.Name)) {
        $target = $map[$ip.Name]
    }
    elseif ($baseMap.ContainsKey($ip.Name) -and $baseMap[$ip.Name].Count -eq 1) {
        $target = $baseMap[$ip.Name][0]
    }
    if ($target) {
        $allRefs[$target] = $true
        [void]$refPoints.Add([pscustomobject]@{
            Artifact = $ip.Artifact; File = $target; Start = $ip.Start; End = $ip.End; Kind = 'inline'; Line = $ip.Line
        })
    }
    else {
        [void]$unresolved.Add(("{0}:{1}: {2} line {3}" -f $ip.Artifact, $ip.Line, $ip.Name, $ip.Start))
    }
}

# --- pass 3: check referenced files: existence, line counts, mtime ---
$missingFiles = New-Object System.Collections.ArrayList
$fileInfo     = @{}    # refPath -> psustomobject Exists, Abs, Lines, Mtime
foreach ($rp in $allRefs.Keys) {
    $abs = Join-Path $engRoot ($rp -replace '/', '\')
    $exists = Test-Path -LiteralPath $abs -PathType Leaf
    $lineCount = $null
    $mtime = $null
    if ($exists) {
        $lineCount = [System.IO.File]::ReadAllLines($abs).Count
        $mtime = (Get-Item -LiteralPath $abs).LastWriteTime
    }
    else {
        [void]$missingFiles.Add($rp)
    }
    $fileInfo[$rp] = [pscustomobject]@{ Exists = $exists; Abs = $abs; Lines = $lineCount; Mtime = $mtime }
}

$outOfRange = New-Object System.Collections.ArrayList
foreach ($pt in $refPoints) {
    $fi = $fileInfo[$pt.File]
    if ($fi -and $fi.Exists) {
        if ($pt.End -gt $fi.Lines) {
            [void]$outOfRange.Add(("{0}:{1}: {2} range {3}-{4} exceeds file length {5}" -f `
                $pt.Artifact, $pt.Line, $pt.File, $pt.Start, $pt.End, $fi.Lines))
        }
    }
    elseif (-not $fi) {
        [void]$outOfRange.Add(("{0}:{1}: target not resolved: {2}" -f $pt.Artifact, $pt.Line, $pt.File))
    }
}

# --- report ---
$badCount = $missingFiles.Count + $outOfRange.Count + $pathViolations.Count + @($headerLines | Where-Object { $_.Missing.Count -gt 0 }).Count

Write-Host '== [1] Artifact headers =='
foreach ($h in $headerLines) {
    if ($h.Missing.Count -eq 0) {
        Write-Host ("  [ok]   {0}" -f $h.Artifact)
    }
    else {
        Write-Host ("  [FAIL] {0}  missing: {1}" -f $h.Artifact, ($h.Missing -join ','))
    }
}
Write-Host ''

Write-Host '== [2] Path-format violations =='
if ($pathViolations.Count -eq 0) { Write-Host '  (none)' }
else { foreach ($v in $pathViolations) { Write-Host ("  [FAIL] {0}" -f $v) } }
Write-Host ''

Write-Host ("== [3] Referenced files ({0} unique) ==" -f $allRefs.Count)
if ($missingFiles.Count -eq 0) { Write-Host '  all exist' }
else { foreach ($v in ($missingFiles | Sort-Object)) { Write-Host ("  [FAIL] missing: {0}" -f $v) } }
Write-Host ''

Write-Host ("== [4] Line-range references ({0} resolved points) ==" -f $refPoints.Count)
$kindStat = $refPoints | Group-Object Kind | ForEach-Object { "{0}:{1}" -f $_.Name, $_.Count }
Write-Host ("  by kind: {0}" -f ($kindStat -join '  '))
if ($unresolved.Count -gt 0) {
    Write-Host ("  unresolved inline refs ({0}) - check manually:" -f $unresolved.Count)
    foreach ($v in $unresolved) { Write-Host ("    ? {0}" -f $v) }
}
if ($outOfRange.Count -eq 0) { Write-Host '  all in range' }
else { foreach ($v in $outOfRange) { Write-Host ("  [FAIL] {0}" -f $v) } }
Write-Host ''

Write-Host '== [5] mtime snapshot (top 5 newest among referenced files) =='
$sorted = $fileInfo.Values | Where-Object { $_.Exists } | Sort-Object Mtime -Descending | Select-Object -First 5
foreach ($fi in $sorted) {
    Write-Host ("  {0}  {1}" -f $fi.Mtime.ToString('yyyy-MM-dd HH:mm:ss'), $fi.Abs)
}
$bv = Join-Path $engRoot 'Engine\Build\Build.version'
if (Test-Path -LiteralPath $bv -PathType Leaf) {
    $bvm = (Get-Item -LiteralPath $bv).LastWriteTime
    Write-Host ("  reference Build.version mtime : {0}" -f $bvm.ToString('yyyy-MM-dd HH:mm:ss'))
}
Write-Host ''

if ($badCount -eq 0) {
    Write-Host 'SUMMARY: PASS (no machine-detectable defect)'
    exit 0
}
else {
    Write-Host ("SUMMARY: FAIL ({0} machine-detectable defect(s))" -f $badCount)
    exit 1
}
