# Deployment Failure: Orphaned Submodule Commits

**Date:** 2026-07-27
**Branch:** `stable-3_5_0`

## What Happened

Dokploy deployment failed on `git submodule update --init --recursive`:

```
fatal: Fetched in submodule path 'lib/pkp', but it did not contain 49a5559b1502036a8b93b9959c6b71332a8c730a.
```

## Root Cause

The core modifications for the Crossref per-DOI URL feature (see
`crossref-url-override.md`) were committed directly inside the `lib/pkp` and
`lib/ui-library` submodule checkouts. `.gitmodules` still pointed those
submodules at the **upstream** repos (`pkp/pkp-lib`, `pkp/ui-library`), which
we don't have push access to. So the superproject pinned commits that only
ever existed in the local clone — never pushed anywhere. Any fresh clone
(like Dokploy's build) fails because the pinned commit isn't fetchable from
the configured remote.

A third, related case was found in `plugins/generic/crossref`: the
superproject was pinned to a newer local-only commit built from a different
upstream sync point than what had last been pushed to the fork, so pushing it
directly was rejected as a non-fast-forward. The fork's existing commit (a
March 2026 fix for a `TypeError` when `enabledDoiTypes` isn't an array — see
[[feedback_database_safety]]) had to be merged in first to avoid losing it.

## The Fix

Same pattern already used for `crossref`, `s3ojs`, `discountedFee`, etc.:

1. Forked `pkp/pkp-lib` → `hasanur-rahman079/pkp-lib`
2. Forked `pkp/ui-library` → `hasanur-rahman079/ui-library`
3. Pushed the local-only commits to branch `stable-3_5_0-ems` on each fork
4. Updated `.gitmodules` to point `lib/pkp` and `lib/ui-library` at the forks
   with `branch = stable-3_5_0-ems`
5. Merged the fork's existing fix into the local `crossref` commit and pushed
   to `plugins/generic/crossref`'s existing fork branch

## Going Forward

**Any commit made inside `lib/pkp` or `lib/ui-library` (core submodules)
must be pushed to the corresponding fork
(`hasanur-rahman079/pkp-lib` / `hasanur-rahman079/ui-library`,
branch `stable-3_5_0-ems`) before or immediately after committing the
superproject's pointer update.** A commit that only exists in the local
working copy will pass local testing but break every fresh deployment.

Before committing a submodule pointer bump, sanity-check with:

```bash
git submodule foreach 'git branch -r --contains $(git rev-parse HEAD) | grep -q . || echo "ORPHAN: $sm_path"'
```
