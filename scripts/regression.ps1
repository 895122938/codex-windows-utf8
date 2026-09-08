[CmdletBinding()]
param([string]$Root = (Join-Path $env:TEMP ('codex-utf8-' + [guid]::NewGuid())))
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $Root -Force | Out-Null
try {
  $file = Join-Path $Root '中文 文件.txt'
  $text = '中文 / 繁體 / 日本語 / 한국어 / emoji 😀'
  [IO.File]::WriteAllText($file, $text, [Text.UTF8Encoding]::new($false))
  [Console]::InputEncoding = [Text.UTF8Encoding]::new($false)
  [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
  $OutputEncoding = [Text.UTF8Encoding]::new($false)
  $PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8'
  $PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
  $read = Get-Content -LiteralPath $file -Raw
  if ($read -ne $text) { throw "UTF-8 read mismatch: $read" }
  $copy = Join-Path $Root '回写.txt'
  Set-Content -LiteralPath $copy -Value $text -Encoding utf8
  $roundtrip = [IO.File]::ReadAllText($copy, [Text.UTF8Encoding]::new($false))
  if ($roundtrip.TrimEnd("`r", "`n") -ne $text) { throw 'UTF-8 write mismatch' }
  [pscustomobject]@{ status='pass'; root=$Root; file=$file; chars=$text.Length } | ConvertTo-Json
} finally { Remove-Item -LiteralPath $Root -Recurse -Force -ErrorAction SilentlyContinue }
