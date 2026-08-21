# Build result/layout/total/portfolio.pdf from every company-neutral page layout.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File result/layout/total/build-total.ps1
#
# Two Windows-specific details are handled here:
#  * git and python emit UTF-8, but Windows PowerShell decodes native output with the console
#    codepage, which corrupts this repository's non-ASCII path. OutputEncoding is set to UTF-8.
#  * headless Chrome cannot write --print-to-pdf to a path containing non-ASCII characters, so the
#    PDF is produced in the temp directory and copied into place afterwards.

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

Write-Output 'Assembling total.html ...'
Push-Location $repoRoot
try { & python (Join-Path $here 'build-total.py') }
finally { Pop-Location }

$browserCandidates = @(
  'C:\Program Files\Google\Chrome\Application\chrome.exe',
  'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
  'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
  'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
)
$browser = $browserCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $browser) { throw 'Chrome or Edge was not found in a standard Windows install path.' }

$sourceUri = ([Uri](Resolve-Path -LiteralPath (Join-Path $here 'total.html')).Path).AbsoluteUri
$stagePdf = Join-Path ([IO.Path]::GetTempPath()) ('portfolio-' + [Guid]::NewGuid().ToString('N') + '.pdf')
$profileDir = Join-Path ([IO.Path]::GetTempPath()) ('portfolio-pdf-' + [Guid]::NewGuid().ToString('N'))

Write-Output 'Printing to PDF ...'
& $browser --headless=new --disable-gpu --no-pdf-header-footer `
  --run-all-compositor-stages-before-draw --virtual-time-budget=15000 `
  "--print-to-pdf=$stagePdf" "--user-data-dir=$profileDir" $sourceUri | Out-Null

if (-not (Test-Path -LiteralPath $stagePdf)) { throw "Chrome did not produce $stagePdf" }

$finalPdf = Join-Path $here 'portfolio.pdf'
Copy-Item -LiteralPath $stagePdf -Destination $finalPdf -Force
Remove-Item -LiteralPath $stagePdf -Force
Remove-Item -LiteralPath $profileDir -Recurse -Force -ErrorAction SilentlyContinue

$size = (Get-Item -LiteralPath $finalPdf).Length
Write-Output ("Wrote {0} ({1:N0} bytes)" -f $finalPdf, $size)
