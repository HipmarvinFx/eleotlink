<#
patch-earning-visual-dark-mode.ps1

Purpose:
  Fix the Double X / Tetra X diagram card background so it adapts to dark
  mode instead of staying hardcoded white/light, which currently looks
  jarring against an otherwise fully dark-themed page.

  Replaces the hardcoded light gradient background with the theme-aware
  var(--soft) variable (already confirmed defined for both light and dark
  in css/style.css), matching how the Qualification diagram's rects
  already behave correctly in dark mode.

Safety features:
  - Makes a timestamped backup before touching anything.
  - Uses EXACT string matching. If the target text isn't found (already
    changed, or differs), the script stops and reports it - no guessing.
  - Pure single-block replacement, nothing else touched.

Usage:
  Run this from the repo root (C:\Users\user\eleotlink-repo):
    powershell -ExecutionPolicy Bypass -File patch-earning-visual-dark-mode.ps1
#>

$ErrorActionPreference = "Stop"

$targetFile = "css\structure-approved.css"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: $targetFile not found. Run this script from the repo root." -ForegroundColor Red
    exit 1
}

$content = Get-Content -Path $targetFile -Raw

$oldBlock = @"
.approved-earning-copy .earning-visual {
  margin: -2px -2px 18px;
  padding: 10px 8px 4px;
  background: linear-gradient(180deg, rgba(248,250,252,.96), rgba(255,255,255,.98));
  border: 1px solid var(--line-light);
  border-radius: var(--radius-lg);
  overflow-x: auto;
  overflow-y: hidden;
}
"@

$newBlock = @"
.approved-earning-copy .earning-visual {
  margin: -2px -2px 18px;
  padding: 10px 8px 4px;
  background: var(--soft);
  border: 1px solid var(--line-light);
  border-radius: var(--radius-lg);
  overflow-x: auto;
  overflow-y: hidden;
}
"@

if (-not $content.Contains($oldBlock)) {
    Write-Host "ERROR: The expected .earning-visual block was not found (exact match failed)." -ForegroundColor Red
    Write-Host "This likely means the file has already changed since this script was written." -ForegroundColor Yellow
    Write-Host "No changes made. Please check the file manually." -ForegroundColor Yellow
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$targetFile.before-earning-visual-dark-mode-$timestamp"
Copy-Item -Path $targetFile -Destination $backupPath
Write-Host "Backup created: $backupPath" -ForegroundColor Cyan

$updated = $content.Replace($oldBlock, $newBlock)
Set-Content -Path $targetFile -Value $updated -NoNewline

Write-Host "earning-visual background: MATCHED and replaced with var(--soft)." -ForegroundColor Green
Write-Host ""
Write-Host "Review the actual change with:" -ForegroundColor Cyan
Write-Host "  git diff -- $targetFile" -ForegroundColor White
Write-Host ""
Write-Host "Note: this changes ONLY the card background. The Double X / Tetra X SVG" -ForegroundColor Yellow
Write-Host "shapes themselves still use hardcoded hex colors (purple circles, white text)" -ForegroundColor Yellow
Write-Host "and will look the same in both light and dark mode - only the surrounding" -ForegroundColor Yellow
Write-Host "card background will now switch. Check visually that the purple circles" -ForegroundColor Yellow
Write-Host "still have enough contrast against the new dark card background." -ForegroundColor Yellow
Write-Host ""
Write-Host "If anything looks wrong, restore the backup with:" -ForegroundColor Cyan
Write-Host "  Copy-Item '$backupPath' '$targetFile' -Force" -ForegroundColor White
