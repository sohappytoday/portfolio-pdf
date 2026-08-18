$ErrorActionPreference = 'Stop'

try {
  $payloadText = [Console]::In.ReadToEnd()
  if ([string]::IsNullOrWhiteSpace($payloadText)) { exit 0 }
  $payload = $payloadText | ConvertFrom-Json
  $toolInput = $payload.tool_input
  if ($toolInput -is [string]) { $patchText = [string]$toolInput }
  elseif ($null -ne $toolInput.command) { $patchText = [string]$toolInput.command }
  elseif ($null -ne $toolInput.patch) { $patchText = [string]$toolInput.patch }
  else { $patchText = $toolInput | ConvertTo-Json -Depth 20 }

  $headerPattern = '(?im)^\*\*\* (?<operation>Add|Update|Delete) File:\s*(?<path>.+?)\s*$'
  $headers = @([regex]::Matches($patchText, $headerPattern) | ForEach-Object {
    [pscustomobject]@{ operation = $_.Groups['operation'].Value; path = $_.Groups['path'].Value.Trim() }
  })
  $moveHeaders = @([regex]::Matches($patchText, '(?im)^\*\*\* Move to:\s*(?<path>.+?)\s*$') | ForEach-Object {
    [pscustomobject]@{ operation = 'Move'; path = $_.Groups['path'].Value.Trim() }
  })
  $headers += $moveHeaders
  $pathText = if ($headers.Count -gt 0) { @($headers.path) -join "`n" } else { $patchText }

  $frameworkPattern = '(?i)(APPLICATION_CONTRACT|theme-application\.schema|font-license\.schema|application-(?:input-lock|preflight|review|acceptance)\.schema|apply-company-art-direction|review-applied-portfolio|company-theme-applier|applied-(?:theme-contract|portfolio-visual|portfolio-adjudicator)|validate-application-workflow|AGENTS\.md|portfolio-system-strategy|SYSTEM\.md|THEME_CONTRACT\.md|system\.manifest\.json)'
  $sourcePattern = '(?i)designs[/\\](?<slug>[a-z0-9]+(?:-[a-z0-9]+)*)[/\\]application[/\\]'
  $buildPattern = '(?i)result[/\\]design[/\\](?<slug>[a-z0-9]+(?:-[a-z0-9]+)*)[/\\]builds[/\\](?<build>[a-z0-9]+(?:-[a-z0-9]+)*)[/\\](?<tail>.+)$'
  $sourceMatches = [regex]::Matches($pathText, $sourcePattern)
  $buildMatches = [regex]::Matches($pathText, $buildPattern)
  if ($pathText -notmatch $frameworkPattern -and $sourceMatches.Count -eq 0 -and $buildMatches.Count -eq 0) { exit 0 }

  $sourceSlugs = @($sourceMatches | ForEach-Object { $_.Groups['slug'].Value } | Sort-Object -Unique)
  if ($sourceSlugs.Count -gt 0) {
    $protected = @($headers | Where-Object {
      $_.path -match '(?i)^(?:content|result[/\\]content|result[/\\]layout|portfolio-system|\.claude|designs[/\\][^/\\]+[/\\]research)[/\\]'
    })
    if ($protected.Count -gt 0) {
      [Console]::Error.WriteLine('An application source patch may not also modify core, content, neutral layouts, legacy configuration, or extraction research.')
      exit 2
    }
  }

  foreach ($header in $headers) {
    if ($header.path -match $buildPattern) {
      $tail = $Matches['tail'].Replace('\', '/')
      if ($header.operation -ne 'Add' -or ($tail -ne 'acceptance.json' -and $tail -notmatch '^reviews/[^/]+\.json$')) {
        [Console]::Error.WriteLine('Builds are immutable. apply_patch may only add a new review JSON or acceptance.json; renderer output must come from the renderer.')
        exit 2
      }
    }
  }

  $repoRoot = (& git rev-parse --show-toplevel).Trim()
  $validator = Join-Path $repoRoot '.agents/skills/apply-company-art-direction/scripts/validate-application.ps1'
  $previous = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $results = New-Object System.Collections.Generic.List[string]
  $exitCode = 0

  if ($pathText -match $frameworkPattern) {
    $result = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -RepoRoot $repoRoot 2>&1
    foreach ($line in @($result)) { $results.Add([string]$line) }
    if ($LASTEXITCODE -ne 0) { $exitCode = $LASTEXITCODE }
  }

  foreach ($slug in $sourceSlugs) {
    $result = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -RepoRoot $repoRoot -CompanySlug $slug 2>&1
    foreach ($line in @($result)) { $results.Add([string]$line) }
    if ($LASTEXITCODE -ne 0) { $exitCode = $LASTEXITCODE }
  }

  $buildPairs = @($buildMatches | ForEach-Object { "$($_.Groups['slug'].Value)|$($_.Groups['build'].Value)" } | Sort-Object -Unique)
  foreach ($pair in $buildPairs) {
    $parts = $pair -split '\|', 2
    $acceptancePath = Join-Path $repoRoot "result/design/$($parts[0])/builds/$($parts[1])/acceptance.json"
    $arguments = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$validator,'-RepoRoot',$repoRoot,'-CompanySlug',$parts[0],'-BuildId',$parts[1])
    if (Test-Path -LiteralPath $acceptancePath -PathType Leaf) { $arguments += '-RequireAcceptance' }
    $result = & powershell.exe @arguments 2>&1
    foreach ($line in @($result)) { $results.Add([string]$line) }
    if ($LASTEXITCODE -ne 0) { $exitCode = $LASTEXITCODE }
  }
  $ErrorActionPreference = $previous

  if ($exitCode -ne 0) {
    [Console]::Error.WriteLine(($results -join [Environment]::NewLine))
    exit 2
  }
  exit 0
}
catch {
  [Console]::Error.WriteLine("Application workflow hook error: $($_.Exception.Message)")
  exit 2
}
