$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$regression = & pwsh -NoProfile -File (Join-Path $root 'scripts\regression.ps1') | ConvertFrom-Json
if ($regression.status -ne 'pass' -or $regression.engines.Count -lt 1) { throw 'Regression suite failed' }
foreach ($engine in @('pwsh','powershell')) {
  if (Get-Command $engine -ErrorAction SilentlyContinue) {
    $result = & pwsh -NoProfile -File (Join-Path $root 'scripts\utf8-wrapper.ps1') -ScriptPath (Join-Path $PSScriptRoot 'probe.ps1') -Engine $engine -ArgumentList '中文参数'
    if (($result -join '') -ne '中文参数') { throw "$engine wrapper argument round-trip failed" }
  }
}
Write-Output 'All tests passed.'
