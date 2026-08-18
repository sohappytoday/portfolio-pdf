param(
  [Parameter(Mandatory = $false)] [string]$RepoRoot = '.',
  [Parameter(Mandatory = $false)] [string]$CompanySlug,
  [Parameter(Mandatory = $false)] [string]$BuildId,
  [Parameter(Mandatory = $false)] [switch]$RequireAcceptance
)

$ErrorActionPreference = 'Stop'
$script:Failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$Message) { $script:Failures.Add($Message) }
function Require-File([string]$RelativePath) {
  $full = Join-Path $RepoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { Add-Failure("Missing required file: $RelativePath") }
  return $full
}
function Read-Json([string]$Path) {
  try { return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json }
  catch { Add-Failure("Invalid JSON: $Path - $($_.Exception.Message)"); return $null }
}
function Get-Sha([string]$Path) { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-Relative([string]$Path) { return $Path.Substring($RepoRoot.Length).TrimStart('\', '/').Replace('\', '/') }
function Get-CombinedHash([string]$Root, [string]$Filter = '*') {
  if (-not (Test-Path -LiteralPath $Root -PathType Container)) { return $null }
  $records = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Filter $Filter | Sort-Object FullName | ForEach-Object {
    "$(Get-Relative $_.FullName):$(Get-Sha $_.FullName)"
  })
  $bytes = [Text.Encoding]::UTF8.GetBytes(($records -join "`n"))
  $hasher = [Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($hasher.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
  finally { $hasher.Dispose() }
}
function Resolve-BuildFile([string]$BuildRoot, [string]$RelativePath) {
  if ([string]::IsNullOrWhiteSpace($RelativePath) -or [IO.Path]::IsPathRooted($RelativePath)) { return $null }
  $root = [IO.Path]::GetFullPath($BuildRoot).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
  $full = [IO.Path]::GetFullPath((Join-Path $BuildRoot $RelativePath))
  if (-not $full.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { return $null }
  return $full
}
function Get-BuildOutputSetHash([string]$BuildRoot) {
  $records = @(Get-ChildItem -LiteralPath $BuildRoot -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($BuildRoot.Length).TrimStart('\', '/').Replace('\', '/')
    $relative -notin @('inputs.lock.json', 'preflight.json', 'acceptance.json') -and $relative -notmatch '^reviews/'
  } | Sort-Object FullName | ForEach-Object {
    $relative = $_.FullName.Substring($BuildRoot.Length).TrimStart('\', '/').Replace('\', '/')
    "$relative`:$(Get-Sha $_.FullName)"
  })
  $bytes = [Text.Encoding]::UTF8.GetBytes(($records -join "`n"))
  $hasher = [Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($hasher.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
  finally { $hasher.Dispose() }
}
function Invoke-Schema([string]$Schema, [string]$Data) {
  $runner = Join-Path $RepoRoot '.agents/skills/extract-company-art-direction/scripts/validate-json-schema.mjs'
  $prior = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  $result = & node $runner $Schema $Data 2>&1; $code = $LASTEXITCODE
  $ErrorActionPreference = $prior
  if ($code -ne 0) { Add-Failure(($result -join [Environment]::NewLine)) }
}
function Get-FontFamilies($Value) {
  $items = if ($Value -is [string]) { @(([string]$Value) -split ',') } elseif ($Value -is [Collections.IEnumerable]) { @($Value) } else { @() }
  return @($items | ForEach-Object { ([string]$_).Trim().Trim('"').Trim("'") } | Where-Object { $_ })
}

$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$framework = @(
  'portfolio-system/APPLICATION_CONTRACT.md',
  'portfolio-system/theme-application.schema.json',
  'portfolio-system/font-license.schema.json',
  'portfolio-system/application-input-lock.schema.json',
  'portfolio-system/application-preflight.schema.json',
  'portfolio-system/application-review.schema.json',
  'portfolio-system/application-acceptance.schema.json',
  '.agents/skills/apply-company-art-direction/SKILL.md',
  '.agents/skills/apply-company-art-direction/agents/openai.yaml',
  '.agents/skills/apply-company-art-direction/references/application-protocol.md',
  '.agents/skills/apply-company-art-direction/scripts/get-application-inputs.ps1',
  '.agents/skills/apply-company-art-direction/scripts/render-application.mjs',
  '.agents/skills/review-applied-portfolio/SKILL.md',
  '.agents/skills/review-applied-portfolio/agents/openai.yaml',
  '.agents/skills/review-applied-portfolio/references/applied-review-protocol.md',
  '.codex/agents/company-theme-applier.toml',
  '.codex/agents/applied-theme-contract-verifier.toml',
  '.codex/agents/applied-portfolio-visual-verifier.toml',
  '.codex/agents/applied-portfolio-adjudicator.toml',
  '.codex/hooks/validate-application-workflow.ps1',
  '.codex/hooks.json'
)
foreach ($file in $framework) { Require-File $file | Out-Null }

foreach ($schema in @(
  'portfolio-system/theme-application.schema.json', 'portfolio-system/font-license.schema.json',
  'portfolio-system/application-input-lock.schema.json', 'portfolio-system/application-preflight.schema.json',
  'portfolio-system/application-review.schema.json', 'portfolio-system/application-acceptance.schema.json'
)) { if (Test-Path -LiteralPath (Join-Path $RepoRoot $schema)) { Read-Json (Join-Path $RepoRoot $schema) | Out-Null } }

$agentModes = @{
  '.codex/agents/company-theme-applier.toml' = 'workspace-write'
  '.codex/agents/applied-theme-contract-verifier.toml' = 'read-only'
  '.codex/agents/applied-portfolio-visual-verifier.toml' = 'read-only'
  '.codex/agents/applied-portfolio-adjudicator.toml' = 'read-only'
}
foreach ($relative in $agentModes.Keys) {
  $path = Join-Path $RepoRoot $relative
  if (Test-Path -LiteralPath $path) {
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($field in @('name =', 'description =', 'developer_instructions =')) { if ($text -notmatch [regex]::Escape($field)) { Add-Failure("Missing $field in $relative") } }
    if ($text -notmatch ('sandbox_mode\s*=\s*"' + [regex]::Escape($agentModes[$relative]) + '"')) { Add-Failure("Wrong sandbox mode in $relative") }
  }
}

if (-not [string]::IsNullOrWhiteSpace($CompanySlug)) {
  if ($CompanySlug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { Add-Failure("Invalid company slug: $CompanySlug") }
  $applicationRoot = Join-Path $RepoRoot "designs/$CompanySlug/application"
  $manifestPath = Join-Path $applicationRoot 'theme-manifest.json'
  $adapterPath = Join-Path $applicationRoot 'adapter.css'
  $fontPath = Join-Path $applicationRoot 'font-license.json'
  foreach ($path in @($manifestPath, $adapterPath, $fontPath)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Add-Failure("Missing application source: $path") } }

  $extractionValidator = Join-Path $RepoRoot '.agents/skills/extract-company-art-direction/scripts/validate-art-direction.ps1'
  if (Test-Path -LiteralPath $extractionValidator) {
    $prior = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $validation = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $extractionValidator -RepoRoot $RepoRoot -CompanySlug $CompanySlug -RequireAcceptance 2>&1
    $code = $LASTEXITCODE; $ErrorActionPreference = $prior
    if ($code -ne 0) { Add-Failure("Extraction acceptance is not consumable:`n$($validation -join [Environment]::NewLine)") }
  }

  if ((Test-Path -LiteralPath $manifestPath) -and (Test-Path -LiteralPath $adapterPath) -and (Test-Path -LiteralPath $fontPath)) {
    Invoke-Schema (Join-Path $RepoRoot 'portfolio-system/theme-application.schema.json') $manifestPath
    Invoke-Schema (Join-Path $RepoRoot 'portfolio-system/font-license.schema.json') $fontPath
    $manifest = Read-Json $manifestPath
    $fonts = Read-Json $fontPath
    $inputs = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot '.agents/skills/apply-company-art-direction/scripts/get-application-inputs.ps1') -RepoRoot $RepoRoot -CompanySlug $CompanySlug | ConvertFrom-Json)

    if ($null -ne $manifest) {
      if ([string]$manifest.companySlug -ne $CompanySlug) { Add-Failure('Manifest companySlug does not match directory') }
      $expectedPaths = @{
        'artDirection.artifactPath' = "designs/$CompanySlug/research/art-direction/art-direction.json"
        'artDirection.acceptancePath' = "designs/$CompanySlug/research/art-direction/acceptance.json"
        'adapter.path' = "designs/$CompanySlug/application/adapter.css"
        'fontLicense.path' = "designs/$CompanySlug/application/font-license.json"
      }
      if ([string]$manifest.artDirection.artifactPath -ne $expectedPaths['artDirection.artifactPath']) { Add-Failure('Unexpected artDirection.artifactPath') }
      if ([string]$manifest.artDirection.acceptancePath -ne $expectedPaths['artDirection.acceptancePath']) { Add-Failure('Unexpected artDirection.acceptancePath') }
      if ([string]$manifest.adapter.path -ne $expectedPaths['adapter.path']) { Add-Failure('Unexpected adapter.path') }
      if ([string]$manifest.fontLicense.path -ne $expectedPaths['fontLicense.path']) { Add-Failure('Unexpected fontLicense.path') }

      $hashChecks = @(
        @($manifest.artDirection.artifactSha256, $inputs.artDirection.sha256, 'art direction'),
        @($manifest.artDirection.acceptanceSha256, $inputs.extractionAcceptance.sha256, 'extraction acceptance'),
        @($manifest.system.manifestSha256, $inputs.systemManifest.sha256, 'system manifest'),
        @($manifest.system.coreSha256, $inputs.core.sha256, 'core'),
        @($manifest.system.themeContractSha256, $inputs.themeContract.sha256, 'theme contract'),
        @($manifest.system.pageMapSha256, $inputs.pageMap.sha256, 'page map'),
        @($manifest.system.contentCombinedSha256, $inputs.content.sha256, 'content'),
        @($manifest.adapter.sha256, (Get-Sha $adapterPath), 'adapter'),
        @($manifest.fontLicense.sha256, (Get-Sha $fontPath), 'font license')
      )
      foreach ($check in $hashChecks) { if ([string]$check[0] -ne [string]$check[1]) { Add-Failure("Stale or mismatched $($check[2]) hash") } }

      $requiredTokens = @('--theme-bg','--theme-surface','--theme-surface-strong','--theme-text','--theme-text-muted','--theme-line','--theme-accent','--theme-accent-strong','--theme-accent-soft','--theme-positive','--theme-warning','--theme-negative','--theme-display-font','--theme-body-font','--theme-mono-font','--theme-radius-sm','--theme-radius-md','--theme-radius-lg','--theme-radius-pill','--theme-shadow-floating','--theme-line-width')
      $variableNames = @($manifest.adapter.variables.PSObject.Properties.Name)
      $css = Get-Content -LiteralPath $adapterPath -Raw -Encoding UTF8
      foreach ($token in $requiredTokens) {
        if ($variableNames -notcontains $token) { Add-Failure("Missing manifest theme variable: $token"); continue }
        $matches = [regex]::Matches($css, ('(?m)^\s*' + [regex]::Escape($token) + '\s*:\s*([^;]+);'))
        if ($matches.Count -ne 1) { Add-Failure("Adapter must define $token exactly once") }
        elseif ($matches[0].Groups[1].Value.Trim() -ne [string]$manifest.adapter.variables.PSObject.Properties[$token].Value.value) { Add-Failure("CSS value differs from manifest: $token") }
      }
      if ($css -match '(?i)@import|https?://|data:') { Add-Failure('Adapter contains a remote/import/data dependency') }
      if ($css -match '(?im)(?:^|[;}])\s*content\s*:') { Add-Failure('Adapter may not generate text with CSS content') }
      if ($css -match '(?i):nth-(?:child|of-type)|\[data-page-(?:number|type)|\[data-density') { Add-Failure('Adapter contains a page-structure selector') }
      foreach ($selectorLine in ($css -split "`r?`n" | Where-Object { $_ -match '\{' })) {
        $selector = ($selectorLine -split '\{')[0]
        if ($selector -match '#[A-Za-z_]') { Add-Failure("Adapter contains an ID selector: $selector") }
      }
      $cssModifiers = @([regex]::Matches($css, '\.theme-[a-z0-9-]+') | ForEach-Object { $_.Value.TrimStart('.') } | Sort-Object -Unique)
      $manifestModifiers = @($manifest.adapter.modifierClasses | Sort-Object -Unique)
      foreach ($modifier in $cssModifiers) { if ($manifestModifiers -notcontains $modifier) { Add-Failure("Undeclared modifier class: $modifier") } }
      foreach ($modifier in $manifestModifiers) { if ($cssModifiers -notcontains $modifier) { Add-Failure("Declared modifier class missing from CSS: $modifier") } }

      $artifactPath = Join-Path $RepoRoot ([string]$manifest.artDirection.artifactPath)
      $artifact = if (Test-Path -LiteralPath $artifactPath) { Read-Json $artifactPath } else { $null }
      if ($null -ne $artifact) {
        $evidenceIds = @($artifact.evidence | ForEach-Object { [string]$_.id })
        foreach ($property in $manifest.adapter.variables.PSObject.Properties) {
          foreach ($id in @($property.Value.evidenceIds)) { if ($evidenceIds -notcontains [string]$id) { Add-Failure("Broken adapter evidence reference: $id") } }
        }
      }

      if ($null -ne $fonts) {
        $fontFamilies = @($fonts.fonts | ForEach-Object { [string]$_.family } | Sort-Object -Unique)
        foreach ($font in @($fonts.fonts)) {
          $file = Join-Path $applicationRoot ([string]$font.file)
          if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { Add-Failure("Missing declared font file: $($font.file)"); continue }
          if ((Get-Sha $file) -ne [string]$font.sha256) { Add-Failure("Font hash mismatch: $($font.file)") }
          if ([string]$font.file -match '(?i)variable' -or [string]$font.family -match '(?i)variable') { Add-Failure("Variable font is forbidden: $($font.file)") }
          if ($css -notmatch [regex]::Escape(([string]$font.file).Replace('\','/'))) { Add-Failure("Declared font is not referenced by adapter: $($font.file)") }
        }
        foreach ($token in @('--theme-display-font','--theme-body-font','--theme-mono-font')) {
          $families = @(Get-FontFamilies $manifest.adapter.variables.PSObject.Properties[$token].Value.value)
          if (@($families | Where-Object { $fontFamilies -contains $_ }).Count -eq 0) { Add-Failure("Font token has no licensed local family: $token") }
        }
      }

      $contentFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'result/content') -Filter '[0-9][0-9]-*.md' -File | Sort-Object Name)
      $layoutRoot = Join-Path $RepoRoot 'result/layout'
      $layoutFiles = if (Test-Path -LiteralPath $layoutRoot) { @(Get-ChildItem -LiteralPath $layoutRoot -Recurse -Filter '[0-9][0-9]-*.html' -File | Sort-Object FullName) } else { @() }
      $expectedLayoutPaths = @($contentFiles | ForEach-Object { $stem = [IO.Path]::GetFileNameWithoutExtension($_.Name); "$stem/$stem.html" })
      $actualLayoutPaths = @($layoutFiles | ForEach-Object { $_.FullName.Substring($layoutRoot.Length).TrimStart('\', '/').Replace('\', '/') })
      $layoutComplete = ($layoutFiles.Count -eq $contentFiles.Count) -and (@($actualLayoutPaths | Where-Object { $expectedLayoutPaths -notcontains $_ }).Count -eq 0)
      if ([string]$manifest.layout.status -eq 'available' -and -not $layoutComplete) { Add-Failure('Manifest claims available layout but inventory is incomplete') }
      if ([string]$manifest.mode -eq 'portfolio-render') {
        if ([string]$manifest.status -ne 'portfolio-ready' -or -not $layoutComplete) { Add-Failure('portfolio-render requires portfolio-ready source and complete neutral layouts') }
      }
      elseif ([string]$manifest.status -ne 'adapter-ready') { Add-Failure('adapter-proof requires adapter-ready source') }

      if ($layoutComplete) {
        $pageMap = Read-Json (Join-Path $RepoRoot 'portfolio-system/page-map.json')
        foreach ($layoutFile in $layoutFiles) {
          $layoutStem = [IO.Path]::GetFileNameWithoutExtension($layoutFile.Name)
          $contentName = $layoutStem + '.md'
          $entry = $pageMap.pages.PSObject.Properties[$contentName].Value
          $html = Get-Content -LiteralPath $layoutFile.FullName -Raw -Encoding UTF8
          if ($null -eq $entry) { Add-Failure("Layout has no page-map entry: $($layoutFile.Name)"); continue }
          $expectedType = 'data-page-type="' + [string]$entry.type + '"'
          $expectedDensity = 'data-density="' + [string]$entry.density + '"'
          if ($html -notmatch [regex]::Escape($expectedType) -or $html -notmatch [regex]::Escape($expectedDensity)) { Add-Failure("Layout metadata mismatch: $($layoutFile.Name)") }
          if ($html -notmatch 'href=["'']theme\.css["'']') { Add-Failure("Layout must link only theme.css: $($layoutFile.Name)") }
          if ($html -match '(?i)https?://') { Add-Failure("Layout contains remote dependency: $($layoutFile.Name)") }
          $probes = @([regex]::Matches($html, '<meta\s+name=["'']pdf-text-probe["'']\s+content=["'']([^"'']+)["'']') | ForEach-Object { $_.Groups[1].Value })
          if ($probes.Count -lt 1) { Add-Failure("Layout lacks pdf-text-probe: $($layoutFile.Name)") }
          $contentText = Get-Content -LiteralPath (Join-Path $RepoRoot "result/content/$contentName") -Raw -Encoding UTF8
          foreach ($probe in $probes) { if ($contentText -notmatch [regex]::Escape($probe)) { Add-Failure("Layout text probe is not in content source: $($layoutFile.Name) -> $probe") } }
        }
      }
    }
  }

  if (-not [string]::IsNullOrWhiteSpace($BuildId)) {
    if ($BuildId -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { Add-Failure("Invalid build ID: $BuildId") }
    $buildRoot = Join-Path $RepoRoot "result/design/$CompanySlug/builds/$BuildId"
    $lockPath = Join-Path $buildRoot 'inputs.lock.json'
    $preflightPath = Join-Path $buildRoot 'preflight.json'
    foreach ($path in @($lockPath, $preflightPath)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Add-Failure("Missing build evidence: $path") } }
    if ((Test-Path -LiteralPath $lockPath) -and (Test-Path -LiteralPath $preflightPath)) {
      Invoke-Schema (Join-Path $RepoRoot 'portfolio-system/application-input-lock.schema.json') $lockPath
      Invoke-Schema (Join-Path $RepoRoot 'portfolio-system/application-preflight.schema.json') $preflightPath
      $lock = Read-Json $lockPath; $preflight = Read-Json $preflightPath
      if ([string]$lock.companySlug -ne $CompanySlug -or [string]$lock.buildId -ne $BuildId) { Add-Failure('Input lock identity mismatch') }
      if ([string]$preflight.companySlug -ne $CompanySlug -or [string]$preflight.buildId -ne $BuildId) { Add-Failure('Preflight identity mismatch') }
      if ([string]$preflight.inputLockSha256 -ne (Get-Sha $lockPath)) { Add-Failure('Preflight input-lock hash mismatch') }
      if ([string]$preflight.sourceManifestSha256 -ne (Get-Sha $manifestPath)) { Add-Failure('Preflight source-manifest hash mismatch') }
      foreach ($property in $lock.inputs.PSObject.Properties) {
        $record = $property.Value
        if ([string]$record.path -eq 'result/content') {
          $currentHash = Get-CombinedHash (Join-Path $RepoRoot 'result/content') '*.md'
        }
        else {
          $inputFull = [IO.Path]::GetFullPath((Join-Path $RepoRoot ([string]$record.path)))
          $repoPrefix = $RepoRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
          if (-not $inputFull.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $inputFull -PathType Leaf)) {
            Add-Failure("Missing or unsafe locked input: $($record.path)")
            continue
          }
          $currentHash = Get-Sha $inputFull
        }
        if ([string]$currentHash -ne [string]$record.sha256) { Add-Failure("Locked input drift: $($record.path)") }
      }
      foreach ($page in @($lock.pages)) {
        $contentFile = Join-Path $RepoRoot "result/content/$($page.name).md"
        $layoutFile = Join-Path $RepoRoot "result/layout/$($page.name)/$($page.name).html"
        if (-not (Test-Path -LiteralPath $contentFile -PathType Leaf) -or (Get-Sha $contentFile) -ne [string]$page.contentSha256) { Add-Failure("Locked page content drift: $($page.name)") }
        if (-not (Test-Path -LiteralPath $layoutFile -PathType Leaf) -or (Get-Sha $layoutFile) -ne [string]$page.layoutSha256) { Add-Failure("Locked neutral layout drift: $($page.name)") }
      }
      foreach ($output in @($preflight.outputs)) {
        foreach ($kind in @('html','png','pdf')) {
          $relative = [string]$output.$kind; $full = Resolve-BuildFile $buildRoot $relative
          if ($null -eq $full) { Add-Failure("Unsafe rendered output path: $relative") }
          elseif (-not (Test-Path -LiteralPath $full -PathType Leaf)) { Add-Failure("Missing rendered output: $relative") }
          else { $hashProperty = $kind + 'Sha256'; if ((Get-Sha $full) -ne [string]$output.$hashProperty) { Add-Failure("Rendered output hash mismatch: $relative") } }
        }
        if ($output.png1280x720 -ne $true -or $output.pdfNonEmpty -ne $true -or $output.overflowFree -ne $true) { Add-Failure("Rendered output failed deterministic checks: $($output.name)") }
        if ([string]$output.kind -eq 'page') {
          $number = [int]([string]$output.name).Substring(0, 2)
          $published = Join-Path $buildRoot "portfolio-$number.pdf"
          if (-not (Test-Path -LiteralPath $published -PathType Leaf) -or (Get-Sha $published) -ne [string]$output.pdfSha256) { Add-Failure("Published page PDF mismatch: portfolio-$number.pdf") }
        }
      }
      $fixtureCount = @($preflight.outputs | Where-Object { [string]$_.kind -eq 'fixture' }).Count
      $pageCount = @($preflight.outputs | Where-Object { [string]$_.kind -eq 'page' }).Count
      if ($fixtureCount -ne 4) { Add-Failure('Build must contain exactly four fixture renders') }
      if ([string]$preflight.mode -eq 'portfolio-render' -and $pageCount -ne @($lock.pages).Count) { Add-Failure('Portfolio page inventory does not match the input lock') }
      if ([string]$preflight.mode -eq 'adapter-proof' -and $pageCount -ne 0) { Add-Failure('Adapter-proof build may not contain portfolio pages') }
      if ((Get-BuildOutputSetHash $buildRoot) -ne [string]$preflight.outputSetSha256) { Add-Failure('Rendered output-set hash mismatch') }
      if ($preflight.checks.inputLockStable -ne $true -or $preflight.checks.fixtureDomStable -ne $true -or $preflight.checks.fontsVerified -ne $true -or $preflight.checks.allRendersValid -ne $true -or $preflight.checks.overflowFree -ne $true) { Add-Failure('Preflight core checks did not all pass') }
      if ([string]$preflight.mode -eq 'portfolio-render' -and $preflight.productionGateEligible -ne $true) { Add-Failure('Portfolio-render build is not production-gate eligible') }
      if (@($preflight.blockers).Count -gt 0) { Add-Failure('Preflight contains blockers') }

      if ($RequireAcceptance) {
        $acceptancePath = Join-Path $buildRoot 'acceptance.json'
        if (-not (Test-Path -LiteralPath $acceptancePath -PathType Leaf)) { Add-Failure('Missing application acceptance.json') }
        else {
          Invoke-Schema (Join-Path $RepoRoot 'portfolio-system/application-acceptance.schema.json') $acceptancePath
          $acceptance = Read-Json $acceptancePath
          $lockHash = Get-Sha $lockPath; $preflightHash = Get-Sha $preflightPath
          if ([string]$acceptance.scope -ne [string]$preflight.mode -or [string]$acceptance.companySlug -ne $CompanySlug -or [string]$acceptance.buildId -ne $BuildId) { Add-Failure('Application acceptance identity/scope mismatch') }
          if ([string]$acceptance.inputLockSha256 -ne $lockHash -or [string]$acceptance.preflightSha256 -ne $preflightHash -or [string]$acceptance.outputSetSha256 -ne [string]$preflight.outputSetSha256) { Add-Failure('Application acceptance build hashes mismatch') }
          $reviewers = @($acceptance.reviewers)
          $roles = @($reviewers | ForEach-Object { [string]$_.role })
          foreach ($role in @('applied_theme_contract_verifier','applied_portfolio_visual_verifier')) { if ($roles -notcontains $role) { Add-Failure("Missing designated application reviewer: $role") } }
          if (($roles | Sort-Object -Unique).Count -ne $roles.Count) { Add-Failure('Application reviewer roles must be unique') }
          $paths = @($reviewers | ForEach-Object { [string]$_.reportPath }); if (($paths | Sort-Object -Unique).Count -ne $paths.Count) { Add-Failure('Application review paths must be unique') }
          $hashes = @($reviewers | ForEach-Object { [string]$_.reportSha256 }); if (($hashes | Sort-Object -Unique).Count -ne $hashes.Count) { Add-Failure('Application review hashes must be unique') }
          $maximums = [ordered]@{ typography=25; layout=20; hierarchy=15; storytelling=15; adaptability=15; detail=5; production=5 }
          $floors = [ordered]@{ typography=22; layout=18; hierarchy=13; storytelling=13; adaptability=13; detail=4; production=5 }
          $reports = @()
          foreach ($reviewer in $reviewers) {
            $reportFull = [IO.Path]::GetFullPath((Join-Path $buildRoot ([string]$reviewer.reportPath)))
            $reviewRoot = [IO.Path]::GetFullPath((Join-Path $buildRoot 'reviews')).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
            if (-not $reportFull.StartsWith($reviewRoot, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $reportFull -PathType Leaf)) { Add-Failure("Invalid review report path: $($reviewer.reportPath)"); continue }
            Invoke-Schema (Join-Path $RepoRoot 'portfolio-system/application-review.schema.json') $reportFull
            $report = Read-Json $reportFull; if ($null -eq $report) { continue }; $reports += $report
            if ((Get-Sha $reportFull) -ne [string]$reviewer.reportSha256) { Add-Failure("Review report hash mismatch: $($reviewer.role)") }
            if ([string]$report.role -ne [string]$reviewer.role -or [int]$report.totalScore -ne [int]$reviewer.totalScore) { Add-Failure("Review identity/score mismatch: $($reviewer.role)") }
            if ([string]$report.scope -ne [string]$preflight.mode -or [string]$report.companySlug -ne $CompanySlug -or [string]$report.buildId -ne $BuildId) { Add-Failure("Review build identity mismatch: $($reviewer.role)") }
            if ([string]$report.inputLockSha256 -ne $lockHash -or [string]$report.preflightSha256 -ne $preflightHash -or [string]$report.outputSetSha256 -ne [string]$preflight.outputSetSha256) { Add-Failure("Review build hashes mismatch: $($reviewer.role)") }
            if ([string]$report.reviewProfile.id -ne 'full-portfolio' -or $report.acceptanceEligible -ne $true) { Add-Failure("Only a full-portfolio, acceptance-eligible review may support acceptance: $($reviewer.role)") }
            $total = 0; $floorPass = $true
            foreach ($category in $maximums.Keys) { $score = [int]$report.categoryScores.$category; $total += $score; if ($score -lt [int]$floors[$category]) { $floorPass = $false } }
            if ($total -ne [int]$report.totalScore -or $report.categoryFloorsPass -ne $floorPass -or -not $floorPass) { Add-Failure("Review score/floor mismatch: $($reviewer.role)") }
            if ([int]$report.totalScore -lt 90 -or @($report.hardBlockers).Count -gt 0 -or [string]$report.verdict -ne 'PASS') { Add-Failure("Review does not pass: $($reviewer.role)") }
          }
          $primary = @($reports | Where-Object { @('applied_theme_contract_verifier','applied_portfolio_visual_verifier') -contains [string]$_.role })
          if ($primary.Count -eq 2) {
            $needsAdjudicator = [math]::Abs([int]$primary[0].totalScore - [int]$primary[1].totalScore) -gt 2
            foreach ($category in $maximums.Keys) { if ([math]::Abs([int]$primary[0].categoryScores.$category - [int]$primary[1].categoryScores.$category) -gt 1) { $needsAdjudicator = $true } }
            if ($needsAdjudicator -and $roles -notcontains 'applied_portfolio_adjudicator') { Add-Failure('Application review divergence requires adjudicator') }
          }
          if ($reviewers.Count -ge 2) { $minimum = ($reviewers | Measure-Object -Property totalScore -Minimum).Minimum; if ([int]$acceptance.finalScore -ne [int]$minimum) { Add-Failure('Application finalScore must be the minimum reviewer score') } }
          if (@($acceptance.hardBlockers).Count -gt 0 -or [string]$acceptance.verdict -ne 'PASS') { Add-Failure('Application acceptance contains blockers or non-PASS verdict') }
        }
      }
    }
  }
}

if ($script:Failures.Count -gt 0) {
  [Console]::Error.WriteLine('Application validation FAIL')
  foreach ($failure in $script:Failures) { [Console]::Error.WriteLine("- $failure") }
  exit 1
}
if ([string]::IsNullOrWhiteSpace($CompanySlug)) { Write-Output 'Application workflow validation PASS' }
elseif ([string]::IsNullOrWhiteSpace($BuildId)) { Write-Output "Application source validation PASS: $CompanySlug" }
else { Write-Output "Application build validation PASS: $CompanySlug/$BuildId" }
exit 0
