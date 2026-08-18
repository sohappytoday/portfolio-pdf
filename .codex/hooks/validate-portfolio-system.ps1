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
  $pathMatches = [regex]::Matches($patchText, '(?im)^\*\*\* (?:(?:Add|Update|Delete) File|Move to):\s*(.+?)\s*$')
  $changedPaths = @($pathMatches | ForEach-Object { $_.Groups[1].Value.Trim() })
  $pathText = if ($changedPaths.Count -gt 0) { $changedPaths -join "`n" } else { $patchText }
  if ($pathText -notmatch '(?i)(portfolio-system|result[/\\](content|layout)|\.agents[/\\]skills[/\\](build-common-portfolio-system|review-portfolio-system)|\.agents[/\\]memory[/\\]portfolio-system-strategy|\.codex[/\\](agents|hooks)|AGENTS\.md)') { exit 0 }

  $repoRoot = (& git rev-parse --show-toplevel).Trim()
  $validator = Join-Path $repoRoot '.agents/skills/build-common-portfolio-system/scripts/validate-portfolio-system.ps1'
  $result = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -RepoRoot $repoRoot 2>&1
  if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine(($result -join [Environment]::NewLine))
    exit 2
  }
  exit 0
}
catch {
  [Console]::Error.WriteLine("Portfolio-system hook error: $($_.Exception.Message)")
  exit 2
}
