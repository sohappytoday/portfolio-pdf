param(
  [Parameter(Mandatory = $false)]
  [string]$RepoRoot = '.'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$protectedRoots = @('content', 'result/content', 'portfolio-system')
$records = New-Object System.Collections.Generic.List[string]

foreach ($relativeRoot in $protectedRoots) {
  $fullRoot = Join-Path $RepoRoot $relativeRoot
  if (-not (Test-Path -LiteralPath $fullRoot -PathType Container)) { continue }
  foreach ($file in Get-ChildItem -LiteralPath $fullRoot -File -Recurse | Sort-Object FullName) {
    $relative = $file.FullName.Substring($RepoRoot.Length).TrimStart('\', '/').Replace('\', '/')
    if ($relative -like 'portfolio-system/.generated/*') { continue }
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $records.Add("$relative`:$hash")
  }
}

$joined = $records -join "`n"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($joined)
$sha = [System.Security.Cryptography.SHA256]::Create()
try { $combined = ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
finally { $sha.Dispose() }

[ordered]@{
  algorithm = 'SHA256'
  combinedSha256 = $combined
  fileCount = $records.Count
  protectedRoots = $protectedRoots
} | ConvertTo-Json -Compress
