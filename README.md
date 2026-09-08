# Codex Windows UTF-8

A Codex Skill and small PowerShell toolkit for diagnosing and hardening Windows shell execution when UTF-8, Chinese/Japanese/Korean paths, or native-command output are unreliable.

## What it does

- Diagnoses the active PowerShell, code page, console encodings, pipeline encoding, and file-cmdlet defaults.
- Runs a regression test with CJK filenames and BOM-less UTF-8 content.
- Provides a process-local UTF-8 wrapper instead of changing the system locale or registry.

## Install as a global Codex Skill

Copy this folder to `%USERPROFILE%\\.codex\\skills\\codex-windows-utf8` (or to `%CODEX_HOME%\\skills\\codex-windows-utf8` when `CODEX_HOME` is set), then restart Codex if it does not discover the skill immediately.

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

## Codex feature flag

Recent Codex builds expose the upstream experimental Windows UTF-8 path. Enable it in `%USERPROFILE%\\.codex\\config.toml`:

```toml
[features]
powershell_utf8 = true
```

Or for a one-off CLI run:

```powershell
codex --enable powershell_utf8
```

This is the preferred integration path when the installed Codex version recognizes the flag. Keep the wrapper and tests because Skills and older builds may still execute through a separate shell path.

## Why this exists

Windows PowerShell 5.1 can read a BOM-less UTF-8 file using the active ANSI code page, while PowerShell 7 defaults to UTF-8. Codex wrappers may also bypass user profiles. See the references in `references/encoding-model.md` for upstream issue links and Microsoft documentation.

## License

MIT. See [LICENSE](LICENSE).
