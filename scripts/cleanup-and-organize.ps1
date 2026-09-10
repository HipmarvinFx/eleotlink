<#
cleanup-and-organize.ps1

Purpose:
  1. Move all timestamped backup files/folders (the *.before-*, *.backup-*,
     _backup-* pattern) out of the repo into a local, git-ignored archive
     folder - keeping them on disk as a safety net, but out of `git status`.
  2. Organize the four patch-*.ps1 scripts into a dedicated scripts/ folder
     so they can be committed as documented, reusable maintenance tooling.
  3. Add/update .gitignore so future backup files made the same way never
     clutter `git status` again.

Safety features:
  - MOVES backups, does not delete them. Nothing is destroyed.
  - Creates the archive folder if it doesn't exist.
  - Skips any file that's already been moved (safe to re-run).
  - Reports exactly what it did/skipped for each file.
  - Does NOT touch git itself (no add/commit/push) - you review and
    run those yourself afterward.

Usage:
  Run this from the repo root (C:\Users\user\eleotlink-repo):
    powershell -ExecutionPolicy Bypass -File cleanup-and-organize.ps1
#>

$ErrorActionPreference = "Stop"

$repoRoot = Get-Location
$archiveFolder = Join-Path $repoRoot "..\eleotlink-local-backups"
$scriptsFolder = Join-Path $repoRoot "scripts"

Write-Host "=== Step 1: Setting up folders ===" -ForegroundColor Cyan

if (-not (Test-Path $archiveFolder)) {
    New-Item -ItemType Directory -Path $archiveFolder | Out-Null
    Write-Host "Created archive folder: $archiveFolder" -ForegroundColor Green
} else {
    Write-Host "Archive folder already exists: $archiveFolder" -ForegroundColor Yellow
}

if (-not (Test-Path $scriptsFolder)) {
    New-Item -ItemType Directory -Path $scriptsFolder | Out-Null
    Write-Host "Created scripts folder: $scriptsFolder" -ForegroundColor Green
} else {
    Write-Host "scripts/ folder already exists" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Step 2: Moving backup files/folders to archive ===" -ForegroundColor Cyan

# Explicit list of known backup items (safer than a broad wildcard match,
# so we don't accidentally sweep up something unexpected).
$backupItems = @(
    "_backup-before-double-x-20260908-104150",
    "_backup-before-earning-svg-insert-20260910-005648.html",
    "_backup-before-earnings-renderings-20260908-184210.html",
    "backup-before-how-it-works-hard-fix-20260908-132223",
    "css\structure-approved.css.before-earning-visual-dark-mode-20260910-012602",
    "css\structure-approved.css.before-final-mobile-20260908-153204",
    "css\structure-approved.css.before-mobile-diagram-fix-20260908-165723",
    "css\structure-approved.css.before-qualification-color-fix-20260910-010024",
    "css\structure-approved.css.before-shrink-to-fit-patch-20260910-005214",
    "css\structure-approved.css.before-text-readability-20260908-172916",
    "css\structure-approved.css.mobile-backup-20260908-145224",
    "css\structure-approved.css.mobile-final-backup-20260908-151105",
    "css\style.css.backup-20260908-163331",
    "css\style.css.before-final-mobile-20260908-153204",
    "css\style.css.before-restore",
    "css\style.css.mobile-backup-20260908-145224",
    "css\style.css.mobile-final-backup-20260908-151105"
)

foreach ($item in $backupItems) {
    if (Test-Path $item) {
        $destName = ($item -replace '[\\/]', '__')
        $dest = Join-Path $archiveFolder $destName
        Move-Item -Path $item -Destination $dest -Force
        Write-Host "Moved: $item" -ForegroundColor Green
    } else {
        Write-Host "Not found (already moved or never existed): $item" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=== Step 3: Organizing patch scripts into scripts/ ===" -ForegroundColor Cyan

$patchScripts = @(
    "patch-earning-svgs.ps1",
    "patch-earning-visual-css.ps1",
    "patch-earning-visual-dark-mode.ps1",
    "patch-qualification-diagram-css.ps1"
)

foreach ($script in $patchScripts) {
    if (Test-Path $script) {
        Move-Item -Path $script -Destination (Join-Path $scriptsFolder $script) -Force
        Write-Host "Moved into scripts/: $script" -ForegroundColor Green
    } else {
        Write-Host "Not found (already moved or never existed): $script" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=== Step 4: Updating .gitignore ===" -ForegroundColor Cyan

$gitignorePath = ".gitignore"
$ignorePatterns = @(
    "",
    "# Local backup snapshots (kept outside the repo, see ../eleotlink-local-backups)",
    "*.before-*",
    "*.backup-*",
    "*.mobile-backup-*",
    "_backup-*",
    "_backup-*/",
    "backup-before-*/",
    "backup-before-*"
)

$existingContent = ""
if (Test-Path $gitignorePath) {
    $existingContent = Get-Content -Path $gitignorePath -Raw
}

$toAdd = @()
foreach ($pattern in $ignorePatterns) {
    if ($pattern -eq "" -or -not $existingContent.Contains($pattern)) {
        $toAdd += $pattern
    }
}

if ($toAdd.Count -gt 1) {
    Add-Content -Path $gitignorePath -Value ($toAdd -join "`n")
    Write-Host ".gitignore updated with backup file patterns." -ForegroundColor Green
} else {
    Write-Host ".gitignore already contains these patterns, nothing added." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host "Backups archived to: $archiveFolder" -ForegroundColor White
Write-Host "Patch scripts moved to: $scriptsFolder" -ForegroundColor White
Write-Host ""
Write-Host "Next: review the result with:" -ForegroundColor Cyan
Write-Host "  git status" -ForegroundColor White
Write-Host ""
Write-Host "You should now see only the 4 modified files, the new scripts/ folder," -ForegroundColor White
Write-Host "and the updated .gitignore - no more loose backup files." -ForegroundColor White
