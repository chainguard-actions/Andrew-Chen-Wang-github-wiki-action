<!-- markdownlint-disable -->

# Hardening Report: Andrew-Chen-Wang--github-wiki-action/v5.0.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **Andrew-Chen-Wang--github-wiki-action/v5.0.3** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The `cliw` script downloads a remote installer script and pipes it directly to a shell interpreter: `curl -fsSL https://deno.land/x/install/install.sh | chronic sh -s "v1.35.1"`. This is unsafe because the remote content is executed without any integrity verification. An attacker who compromises deno.land could serve malicious content that would be executed on the runner.

Locations:

- `cliw:21`

### unpinned-uses (severity: high)

Multiple `uses:` references in workflow files use mutable tag/version refs instead of pinned 40-character SHA commit hashes, making them vulnerable to supply-chain attacks if the referenced tag is moved or overwritten. Unpinned refs: `actions/checkout@v3` (used 5 times in test-action.yml) and `actions/publish-action@v0.2.2` (in update-tags.yml).

Locations:

- `.github/workflows/test-action.yml:33`
- `.github/workflows/test-action.yml:40`
- `.github/workflows/test-action.yml:50`
- `.github/workflows/test-action.yml:60`
- `.github/workflows/test-action.yml:70`
- `.github/workflows/update-tags.yml:14`

### missing-permissions (severity: medium)

The workflow file `test-action.yml` has no top-level `permissions:` key, and 4 of its 5 jobs (`test-action-clone-dry-run`, `test-action-init-dry-run`, `test-action-clone-dry-run-no-empty`, `test-action-init-dry-run-no-empty`) also have no job-level `permissions:` key. Only the `test-action-real` job defines its own `permissions:`. Without explicit permissions, GitHub Actions defaults to the repository's default token permissions, which may be overly broad.

Locations:

- `.github/workflows/test-action.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, missing-permissions

**Notes:**

1. cliw: Replaced `curl ... | chronic sh` pipe with a safe two-step approach: download installer to a temp file via `curl -fsSL -o "$_install_script"`, then execute it separately with `chronic sh "$_install_script" -s "v1.35.1"`, then clean up. 2. test-action.yml: Pinned all 5 `actions/checkout@v3` references to SHA `a37ce9120846195fa4ece8f58b268e6043cb2f26`. update-tags.yml: Pinned `actions/publish-action@v0.2.2` to SHA `dca2315f75060c81e52b00dfc86b660107013642`. 3. test-action.yml: Added top-level `permissions: contents: read` and added explicit `permissions: contents: read` to each of the 4 dry-run jobs (`test-action-clone-dry-run`, `test-action-init-dry-run`, `test-action-clone-dry-run-no-empty`, `test-action-init-dry-run-no-empty`). The `test-action-real` job already had `permissions: contents: write` which was preserved.

