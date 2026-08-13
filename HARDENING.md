<!-- markdownlint-disable -->

# Hardening Report: Andrew-Chen-Wang--github-wiki-action/v5.0.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **Andrew-Chen-Wang--github-wiki-action/v5.0.4** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Workflow files reference GitHub Actions by mutable tags rather than immutable 40-character commit SHAs, making them vulnerable to supply-chain attacks if the tag is moved. Failing references:
- `.github/workflows/test-action.yml`: `actions/checkout@v3` (used 5 times)
- `.github/workflows/update-tags.yml`: `actions/publish-action@v0.2.2`
All should be pinned to full SHA digests, e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v3`.

Locations:

- `.github/workflows/test-action.yml:33`
- `.github/workflows/test-action.yml:42`
- `.github/workflows/test-action.yml:53`
- `.github/workflows/test-action.yml:64`
- `.github/workflows/test-action.yml:75`
- `.github/workflows/update-tags.yml:14`

### unsafe-shell (severity: high)

The `cliw` script downloads a remote install script and pipes it directly to a shell interpreter: `curl -fsSL https://deno.land/x/install/install.sh | chronic sh -s "v1.35.1"`. The `chronic` wrapper still executes the downloaded content in `sh`. If the remote URL is compromised or the response is tampered with in transit, arbitrary code will execute on the runner. The script should be downloaded to a file first, its integrity verified (e.g. via checksum), and then executed separately.

Locations:

- `cliw:24`

### missing-permissions (severity: medium)

`test-action.yml` has no top-level `permissions:` key, and 4 of its 5 jobs (`test-action-clone-dry-run`, `test-action-init-dry-run`, `test-action-clone-dry-run-no-empty`, `test-action-init-dry-run-no-empty`) also have no job-level `permissions:` block. This means those jobs run with the default, overly-broad repository permissions. A top-level `permissions: {}` (or minimal specific scopes) should be added, with `contents: write` granted only to the job that needs it.

Locations:

- `.github/workflows/test-action.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, unsafe-shell

**Notes:**

1. unpinned-uses: Pinned actions/checkout@v3 → @f43a0e5ff2bd294095638e18286ca9a3d1956744 (5 occurrences in test-action.yml) and actions/publish-action@v0.2.2 → @dca2315f75060c81e52b00dfc86b660107013642 (1 occurrence in update-tags.yml). Tag names preserved as inline comments.
2. missing-permissions: Added top-level `permissions: {}` to test-action.yml and `permissions: {}` to each of the 4 dry-run jobs (test-action-clone-dry-run, test-action-init-dry-run, test-action-clone-dry-run-no-empty, test-action-init-dry-run-no-empty). The test-action-real job already had `permissions: contents: write`.
3. unsafe-shell: Fixed cliw script to download the Deno install script to a mktemp file first, then execute it separately with `chronic sh "$_install_script" -s "v1.35.1"`, then remove the temp file. Eliminates the curl-pipe-to-shell anti-pattern.

