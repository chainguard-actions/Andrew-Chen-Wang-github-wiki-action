<!-- markdownlint-disable -->

# Hardening Report: Andrew-Chen-Wang--github-wiki-action/v5.0.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **Andrew-Chen-Wang--github-wiki-action/v5.0.6** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Workflow files reference external actions using mutable tag-based refs instead of pinned full-length SHA digests. This exposes the workflow to supply-chain attacks if the tag is moved or the upstream repo is compromised. Failing references: test-action.yml uses actions/checkout@v4 and denoland/setup-deno@v2; update-tags.yml uses actions/publish-action@v0.2.2.

Locations:

- `.github/workflows/test-action.yml:34`
- `.github/workflows/test-action.yml:35`
- `.github/workflows/update-tags.yml:15`

### missing-permissions (severity: medium)

test-action.yml has no top-level permissions: key, and five of its six jobs (test-cli, test-action-clone-dry-run, test-action-init-dry-run, test-action-clone-dry-run-no-empty, test-action-init-dry-run-no-empty) also have no job-level permissions: block. Without explicit permissions, GitHub grants the default token permissions (which may be write for some scopes), violating the principle of least privilege.

Locations:

- `.github/workflows/test-action.yml:1`

### unsafe-shell (severity: high)

The cliw script downloads a remote install script and pipes it directly to a shell interpreter: `curl -fsSL https://deno.land/install.sh | chronic sh -s "v2.8.3"`. The chronic() wrapper still passes the downloaded content to sh for execution. This pattern allows a compromised or MITM'd remote server to execute arbitrary code on the runner without any integrity verification.

Locations:

- `cliw:22`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, unsafe-shell

**Notes:**

1. Pinned all unpinned action references to full commit SHAs: actions/checkout@v4 → 34e114876b0b11c390a56381ad16ebd13914f8d5, denoland/setup-deno@v2 → 22d081ff2d3a40755e97629de92e3bcbfa7cf2ed, actions/publish-action@v0.2.2 → dca2315f75060c81e52b00dfc86b660107013642. 2. Added top-level `permissions: {}` to test-action.yml and explicit `permissions: {}` to the five jobs lacking permissions blocks (test-cli, test-action-clone-dry-run, test-action-init-dry-run, test-action-clone-dry-run-no-empty, test-action-init-dry-run-no-empty); the test-action-real job retains its existing `contents: write` permission needed for wiki pushes. 3. Fixed the unsafe curl-pipe-to-shell pattern in cliw by downloading the install script to a temp file first (`curl -fsSL -o "$_install_script"`), then executing it separately (`chronic sh "$_install_script" -s "v2.8.3"`), then cleaning up the temp file.

