# Open-source release checklist

- Keep the skill self-contained and free of credentials, machine-specific paths, or private logs.
- Test on Windows PowerShell 5.1 and PowerShell 7+ where both exist.
- Include a diagnosis command, a reversible process-local wrapper, and a regression test.
- Document that the skill does not change system locale or registry settings automatically.
- License code and documentation explicitly; include a changelog and issue template before publishing.
- Redact usernames and local paths from captured diagnostics.
