[CmdletBinding()]
param(
  [Parameter(Mandatory=$true, Position=0)][string]$ScriptPath,
  [string[]]$ArgumentList = @(),
  [ValidateSet('pwsh','powershell')][string]$Engine = 'pwsh'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) { throw "Script not found: $ScriptPath" }
$command = Get-Command $Engine -ErrorAction Stop
$bootstrap = Join-Path ([IO.Path]::GetTempPath()) ('codex-windows-utf8-' + [guid]::NewGuid() + '.ps1')
$body = @'
param([string]$TargetScript, [Parameter(ValueFromRemainingArguments=$true)][string[]]$RemainingArguments)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8
$PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
& $TargetScript @RemainingArguments
if ($null -ne $LASTEXITCODE) { exit $LASTEXITCODE }
if (-not $?) { exit 1 }
'@
try {
  # UTF-8 BOM keeps the bootstrap source readable by Windows PowerShell 5.1.
  [IO.File]::WriteAllText($bootstrap, $body, (New-Object Text.UTF8Encoding($true)))
  & $command.Source -NoLogo -NoProfile -NonInteractive -File $bootstrap $ScriptPath @ArgumentList
  exit $LASTEXITCODE
} finally {
  Remove-Item -LiteralPath $bootstrap -Force -ErrorAction SilentlyContinue
}
