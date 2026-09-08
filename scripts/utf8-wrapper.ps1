[CmdletBinding()]
param(
  [Parameter(Mandatory=$true, Position=0)][string]$ScriptPath,
  [string[]]$ArgumentList = @(),
  [ValidateSet('pwsh','powershell')][string]$Engine = 'pwsh'
)
$ErrorActionPreference = 'Stop'
[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) { throw "Script not found: $ScriptPath" }
& $ScriptPath @ArgumentList
exit $LASTEXITCODE
