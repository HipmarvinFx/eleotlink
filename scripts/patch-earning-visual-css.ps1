<#
patch-earning-visual-css.ps1

Purpose:
  Safely replace the earning-visual / qualification-visual SVG sizing rules
  in css/structure-approved.css, switching from the old fixed-width
  "min-width: 620px + horizontal scroll" approach to a "shrink-to-fit"
  approach consistent with structure.html.

Safety features:
  - Makes a timestamped backup copy before touching anything.
  - Uses an EXACT string match for the block being replaced. If the file
    doesn't contain that exact text (e.g. it was already changed, or the
    text differs by even one character/whitespace), the script stops and
    tells you instead of guessing or corrupting the file.
  - Prints status for each block so you know exactly what happened.
  - Never touches git. You still run git diff and git commit yourself.

Usage:
  Run this from the repo root (C:\Users\user\eleotlink-repo):
    powershell -ExecutionPolicy Bypass -File patch-earning-visual-css.ps1
#>

$ErrorActionPreference = "Stop"

$targetFile = "css\structure-approved.css"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: $targetFile not found. Run this script from the repo root." -ForegroundColor Red
    exit 1
}

$oldBlock = @"
.approved-earning-copy .earning-visual svg {
  display: block;
  width: 100%;
  min-width: 620px;
  height: auto;
  max-width: none;
}

.approved-earning-copy .qualification-visual svg {
  min-width: 620px;
}
"@

$newBlock = @"
.approved-earning-copy .earning-visual svg {
  display: block;
  width: 100%;
  max-width: 380px;
  height: auto;
  margin: 0 auto;
}
"@

$oldMobileBlock = @"
@media (max-width: 767px) {
  .approved-earning-copy .earning-visual {
    margin: -2px -2px 16px;
    -webkit-overflow-scrolling: touch;
  }
}
"@

$newMobileBlock = @"
@media (max-width: 767px) {
  .approved-earning-copy .earning-visual {
    margin: -2px -2px 16px;
  }
}
"@

$content = Get-Content -Path $targetFile -Raw

$foundMain = $content.Contains($oldBlock)
$foundMobile = $content.Contains($oldMobileBlock)

if (-not $foundMain -and -not $foundMobile) {
    Write-Host "ERROR: Neither target block was found in $targetFile." -ForegroundColor Red
    Write-Host "This likely means the file has already changed since this script was written." -ForegroundColor Yellow
    Write-Host "No changes made. Please check the file manually." -ForegroundColor Yellow
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$targetFile.before-shrink-to-fit-patch-$timestamp"
Copy-Item -Path $targetFile -Destination $backupPath
Write-Host "Backup created: $backupPath" -ForegroundColor Cyan

$updated = $content

if ($foundMain) {
    $updated = $updated.Replace($oldBlock, $newBlock)
    Write-Host "Main SVG sizing block: MATCHED and replaced." -ForegroundColor Green
} else {
    Write-Host "Main SVG sizing block: NOT FOUND (skipped)." -ForegroundColor Yellow
}

if ($foundMobile) {
    $updated = $updated.Replace($oldMobileBlock, $newMobileBlock)
    Write-Host "Mobile overflow-scrolling block: MATCHED and replaced." -ForegroundColor Green
} else {
    Write-Host "Mobile overflow-scrolling block: NOT FOUND (skipped)." -ForegroundColor Yellow
}

Set-Content -Path $targetFile -Value $updated -NoNewline

Write-Host ""
Write-Host "Done. Review the actual change with:" -ForegroundColor Cyan
Write-Host "  git diff -- $targetFile" -ForegroundColor White
Write-Host ""
Write-Host "If anything looks wrong, restore the backup with:" -ForegroundColor Cyan
Write-Host "  Copy-Item '$backupPath' '$targetFile' -Force" -ForegroundColor White
