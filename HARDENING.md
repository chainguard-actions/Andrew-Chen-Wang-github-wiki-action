<!-- markdownlint-disable -->

# Hardening Report: Andrew-Chen-Wang--github-wiki-action/v5.0.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **Andrew-Chen-Wang--github-wiki-action/v5.0.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow steps use mutable tag references instead of pinned full-length SHA commits. In test-action.yml, `actions/checkout@v3` is used in every job (5 occurrences). In update-tags.yml, `actions/publish-action@v0.2.2` is used. These tag refs can be silently moved to point to different (potentially malicious) commits without any change to the workflow file.

Locations:

- `.github/workflows/test-action.yml:33`
- `.github/workflows/test-action.yml:44`
- `.github/workflows/test-action.yml:56`
- `.github/workflows/test-action.yml:67`
- `.github/workflows/test-action.yml:80`
- `.github/workflows/update-tags.yml:16`

### unsafe-shell (severity: high)

The `cliw` script downloads a remote install script and pipes it directly to a shell interpreter: `curl -fsSL https://deno.land/x/install/install.sh | chronic sh -s "v1.35.1"`. The `chronic` function is a local wrapper that still executes `sh`, making this effectively `curl | sh`. If the remote URL is compromised or subject to a MITM attack, arbitrary code will execute on the runner.

Locations:

- `cliw:23`

### missing-permissions (severity: medium)

The workflow file `test-action.yml` has no top-level `permissions:` key, and four of its five jobs (`test-action-clone-dry-run`, `test-action-init-dry-run`, `test-action-clone-dry-run-no-empty`, `test-action-init-dry-run-no-empty`) also have no job-level `permissions:` key. This means those jobs run with the default (broad) token permissions rather than minimal required permissions.

Locations:

- `.github/workflows/test-action.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, unsafe-shell

**Notes:**

1. Pinned all 6 unpinned action references: actions/checkout@v3 → @a37ce9120846195fa4ece8f58b268e6043cb2f26 (5 occurrences in test-action.yml) and actions/publish-action@v0.2.2 → @dca2315f75060c81e52b00dfc86b660107013642 (in update-tags.yml). Tags preserved as inline comments. 2. Added `permissions: {}` at the top-level of test-action.yml and to each of the four jobs missing permissions (test-action-clone-dry-run, test-action-init-dry-run, test-action-clone-dry-run-no-empty, test-action-init-dry-run-no-empty). The test-action-real job already had `permissions: contents: write`. 3. Fixed the unsafe curl|sh pattern in cliw by downloading the Deno install script to a mktemp file first, then executing it separately, then removing the temp file — eliminating the pipe-to-shell vulnerability.

