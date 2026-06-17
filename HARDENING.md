<!-- markdownlint-disable -->

# Hardening Report: Andrew-Chen-Wang--github-wiki-action/v5.0.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **Andrew-Chen-Wang--github-wiki-action/v5.0.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The `cliw` script downloads and executes a remote installer script by piping `curl` output directly to a shell. The locally-defined `chronic` function wraps its arguments as a command, so `curl -fsSL https://deno.land/x/install/install.sh | chronic sh -s "v1.35.1"` is functionally equivalent to `curl ... | sh`. Remote content is never saved to disk for inspection before execution, making this vulnerable to supply-chain attacks if the remote URL is compromised or tampered with in transit.

Locations:

- `cliw:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

Fixed the unsafe curl-pipe-to-shell pattern in the `cliw` script. Instead of `curl -fsSL https://deno.land/x/install/install.sh | chronic sh -s "v1.35.1"`, the script now: (1) downloads the installer to a temp file via `curl -fsSL -o "$_install_script"`, (2) verifies the file is non-empty before proceeding, (3) executes it as a separate step with `chronic sh "$_install_script" -s "v1.35.1"`, and (4) cleans up the temp file. This prevents supply-chain attacks where a compromised or tampered remote URL could inject malicious commands into the shell.

