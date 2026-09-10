<#
patch-earning-svgs.ps1

Purpose:
  Insert the actual Double X, Tetra X, and Qualification SVG markup into
  earnings.html, replacing the three placeholder HTML comments that were
  left in place by an earlier edit (<!-- Double X SVG goes here --> etc).

Safety features:
  - Makes a timestamped backup copy before touching anything.
  - Uses EXACT string matching for each placeholder comment. If a
    placeholder isn't found (e.g. already replaced, or text differs),
    that specific replacement is skipped and reported - the script
    does not guess or partially corrupt the file.
  - Prints a clear report of what was replaced vs skipped.
  - Never touches git. Run git diff / git commit yourself afterward.

Usage:
  Run this from the repo root (C:\Users\user\eleotlink-repo):
    powershell -ExecutionPolicy Bypass -File patch-earning-svgs.ps1
#>

$ErrorActionPreference = "Stop"

$targetFile = "earnings.html"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: $targetFile not found. Run this script from the repo root." -ForegroundColor Red
    exit 1
}

$content = Get-Content -Path $targetFile -Raw

# --- Placeholder 1: Double X ---
$oldDX = "<!-- Double X SVG goes here -->"
$newDX = @'
<svg viewBox="0 0 380 172" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Double X: you refer two partners">
  <defs>
    <linearGradient id="dxMiniNode" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#4338CA"/>
      <stop offset="1" stop-color="#312E81"/>
    </linearGradient>
  </defs>
  <line x1="190" y1="60" x2="112" y2="96" stroke="#4F46E5" stroke-width="2"/>
  <line x1="190" y1="60" x2="268" y2="96" stroke="#4F46E5" stroke-width="2"/>
  <circle cx="190" cy="36" r="26" fill="url(#dxMiniNode)"/>
  <text x="190" y="41" text-anchor="middle" fill="#fff" font-size="13" font-weight="700" font-family="Inter, sans-serif">YOU</text>
  <circle cx="112" cy="120" r="28" fill="url(#dxMiniNode)"/>
  <text x="112" y="125" text-anchor="middle" fill="#fff" font-size="14" font-weight="700" font-family="Inter, sans-serif">P1</text>
  <circle cx="268" cy="120" r="28" fill="url(#dxMiniNode)"/>
  <text x="268" y="125" text-anchor="middle" fill="#fff" font-size="14" font-weight="700" font-family="Inter, sans-serif">P2</text>
  <text class="cap" x="190" y="164" text-anchor="middle" font-size="13" font-family="Inter, sans-serif">You refer 2 partners, each opens 2 more</text>
</svg>
'@

# --- Placeholder 2: Tetra X ---
$oldTX = "<!-- Tetra X SVG goes here -->"
$newTX = @'
<svg viewBox="0 0 380 172" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Tetra X: you have four direct positions">
  <defs>
    <linearGradient id="txMiniNode" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#4F46E5"/>
      <stop offset="1" stop-color="#312E81"/>
    </linearGradient>
  </defs>
  <line x1="190" y1="60" x2="70" y2="98" stroke="#6366F1" stroke-width="1.6"/>
  <line x1="190" y1="60" x2="157" y2="98" stroke="#6366F1" stroke-width="1.6"/>
  <line x1="190" y1="60" x2="223" y2="98" stroke="#6366F1" stroke-width="1.6"/>
  <line x1="190" y1="60" x2="310" y2="98" stroke="#6366F1" stroke-width="1.6"/>
  <circle cx="190" cy="36" r="24" fill="url(#txMiniNode)"/>
  <text x="190" y="41" text-anchor="middle" fill="#fff" font-size="13" font-weight="700" font-family="Inter, sans-serif">YOU</text>
  <circle cx="70" cy="118" r="20" fill="url(#txMiniNode)"/>
  <circle cx="157" cy="118" r="20" fill="url(#txMiniNode)"/>
  <circle cx="223" cy="118" r="20" fill="url(#txMiniNode)"/>
  <circle cx="310" cy="118" r="20" fill="url(#txMiniNode)"/>
  <text class="cap" x="190" y="164" text-anchor="middle" font-size="13" font-family="Inter, sans-serif">Four direct positions, each with four more</text>
</svg>
'@

# --- Placeholder 3: Qualification ---
$oldQ = "<!-- Qualification SVG goes here -->"
$newQ = @'
<svg viewBox="0 0 380 100" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Qualification flow: activation, referrals, placement, eligible">
  <rect class="step" x="6" y="16" width="80" height="46" rx="10"/>
  <text class="step-label" x="46" y="44" text-anchor="middle" font-size="12" font-weight="700" font-family="Inter, sans-serif">Activation</text>
  <text class="arrow" x="96" y="44" text-anchor="middle" font-size="16" font-family="Inter, sans-serif">&#8250;</text>
  <rect class="step" x="102" y="16" width="80" height="46" rx="10"/>
  <text class="step-label" x="142" y="44" text-anchor="middle" font-size="12" font-weight="700" font-family="Inter, sans-serif">Referrals</text>
  <text class="arrow" x="192" y="44" text-anchor="middle" font-size="16" font-family="Inter, sans-serif">&#8250;</text>
  <rect class="step" x="198" y="16" width="80" height="46" rx="10"/>
  <text class="step-label" x="238" y="44" text-anchor="middle" font-size="12" font-weight="700" font-family="Inter, sans-serif">Placement</text>
  <text class="arrow" x="288" y="44" text-anchor="middle" font-size="16" font-family="Inter, sans-serif">&#8250;</text>
  <rect class="step done" x="294" y="16" width="80" height="46" rx="10"/>
  <text class="step-label done" x="334" y="44" text-anchor="middle" font-size="12" font-weight="700" font-family="Inter, sans-serif">Eligible</text>
</svg>
'@

$replacements = @(
    @{ Name = "Double X"; Old = $oldDX; New = $newDX },
    @{ Name = "Tetra X"; Old = $oldTX; New = $newTX },
    @{ Name = "Qualification"; Old = $oldQ; New = $newQ }
)

$anyFound = $false
foreach ($r in $replacements) {
    if ($content.Contains($r.Old)) { $anyFound = $true }
}

if (-not $anyFound) {
    Write-Host "ERROR: None of the three placeholder comments were found in $targetFile." -ForegroundColor Red
    Write-Host "No changes made. Please check the file manually." -ForegroundColor Yellow
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "_backup-before-earning-svg-insert-$timestamp.html"
Copy-Item -Path $targetFile -Destination $backupPath
Write-Host "Backup created: $backupPath" -ForegroundColor Cyan

$updated = $content
foreach ($r in $replacements) {
    if ($updated.Contains($r.Old)) {
        $updated = $updated.Replace($r.Old, $r.New)
        Write-Host "$($r.Name) SVG: MATCHED and inserted." -ForegroundColor Green
    } else {
        Write-Host "$($r.Name) SVG: placeholder NOT FOUND (skipped)." -ForegroundColor Yellow
    }
}

Set-Content -Path $targetFile -Value $updated -NoNewline

Write-Host ""
Write-Host "Done. Review the actual change with:" -ForegroundColor Cyan
Write-Host "  git diff -- $targetFile" -ForegroundColor White
Write-Host ""
Write-Host "If anything looks wrong, restore the backup with:" -ForegroundColor Cyan
Write-Host "  Copy-Item '$backupPath' '$targetFile' -Force" -ForegroundColor White
