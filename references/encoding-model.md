# Windows/Codex encoding model

There are four independent boundaries: process arguments, console input/output, PowerShell-to-native pipeline output (`$OutputEncoding`), and file cmdlets. `chcp 65001` only changes the console code page; it does not make Windows PowerShell 5.1 `Get-Content` decode a BOM-less UTF-8 file. PowerShell 5.1 uses the active ANSI code page in that case, while PowerShell 7 defaults to UTF-8.

For Codex, an in-command initializer is more reliable than a user profile because wrappers may pass `-NoProfile` or use encoded commands. A robust initializer sets `[Console]::InputEncoding`, `[Console]::OutputEncoding`, `$OutputEncoding`, and the relevant `$PSDefaultParameterValues` entries. Prefer `-LiteralPath` for model-generated paths and avoid nested command-string quoting.

Primary references:

- https://github.com/openai/codex/issues/23044
- https://github.com/openai/codex/issues/4498
- https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/7.5/Microsoft.PowerShell.Core/About/about_Character_Encoding.md
