$ErrorActionPreference = 'Stop'

try {
  $payloadText = [Console]::In.ReadToEnd()
  if ([string]::IsNullOrWhiteSpace($payloadText)) { exit 0 }
  $payload = $payloadText | ConvertFrom-Json
  $toolInput = $payload.tool_input
  if ($toolInput -is [string]) {
    $patchText = [string]$toolInput
  }
  elseif ($null -ne $toolInput.command) {
    $patchText = [string]$toolInput.command
  }
  elseif ($null -ne $toolInput.patch) {
    $patchText = [string]$toolInput.patch
  }
  else {
    $patchText = $toolInput | ConvertTo-Json -Depth 20
  }
  $pathMatches = [regex]::Matches($patchText, '(?im)^\*\*\* (?:(?:Add|Update|Delete) File|Move to):\s*(.+?)\s*$')
  $changedPaths = @($pathMatches | ForEach-Object { $_.Groups[1].Value.Trim() })
  $pathText = if ($changedPaths.Count -gt 0) { $changedPaths -join "`n" } else { $patchText }
  $frameworkPattern = '(?i)(ART_DIRECTION_CONTRACT|art-direction(?:-acceptance|-review)?\.schema|extract-company-art-direction|review-company-art-direction|company-(brand|visual|art-direction)|validate-(?:art-direction|json-schema)|get-protected-state|AGENTS\.md|portfolio-system-strategy)'
  $artifactPattern = '(?i)designs[/\\](?<slug>[a-z0-9]+(?:-[a-z0-9]+)*)[/\\]research[/\\]art-direction[/\\](?:sources\.md|art-direction\.(?:json|md)|acceptance\.json|reviews[/\\][^\s]+)'
  $artifactMatches = [regex]::Matches($pathText, $artifactPattern)
  if ($pathText -notmatch $frameworkPattern -and $artifactMatches.Count -eq 0) { exit 0 }

  $hasProtectedChange = @($changedPaths | Where-Object { $_ -match '(?i)^(?:content|result|portfolio-system|\.claude)[/\\]' }).Count -gt 0
  if ($artifactMatches.Count -gt 0 -and $hasProtectedChange) {
    [Console]::Error.WriteLine('An extraction patch may not also modify protected core, content, result, or legacy paths.')
    exit 2
  }

  $repoRoot = (& git rev-parse --show-toplevel).Trim()
  $validator = Join-Path $repoRoot '.agents/skills/extract-company-art-direction/scripts/validate-art-direction.ps1'
  $previousErrorPreference = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $results = New-Object System.Collections.Generic.List[string]
  $validatorExitCode = 0
  if ($pathText -match $frameworkPattern) {
    $frameworkResult = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -RepoRoot $repoRoot 2>&1
    foreach ($line in @($frameworkResult)) { $results.Add([string]$line) }
    if ($LASTEXITCODE -ne 0) { $validatorExitCode = $LASTEXITCODE }
  }
  $slugs = @($artifactMatches | ForEach-Object { $_.Groups['slug'].Value } | Sort-Object -Unique)
  foreach ($slug in $slugs) {
    $slugPattern = '(?i)designs[/\\]' + [regex]::Escape($slug) + '[/\\]research[/\\]art-direction[/\\]'
    $slugPaths = @($changedPaths | Where-Object { $_ -match $slugPattern })
    $acceptancePath = Join-Path $repoRoot "designs/$slug/research/art-direction/acceptance.json"
    $acceptanceChanged = @($slugPaths | Where-Object { $_ -match '(?i)acceptance\.json$' }).Count -gt 0
    $requiresAcceptance = $acceptanceChanged -or (Test-Path -LiteralPath $acceptancePath -PathType Leaf)
    if ($requiresAcceptance) {
      $companyResult = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -RepoRoot $repoRoot -CompanySlug $slug -RequireAcceptance 2>&1
    }
    else {
      $companyResult = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -RepoRoot $repoRoot -CompanySlug $slug 2>&1
    }
    foreach ($line in @($companyResult)) { $results.Add([string]$line) }
    if ($LASTEXITCODE -ne 0) { $validatorExitCode = $LASTEXITCODE }
  }
  $ErrorActionPreference = $previousErrorPreference
  if ($validatorExitCode -ne 0) {
    [Console]::Error.WriteLine(($results -join [Environment]::NewLine))
    exit 2
  }
  exit 0
}
catch {
  [Console]::Error.WriteLine("Art-direction workflow hook error: $($_.Exception.Message)")
  exit 2
}
