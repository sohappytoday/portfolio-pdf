param(
  [Parameter(Mandatory = $false)] [string]$RepoRoot = '.',
  [Parameter(Mandatory = $true)] [string]$CompanySlug
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

function Get-Relative([string]$Path) {
  return $Path.Substring($RepoRoot.Length).TrimStart('\', '/').Replace('\', '/')
}

function Get-CombinedHash([string]$Root, [string]$Filter = '*') {
  if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    return [ordered]@{ sha256 = $null; fileCount = 0 }
  }
  $records = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Filter $Filter | Sort-Object FullName | ForEach-Object {
    "$(Get-Relative $_.FullName)`:$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())"
  })
  $bytes = [Text.Encoding]::UTF8.GetBytes(($records -join "`n"))
  $hasher = [Security.Cryptography.SHA256]::Create()
  try { $hash = ([BitConverter]::ToString($hasher.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
  finally { $hasher.Dispose() }
  return [ordered]@{ sha256 = $hash; fileCount = $records.Count }
}

function Get-FileRecord([string]$RelativePath) {
  $full = Join-Path $RepoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { return [ordered]@{ path = $RelativePath; sha256 = $null } }
  return [ordered]@{ path = $RelativePath; sha256 = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant() }
}

$content = Get-CombinedHash (Join-Path $RepoRoot 'result/content') '*.md'
$layout = Get-CombinedHash (Join-Path $RepoRoot 'result/layout') '*.html'

[ordered]@{
  schemaVersion = '1.0.0'
  companySlug = $CompanySlug
  artDirection = Get-FileRecord "designs/$CompanySlug/research/art-direction/art-direction.json"
  extractionAcceptance = Get-FileRecord "designs/$CompanySlug/research/art-direction/acceptance.json"
  systemManifest = Get-FileRecord 'portfolio-system/system.manifest.json'
  core = Get-FileRecord 'portfolio-system/core.css'
  themeContract = Get-FileRecord 'portfolio-system/THEME_CONTRACT.md'
  pageMap = Get-FileRecord 'portfolio-system/page-map.json'
  content = [ordered]@{ path = 'result/content'; sha256 = $content.sha256; fileCount = $content.fileCount }
  layout = [ordered]@{ path = 'result/layout'; status = if ($layout.fileCount -gt 0) { 'available' } else { 'missing' }; sha256 = $layout.sha256; fileCount = $layout.fileCount }
} | ConvertTo-Json -Depth 6

