# Codex Windows UTF-8

[![Windows UTF-8 regression](https://github.com/895122938/codex-windows-utf8/actions/workflows/windows.yml/badge.svg)](https://github.com/895122938/codex-windows-utf8/actions/workflows/windows.yml)

A Codex Skill and small PowerShell toolkit for diagnosing and hardening Windows shell execution when UTF-8, Chinese/Japanese/Korean paths, or native-command output are unreliable.

## What it does

- Diagnoses the active PowerShell, code page, console encodings, pipeline encoding, and file-cmdlet defaults.
- Runs a regression test with CJK filenames and BOM-less UTF-8 content.
- Provides a process-local UTF-8 wrapper instead of changing the system locale or registry.

## Install as a global Codex Skill

Copy this folder to `%USERPROFILE%\\.codex\\skills\\codex-windows-utf8` (or to `%CODEX_HOME%\\skills\\codex-windows-utf8` when `CODEX_HOME` is set), then restart Codex if it does not discover the skill immediately.

From a cloned checkout, preview the installer first:

```powershell
pwsh -NoProfile -File .\\scripts\\install-skill.ps1 -WhatIf
```

## Verify

```powershell
pwsh -NoProfile -File .\\scripts\\diagnose.ps1 -Json
pwsh -NoProfile -File .\\scripts\\regression.ps1
```

Run the complete local test suite:

```powershell
pwsh -NoProfile -File .\\tests\\run-tests.ps1
```

The regression suite tests every locally available PowerShell edition, including Windows PowerShell 5.1 and PowerShell 7+, under `-NoProfile`.

For an interactive PowerShell profile, preview the reversible change first:

```powershell
pwsh -NoProfile -File .\\scripts\\install-profile.ps1 -WhatIf
```

Only run without `-WhatIf` when you explicitly want the profile change. Existing profiles are copied to a `.codex-windows-utf8.bak` file; uninstall with `-Uninstall`.

The toolkit does not change the Windows system locale, registry, or user profile automatically. Codex integration changes must be validated against the actual tool-execution path, including any `-NoProfile` or encoded-command wrapper.

## Codex integration status

An upstream experimental `powershell_utf8` flag was proposed in Codex issue #7290, but the current Codex CLI 0.153.4 feature registry does not expose that key. This project therefore does not enable an unrecognized flag. When a future Codex build exposes a supported UTF-8 or shell-version setting, add it only after verifying it with `codex features list` and `codex doctor`.

## Why this exists

Windows PowerShell 5.1 can read a BOM-less UTF-8 file using the active ANSI code page, while PowerShell 7 defaults to UTF-8. Codex wrappers may also bypass user profiles. See the references in `references/encoding-model.md` for upstream issue links and Microsoft documentation.

## License

MIT. See [LICENSE](LICENSE).
