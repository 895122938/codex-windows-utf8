[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$SourceRoot = (Split-Path -Parent $PSScriptRoot),
  [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' })
)
$ErrorActionPreference = 'Stop'
$skillName = 'codex-windows-utf8'
$source = Join-Path $SourceRoot $skillName
if (-not (Test-Path -LiteralPath (Join-Path $SourceRoot 'SKILL.md'))) {
  $source = $SourceRoot
}
if (-not (Test-Path -LiteralPath (Join-Path $source 'SKILL.md'))) { throw "Skill source not found: $source" }
$destination = Join-Path (Join-Path $CodexHome 'skills') $skillName
if ($PSCmdlet.ShouldProcess($destination, 'install Codex Skill')) {
  New-Item -ItemType Directory -Path $destination -Force | Out-Null
  Get-ChildItem -LiteralPath $source -Force | Copy-Item -Destination $destination -Recurse -Force
  Write-Output $destination
}
