<!-- markdownlint-disable -->

# Hardening Report: Andrew-Chen-Wang--github-wiki-action/v5.0.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **Andrew-Chen-Wang--github-wiki-action/v5.0.2** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The `cliw` script downloads a remote install script and pipes it directly to a shell interpreter: `curl -fsSL https://deno.land/x/install/install.sh | chronic sh -s "v1.35.1"`. The locally-defined `chronic` function simply executes its arguments (`$@`), making this functionally equivalent to `curl ... | sh`. If the remote URL is compromised or subject to a MITM attack, arbitrary code will execute on the runner.

Locations:

- `cliw:24`

### unpinned-uses (severity: high)

Multiple `uses:` references in workflow files use mutable version tags instead of immutable 40-character SHA digests, making them vulnerable to supply-chain attacks if the referenced tag is moved or overwritten.

- `.github/workflows/test-action.yml`: `actions/checkout@v3` (lines 33, 44, 57, 68, 81)
- `.github/workflows/update-tags.yml`: `actions/publish-action@v0.2.2` (line 15)

Locations:

- `.github/workflows/test-action.yml:33`
- `.github/workflows/test-action.yml:44`
- `.github/workflows/test-action.yml:57`
- `.github/workflows/test-action.yml:68`
- `.github/workflows/test-action.yml:81`
- `.github/workflows/update-tags.yml:15`

### missing-permissions (severity: medium)

`.github/workflows/test-action.yml` has no top-level `permissions:` block, and four of its five jobs (`test-action-clone-dry-run`, `test-action-init-dry-run`, `test-action-clone-dry-run-no-empty`, `test-action-init-dry-run-no-empty`) also have no job-level `permissions:` block. Only the `test-action-real` job defines permissions. Without explicit permissions, jobs inherit the default repository token permissions, which may be broader than necessary.

Locations:

- `.github/workflows/test-action.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, missing-permissions

**Notes:**

1. cliw (unsafe-shell): Replaced `curl ... | chronic sh` pipe pattern with a two-step approach: download the install script to a mktemp file, then execute it separately, then clean up. This prevents arbitrary code execution if the remote URL is compromised.
2. test-action.yml (unpinned-uses): Pinned all 5 `actions/checkout@v3` references to full SHA `a37ce9120846195fa4ece8f58b268e6043cb2f26 # v3`.
3. update-tags.yml (unpinned-uses): Pinned `actions/publish-action@v0.2.2` to full SHA `dca2315f75060c81e52b00dfc86b660107013642 # v0.2.2`.
4. test-action.yml (missing-permissions): Added top-level `permissions: {}` and job-level `permissions: { contents: read }` to the four dry-run jobs that previously had no permissions block. The test-action-real job's existing `permissions: { contents: write }` was preserved.

