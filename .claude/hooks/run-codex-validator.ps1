# Bridges a Claude Code PostToolUse payload to a .codex/hooks validator.
#
# Two impedance mismatches are handled here so that .codex/hooks/ stays the single source of
# validation logic and needs no Claude-specific edits:
#
# 1. Payload shape. The .codex validators read the tool payload from stdin and recover changed
#    paths from Codex's apply_patch format ("*** Update File: <path>"). Claude Code sends
#    {tool_input:{file_path:...}} instead, so this shim rewrites the payload into the shape the
#    validators already parse, emitting repo-relative forward-slash paths.
#
# 2. Console encoding. git emits UTF-8, but Windows PowerShell 5.1 decodes native command output
#    using [Console]::OutputEncoding, which is CP949 on this machine. That corrupts the non-ASCII
#    segment of this repository's path, so the validators' own `git rev-parse --show-toplevel`
#    would yield a path that does not exist. The shim derives the root from $PSScriptRoot instead,
#    and starts each validator with UTF-8 console encoding already in effect.
param(
  [Parameter(Mandatory = $true)][string]$Validator
)

$ErrorActionPreference = 'Stop'

try {
  # Claude Code writes the hook payload as UTF-8. [Console]::In would decode it with the console
  # codepage (CP949 here), corrupting the non-ASCII segment of an absolute file_path, so read the
  # raw stream with an explicit UTF-8 decoder instead.
  $reader = New-Object System.IO.StreamReader(
    [Console]::OpenStandardInput(),
    (New-Object System.Text.UTF8Encoding($false)))
  $payloadText = $reader.ReadToEnd()
  if ([string]::IsNullOrWhiteSpace($payloadText)) { exit 0 }

  $payload = $payloadText | ConvertFrom-Json
  $toolInput = $payload.tool_input

  $paths = New-Object System.Collections.Generic.List[string]
  foreach ($candidate in @($toolInput.file_path, $toolInput.notebook_path, $payload.tool_response.filePath)) {
    if (-not [string]::IsNullOrWhiteSpace($candidate)) { $paths.Add([string]$candidate) }
  }
  if ($null -ne $toolInput.edits) {
    foreach ($edit in $toolInput.edits) {
      if (-not [string]::IsNullOrWhiteSpace($edit.file_path)) { $paths.Add([string]$edit.file_path) }
    }
  }
  if ($paths.Count -eq 0) { exit 0 }

  # .claude/hooks -> .claude -> repo root. Never round-tripped through a console codepage.
  $repoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent).Replace('\', '/')

  $lines = foreach ($path in ($paths | Select-Object -Unique)) {
    $normalized = $path.Replace('\', '/')
    if ($normalized.StartsWith($repoRoot, [StringComparison]::OrdinalIgnoreCase)) {
      $normalized = $normalized.Substring($repoRoot.Length).TrimStart('/')
    }
    "*** Update File: $normalized"
  }

  $synthetic = @{ tool_input = @{ patch = ($lines -join "`n") } } | ConvertTo-Json -Depth 5 -Compress

  # The synthetic payload is pure ASCII (repo-relative paths), so only OutputEncoding needs fixing.
  # Do NOT set [Console]::InputEncoding in the child: reassigning it re-opens stdin and discards
  # the piped payload.
  # UTF8Encoding($false), not [Text.Encoding]::UTF8 -- the latter prepends a BOM to the piped
  # payload, which ConvertFrom-Json rejects as an invalid JSON primitive.
  $OutputEncoding = New-Object System.Text.UTF8Encoding($false)
  $escaped = $Validator -replace "'", "''"
  # The trailing `exit $LASTEXITCODE` matters: without it powershell.exe -Command collapses the
  # validator's exit 2 (Claude Code's "block and report to the model") into a plain 1.
  $bootstrap = "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; " +
               "& '$escaped'; exit `$LASTEXITCODE"
  $synthetic | & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $bootstrap
  exit $LASTEXITCODE
}
catch {
  [Console]::Error.WriteLine("Claude validator shim error: $($_.Exception.Message)")
  exit 2
}
