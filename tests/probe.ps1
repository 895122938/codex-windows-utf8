param([string]$Message)
if ([Console]::InputEncoding.WebName -ne 'utf-8') { throw 'Input encoding is not UTF-8' }
if ([Console]::OutputEncoding.WebName -ne 'utf-8') { throw 'Output encoding is not UTF-8' }
if ($OutputEncoding.WebName -ne 'utf-8') { throw 'Pipeline encoding is not UTF-8' }
Write-Output $Message
