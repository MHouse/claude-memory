<#
.SYNOPSIS
  Bootstrap the Claude Code cross-project memory system on this machine.

.DESCRIPTION
  Idempotent setup that:

    1. Creates ~/.claude/memory/ if absent.
    2. Seeds ~/.claude/memory/MEMORY.md from MEMORY.md.template if absent.
    3. Creates ~/.claude/CLAUDE.md with a minimal header if absent.
    4. Appends the Cross-project memory section to ~/.claude/CLAUDE.md
       if (and only if) the section isn't already present.

  Re-running is a no-op once the system is in place: nothing is
  duplicated, nothing already on disk is overwritten.

  Run from a clone of MHouse/claude-memory:

    .\bootstrap.ps1

  If PowerShell's execution policy blocks the script, run once via:

    powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1

  Or set the user-scope policy once:

    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

  Script is ASCII-only so it parses cleanly under Windows PowerShell 5.1
  (which reads .ps1 source files as CP-1252).
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot    = $PSScriptRoot
$claudeHome  = Join-Path $env:USERPROFILE '.claude'
$memoryDir   = Join-Path $claudeHome 'memory'
$memoryIndex = Join-Path $memoryDir 'MEMORY.md'
$claudeMd    = Join-Path $claudeHome 'CLAUDE.md'
$template    = Join-Path $repoRoot 'MEMORY.md.template'
$snippet     = Join-Path $repoRoot 'snippets\cross-project-memory-claude-md.md'

if (-not (Test-Path $template)) {
    throw "Template not found at $template -- run this script from a clone of MHouse/claude-memory."
}
if (-not (Test-Path $snippet)) {
    throw "Snippet not found at $snippet -- run this script from a clone of MHouse/claude-memory."
}

$summary = @()

# 1. Memory directory
if (-not (Test-Path $memoryDir)) {
    New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
    $summary += "  created   $memoryDir"
} else {
    $summary += "  exists    $memoryDir"
}

# 2. MEMORY.md index
if (-not (Test-Path $memoryIndex)) {
    Copy-Item -Path $template -Destination $memoryIndex
    $summary += "  created   $memoryIndex (from template)"
} else {
    $summary += "  exists    $memoryIndex (left untouched)"
}

# 3 + 4. CLAUDE.md + section
$sectionMarker  = '## Cross-project memory'
$snippetContent = Get-Content -Path $snippet -Raw -Encoding utf8

$needsAppend = $false
if (-not (Test-Path $claudeMd)) {
    $header = "# Global CLAUDE.md`r`n`r`nPersonal preferences and conventions that apply across all projects.`r`nProject-specific guidance lives in each repo's CLAUDE.md.`r`n"
    Set-Content -Path $claudeMd -Value $header -Encoding utf8 -NoNewline
    $summary += "  created   $claudeMd (with minimal header)"
    $needsAppend = $true
} else {
    $existing = Get-Content -Path $claudeMd -Raw -Encoding utf8
    if ($existing -match [regex]::Escape($sectionMarker)) {
        $summary += "  exists    $claudeMd (section already present, skipping)"
    } else {
        $summary += "  exists    $claudeMd (section missing, appending)"
        $needsAppend = $true
    }
}

if ($needsAppend) {
    $existing = Get-Content -Path $claudeMd -Raw -Encoding utf8
    if (-not $existing) { $existing = '' }
    # Ensure a blank line precedes the new section
    if (-not $existing.EndsWith("`n")) { $existing += "`r`n" }
    if (-not $existing.EndsWith("`n`n") -and -not $existing.EndsWith("`r`n`r`n")) { $existing += "`r`n" }
    $newContent = $existing + $snippetContent
    if (-not $newContent.EndsWith("`n")) { $newContent += "`r`n" }
    Set-Content -Path $claudeMd -Value $newContent -Encoding utf8 -NoNewline
    $summary += "  appended  cross-project memory section to $claudeMd"
}

Write-Host ""
Write-Host "Bootstrap complete."
Write-Host ""
Write-Host "Summary:"
$summary | ForEach-Object { Write-Host $_ }
Write-Host ""
Write-Host "Next steps:"
Write-Host "  - Open ~/.claude/CLAUDE.md and confirm the new section reads well."
Write-Host "  - Optionally seed ~/.claude/memory/user_identity.md (see BOOTSTRAP.md step 4)."
Write-Host "  - Save memories as you work; the system fills itself."
