<#
  build-data.ps1
  Raw rent transactions -> slim JSON (data\slim.json) -> embedded into index.html

  Input (pick one):
    -SourceJson : already-processed southwest-rent.json (default, exists locally)
    -CsvPath    : raw seoul-apt-latest.csv
                  (columns: gu,dong,complex,area_m2,floor,deal_type,deposit,monthly_rent,contract_ym)

  Rules (PRD):
    - area <= 40 m2
    - jeonse         : deposit <= 30000 (3eok)
    - half-jeonse    : monthly rent > 0 and deposit <= 10000 (1eok)
    - Yeongdeungpo sub-dongs ("Dangsan-dong 4-ga") are merged into the main dong
    - amounts in 10,000 KRW (man-won)

  Korean literals are written as \u escapes so the script is safe under Windows PowerShell 5.1.

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts\build-data.ps1
#>
param(
  [string]$SourceJson = '',   # empty = search Downloads for southwest-rent.json
  [string]$CsvPath = '',
  [string]$DongInfoPath = '', # empty = search Downloads for dong-info.json
  [string]$InfraCopyPath = "$PSScriptRoot\..\data\dong-infra-copy.json",
  [string]$CommutePath = "$PSScriptRoot\..\data\dong-commute.json",
  [string]$OutJson ="$PSScriptRoot\..\data\slim.json",
  [string]$IndexHtml = "$PSScriptRoot\..\index.html",
  [double]$MaxAreaM2 = 40,
  [int]$MaxJeonse = 30000,
  [int]$MaxHalfJeonse = 10000
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
function U([string]$s) { [regex]::Unescape($s) }
# ArrayList always serializes as a JSON array, even when empty or single-item
function ToList($items) {
  $l = New-Object System.Collections.ArrayList
  foreach ($i in @($items)) { if ($null -ne $i) { [void]$l.Add([string]$i) } }
  , $l
}
function FindInDownloads([string]$name) {
  $f = Get-ChildItem -Path (Join-Path $env:USERPROFILE 'Downloads') -Recurse -Filter $name -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $f) { throw "$name not found under Downloads; pass the path explicitly" }
  $f.FullName
}
if (-not $CsvPath -and -not $SourceJson) { $SourceJson = FindInDownloads 'southwest-rent.json' }
if (-not $DongInfoPath) { $DongInfoPath = FindInDownloads 'dong-info.json' }

$JEONSE = U '\uC804\uC138'            # jeonse
$HALF   = U '\uBC18\uC804\uC138'      # half-jeonse (deposit + monthly rent)
$WOLSE  = U '\uC6D4\uC138'            # monthly rent (CSV deal_type)
$GA_SUFFIX = U '[0-9]+\uAC00$'        # "4-ga" suffix of Yeongdeungpo dongs
$YDP    = U '\uC601\uB4F1\uD3EC\uAD6C'

# ---- 1. load raw rows into a common shape --------------------------------
# common row: gu, dong, complex, area, floor, kind(JEONSE|HALF), deposit, rent, ym
$raw = New-Object System.Collections.ArrayList

if ($CsvPath) {
  if (-not (Test-Path $CsvPath)) { throw "CSV not found: $CsvPath" }
  foreach ($r in (Import-Csv -Path $CsvPath -Encoding UTF8)) {
    $dep = 0; [void][int]::TryParse($r.deposit, [ref]$dep)
    $rent = 0; [void][int]::TryParse($r.monthly_rent, [ref]$rent)
    $area = 0.0; [void][double]::TryParse($r.area_m2, [ref]$area)
    $fl = 0; [void][int]::TryParse($r.floor, [ref]$fl)
    $kind = $null
    if ($r.deal_type -eq $JEONSE) { $kind = $JEONSE }
    elseif ($r.deal_type -eq $WOLSE -and $rent -gt 0) { $kind = $HALF }
    else { continue }
    [void]$raw.Add(@($r.gu, $r.dong, $r.complex, $area, $fl, $kind, $dep, $rent, $r.contract_ym))
  }
  $sourceLabel = "MOLIT apartment rent transactions (raw CSV: $(Split-Path $CsvPath -Leaf))"
}
else {
  if (-not (Test-Path $SourceJson)) { throw "Source JSON not found: $SourceJson" }
  $src = [System.IO.File]::ReadAllText($SourceJson, [Text.Encoding]::UTF8) | ConvertFrom-Json
  foreach ($r in $src.rows) {
    [void]$raw.Add(@($r[0], $r[1], $r[2], [double]$r[3], [int]$r[4], $src.types[$r[5]], [int]$r[6], [int]$r[7], $src.yms[$r[8]]))
  }
  $sourceLabel = "MOLIT apartment rent transactions (pre-processed: $(Split-Path $SourceJson -Leaf))"
}
Write-Host ("input rows: {0}" -f $raw.Count)

# ---- 2. dong master (coords + copy) --------------------------------------
$dongInfo = [System.IO.File]::ReadAllText($DongInfoPath, [Text.Encoding]::UTF8) | ConvertFrom-Json
$infra = $null
if (Test-Path $InfraCopyPath) {
  $infra = [System.IO.File]::ReadAllText((Resolve-Path $InfraCopyPath), [Text.Encoding]::UTF8) | ConvertFrom-Json
}
$infraMap = @{}
if ($infra) { foreach ($d in $infra.dong) { $infraMap["$($d.gu)|$($d.dong)"] = $d } }

$commuteMap = @{}
if (Test-Path $CommutePath) {
  $cm = [System.IO.File]::ReadAllText((Resolve-Path $CommutePath), [Text.Encoding]::UTF8) | ConvertFrom-Json
  foreach ($d in $cm.dong) { $commuteMap["$($d.gu)|$($d.dong)"] = $d }
}
else { Write-Host "WARNING: dong-commute.json not found; scores will be empty" }

$dongIdx = @{}
$dongList =New-Object System.Collections.ArrayList
foreach ($d in $dongInfo.dong) {
  $k = "$($d.gu)|$($d.dong)"
  $c = $infraMap[$k]
  $entry = [ordered]@{
    gu        = $d.gu
    dong      = $d.dong
    lat       = $d.lat
    lng       = $d.lng
    subway    = $d.subway
    headline  = $(if ($c) { $c.headline } else { $d.note })
    strengths = $null
    cautions  = $null
    commuteMin = $null
    transfers  = $null
    route      = $null
    transit    = $null
    infra      = $null
  }
  $cx = $commuteMap[$k]
  if ($cx) {
    $entry.commuteMin = $cx.min; $entry.transfers = $cx.transfers; $entry.route = $cx.route
    $entry.transit = $cx.transit; $entry.infra = $cx.infra
  }
  else { Write-Host "WARNING: no commute data for $k" }
  # assign outside $(...) so PowerShell does not unroll single/empty arrays
  $entry.strengths = ToList $(if ($c) { $c.strengths } else { $null })
  $entry.cautions  = ToList $(if ($c) { $c.cautions } else { $null })
  $dongIdx[$k] = $dongList.Count
  [void]$dongList.Add($entry)
}

# ---- 3. filter + slim ----------------------------------------------------
$types = @($JEONSE, $HALF)
$ymSet = @{}
$rows = New-Object System.Collections.ArrayList
$skippedDong = @{}
foreach ($r in $raw) {
  $gu = $r[0]; $dong = $r[1]
  if ($gu -eq $YDP) { $dong = $dong -replace $GA_SUFFIX, '' }
  if ($r[3] -gt $MaxAreaM2 -or $r[3] -le 0) { continue }
  if ($r[5] -eq $JEONSE -and $r[6] -gt $MaxJeonse) { continue }
  if ($r[5] -eq $HALF -and $r[6] -gt $MaxHalfJeonse) { continue }
  $k = "$gu|$dong"
  if (-not $dongIdx.ContainsKey($k)) { $skippedDong[$k] = 1 + [int]$skippedDong[$k]; continue }
  $ymSet[$r[8]] = 1
  [void]$rows.Add(@(
      $dongIdx[$k], $r[2], [math]::Round($r[3], 1), $r[4],
      [array]::IndexOf($types, $r[5]), $r[6], $r[7], $r[8]
    ))
}
$yms = @($ymSet.Keys | Sort-Object)
foreach ($row in $rows) { $row[7] = [array]::IndexOf($yms, $row[7]) }

if ($skippedDong.Count) {
  Write-Host "WARNING: rows skipped (dong not in dong-info):"
  $skippedDong.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object { Write-Host ("  {0}: {1}" -f $_.Key, $_.Value) }
}

$payload = [ordered]@{
  meta = [ordered]@{
    generatedAt = (Get-Date).ToString('yyyy-MM-dd')
    source      = $sourceLabel
    note        = 'Past transactions, not current listings. Amounts in 10,000 KRW.'
    ymRange     = @($yms[0], $yms[-1])
    count       = $rows.Count
    rule        = "area<=$MaxAreaM2; jeonse<=$MaxJeonse; half-jeonse deposit<=$MaxHalfJeonse"
  }
  cols  = @('dong', 'complex', 'area_m2', 'floor', 'type', 'deposit', 'monthly_rent', 'ym')
  types = $types
  yms   = $yms
  dong  = $dongList
  rows  = $rows
}
$json = ConvertTo-Json -InputObject $payload -Depth 6 -Compress

# ---- 4. write slim.json and embed into index.html ------------------------
$dir = Split-Path $OutJson -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
[System.IO.File]::WriteAllText((Join-Path (Resolve-Path $dir).Path (Split-Path $OutJson -Leaf)), $json, $utf8)

if (Test-Path $IndexHtml) {
  $htmlPath = (Resolve-Path $IndexHtml).Path
  $html = [System.IO.File]::ReadAllText($htmlPath, $utf8)
  $pattern = '(?s)(<!--DATA_START-->).*?(<!--DATA_END-->)'
  if ($html -notmatch $pattern) { throw 'DATA_START/DATA_END markers not found in index.html' }
  $block = '<!--DATA_START--><script id="slim-data" type="application/json">' + $json + '</script><!--DATA_END-->'
  $html = [regex]::Replace($html, $pattern, { param($m) $block })
  [System.IO.File]::WriteAllText($htmlPath, $html, $utf8)
  Write-Host "embedded into index.html"
}

$kb = [math]::Round(([System.Text.Encoding]::UTF8.GetByteCount($json)) / 1024)
Write-Host ("done: {0} rows, {1} KB -> {2}" -f $rows.Count, $kb, $OutJson)
