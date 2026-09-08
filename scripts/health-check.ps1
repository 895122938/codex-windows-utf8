[CmdletBinding()]
param(
  [string]$SkillRoot,
  [switch]$Json
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($SkillRoot)) {
  $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
  $SkillRoot = Split-Path -Parent $scriptDirectory
}

function Add-ItemToList {
  param(
    [System.Collections.ArrayList]$List,
    [object]$Value
  )
  [void]$List.Add($Value)
}

function Invoke-JsonScript {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [hashtable]$Arguments = @{}
  )

  $raw = & $Path @Arguments 2>&1 | Out-String
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  if ($exitCode -ne 0) {
    throw "Script failed ($exitCode): $Path`n$raw"
  }
  return ($raw | ConvertFrom-Json)
}

$errors = New-Object System.Collections.ArrayList
$warnings = New-Object System.Collections.ArrayList
$requiredFiles = @(
  'SKILL.md',
  'scripts/diagnose.ps1',
  'scripts/regression.ps1',
  'scripts/utf8-wrapper.ps1',
  'scripts/install-profile.ps1',
  'scripts/install-skill.ps1',
  'tests/run-tests.ps1'
)

$fileResults = @(
  foreach ($relative in $requiredFiles) {
    $path = Join-Path $SkillRoot ($relative -replace '/', '\')
    [pscustomobject]@{
      path = $relative
      present = Test-Path -LiteralPath $path -PathType Leaf
    }
  }
)
$missingFiles = @($fileResults | Where-Object { -not $_.present } | ForEach-Object { $_.path })
if ($missingFiles.Count -gt 0) {
  Add-ItemToList $errors ("Missing required files: " + ($missingFiles -join ', '))
}

$codexHome = if ([string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
  Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
} else {
  $env:CODEX_HOME
}
$globalSkillRoot = Join-Path $codexHome 'skills/codex-windows-utf8'
$globalSkillInstalled = Test-Path -LiteralPath (Join-Path $globalSkillRoot 'SKILL.md') -PathType Leaf
if (-not $globalSkillInstalled) {
  Add-ItemToList $warnings ("Global Skill is not installed at $globalSkillRoot")
}

$diagnosis = $null
try {
  $diagnosis = Invoke-JsonScript -Path (Join-Path $SkillRoot 'scripts/diagnose.ps1') -Arguments @{ Json = $true }
} catch {
  Add-ItemToList $errors $_.Exception.Message
}

$regression = $null
try {
  $regression = Invoke-JsonScript -Path (Join-Path $SkillRoot 'scripts/regression.ps1')
} catch {
  Add-ItemToList $errors $_.Exception.Message
}

$codex = Get-Command codex -ErrorAction SilentlyContinue
$doctorExitCode = $null
$doctorConfigLoaded = $null
$featureLines = [ordered]@{
  powershell_utf8 = $null
  powershell_shell_version = $null
}
if ($codex) {
  try {
    $doctorOutput = (& $codex.Source doctor --summary --no-color 2>&1 | Out-String)
    $doctorExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
    $doctorConfigLoaded = $doctorOutput -match '(?im)config\s+loaded'
    if (-not $doctorConfigLoaded) {
      Add-ItemToList $warnings 'codex doctor did not report config loaded'
    }
    if ($doctorExitCode -ne 0) {
      Add-ItemToList $warnings ("codex doctor exited with code $doctorExitCode; inspect doctor output separately for environment warnings")
    }
  } catch {
    Add-ItemToList $warnings $_.Exception.Message
  }
  try {
    $featureOutput = (& $codex.Source features list 2>&1 | Out-String)
    foreach ($featureName in @('powershell_utf8', 'powershell_shell_version')) {
      $featureLine = $featureOutput -split "`r?`n" |
        Where-Object { $_ -match "^\s*$featureName\s+" } |
        Select-Object -First 1
      if ($featureLine) { $featureLines[$featureName] = $featureLine.Trim() }
    }
  } catch {
    Add-ItemToList $warnings $_.Exception.Message
  }
} else {
  Add-ItemToList $warnings 'codex executable was not found on PATH'
}

$regressionPass = $null -ne $regression -and $regression.status -eq 'pass'
$status = if ($errors.Count -eq 0 -and $regressionPass) { 'pass' } else { 'fail' }
$report = [ordered]@{
  status = $status
  timestamp = (Get-Date).ToString('o')
  skill_root = $SkillRoot
  global_skill_root = $globalSkillRoot
  global_skill_installed = $globalSkillInstalled
  required_files = $fileResults
  diagnosis = $diagnosis
  regression = $regression
  codex = [ordered]@{
    available = [bool]$codex
    path = if ($codex) { $codex.Source } else { $null }
    doctor_exit_code = $doctorExitCode
    doctor_config_loaded = $doctorConfigLoaded
    feature_lines = $featureLines
  }
  warnings = @($warnings)
  errors = @($errors)
}

if ($Json) {
  $report | ConvertTo-Json -Depth 10
} else {
  [pscustomobject]@{
    status = $report.status
    skill_root = $report.skill_root
    global_skill_installed = $report.global_skill_installed
    regression = if ($regression) { $regression.status } else { 'not-run' }
    codex_available = $report.codex.available
    doctor_config_loaded = $report.codex.doctor_config_loaded
    warnings = ($warnings -join ' | ')
    errors = ($errors -join ' | ')
  } | Format-List
}

if ($status -ne 'pass') { exit 1 }
