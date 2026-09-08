---
name: codex-windows-utf8
description: Diagnose and harden Codex Windows PowerShell execution for UTF-8, CJK paths, file content, and native-command output; use when shell commands or Chinese characters are unreliable on Windows.
---

# Codex Windows UTF-8

Use this skill for Windows Codex shell diagnostics and remediation. Treat encoding as an end-to-end protocol, not a display-only setting.

## Safety and scope

- Start with a read-only diagnosis using `scripts/diagnose.ps1`.
- Never change the system locale, registry, or global PowerShell profile automatically.
- Prefer a process-local wrapper and explicit UTF-8 settings. Preserve a backup before editing any user file.
- Report whether the active path is `pwsh.exe` 7+ or Windows PowerShell 5.1 and whether `-NoProfile` is in effect.

## Workflow

1. Run `scripts/diagnose.ps1 -Json` and capture the actual executable, code pages, console encodings, `$OutputEncoding`, and default file encodings.
2. Run `scripts/regression.ps1` in a temporary directory. It must cover CJK filenames, BOM-less UTF-8 reads/writes, pipelines, quoting, and both PowerShell editions when available. For one auditable report that also checks the Skill files and Codex configuration, run `scripts/health-check.ps1 -Json`.
3. If the tests fail, use `scripts/utf8-wrapper.ps1` for process-local execution. It initializes input/output and file cmdlet defaults before invoking the requested script.
4. Prefer PowerShell 7+ when available. If 5.1 is unavoidable, keep the explicit initialization in the wrapper; do not rely on a profile because Codex may use `-NoProfile`.
5. For interactive shells, offer `scripts/install-profile.ps1 -WhatIf` first, then install only with explicit user authorization. The script backs up an existing profile and supports `-Uninstall`.
6. For Codex integration changes, verify the wrapper invocation and rerun the regression suite. Do not claim a global fix until the actual Codex tool path passes the same tests. A Skill cannot replace Codex's internal shell executable; distinguish skill guidance, profile configuration, and app-server fixes.

Read [references/encoding-model.md](references/encoding-model.md) when explaining root causes or reviewing a proposed Codex wrapper change. Read [references/opensource-checklist.md](references/opensource-checklist.md) when packaging or publishing this skill.
