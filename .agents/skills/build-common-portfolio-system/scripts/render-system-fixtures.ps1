param(
  [Parameter(Mandatory = $false)] [string]$RepoRoot = (Get-Location).Path,
  [Parameter(Mandatory = $false)] [string]$OutputRoot,
  [Parameter(Mandatory = $false)] [string]$ProtectedPath,
  [Parameter(Mandatory = $false)] [switch]$RequirePdfTextTools
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
if ([string]::IsNullOrWhiteSpace($OutputRoot)) { $OutputRoot = Join-Path $RepoRoot 'portfolio-system/.generated' }
$snapshotId = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$snapshotRoot = Join-Path $OutputRoot $snapshotId
New-Item -ItemType Directory -Force -Path $snapshotRoot | Out-Null

function Get-DirectoryFingerprint([string]$Path) {
  if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
  $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
  $root = $resolved.Path.TrimEnd('\','/')
  $records = Get-ChildItem -LiteralPath $root -Recurse -File | Sort-Object FullName | ForEach-Object {
    $relative = $_.FullName.Substring($root.Length).TrimStart('\','/').Replace('\','/')
    "$relative`t$((Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash)"
  }
  $bytes = [Text.Encoding]::UTF8.GetBytes(($records -join "`n"))
  $hasher = [Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($hasher.ComputeHash($bytes))).Replace('-','').ToLowerInvariant() }
  finally { $hasher.Dispose() }
}

function Get-FileUri([string]$Path) {
  $resolved = (Resolve-Path -LiteralPath $Path).Path
  return ([Uri]$resolved).AbsoluteUri
}

$manifestPath = Join-Path $RepoRoot 'portfolio-system/system.manifest.json'
$manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath | ConvertFrom-Json
$corePath = Join-Path $RepoRoot ([string]$manifest.core)
$coreUri = Get-FileUri $corePath

$browserCandidates = @(
  'C:\Program Files\Google\Chrome\Application\chrome.exe',
  'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
  'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
  'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
)
$browser = $browserCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $browser) { throw 'Chrome or Edge was not found in a standard Windows install path.' }

$protectedAbsolute = $null
$protectedBefore = $null
if (-not [string]::IsNullOrWhiteSpace($ProtectedPath)) {
  $protectedAbsolute = if ([IO.Path]::IsPathRooted($ProtectedPath)) { $ProtectedPath } else { Join-Path $RepoRoot $ProtectedPath }
  $protectedBefore = Get-DirectoryFingerprint $protectedAbsolute
}

$tempBase = [IO.Path]::GetTempPath().TrimEnd('\','/')
$profilePath = Join-Path $tempBase ("portfolio-fixture-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $profilePath | Out-Null
$outputs = [System.Collections.Generic.List[object]]::new()
$renderFailure = $null

try {
  foreach ($themeName in @($manifest.requiredThemeFixtures)) {
    $themeRelative = "portfolio-system/themes/$themeName.css"
    $themePath = Join-Path $RepoRoot $themeRelative
    $themeUri = Get-FileUri $themePath
    foreach ($fixtureRelative in @($manifest.fixtures)) {
      $fixturePath = Join-Path $RepoRoot ([string]$fixtureRelative)
      $fixtureName = [IO.Path]::GetFileNameWithoutExtension($fixturePath)
      $targetDir = Join-Path $snapshotRoot ([string]$themeName)
      New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
      $htmlPath = Join-Path $targetDir "$fixtureName.html"
      $pdfPath = Join-Path $targetDir "$fixtureName.pdf"
      $pngPath = Join-Path $targetDir "$fixtureName.png"

      $html = Get-Content -Raw -Encoding UTF8 -LiteralPath $fixturePath
      $html = $html.Replace('__CORE_URI__', $coreUri).Replace('__THEME_URI__', $themeUri)
      Set-Content -Encoding UTF8 -LiteralPath $htmlPath -Value $html
      $htmlUri = Get-FileUri $htmlPath

      & $browser '--headless' '--disable-gpu' '--hide-scrollbars' '--allow-file-access-from-files' '--no-first-run' '--no-default-browser-check' "--user-data-dir=$profilePath" '--no-pdf-header-footer' "--print-to-pdf=$pdfPath" $htmlUri | Out-Null
      if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $pdfPath)) { throw "PDF render failed: $themeName/$fixtureName" }
      & $browser '--headless' '--disable-gpu' '--hide-scrollbars' '--allow-file-access-from-files' '--no-first-run' '--no-default-browser-check' "--user-data-dir=$profilePath" '--window-size=1280,720' '--virtual-time-budget=1000' "--screenshot=$pngPath" $htmlUri | Out-Null
      if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $pngPath)) { throw "PNG render failed: $themeName/$fixtureName" }

      Add-Type -AssemblyName System.Drawing
      $image = [System.Drawing.Image]::FromFile($pngPath)
      try { $dimensionsOk = ($image.Width -eq 1280 -and $image.Height -eq 720) }
      finally { $image.Dispose() }
      $pdfSize = (Get-Item -LiteralPath $pdfPath).Length
      $outputs.Add([ordered]@{
        theme = [string]$themeName
        fixture = $fixtureName
        html = $htmlPath.Substring($RepoRoot.Length).TrimStart('\','/').Replace('\','/')
        pdf = $pdfPath.Substring($RepoRoot.Length).TrimStart('\','/').Replace('\','/')
        png = $pngPath.Substring($RepoRoot.Length).TrimStart('\','/').Replace('\','/')
        png1280x720 = $dimensionsOk
        pdfNonEmpty = ($pdfSize -gt 1024)
        sourceSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $htmlPath).Hash.ToLowerInvariant()
      })
    }
  }
}
catch { $renderFailure = $_.Exception.Message }
finally {
  $resolvedProfile = [IO.Path]::GetFullPath($profilePath)
  if ($resolvedProfile.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase) -and (Split-Path -Leaf $resolvedProfile) -like 'portfolio-fixture-*') {
    Remove-Item -LiteralPath $resolvedProfile -Recurse -Force -ErrorAction SilentlyContinue
  }
}

$protectedAfter = if ($protectedAbsolute) { Get-DirectoryFingerprint $protectedAbsolute } else { $null }
$protectedUnchanged = ($protectedBefore -eq $protectedAfter)
$pdfTextTool = Get-Command pdftotext -ErrorAction SilentlyContinue
$textChecks = [System.Collections.Generic.List[object]]::new()
if ($pdfTextTool -and -not $renderFailure) {
  foreach ($item in $outputs) {
    $pdfAbsolute = Join-Path $RepoRoot $item.pdf
    $text = & $pdfTextTool.Source -enc UTF-8 $pdfAbsolute - 2>$null | Out-String
    $textChecks.Add([ordered]@{ pdf = $item.pdf; asciiProbe = ($text -match 'PORTFOLIO SYSTEM'); koreanProbe = ($text -match '[\uAC00-\uD7A3]') })
  }
}

$allRendersValid = (-not $renderFailure) -and ($outputs.Count -eq (@($manifest.requiredThemeFixtures).Count * @($manifest.fixtures).Count)) -and (($outputs | Where-Object { -not $_.png1280x720 -or -not $_.pdfNonEmpty }).Count -eq 0)
$textVerified = $pdfTextTool -and (($textChecks | Where-Object { -not $_.asciiProbe -or -not $_.koreanProbe }).Count -eq 0)
$preflight = [ordered]@{
  schemaVersion = 1
  snapshotId = $snapshotId
  generatedAt = (Get-Date).ToString('o')
  browser = $browser
  manifestSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $manifestPath).Hash.ToLowerInvariant()
  coreSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $corePath).Hash.ToLowerInvariant()
  protectedPath = $ProtectedPath
  protectedBeforeSha256 = $protectedBefore
  protectedAfterSha256 = $protectedAfter
  protectedUnchanged = $protectedUnchanged
  renderFailure = $renderFailure
  outputs = $outputs
  pdfTextTool = if ($pdfTextTool) { $pdfTextTool.Source } else { $null }
  pdfTextChecks = $textChecks
  allRendersValid = [bool]$allRendersValid
  textExtractionVerified = [bool]$textVerified
  productionGateEligible = [bool]($allRendersValid -and $textVerified -and $protectedUnchanged)
}
$preflightPath = Join-Path $snapshotRoot 'preflight.json'
Set-Content -Encoding UTF8 -LiteralPath $preflightPath -Value ($preflight | ConvertTo-Json -Depth 8)

if ($renderFailure) { Write-Error $renderFailure; exit 1 }
if (-not $protectedUnchanged) { Write-Error 'Protected path changed during fixture rendering.'; exit 1 }
if (-not $allRendersValid) { Write-Error 'One or more fixture renders failed deterministic output checks.'; exit 1 }
if ($RequirePdfTextTools -and -not $textVerified) { Write-Error 'PDF text extraction/glyph verification is required but unavailable or failed.'; exit 1 }

Write-Output "Fixture render: PASS ($($outputs.Count) outputs)"
Write-Output "Snapshot: $snapshotRoot"
Write-Output "Protected path unchanged: $protectedUnchanged"
Write-Output "PDF text extraction verified: $textVerified"
if (-not $textVerified) { Write-Output 'Production gate: NOT ELIGIBLE until rerun with working pdftotext and -RequirePdfTextTools.' }
exit 0
