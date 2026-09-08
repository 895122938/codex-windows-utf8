[CmdletBinding()]
param(
  [string]$Root = (Join-Path $env:TEMP ('codex-utf8-' + [guid]::NewGuid())),
  [switch]$KeepArtifacts
)
$ErrorActionPreference = 'Stop'
$expected = '中文 / 繁體 / 日本語 / 한국어 / emoji 😀'
$specialDir = Join-Path $Root '中文 空格 & 括号(测试)'
$inputFile = Join-Path $specialDir '无BOM 输入.txt'
$worker = Join-Path $Root 'worker.ps1'
New-Item -ItemType Directory -Path $specialDir -Force | Out-Null
[IO.File]::WriteAllText($inputFile, $expected, (New-Object Text.UTF8Encoding($false)))
$workerBody = @'
param([string]$InputFile, [string]$Expected)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8
$PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$read = Get-Content -LiteralPath $InputFile -Raw
if ($read -ne $Expected) { throw 'BOM-less UTF-8 read mismatch' }
$outputFile = Join-Path (Split-Path -Parent $InputFile) '回写 结果.txt'
Set-Content -LiteralPath $outputFile -Value $Expected -Encoding utf8
$roundtrip = [IO.File]::ReadAllText($outputFile, $utf8).TrimEnd("`r", "`n")
if ($roundtrip -ne $Expected) { throw 'UTF-8 write mismatch' }
[pscustomobject]@{
  status = 'pass'
  edition = $PSVersionTable.PSEdition
  version = $PSVersionTable.PSVersion.ToString()
  input = [Console]::InputEncoding.WebName
  output = [Console]::OutputEncoding.WebName
  path = $InputFile
} | ConvertTo-Json -Compress
'@
[IO.File]::WriteAllText($worker, $workerBody, (New-Object Text.UTF8Encoding($true)))
$engines = @()
foreach ($name in @('pwsh','powershell')) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  if ($cmd -and $engines.Source -notcontains $cmd.Source) { $engines += $cmd }
}
$results = @()
try {
  foreach ($engine in $engines) {
    $raw = & $engine.Source -NoLogo -NoProfile -NonInteractive -File $worker $inputFile $expected
    if ($LASTEXITCODE -ne 0) { throw "$($engine.Name) regression failed with exit code $LASTEXITCODE" }
    $results += ($raw | ConvertFrom-Json)
  }
  [pscustomobject]@{ status='pass'; engines=$results; root=$Root } | ConvertTo-Json -Depth 5
} finally {
  if (-not $KeepArtifacts) { Remove-Item -LiteralPath $Root -Recurse -Force -ErrorAction SilentlyContinue }
}
