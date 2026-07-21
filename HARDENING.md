<!-- markdownlint-disable -->

# Hardening Report: Andrew-Chen-Wang--github-wiki-action/v5.0.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **Andrew-Chen-Wang--github-wiki-action/v5.0.6** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The `cliw` supporting script (executed by action.yml's `run:` step) downloads and pipes a remote install script directly to a shell interpreter without first saving it to disk: `curl -fsSL https://deno.land/install.sh | chronic sh -s "v2.8.3"`. If the remote URL is compromised or subject to a MITM attack, arbitrary code would be executed on the runner.

Locations:

- `cliw:22`

### unpinned-uses (severity: high)

Multiple `uses:` references in workflow files are pinned to mutable tags or version strings rather than immutable 40-character commit SHAs, making them vulnerable to supply-chain attacks if the referenced tag is moved or overwritten. Unpinned references found:
- `.github/workflows/test-action.yml`: `actions/checkout@v4` (multiple jobs), `denoland/setup-deno@v2`
- `.github/workflows/update-tags.yml`: `actions/publish-action@v0.2.2`

Locations:

- `.github/workflows/test-action.yml:35`
- `.github/workflows/test-action.yml:36`
- `.github/workflows/update-tags.yml:15`

### missing-permissions (severity: medium)

`.github/workflows/test-action.yml` has no top-level `permissions:` key, and five of its six jobs (`test-cli`, `test-action-clone-dry-run`, `test-action-init-dry-run`, `test-action-clone-dry-run-no-empty`, `test-action-init-dry-run-no-empty`) also have no job-level `permissions:` block. Only the `test-action-real` job defines `permissions: contents: write`. Without explicit permissions, jobs inherit the default repository permissions, which may be broader than necessary.

Locations:

- `.github/workflows/test-action.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, missing-permissions

**Notes:**

1. unsafe-shell (cliw): Replaced `curl ... | chronic sh` pipe pattern with a safe two-step approach: download install script to a mktemp file, execute it separately, then remove it. 2. unpinned-uses: Pinned all mutable action references to full 40-char SHAs — actions/checkout@v4→11d5960a..., denoland/setup-deno@v2→22d081ff..., actions/publish-action@v0.2.2→dca2315f... — with original tags preserved as inline comments. 3. missing-permissions: Added top-level `permissions: {}` to test-action.yml and added `permissions: {}` to each of the five jobs that lacked explicit permissions blocks (test-cli, test-action-clone-dry-run, test-action-init-dry-run, test-action-clone-dry-run-no-empty, test-action-init-dry-run-no-empty); the test-action-real job's existing `permissions: contents: write` was preserved.

