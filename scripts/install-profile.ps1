[CmdletBinding(SupportsShouldProcess)]
param(
  [switch]$Uninstall,
  [switch]$AllHosts
)
$ErrorActionPreference = 'Stop'
$marker = '# >>> codex-windows-utf8 >>>'
$end = '# <<< codex-windows-utf8 <<<'
$block = @"
$marker
`$OutputEncoding = [System.Text.UTF8Encoding]::new(`$false)
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new(`$false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(`$false)
`$PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8'
`$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
`$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
`$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$end
"@
$profiles = @($PROFILE.CurrentUserCurrentHost)
if ($AllHosts) { $profiles += $PROFILE.CurrentUserAllHosts }
foreach ($path in ($profiles | Select-Object -Unique)) {
  $dir = Split-Path -Parent $path
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $old = if (Test-Path -LiteralPath $path) { [IO.File]::ReadAllText($path) } else { '' }
  $pattern = '(?ms)\r?\n?' + [regex]::Escape($marker) + '.*?' + [regex]::Escape($end) + '\r?\n?'
  $new = [regex]::Replace($old, $pattern, '')
  if (-not $Uninstall) { $new = $new.TrimEnd() + "`r`n`r`n" + $block.Trim() + "`r`n" }
  if ($PSCmdlet.ShouldProcess($path, $(if($Uninstall){'remove UTF-8 block'}else{'install UTF-8 block'}))) {
    if (Test-Path -LiteralPath $path) { Copy-Item -LiteralPath $path -Destination ($path + '.codex-windows-utf8.bak') -Force }
    [IO.File]::WriteAllText($path, $new, [Text.UTF8Encoding]::new($false))
    Write-Output $path
  }
}
