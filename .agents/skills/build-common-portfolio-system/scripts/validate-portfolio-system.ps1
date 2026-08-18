param(
  [Parameter(Mandatory = $false)]
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()
$manifest = $null

function Add-Failure([string]$Message) { $script:failures.Add($Message) }
function Require-File([string]$RelativePath) {
  $full = Join-Path $RepoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { Add-Failure "Missing required file: $RelativePath" }
}
function Read-Text([string]$RelativePath) { Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $RepoRoot $RelativePath) }

$required = @(
  'AGENTS.md',
  '.agents/memory/portfolio-system-strategy.md',
  '.agents/skills/build-common-portfolio-system/SKILL.md',
  '.agents/skills/build-common-portfolio-system/agents/openai.yaml',
  '.agents/skills/build-common-portfolio-system/references/build-protocol.md',
  '.agents/skills/build-common-portfolio-system/scripts/render-system-fixtures.ps1',
  '.agents/skills/review-portfolio-system/SKILL.md',
  '.agents/skills/review-portfolio-system/agents/openai.yaml',
  '.agents/skills/review-portfolio-system/references/workflow-readiness-rubric.md',
  '.codex/agents/portfolio-system-architect.toml',
  '.codex/agents/portfolio-system-verifier.toml',
  '.codex/agents/portfolio-visual-qa.toml',
  '.codex/hooks.json',
  '.codex/hooks/validate-portfolio-system.ps1',
  'portfolio-system/SYSTEM.md',
  'portfolio-system/THEME_CONTRACT.md',
  'portfolio-system/PAGE_TYPES.md',
  'portfolio-system/QUALITY_GATE.md',
  'portfolio-system/system.manifest.json',
  'portfolio-system/core.css'
)
$required | ForEach-Object { Require-File $_ }

if (Test-Path -LiteralPath (Join-Path $RepoRoot 'portfolio-system/system.manifest.json')) {
  try { $manifest = Read-Text 'portfolio-system/system.manifest.json' | ConvertFrom-Json }
  catch { Add-Failure "Invalid system.manifest.json: $($_.Exception.Message)" }
}
if (Test-Path -LiteralPath (Join-Path $RepoRoot '.codex/hooks.json')) {
  try { Read-Text '.codex/hooks.json' | ConvertFrom-Json | Out-Null }
  catch { Add-Failure "Invalid .codex/hooks.json: $($_.Exception.Message)" }
}

if ($null -ne $manifest) {
  if ($manifest.canvas.widthPx -ne 1280 -or $manifest.canvas.heightPx -ne 720) { Add-Failure 'Manifest canvas must be 1280x720.' }
  if ($manifest.acceptance.minimumScoreEach -ne 97) { Add-Failure 'Manifest acceptance score must be 97 for each reviewer.' }
  if ($manifest.acceptance.independentReviewers -lt 2) { Add-Failure 'Manifest requires at least two independent reviewers.' }
  if ($manifest.acceptance.deterministicChecks -ne 'all-pass') { Add-Failure 'Manifest deterministicChecks must be all-pass.' }
  if ($manifest.acceptance.hardBlockers -ne 0) { Add-Failure 'Manifest hardBlockers must be zero.' }
  if ($manifest.acceptance.finalScoreStrategy -ne 'lower-score') { Add-Failure 'Manifest finalScoreStrategy must be lower-score.' }
  Require-File ([string]$manifest.core)
  Require-File ([string]$manifest.pageMap)
  Require-File ([string]$manifest.renderer)
  foreach ($path in $manifest.contracts) { Require-File ([string]$path) }
  foreach ($path in $manifest.fixtures) { Require-File ([string]$path) }
  if (@($manifest.requiredThemeFixtures).Count -lt 4) { Add-Failure 'Manifest requires neutral plus three contrasting theme fixtures.' }
  foreach ($themeName in @($manifest.requiredThemeFixtures)) { Require-File "portfolio-system/themes/$themeName.css" }
}

$skillChecks = @(
  @{ Path = '.agents/skills/build-common-portfolio-system/SKILL.md'; Name = 'build-common-portfolio-system' },
  @{ Path = '.agents/skills/review-portfolio-system/SKILL.md'; Name = 'review-portfolio-system' }
)
foreach ($item in $skillChecks) {
  if (Test-Path -LiteralPath (Join-Path $RepoRoot $item.Path)) {
    $skillText = Read-Text $item.Path
    $escapedName = [regex]::Escape([string]$item.Name)
    if ($skillText -notmatch "(?ms)\A---\s*.*?^name:\s+$escapedName\s*$.*?^description:\s+.+?^---\s*$") {
      Add-Failure "Invalid or incomplete skill frontmatter: $($item.Path)"
    }
    if ($item.Name.Length -gt 64 -or $item.Name -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { Add-Failure "Invalid skill name: $($item.Name)" }
    $frontmatterMatch = [regex]::Match($skillText, '(?ms)\A---\s*(.*?)^---\s*$')
    if ($frontmatterMatch.Success) {
      $frontmatterLines = $frontmatterMatch.Groups[1].Value -split "`r?`n" | Where-Object { $_ -match '^([A-Za-z0-9-]+):' }
      $allowed = @('name','description','license','allowed-tools','metadata')
      foreach ($line in $frontmatterLines) {
        $key = ([regex]::Match($line, '^([A-Za-z0-9-]+):')).Groups[1].Value
        if ($allowed -notcontains $key) { Add-Failure "Unexpected skill frontmatter key '$key': $($item.Path)" }
      }
      $descriptionLine = $frontmatterLines | Where-Object { $_ -match '^description:' } | Select-Object -First 1
      $descriptionValue = ([string]$descriptionLine) -replace '^description:\s*',''
      if ($descriptionValue.Length -gt 1024 -or $descriptionValue -match '[<>]') { Add-Failure "Invalid skill description: $($item.Path)" }
    }
  }
}

foreach ($yaml in @('.agents/skills/build-common-portfolio-system/agents/openai.yaml', '.agents/skills/review-portfolio-system/agents/openai.yaml')) {
  if (Test-Path -LiteralPath (Join-Path $RepoRoot $yaml)) {
    $yamlText = Read-Text $yaml
    if ($yamlText -notmatch '(?m)^\s+default_prompt:\s+"[^"]*\$[a-z0-9-]+') { Add-Failure "default_prompt must name its skill: $yaml" }
  }
}

foreach ($agent in @('.codex/agents/portfolio-system-architect.toml', '.codex/agents/portfolio-system-verifier.toml', '.codex/agents/portfolio-visual-qa.toml')) {
  if (Test-Path -LiteralPath (Join-Path $RepoRoot $agent)) {
    $agentText = Read-Text $agent
    foreach ($field in @('name', 'description', 'developer_instructions')) {
      if ($agentText -notmatch "(?m)^$field\s*=") { Add-Failure "Missing TOML field '$field': $agent" }
    }
  }
}
foreach ($reviewer in @('.codex/agents/portfolio-system-verifier.toml', '.codex/agents/portfolio-visual-qa.toml')) {
  if ((Test-Path -LiteralPath (Join-Path $RepoRoot $reviewer)) -and (Read-Text $reviewer) -notmatch '(?m)^sandbox_mode\s*=\s*"read-only"') {
    Add-Failure "Reviewer must be read-only: $reviewer"
  }
}

$themeVars = @(
  '--theme-bg','--theme-surface','--theme-surface-strong','--theme-text','--theme-text-muted','--theme-line',
  '--theme-accent','--theme-accent-strong','--theme-accent-soft','--theme-positive','--theme-warning','--theme-negative',
  '--theme-display-font','--theme-body-font','--theme-mono-font','--theme-radius-sm','--theme-radius-md',
  '--theme-radius-lg','--theme-radius-pill','--theme-shadow-floating','--theme-line-width'
)
$themeNames = if ($null -ne $manifest) { @($manifest.requiredThemeFixtures) } else { @() }
foreach ($theme in $themeNames) {
  $path = "portfolio-system/themes/$theme.css"
  Require-File $path
  if (Test-Path -LiteralPath (Join-Path $RepoRoot $path)) {
    $themeText = Read-Text $path
    foreach ($variable in $themeVars) { if ($themeText -notmatch [regex]::Escape($variable)) { Add-Failure "Theme '$theme' misses $variable" } }
  }
}

if ($null -ne $manifest -and (Test-Path -LiteralPath (Join-Path $RepoRoot ([string]$manifest.pageMap)))) {
  try { $pageMap = Read-Text ([string]$manifest.pageMap) | ConvertFrom-Json }
  catch { Add-Failure "Invalid page map JSON: $($_.Exception.Message)"; $pageMap = $null }
  if ($null -ne $pageMap) {
    $validTypes = @('cover','profile','capability','experience','project-opener','architecture','process','troubleshooting','result','closing')
    $validDensities = @('sparse','balanced','dense')
    $contentFiles = Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'result/content') -Filter '[0-9][0-9]-*.md' -File | Sort-Object Name
    foreach ($file in $contentFiles) {
      $entry = $pageMap.pages.PSObject.Properties[$file.Name].Value
      if ($null -eq $entry) { Add-Failure "Page map misses result/content/$($file.Name)"; continue }
      if ($validTypes -notcontains [string]$entry.type) { Add-Failure "Invalid page type for $($file.Name): $($entry.type)" }
      if ($validDensities -notcontains [string]$entry.density) { Add-Failure "Invalid page density for $($file.Name): $($entry.density)" }
    }
    foreach ($property in $pageMap.pages.PSObject.Properties) {
      if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "result/content/$($property.Name)"))) { Add-Failure "Page map references missing content: $($property.Name)" }
    }
  }
}

if ($null -ne $manifest) {
  foreach ($fixturePath in @($manifest.fixtures)) {
    if (Test-Path -LiteralPath (Join-Path $RepoRoot ([string]$fixturePath))) {
      $fixtureText = Read-Text ([string]$fixturePath)
      if ($fixtureText -notmatch '__CORE_URI__' -or $fixtureText -notmatch '__THEME_URI__') { Add-Failure "Fixture must use core/theme URI placeholders: $fixturePath" }
      if ($fixtureText -notmatch 'data-page-type=' -or $fixtureText -notmatch 'data-density=') { Add-Failure "Fixture must declare page type and density: $fixturePath" }
    }
  }
}

if (Test-Path -LiteralPath (Join-Path $RepoRoot 'portfolio-system/core.css')) {
  $core = Read-Text 'portfolio-system/core.css'
  foreach ($requiredToken in @('--page-width: 1280px','--page-height: 720px','--grid-columns: 12','.stat','.comparison','.flow','.architecture','.timeline')) {
    if ($core -notmatch [regex]::Escape($requiredToken)) { Add-Failure "core.css misses required token/component: $requiredToken" }
  }
  if ($core -match '(?i)toss|kakao|naver|coupang|baemin|daangn') { Add-Failure 'core.css contains a company-specific brand name.' }
  if ($core -match '(?i)@font-face|https?://') { Add-Failure 'core.css must not load or embed fonts/assets; final bundles own licensed static fonts.' }
}

if ($failures.Count -gt 0) {
  Write-Output "Portfolio system validation: FAIL ($($failures.Count))"
  $failures | ForEach-Object { Write-Output "- $_" }
  exit 1
}

Write-Output 'Portfolio system validation: PASS'
Write-Output "Required files: $($required.Count)"
Write-Output "Theme fixtures: $($themeNames.Count); page map: complete; reviewers: 2 read-only roles; acceptance: 97/100 each"
exit 0
