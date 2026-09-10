<#
patch-qualification-diagram-css.ps1

Purpose:
  Append the missing color/fill CSS rules for the Qualification diagram
  (.qualification-visual rect.step, text.step-label, etc.) to the end of
  css/structure-approved.css. Without these rules, the SVG's <rect> and
  <text> elements fall back to SVG defaults (black fill), making the
  diagram render as solid black boxes with invisible text.

Safety features:
  - Makes a timestamped backup before touching anything.
  - Checks whether these rules already exist; if so, does nothing and
    tells you (avoids creating duplicate CSS blocks).
  - Pure append - does not modify or remove any existing lines.

Usage:
  Run this from the repo root (C:\Users\user\eleotlink-repo):
    powershell -ExecutionPolicy Bypass -File patch-qualification-diagram-css.ps1
#>

$ErrorActionPreference = "Stop"

$targetFile = "css\structure-approved.css"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: $targetFile not found. Run this script from the repo root." -ForegroundColor Red
    exit 1
}

$content = Get-Content -Path $targetFile -Raw

$marker = "qualification-visual rect.step"
if ($content.Contains($marker)) {
    Write-Host "These rules already appear to exist in $targetFile (found '$marker')." -ForegroundColor Yellow
    Write-Host "No changes made, to avoid creating a duplicate block." -ForegroundColor Yellow
    Write-Host "If the diagram is still rendering black, check the existing rule manually." -ForegroundColor Yellow
    exit 0
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$targetFile.before-qualification-color-fix-$timestamp"
Copy-Item -Path $targetFile -Destination $backupPath
Write-Host "Backup created: $backupPath" -ForegroundColor Cyan

$addition = @'


/* Qualification diagram fills - fixes rects/text rendering as solid black */
.earning-visual text.cap {
  fill: var(--muted);
}
.qualification-visual rect.step {
  fill: var(--soft);
  stroke: var(--line);
  stroke-width: 1;
}
.qualification-visual text.step-label {
  fill: var(--ink);
}
.qualification-visual rect.step.done {
  fill: rgba(16,185,129,.12);
  stroke: rgba(16,185,129,.35);
}
.qualification-visual text.step-label.done {
  fill: var(--emerald-dark);
}
.qualification-visual text.arrow {
  fill: var(--muted-light);
}
'@

Add-Content -Path $targetFile -Value $addition -NoNewline

Write-Host "CSS block appended successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Review the actual change with:" -ForegroundColor Cyan
Write-Host "  git diff -- $targetFile" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: this uses CSS variables (--soft, --line, --ink, --emerald-dark, --muted-light)." -ForegroundColor Yellow
Write-Host "If any of these are not defined elsewhere in your stylesheet, that specific rule will" -ForegroundColor Yellow
Write-Host "silently fall back to a default instead of erroring - check the rendered result visually." -ForegroundColor Yellow
Write-Host ""
Write-Host "If anything looks wrong, restore the backup with:" -ForegroundColor Cyan
Write-Host "  Copy-Item '$backupPath' '$targetFile' -Force" -ForegroundColor White
