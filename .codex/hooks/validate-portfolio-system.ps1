$ErrorActionPreference = 'Stop'

try {
  $payloadText = [Console]::In.ReadToEnd()
  if ([string]::IsNullOrWhiteSpace($payloadText)) { exit 0 }
  $payload = $payloadText | ConvertFrom-Json
  $patchText = [string]$payload.tool_input.command
  if ($patchText -notmatch '(?i)(portfolio-system|\.agents[/\\]skills[/\\](build-common-portfolio-system|review-portfolio-system)|\.agents[/\\]memory[/\\]portfolio-system-strategy|\.codex[/\\](agents|hooks)|AGENTS\.md)') { exit 0 }

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
