<#
.SYNOPSIS
  ue-doc-verify machine screening: referenced-file existence, line-range bounds,
  artifact header fields, path-format violations, engine version anchor.

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
        - di form:      "\u7B2C N-M \u884C" (number precedes the char) bound ONLY
          when a file token sits immediately before the number on the same line;
          other occurrences are counted as unbound and never guessed
    [5] engine version anchor read from Engine/Build/Build.version

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

$PATH_PAT      = '(?<![A-Za-z0-9_\\/])Engine/[A-Za-z0-9_\-./]+\.(?:h|cpp|cs|inl)'
$BLOCK_FILE    = '^\s*' + $P_FILE_COLON + '\s*`?([^`\s]+)`?'
$BLOCK_LINE    = '^\s*' + $P_LINE + '\s*(\d+)(?:\s*-\s*(\d+))?'
$INLINE_REF    = '([A-Za-z0-9_]+\.(?:h|cpp|cs|inl))`?\s*' + $P_LINE + '\s*(\d+)(?:\s*-\s*(\d+))?'
$SHORTMAP_ROW  = '^\|\s*`([^`]+)`\s*\|\s*`(Engine/[^`]+)`\s*\|'
$DRIVE_PAT     = '(?<![A-Za-z])[A-Za-z]:[\\/]'
$BACKSLASH_PAT = 'Engine\\'
$NAME_PAT      = '[A-Za-z0-9_]+\.(?:h|cpp|cs|inl)'
$DI_LINE       = '\u7B2C\s*(\d+)(?:\s*[-\u2013~]\s*(\d+))?\s*' + $P_LINE
# adjacency form: a file token immediately (spaces / one opening bracket allowed) before the number
$DI_ADJ        = '(?<f>(?<![A-Za-z0-9_\\/])Engine/[A-Za-z0-9_\-./]+\.(?:h|cpp|cs|inl)|[A-Za-z0-9_]+\.(?:h|cpp|cs|inl))`?\s*[\uFF08(]?\s*\u7B2C\s*(?<s>\d+)(?:\s*[-\u2013~]\s*(?<e>\d+))?\s*' + $P_LINE

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
$rawDis        = New-Object System.Collections.ArrayList   # "di" form: Artifact, File, Name, Start, End, Line, Kind
$shortMaps     = @{}                                       # artifact -> hashtable name->path
$allRefs       = @{}                                       # full path -> $true
$diUnboundRaw  = 0                                         # "di" occurrences with no adjacent file token (never guessed)

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

        # [4] "di" form: "<file> 第 N(-M) 行" — bind ONLY when a file token sits
        #   immediately before the number on the SAME line (spaces, a backtick and
        #   one opening bracket allowed in between). Any other occurrence is counted
        #   as unbound and NEVER guessed: a single line may cite several files, and
        #   the nearest file name in a paragraph is not necessarily the referent.
        $diTotal = ([regex]::Matches($line, $DI_LINE)).Count
        $diHit   = 0
        foreach ($m in [regex]::Matches($line, $DI_ADJ)) {
            $tok = $m.Groups['f'].Value
            $s   = [int]$m.Groups['s'].Value
            $e   = $s
            if ($m.Groups['e'].Success) { $e = [int]$m.Groups['e'].Value }
            $entry = [pscustomobject]@{
                Artifact = $rel; File = $null; Name = $null
                Start = $s; End = $e; Line = $lineNo; Kind = 'di-name'
            }
            if ($tok -match '^(?i)Engine[\\/]') {
                $entry.File = $tok -replace '\\', '/'
                $entry.Kind = 'di-path'
            }
            else {
                $entry.Name = ($tok -replace '\\', '/' -split '/')[-1]
            }
            [void]$rawDis.Add($entry)
            $diHit++
        }
        if ($diTotal -gt $diHit) { $diUnboundRaw += ($diTotal - $diHit) }
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

# resolve "di" refs whose binding came from a short name (same line, or single-name paragraph)
$diBound   = 0
$diUnbound = 0
foreach ($dp in $rawDis) {
    $target = $dp.File
    if (-not $target -and $dp.Name) {
        $map = $shortMaps[$dp.Artifact]
        if ($map.ContainsKey($dp.Name)) {
            $target = $map[$dp.Name]
        }
        elseif ($baseMap.ContainsKey($dp.Name) -and $baseMap[$dp.Name].Count -eq 1) {
            $target = $baseMap[$dp.Name][0]
        }
    }
    if ($target) {
        $allRefs[$target] = $true
        $diBound++
        [void]$refPoints.Add([pscustomobject]@{
            Artifact = $dp.Artifact; File = $target; Start = $dp.Start; End = $dp.End; Kind = $dp.Kind; Line = $dp.Line
        })
    }
    else {
        $diUnbound++
    }
}

# --- pass 3: check referenced files: existence, line counts ---
$missingFiles = New-Object System.Collections.ArrayList
$fileInfo     = @{}    # refPath -> pscustomobject Exists, Abs, Lines
foreach ($rp in $allRefs.Keys) {
    $abs = Join-Path $engRoot ($rp -replace '/', '\')
    $exists = Test-Path -LiteralPath $abs -PathType Leaf
    $lineCount = $null
    if ($exists) {
        $lineCount = [System.IO.File]::ReadAllLines($abs).Count
    }
    else {
        [void]$missingFiles.Add($rp)
    }
    $fileInfo[$rp] = [pscustomobject]@{ Exists = $exists; Abs = $abs; Lines = $lineCount }
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
Write-Host ("  di form (number before the CJK line char): {0} checked / {1} unbound - no file token adjacent to the number" -f $diBound, ($diUnboundRaw + $diUnbound))
if ($unresolved.Count -gt 0) {
    Write-Host ("  unresolved inline refs ({0}) - check manually:" -f $unresolved.Count)
    foreach ($v in $unresolved) { Write-Host ("    ? {0}" -f $v) }
}
if ($outOfRange.Count -eq 0) { Write-Host '  all in range' }
else { foreach ($v in $outOfRange) { Write-Host ("  [FAIL] {0}" -f $v) } }
Write-Host ''

Write-Host '== [5] Engine version anchor (Engine/Build/Build.version) =='
$bv = Join-Path $engRoot 'Engine\Build\Build.version'
if (Test-Path -LiteralPath $bv -PathType Leaf) {
    try {
        $vinfo = Get-Content -LiteralPath $bv -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host ("  UE {0}.{1}.{2} (Build {3})" -f $vinfo.MajorVersion, $vinfo.MinorVersion, $vinfo.PatchVersion, $vinfo.Changelist)
        Write-Host ("  branch   : {0}" -f $vinfo.BranchName)
        Write-Host ("  compatible changelist : {0}" -f $vinfo.CompatibleChangelist)
    }
    catch {
        Write-Host '  [warn] Build.version exists but could not be parsed'
    }
}
else {
    Write-Host '  [warn] Engine/Build/Build.version not found - version anchor not determinable'
}
Write-Host ''

# --- [6] count-method rows: marker classification + recomputation (convention.md 4.2.1) ---
# Every count-method row must declare its method with a leading [M] / [R] / [H].
#   [M] machine-recomputable  -> the row must contain a whitelisted command; it is executed and compared
#   [R] derived from another artifact -> the named source must exist
#   [H] human read-through    -> engine-file-looking tokens must exist
# Rows without a marker, [M] rows without an executable command, and rows whose declared
# source is missing are reported by [6c] and counted as defects.
# SAFETY: this never evaluates raw document text. It parses a strict whitelist of
# read-only counting expressions, REBUILDS the expression from validated parts
# (path + optional flags/pattern), and rejects any part containing  $ ; | & `  or newline.
# Whitelist:
#   (Get-ChildItem "<path>" [flags]).Count
#   [System.IO.File]::ReadAllLines("<path>").Count
#   Select-String "<path>" -Pattern '<pat>' [-CaseSensitive] -AllMatches [-Range A-B]
#     -Range scopes the count to lines A..B (class-body / struct-body claims)
$P_COUNT_SEC = '\u53D6\u6570\u8BF4\u660E'          # "count-method" section heading
$srcRoot     = Join-Path $engRoot 'Engine\Source'

function Resolve-RefPath([string]$p) {
    $q = $p.Trim().Trim('"').Trim("'")
    if ($q -match '^(?i)Engine[\\/]') { return (Join-Path $engRoot ($q -replace '/', '\')) }
    return (Join-Path $srcRoot ($q -replace '/', '\'))
}
function Test-PartSafe([string]$s) {
    if ([string]::IsNullOrEmpty($s)) { return $false }
    return ($s -notmatch '[\$;|&`\r\n]')
}
function Select-StringInRange([string]$path, [string]$pattern, [int]$from, [int]$to) {
    # line-range scoped match count (class-body claims); never executes document text
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return 0 }
    $all = [System.IO.File]::ReadAllLines($path)
    if ($from -lt 1) { $from = 1 }
    if ($to -gt $all.Count) { $to = $all.Count }
    if ($to -lt $from) { return 0 }
    $seg = $all[($from - 1)..($to - 1)]
    $n = 0
    foreach ($ln in $seg) { $n += ([regex]::Matches($ln, $pattern)).Count }
    return $n
}

function Test-DocSource([string]$tok) {
    # returns $true (exists) / $false (looks like a path but missing) / $null (not checkable)
    $t = $tok.Trim()
    if ($t -eq '') { return $null }
    if ($t -match '[\*\s]') { return $null }
    if ($t -notmatch '\.(md|json|h|cpp|cs|inl|txt)$') { return $null }
    if ($t -notmatch '[\\/]') { return $null }
    $rel2 = $t -replace '/', '\'
    foreach ($cand in @((Join-Path $docsRootResolved $rel2),
                        (Join-Path $engRoot $rel2),
                        (Join-Path $engRoot ('Engine\Source\' + $rel2)),
                        (Join-Path $engRoot ('Engine\' + $rel2)))) {
        if (Test-Path -LiteralPath $cand -PathType Leaf) { return $true }
    }
    return $false
}

$cntRows    = New-Object System.Collections.ArrayList   # recomputation mismatches
$cntDecl    = New-Object System.Collections.ArrayList   # declaration defects (4.2.1)
$cntChecked = 0
$rowM = 0; $rowR = 0; $rowH = 0
foreach ($d in @('modules', 'types', 'flows')) {
    $dir = Join-Path $docsRootResolved $d
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { continue }
    foreach ($f in (Get-ChildItem -LiteralPath $dir -File -Filter *.md)) {
        $rel = $f.FullName.Substring($docsRootResolved.Length + 1).Replace('\', '/')
        $lines6 = [System.IO.File]::ReadAllLines($f.FullName)
        $inSec = $false
        foreach ($l in $lines6) {
            if ($l -match ('^##+\s*' + $P_COUNT_SEC)) { $inSec = $true; continue }
            if ($inSec -and ($l -match '^##')) { $inSec = $false }
            if (-not $inSec) { continue }
            if ($l -notmatch '^\s*\|') { continue }
            $cells = @($l.Trim().Trim('|') -split '\|')
            if ($cells.Count -lt 2) { continue }
            $claim = $cells[0].Trim()
            $how   = $cells[1].Trim()
            if ($claim -match '^\s*[-:]+\s*$') { continue }     # separator row
            if ($claim -notmatch '\d') { continue }             # header row / non-count claim
            $nums = @()
            foreach ($mm in [regex]::Matches($claim, '\d[\d,]*')) { $nums += [int]($mm.Value -replace ',', '') }
            $toks = @()
            foreach ($m in [regex]::Matches($how, '`([^`]+)`')) { $toks += $m.Groups[1].Value.Trim() }
            $marker = ''
            if ($how -match '^\s*`?\[(M|R|H)\]`?') { $marker = $matches[1] }
            if ($marker -eq '') {
                [void]$cntDecl.Add([pscustomobject]@{ A = $rel; K = 'undeclared (no [M]/[R]/[H])'; D = $claim })
                continue
            }
            if ($marker -eq 'R') {
                $rowR++
                $found = $false
                foreach ($tk in $toks) { if ((Test-DocSource $tk) -eq $true) { $found = $true } }
                if (-not $found) { [void]$cntDecl.Add([pscustomobject]@{ A = $rel; K = 'R-source-missing'; D = $claim }) }
                continue
            }
            if ($marker -eq 'H') {
                $rowH++
                $badT = @()
                foreach ($tk in $toks) { if ((Test-DocSource $tk) -eq $false) { $badT += $tk } }
                if ($badT.Count -gt 0) { [void]$cntDecl.Add([pscustomobject]@{ A = $rel; K = 'H-token-missing'; D = ($claim + ' | ' + ($badT -join ' ')) }) }
                continue
            }
            # marker M: must yield at least one executable whitelisted command
            $rowM++
            $results = @()
            foreach ($cmd in $toks) {
                $expr = $null
                if ($cmd -match '^\(Get-ChildItem\s+(?<p>"[^"]+"|''[^'']+'')(?<fl>[^)]*)\)\.Count$') {
                    $p = Resolve-RefPath $matches['p']; $fl = $matches['fl'].Trim()
                    if ((Test-PartSafe $p) -and (Test-PartSafe $fl) -and ($fl -notmatch '[''"]')) {
                        $expr = "(Get-ChildItem -LiteralPath '$p' $fl).Count"
                    }
                }
                elseif ($cmd -match '^\[System\.IO\.File\]::ReadAllLines\((?<p>"[^"]+"|''[^'']+'')(?<a>[^)]*)\)\.Count$') {
                    $p = Resolve-RefPath $matches['p']; $a = $matches['a'].Trim()
                    if ((Test-PartSafe $p) -and ($a -eq '') ) {
                        $expr = "[System.IO.File]::ReadAllLines('$p').Count"
                    }
                }
                elseif ($cmd -match '^Select-String\s+(?<p>"[^"]+"|''[^'']+'')\s+(-LiteralPath\s+)?-Pattern\s+(?<pat>''[^'']+''|"[^"]+")(?<fl>[^`]*)$') {
                    $p = Resolve-RefPath $matches['p']; $pat = $matches['pat']; $fl = $matches['fl']
                    $cs = ''
                    if ($fl -match '-CaseSensitive') { $cs = ' -CaseSensitive' }
                    $rg = $null
                    if ($fl -match '-Range\s+(\d+)\s*-\s*(\d+)') { $rg = @([int]$matches[1], [int]$matches[2]) }
                    if ((Test-PartSafe (($p + $pat) -replace ' ','')) -and ($fl -match '-AllMatches')) {
                        if ($null -ne $rg) {
                            $expr = "(Select-StringInRange '$p' $pat $($rg[0]) $($rg[1]))"
                        }
                        else {
                            $expr = "(@(Select-String -LiteralPath '$p' -Pattern $pat$cs -AllMatches)).Matches.Count"
                        }
                    }
                }
                if ($null -eq $expr) { continue }
                try { $results += [int](Invoke-Expression $expr) } catch { $results += $null }
            }
            if ($results.Count -eq 0) {
                [void]$cntDecl.Add([pscustomobject]@{ A = $rel; K = 'M-without-command'; D = $claim })
                continue
            }
            $cntChecked++
            $badR = @()
            foreach ($r in $results) {
                if ($null -eq $r) { $badR += 'exec-failed'; continue }
                if ($nums -contains $r) { continue }
                if (($r -eq 0) -and ($claim -match '\u65E0')) { continue }   # claim says "none" for this item
                $badR += $r
            }
            if ($badR.Count -gt 0) {
                [void]$cntRows.Add([pscustomobject]@{
                    Artifact = $rel; Claim = $claim
                    Expect = ($nums -join '/'); Actual = ($results -join '/')
                    Status = ('MISMATCH:' + ($badR -join '/'))
                })
            }
        }
    }
}

Write-Host ("== [6] Count-method rows by marker (convention.md 4.2.1): [M] {0} / [R] {1} / [H] {2} ==" -f $rowM, $rowR, $rowH)
$cntBad = @($cntRows | Where-Object { $_.Status -ne 'ok' })
if ($cntBad.Count -eq 0) { Write-Host ("  {0} [M] rows recomputed, all values match" -f $cntChecked) }
else { foreach ($r in $cntBad) { Write-Host ("  [{0}] {1}  claim='{2}' expect={3} actual={4}" -f $r.Status, $r.Artifact, $r.Claim, $r.Expect, $r.Actual) } }
Write-Host ''
Write-Host ("== [6c] Row declaration defects ==")
if ($cntDecl.Count -eq 0) { Write-Host '  every count-method row carries a valid [M]/[R]/[H] declaration' }
else {
    Write-Host ("  {0} row(s) with declaration defects" -f $cntDecl.Count)
    $cntDecl | Group-Object K | Sort-Object Count -Descending | ForEach-Object {
        Write-Host ("    {0,-34} {1}" -f $_.Name, $_.Count)
    }
    $cntDecl | Select-Object -First 10 | ForEach-Object { Write-Host ("      {0}  :: {1}" -f $_.A, $_.D) }
}
Write-Host ''
$badCount += $cntBad.Count + $cntDecl.Count

# --- [6b] count-claim coverage vs the count-method section (WARN only) ---
$covRows  = New-Object System.Collections.ArrayList
$covTotal = 0
foreach ($d in @('modules', 'types', 'flows')) {
    $dir = Join-Path $docsRootResolved $d
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { continue }
    foreach ($f in (Get-ChildItem -LiteralPath $dir -File -Filter *.md)) {
        $rel = $f.FullName.Substring($docsRootResolved.Length + 1).Replace('\', '/')
        $lines7 = [System.IO.File]::ReadAllLines($f.FullName)
        $cut = $lines7.Count
        for ($i = 0; $i -lt $lines7.Count; $i++) {
            if ($lines7[$i] -match ('^##+\s*' + $P_COUNT_SEC)) { $cut = $i; break }
        }
        $secTxt  = if ($cut -lt $lines7.Count) { ($lines7[$cut..($lines7.Count - 1)] -join "`n") } else { '' }
        $secNums = @{}
        foreach ($mm in [regex]::Matches($secTxt, '\d[\d,]*')) { $secNums[[int]($mm.Value -replace ',', '')] = $true }
        $miss = @()
        $inFence = $false
        for ($i = 0; $i -lt $cut; $i++) {
            $ln = $lines7[$i]
            if ($ln -match '^\s*```') { $inFence = -not $inFence; continue }
            if ($inFence) { continue }          # skip directory trees / code blocks
            if ($ln -match '^\s*\|') { continue }  # skip table rows (line-ref tables)
            foreach ($mm in [regex]::Matches($ln, '(\d[\d,]*)\s*(?:\u5904|\u4E2A|\u6761|\u9879|\u6587\u4EF6|\u5934\u6587\u4EF6|\u547D\u4E2D)')) {
                $v = [int]($mm.Groups[1].Value -replace ',', '')
                $covTotal++
                if (-not $secNums.ContainsKey($v)) { $miss += $v }
            }
        }
        if ($miss.Count -gt 0) {
            [void]$covRows.Add([pscustomobject]@{ Artifact = $rel; Missing = (@($miss | Select-Object -Unique | Sort-Object) -join ',') })
        }
    }
}
Write-Host ("== [6b] Count-claim coverage in the count-method section (FAIL, {0} claims scanned) ==" -f $covTotal)
$covTot = 0
if ($covRows.Count -eq 0) { Write-Host '  every count claim has a matching number in the section' }
else {
    foreach ($r in $covRows) { $covTot += ($r.Missing -split ',').Count }
    Write-Host ("  {0} claims across {1} artifacts have no matching number in the count-method section" -f $covTot, $covRows.Count)
    $covRows | Select-Object -First 12 | ForEach-Object { Write-Host ("    {0}  missing: {1}" -f $_.Artifact, $_.Missing) }
}
$badCount += $covTot
Write-Host ''

if ($badCount -eq 0) {
    Write-Host 'SUMMARY: PASS (no machine-detectable defect)'
    exit 0
}
else {
    Write-Host ("SUMMARY: FAIL ({0} machine-detectable defect(s))" -f $badCount)
    exit 1
}
