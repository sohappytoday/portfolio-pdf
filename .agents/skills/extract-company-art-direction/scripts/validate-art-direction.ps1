param(
  [Parameter(Mandatory = $false)]
  [string]$RepoRoot = '.',

  [Parameter(Mandatory = $false)]
  [string]$CompanySlug,

  [Parameter(Mandatory = $false)]
  [switch]$RequireAcceptance
)

$ErrorActionPreference = 'Stop'
$script:Errors = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) {
  $script:Errors.Add($Message)
}

function Read-Json([string]$Path) {
  try {
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
  }
  catch {
    Add-Failure("Invalid JSON: $Path - $($_.Exception.Message)")
    return $null
  }
}

function Require-File([string]$RelativePath) {
  $path = Join-Path $RepoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure("Missing required file: $RelativePath")
  }
  return $path
}

function Invoke-SchemaValidation([string]$Runner, [string]$Schema, [string]$Data) {
  if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Add-Failure('Node.js is required for JSON Schema validation')
    return
  }
  $previousErrorPreference = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $result = & node $Runner $Schema $Data 2>&1
  $exitCode = $LASTEXITCODE
  $ErrorActionPreference = $previousErrorPreference
  if ($exitCode -ne 0) { Add-Failure(($result -join [Environment]::NewLine)) }
}

function Collect-EvidenceRefs($Node, [System.Collections.Generic.List[string]]$Refs) {
  if ($null -eq $Node) { return }
  if ($Node -is [string] -or $Node -is [ValueType]) { return }
  if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [System.Management.Automation.PSCustomObject])) {
    foreach ($item in $Node) { Collect-EvidenceRefs $item $Refs }
    return
  }
  foreach ($property in $Node.PSObject.Properties) {
    if ($property.Name -eq 'evidenceIds') {
      foreach ($id in @($property.Value)) { if ($null -ne $id) { $Refs.Add([string]$id) } }
    }
    else {
      Collect-EvidenceRefs $property.Value $Refs
    }
  }
}

function Get-FontFamilyNames($Value) {
  $items = @()
  if ($Value -is [string]) {
    $items = @(([string]$Value) -split ',')
  }
  elseif ($Value -is [System.Collections.IEnumerable]) {
    $items = @($Value)
  }
  $families = @()
  foreach ($item in $items) {
    $clean = ([string]$item).Trim().Trim('"').Trim("'")
    if (-not [string]::IsNullOrWhiteSpace($clean)) { $families += $clean }
  }
  return $families
}

$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$frameworkFiles = @(
  'portfolio-system/ART_DIRECTION_CONTRACT.md',
  'portfolio-system/THEME_CONTRACT.md',
  'portfolio-system/art-direction.schema.json',
  'portfolio-system/art-direction-acceptance.schema.json',
  'portfolio-system/art-direction-review.schema.json',
  '.agents/skills/extract-company-art-direction/SKILL.md',
  '.agents/skills/extract-company-art-direction/references/research-protocol.md',
  '.agents/skills/extract-company-art-direction/agents/openai.yaml',
  '.agents/skills/extract-company-art-direction/scripts/validate-json-schema.mjs',
  '.agents/skills/extract-company-art-direction/scripts/get-protected-state.ps1',
  'portfolio-system/fixtures/art-direction-structural.json',
  'portfolio-system/fixtures/art-direction-acceptance-structural.json',
  'portfolio-system/fixtures/art-direction-review-structural.json',
  '.agents/skills/review-company-art-direction/SKILL.md',
  '.agents/skills/review-company-art-direction/references/art-direction-quality-rubric.md',
  '.agents/skills/review-company-art-direction/agents/openai.yaml',
  '.codex/agents/company-brand-researcher.toml',
  '.codex/agents/company-visual-researcher.toml',
  '.codex/agents/company-art-direction-synthesizer.toml',
  '.codex/agents/company-art-direction-evidence-verifier.toml',
  '.codex/agents/company-art-direction-fit-verifier.toml',
  '.codex/agents/company-art-direction-adjudicator.toml',
  '.codex/hooks/validate-art-direction-workflow.ps1',
  '.codex/hooks.json'
)

foreach ($file in $frameworkFiles) { Require-File $file | Out-Null }

$schemaPath = Join-Path $RepoRoot 'portfolio-system/art-direction.schema.json'
if (Test-Path -LiteralPath $schemaPath) { Read-Json $schemaPath | Out-Null }
$acceptanceSchemaPath = Join-Path $RepoRoot 'portfolio-system/art-direction-acceptance.schema.json'
if (Test-Path -LiteralPath $acceptanceSchemaPath) { Read-Json $acceptanceSchemaPath | Out-Null }
$reviewSchemaPath = Join-Path $RepoRoot 'portfolio-system/art-direction-review.schema.json'
if (Test-Path -LiteralPath $reviewSchemaPath) { Read-Json $reviewSchemaPath | Out-Null }
$schemaRunner = Join-Path $RepoRoot '.agents/skills/extract-company-art-direction/scripts/validate-json-schema.mjs'
$artifactFixturePath = Join-Path $RepoRoot 'portfolio-system/fixtures/art-direction-structural.json'
$acceptanceFixturePath = Join-Path $RepoRoot 'portfolio-system/fixtures/art-direction-acceptance-structural.json'
$reviewFixturePath = Join-Path $RepoRoot 'portfolio-system/fixtures/art-direction-review-structural.json'
if ((Test-Path -LiteralPath $schemaRunner) -and (Test-Path -LiteralPath $schemaPath) -and (Test-Path -LiteralPath $artifactFixturePath)) {
  Invoke-SchemaValidation $schemaRunner $schemaPath $artifactFixturePath
}
if ((Test-Path -LiteralPath $schemaRunner) -and (Test-Path -LiteralPath $acceptanceSchemaPath) -and (Test-Path -LiteralPath $acceptanceFixturePath)) {
  Invoke-SchemaValidation $schemaRunner $acceptanceSchemaPath $acceptanceFixturePath
}
if ((Test-Path -LiteralPath $schemaRunner) -and (Test-Path -LiteralPath $reviewSchemaPath) -and (Test-Path -LiteralPath $reviewFixturePath)) {
  Invoke-SchemaValidation $schemaRunner $reviewSchemaPath $reviewFixturePath
}

$hooksPath = Join-Path $RepoRoot '.codex/hooks.json'
if (Test-Path -LiteralPath $hooksPath) { Read-Json $hooksPath | Out-Null }

$skillChecks = @{
  '.agents/skills/extract-company-art-direction/SKILL.md' = 'name: extract-company-art-direction'
  '.agents/skills/review-company-art-direction/SKILL.md' = 'name: review-company-art-direction'
}
foreach ($relative in $skillChecks.Keys) {
  $path = Join-Path $RepoRoot $relative
  if (Test-Path -LiteralPath $path) {
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    if ($text -notmatch '(?s)^---\s+.*?---') { Add-Failure("Missing SKILL frontmatter: $relative") }
    if ($text -notmatch [regex]::Escape($skillChecks[$relative])) { Add-Failure("Wrong skill name: $relative") }
    $frontmatter = [regex]::Match($text, '(?ms)\A---\s*(.*?)^---\s*$')
    if ($frontmatter.Success) {
      $metadataLines = $frontmatter.Groups[1].Value -split "`r?`n" | Where-Object { $_ -match '^([A-Za-z0-9-]+):' }
      foreach ($line in $metadataLines) {
        $key = ([regex]::Match($line, '^([A-Za-z0-9-]+):')).Groups[1].Value
        if (@('name', 'description', 'license', 'allowed-tools', 'metadata') -notcontains $key) { Add-Failure("Unexpected skill frontmatter key '$key': $relative") }
      }
      $descriptionLine = $metadataLines | Where-Object { $_ -match '^description:' } | Select-Object -First 1
      $descriptionValue = ([string]$descriptionLine) -replace '^description:\s*', ''
      if ([string]::IsNullOrWhiteSpace($descriptionValue) -or $descriptionValue.Length -gt 1024 -or $descriptionValue -match '[<>]') { Add-Failure("Invalid skill description: $relative") }
    }
  }
}

$yamlChecks = @{
  '.agents/skills/extract-company-art-direction/agents/openai.yaml' = '$extract-company-art-direction'
  '.agents/skills/review-company-art-direction/agents/openai.yaml' = '$review-company-art-direction'
}
foreach ($relative in $yamlChecks.Keys) {
  $path = Join-Path $RepoRoot $relative
  if (Test-Path -LiteralPath $path) {
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    if ($text -notmatch 'interface:' -or $text -notmatch 'default_prompt:') { Add-Failure("Incomplete skill UI metadata: $relative") }
    if ($text -notmatch [regex]::Escape($yamlChecks[$relative])) { Add-Failure("Default prompt does not name its skill: $relative") }
  }
}

$agentModes = @{
  '.codex/agents/company-brand-researcher.toml' = 'read-only'
  '.codex/agents/company-visual-researcher.toml' = 'read-only'
  '.codex/agents/company-art-direction-synthesizer.toml' = 'workspace-write'
  '.codex/agents/company-art-direction-evidence-verifier.toml' = 'read-only'
  '.codex/agents/company-art-direction-fit-verifier.toml' = 'read-only'
  '.codex/agents/company-art-direction-adjudicator.toml' = 'read-only'
}
foreach ($relative in $agentModes.Keys) {
  $path = Join-Path $RepoRoot $relative
  if (Test-Path -LiteralPath $path) {
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($field in @('name =', 'description =', 'developer_instructions =')) {
      if ($text -notmatch [regex]::Escape($field)) { Add-Failure("Missing $field in $relative") }
    }
    $modePattern = 'sandbox_mode\s*=\s*"' + [regex]::Escape($agentModes[$relative]) + '"'
    if ($text -notmatch $modePattern) { Add-Failure("Wrong sandbox mode in $relative; expected $($agentModes[$relative])") }
  }
}

if (-not [string]::IsNullOrWhiteSpace($CompanySlug)) {
  if ($CompanySlug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
    Add-Failure("Invalid company slug: $CompanySlug")
  }

  $relativeBase = "designs/$CompanySlug/research/art-direction"
  $base = Join-Path $RepoRoot $relativeBase
  $sourcesPath = Join-Path $base 'sources.md'
  $artifactPath = Join-Path $base 'art-direction.json'
  $briefPath = Join-Path $base 'art-direction.md'

  foreach ($path in @($sourcesPath, $artifactPath, $briefPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Add-Failure("Missing extraction output: $path") }
  }

  if (Test-Path -LiteralPath $artifactPath) {
    $artifact = Read-Json $artifactPath
    if ($null -ne $artifact) {
      Invoke-SchemaValidation $schemaRunner $schemaPath $artifactPath
      if ($artifact.schemaVersion -ne '1.0.0') { Add-Failure('art-direction.json schemaVersion must be 1.0.0') }
      if ($artifact.company.slug -ne $CompanySlug) { Add-Failure('Company slug does not match output directory') }
      if (@('draft', 'review-ready', 'provisional', 'blocked') -notcontains [string]$artifact.status) { Add-Failure('Invalid research status') }

      $evidence = @($artifact.evidence)
      $ids = @($evidence | ForEach-Object { [string]$_.id })
      if ($ids.Count -lt 1) { Add-Failure('At least one evidence item is required') }
      if (($ids | Sort-Object -Unique).Count -ne $ids.Count) { Add-Failure('Evidence IDs must be unique') }
      foreach ($id in $ids) { if ($id -notmatch '^E[0-9]{2,}$') { Add-Failure("Invalid evidence ID: $id") } }

      $officialEvidence = @($evidence | Where-Object { $_.official -eq $true -and [string]$_.sourceType -like 'official-*' })
      $officialContexts = @($officialEvidence | ForEach-Object { [string]$_.sourceId } | Sort-Object -Unique)
      $hasCompanySurface = @($officialEvidence | Where-Object { @('official-site', 'official-brand') -contains [string]$_.sourceType }).Count -gt 0
      $hasProductSurface = @($officialEvidence | Where-Object { @('official-product', 'official-app-store') -contains [string]$_.sourceType }).Count -gt 0
      $renderedContexts = @($officialEvidence | Where-Object { @('rendered', 'official-screenshot') -contains [string]$_.observationMethod } | ForEach-Object { [string]$_.sourceId } | Sort-Object -Unique)
      if ([int]$artifact.researchCoverage.renderedEvidenceCount -ne $renderedContexts.Count) { Add-Failure('renderedEvidenceCount does not match distinct rendered evidence contexts') }
      $isAcceptanceCandidate = ([string]$artifact.status -eq 'review-ready') -or $RequireAcceptance
      if ($isAcceptanceCandidate) {
        if ($officialContexts.Count -lt 3) { Add-Failure('Acceptance coverage requires at least three distinct official source contexts') }
        if (-not $hasCompanySurface) { Add-Failure('Acceptance coverage requires an official company or brand surface') }
        if (-not $hasProductSurface) { Add-Failure('Acceptance coverage requires an official product or app-store surface') }
        if ($renderedContexts.Count -lt 2) { Add-Failure('Acceptance coverage requires two distinct rendered or official-screenshot source contexts') }
      }

      $principles = @($artifact.visualPrinciples)
      if ($principles.Count -lt 3 -or $principles.Count -gt 5) { Add-Failure('visualPrinciples must contain three to five items') }

      $refs = New-Object System.Collections.Generic.List[string]
      Collect-EvidenceRefs $artifact $refs
      foreach ($ref in ($refs | Sort-Object -Unique)) {
        if ($ids -notcontains $ref) { Add-Failure("Broken evidence reference: $ref") }
      }

      $requiredTokens = @(
        '--theme-bg', '--theme-surface', '--theme-surface-strong',
        '--theme-text', '--theme-text-muted', '--theme-line',
        '--theme-accent', '--theme-accent-strong', '--theme-accent-soft',
        '--theme-positive', '--theme-warning', '--theme-negative',
        '--theme-display-font', '--theme-body-font', '--theme-mono-font',
        '--theme-radius-sm', '--theme-radius-md', '--theme-radius-lg', '--theme-radius-pill',
        '--theme-shadow-floating', '--theme-line-width'
      )
      $candidateNames = @($artifact.portfolioTranslation.themeCandidates.PSObject.Properties.Name)
      foreach ($token in $requiredTokens) {
        if ($candidateNames -notcontains $token) {
          Add-Failure("Missing theme candidate: $token")
        }
        else {
          $candidateValue = $artifact.portfolioTranslation.themeCandidates.PSObject.Properties[$token].Value.value
          $candidateValueJson = $candidateValue | ConvertTo-Json -Compress -Depth 20
          if ($null -eq $candidateValue -or @('', '[]', '{}', 'null') -contains [string]$candidateValueJson) { Add-Failure("Theme candidate has an empty value: $token") }
        }
      }

      $observedRestrictedFonts = @($artifact.tokens.typography.observedFonts | Where-Object { @('proprietary', 'unknown') -contains [string]$_.licenseStatus } | ForEach-Object { [string]$_.family })
      $selectedFontFamilies = @()
      foreach ($token in @('--theme-display-font', '--theme-body-font', '--theme-mono-font')) {
        $property = $artifact.portfolioTranslation.themeCandidates.PSObject.Properties[$token]
        if ($null -ne $property) { $selectedFontFamilies += @(Get-FontFamilyNames $property.Value.value) }
      }
      foreach ($family in $observedRestrictedFonts) {
        if (-not [string]::IsNullOrWhiteSpace($family) -and $selectedFontFamilies -contains $family) {
          Add-Failure("Restricted observed font appears in theme candidates: $family")
        }
      }
      $safeAlternatives = @($artifact.tokens.typography.safeAlternatives)
      if ($safeAlternatives.Count -lt 1) { Add-Failure('At least one verified safe font alternative is required') }
      $safeFamilies = @($safeAlternatives | ForEach-Object { [string]$_.family } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
      foreach ($token in @('--theme-display-font', '--theme-body-font', '--theme-mono-font')) {
        $property = $artifact.portfolioTranslation.themeCandidates.PSObject.Properties[$token]
        if ($null -ne $property) {
          $fontFamilies = @(Get-FontFamilyNames $property.Value.value)
          $matchesSafeFamily = @($fontFamilies | Where-Object { $safeFamilies -contains $_ }).Count -gt 0
          if (-not $matchesSafeFamily) { Add-Failure("Font theme candidate does not reference a verified safe alternative: $token") }
        }
      }

      foreach ($flag in @('usesLogo', 'usesProprietaryFont', 'copiesProductionCss', 'usesRestrictedAssets', 'changesCoreOrContent')) {
        if ($artifact.compliance.$flag -ne $false) { Add-Failure("Compliance flag must be false: $flag") }
      }

      if (Test-Path -LiteralPath $sourcesPath) {
        $sourceText = Get-Content -LiteralPath $sourcesPath -Raw -Encoding UTF8
        foreach ($id in $ids) {
          if ($sourceText -notmatch ('(?<![A-Za-z0-9])' + [regex]::Escape($id) + '(?![A-Za-z0-9])')) { Add-Failure("sources.md is missing evidence ID: $id") }
        }
        foreach ($sourceId in @($evidence | ForEach-Object { [string]$_.sourceId } | Sort-Object -Unique)) {
          if ($sourceText -notmatch ('(?<![A-Za-z0-9])' + [regex]::Escape($sourceId) + '(?![A-Za-z0-9])')) { Add-Failure("sources.md is missing source ID: $sourceId") }
        }
      }

      if ($RequireAcceptance) {
        $acceptancePath = Join-Path $base 'acceptance.json'
        if (-not (Test-Path -LiteralPath $acceptancePath -PathType Leaf)) {
          Add-Failure('Missing acceptance.json')
        }
        else {
          $acceptance = Read-Json $acceptancePath
          if ($null -ne $acceptance) {
            Invoke-SchemaValidation $schemaRunner $acceptanceSchemaPath $acceptancePath
            $hash = (Get-FileHash -LiteralPath $artifactPath -Algorithm SHA256).Hash.ToLowerInvariant()
            if ([string]$acceptance.artifactSha256 -ne $hash) { Add-Failure('Acceptance hash does not match art-direction.json') }
            if ([string]$acceptance.protectedState.beforeSha256 -ne [string]$acceptance.protectedState.afterSha256) { Add-Failure('Protected paths changed during extraction') }
            $protectedStateScript = Join-Path $RepoRoot '.agents/skills/extract-company-art-direction/scripts/get-protected-state.ps1'
            $currentProtectedState = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $protectedStateScript -RepoRoot $RepoRoot | ConvertFrom-Json)
            if ([string]$acceptance.protectedState.afterSha256 -ne [string]$currentProtectedState.combinedSha256) { Add-Failure('Current protected-path hash does not match acceptance') }
            if ([int]$acceptance.protectedState.fileCount -ne [int]$currentProtectedState.fileCount) { Add-Failure('Current protected-path file count does not match acceptance') }
            $reviewers = @($acceptance.reviewers)
            if ($reviewers.Count -lt 2) { Add-Failure('Acceptance requires at least two independent reviewers') }
            $roles = @($reviewers | ForEach-Object { [string]$_.role })
            if (($roles | Sort-Object -Unique).Count -ne $roles.Count) { Add-Failure('Reviewer roles must be distinct') }
            $reportPaths = @($reviewers | ForEach-Object { [string]$_.reportPath })
            if (($reportPaths | Sort-Object -Unique).Count -ne $reportPaths.Count) { Add-Failure('Reviewer report paths must be distinct') }
            $reportHashes = @($reviewers | ForEach-Object { [string]$_.reportSha256 })
            if (($reportHashes | Sort-Object -Unique).Count -ne $reportHashes.Count) { Add-Failure('Reviewer report hashes must be distinct') }
            foreach ($requiredRole in @('company_art_direction_evidence_verifier', 'company_art_direction_fit_verifier')) {
              if ($roles -notcontains $requiredRole) { Add-Failure("Missing designated primary reviewer: $requiredRole") }
            }
            $categoryMaximums = [ordered]@{ evidence = 20; synthesis = 18; typography = 15; visualLanguage = 15; brandSafety = 12; themeHandoff = 12; uncertainty = 8 }
            $categoryFloors = [ordered]@{ evidence = 18; synthesis = 16; typography = 14; visualLanguage = 13; brandSafety = 12; themeHandoff = 12; uncertainty = 7 }
            foreach ($reviewer in $reviewers) {
              if ([string]$reviewer.artifactSha256 -ne $hash) { Add-Failure("Reviewer hash mismatch: $($reviewer.role)") }
              $calculatedTotal = 0
              $calculatedFloorsPass = $true
              foreach ($category in $categoryMaximums.Keys) {
                $score = $reviewer.categoryScores.$category
                if ($null -eq $score -or [int]$score -lt 0 -or [int]$score -gt [int]$categoryMaximums[$category]) {
                  Add-Failure("Invalid category score $category for reviewer: $($reviewer.role)")
                  $calculatedFloorsPass = $false
                }
                else {
                  $calculatedTotal += [int]$score
                  if ([int]$score -lt [int]$categoryFloors[$category]) { $calculatedFloorsPass = $false }
                }
              }
              if ([int]$reviewer.totalScore -ne $calculatedTotal) { Add-Failure("Reviewer total does not equal category sum: $($reviewer.role)") }
              if ([int]$reviewer.totalScore -lt 90) { Add-Failure("Reviewer score below 90: $($reviewer.role)") }
              if ($reviewer.categoryFloorsPass -ne $calculatedFloorsPass -or -not $calculatedFloorsPass) { Add-Failure("Reviewer category floors failed or misreported: $($reviewer.role)") }
              if ($null -ne $reviewer.scoreCap -and [int]$reviewer.totalScore -gt [int]$reviewer.scoreCap) { Add-Failure("Reviewer total exceeds its score cap: $($reviewer.role)") }
              if (@($reviewer.hardBlockers).Count -gt 0) { Add-Failure("Reviewer reported hard blockers: $($reviewer.role)") }
              if ([string]::IsNullOrWhiteSpace([string]$reviewer.reportPath)) {
                Add-Failure("Reviewer reportPath is required: $($reviewer.role)")
              }
              else {
                $reportRelative = [string]$reviewer.reportPath
                $reportFull = [System.IO.Path]::GetFullPath((Join-Path $base $reportRelative))
                $reviewsRoot = [System.IO.Path]::GetFullPath((Join-Path $base 'reviews'))
                $reviewsPrefix = $reviewsRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
                if (-not $reportFull.StartsWith($reviewsPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                  Add-Failure("Reviewer report must stay under the extraction reviews directory: $($reviewer.role)")
                }
                elseif (-not (Test-Path -LiteralPath $reportFull -PathType Leaf)) {
                  Add-Failure("Reviewer report does not exist: $reportRelative")
                }
                else {
                  Invoke-SchemaValidation $schemaRunner $reviewSchemaPath $reportFull
                  $report = Read-Json $reportFull
                  $reportHash = (Get-FileHash -LiteralPath $reportFull -Algorithm SHA256).Hash.ToLowerInvariant()
                  if ([string]$reviewer.reportSha256 -ne $reportHash) { Add-Failure("Reviewer report hash mismatch: $($reviewer.role)") }
                  if ($null -ne $report) {
                    if ([string]$report.artifactSha256 -ne $hash) { Add-Failure("Reviewer report artifact hash mismatch: $($reviewer.role)") }
                    if ([string]$report.role -ne [string]$reviewer.role) { Add-Failure("Reviewer report role mismatch: $($reviewer.role)") }
                    if ([int]$report.totalScore -ne [int]$reviewer.totalScore) { Add-Failure("Reviewer report total mismatch: $($reviewer.role)") }
                    if ($report.categoryFloorsPass -ne $reviewer.categoryFloorsPass) { Add-Failure("Reviewer report category floor mismatch: $($reviewer.role)") }
                    if ([string]$report.scoreCap -ne [string]$reviewer.scoreCap) { Add-Failure("Reviewer report score cap mismatch: $($reviewer.role)") }
                    if ([string]$report.verdict -ne 'PASS') { Add-Failure("Reviewer report verdict must be PASS: $($reviewer.role)") }
                    if ((@($report.hardBlockers) | ConvertTo-Json -Compress) -ne (@($reviewer.hardBlockers) | ConvertTo-Json -Compress)) { Add-Failure("Reviewer report hard blockers mismatch: $($reviewer.role)") }
                    foreach ($category in $categoryMaximums.Keys) {
                      if ([int]$report.categoryScores.$category -ne [int]$reviewer.categoryScores.$category) { Add-Failure("Reviewer report category mismatch for $category`: $($reviewer.role)") }
                    }
                  }
                }
              }
            }
            $primaryReviewers = @($reviewers | Where-Object { @('company_art_direction_evidence_verifier', 'company_art_direction_fit_verifier') -contains [string]$_.role })
            if ($primaryReviewers.Count -eq 2) {
              $requiresAdjudicator = [math]::Abs([int]$primaryReviewers[0].totalScore - [int]$primaryReviewers[1].totalScore) -gt 2
              foreach ($category in $categoryMaximums.Keys) {
                if ([math]::Abs([int]$primaryReviewers[0].categoryScores.$category - [int]$primaryReviewers[1].categoryScores.$category) -gt 1) { $requiresAdjudicator = $true }
              }
              if ($requiresAdjudicator -and $roles -notcontains 'company_art_direction_adjudicator') { Add-Failure('Reviewer divergence requires company_art_direction_adjudicator') }
            }
            if (@($acceptance.hardBlockers).Count -gt 0) { Add-Failure('Acceptance contains hard blockers') }
            if ([string]$acceptance.verdict -ne 'PASS') { Add-Failure('Acceptance verdict must be PASS') }
            if ([string]$acceptance.scope -ne 'art-direction-handoff') { Add-Failure('Acceptance scope must be art-direction-handoff') }
            if ([string]$artifact.status -ne 'review-ready') { Add-Failure('Only a review-ready artifact can receive independent acceptance') }
            if ($reviewers.Count -ge 2) {
              $minimumScore = ($reviewers | Measure-Object -Property totalScore -Minimum).Minimum
              if ([int]$acceptance.finalScore -ne [int]$minimumScore) { Add-Failure('finalScore must equal the lower reviewer score') }
            }
          }
        }
      }
    }
  }
}

if ($script:Errors.Count -gt 0) {
  [Console]::Error.WriteLine('Art-direction validation FAIL')
  foreach ($failure in $script:Errors) { [Console]::Error.WriteLine("- $failure") }
  exit 1
}

if ([string]::IsNullOrWhiteSpace($CompanySlug)) {
  Write-Output 'Art-direction workflow validation PASS'
}
else {
  Write-Output "Art-direction extraction validation PASS: $CompanySlug"
}
exit 0
