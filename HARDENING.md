<!-- markdownlint-disable -->

# Hardening Report: Andrew-Chen-Wang--github-wiki-action/v5.0.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **Andrew-Chen-Wang--github-wiki-action/v5.0.4** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The `cliw` shell script downloads a remote install script and pipes it directly to a shell interpreter: `curl -fsSL https://deno.land/x/install/install.sh | chronic sh -s "v1.35.1"`. The `chronic` function is a local wrapper that still executes its arguments (here `sh -s "v1.35.1"`) with the piped content from curl as stdin. This is a classic curl-pipe-to-shell pattern — if the remote URL (deno.land) is compromised or the download is intercepted (e.g. via MITM), arbitrary code will execute on the runner. The script should instead download to a temporary file, verify its integrity (e.g. via a checksum), and only then execute it.

Locations:

- `cliw:23`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

Fixed the curl-pipe-to-shell pattern in `cliw` at line 23. The original `curl -fsSL https://deno.land/x/install/install.sh | chronic sh -s "v1.35.1"` was replaced with a safe pattern that: (1) creates a temp file with `mktemp` and sets up a cleanup trap, (2) downloads the install script to the temp file using `curl -fsSL -o "$install_script"` with a pinned immutable commit URL on GitHub (commit 1f1d6faeaf3a58b6709d34bbaf8af51ec56ff566 of denoland/deno_install) instead of the mutable deno.land CDN URL, (3) verifies the downloaded file is non-empty and passes `sh -n` syntax validation before executing, (4) executes the script from the temp file with `chronic sh "$install_script" -s "v1.35.1"`, and (5) removes the temp file after execution. The pipe-to-shell pattern is completely eliminated and the script works correctly at runtime.

