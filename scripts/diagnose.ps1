[CmdletBinding()]
param([switch]$Json)
$ErrorActionPreference = 'Stop'
$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
$powershell = Get-Command powershell -ErrorAction SilentlyContinue
$data = [ordered]@{
  timestamp = (Get-Date).ToString('o')
  os = (Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
  powershell = $PSVersionTable.PSVersion.ToString()
  edition = $PSVersionTable.PSEdition
  pwsh_path = if ($pwsh) { $pwsh.Source } else { $null }
  powershell_5_path = if ($powershell) { $powershell.Source } else { $null }
  code_page = (chcp) -join ' '
  input_encoding = [Console]::InputEncoding.WebName
  output_encoding = [Console]::OutputEncoding.WebName
  output_encoding_codepage = [Console]::OutputEncoding.CodePage
  pipeline_encoding = $OutputEncoding.WebName
  default_parameters = @{}
}
foreach ($k in @('Get-Content:Encoding','Set-Content:Encoding','Add-Content:Encoding','Out-File:Encoding','*:Encoding')) {
  $data.default_parameters[$k] = $PSDefaultParameterValues[$k]
}
if ($Json) { $data | ConvertTo-Json -Depth 5 } else { $data | Format-List }
