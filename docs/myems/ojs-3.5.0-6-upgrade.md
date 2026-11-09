# OJS 3.5.0-6 local upgrade

Prepared on 9 November 2026 against the official PKP `3_5_0-6` release,
published on 31 October 2026. This targets the release tag rather than later
commits on `stable-3_5_0`.

## Preserved customizations

- The EMS plugins, manuscript theme, Docker configuration, and fork URLs in
  `.gitmodules` remain in place.
- The PKP English locale additions and UI library DOI landing/full-text URL
  fields were merged with the official release trees.
- The Crossref schema and XML URL overrides, including the existing fork's
  settings compatibility fix, were preserved.
- Local credentials remain in the ignored `config.inc.php`.

The root's only file-content conflict was `package-lock.json`. `package.json`
merged to the official release's dependency declarations, so the official
release lockfile was used and installed with `npm ci`.

## Local database and runtime

The development database uses the existing local neond endpoint on port
`50007`. The database and local configuration were backed up before migration:

```text
/home/unix/.local/share/neond/ojs-backups/ojs-dev-before-3506-20261109-120548.dump
/home/unix/.local/share/neond/ojs-backups/ojs-dev-before-3506-20261109-120548.dump.config.ini
```

These files contain private data or credentials; keep them outside the web
root and Git. The dump uses PostgreSQL's custom format and was created with
neond's PostgreSQL 17 client.

The upgrade command was:

```bash
PGSSLMODE=require PGCHANNELBINDING=require php tools/upgrade.php upgrade
```

Start the local server after starting neond:

```bash
cd /home/unix/git_repos/ojs
PGSSLMODE=require PGCHANNELBINDING=require php -S localhost:8000 -t .
```

OJS is at `http://localhost:8000`; the neond dashboard is at
`http://127.0.0.1:7432`.

Local sandbox mode, log-only email, and disabled automatic jobs/scheduled
tasks are retained. S3 uses the existing production bucket through the
standard filesystem adapter; direct-serving URLs, auto-sync, and cleanup
are disabled. The credentials are not read-only, so file mutations in this
development installation can affect the shared bucket. Upgrade validation
uses read operations against S3.

## Git and deployment status

The tested upgrade is recorded locally as upstream merge commits in the root
and three customized submodules: PKP core, UI library, and Crossref. Each
merge retains the existing fork history and the official release history.
Other changed bundled submodules are pinned to the official release commits.

The customized submodule merge commits must be published to their forks
before publishing the OJS root commit. Publishing source code does not run
the production database upgrade or the production spam-account cleanup.

When recording the update, merge history must include both the existing fork
HEAD and the official release commit for the root and customized submodules.
Publish customized submodule merge commits to their configured forks before
publishing the root's updated gitlinks. This avoids the missing-submodule-
commit deployment failure described in `submodule-fork-deployment-fix.md`.

Before a future production deployment, back up that environment's database,
configuration and files separately, install the committed dependency
lockfiles, build the frontend assets, and run the official OJS upgrade in a
maintenance window. The local development database upgrade does not upgrade
production.

## Validation

- The official upgrade completed successfully; the development database reports
  `3.5.0.6`.
- All 163 changed PHP files passed syntax checks.
- The routing and authorization unit tests completed with 48 tests, 81
  assertions, and one intentional skip for the API router's inherited
  bare-request support test.
- `npm run build` completed for both backend and frontend assets, and Composer
  platform requirements passed.
- Homepage, login, journal page, backend JavaScript, frontend JavaScript, and
  stylesheet requests returned HTTP 200.
- OJS's file service successfully checked and read a cloud object through the
  S3 adapter without modifying it.
- The three custom submodule trees match the calculated release merges.
  Fork URLs are unchanged; local credentials and database backups are excluded
  from the commits.

The build reports existing Vite output-directory, Tailwind content-glob, and
large-chunk warnings. PKP's tagged source also contains a trailing space in
`classes/core/PKPContainer.php`; it is retained to match the release.

The full end-to-end suite, authenticated browser workflows, and production
deployment have not been tested.

## References

- [Official tagged release notes](https://github.com/pkp/ojs/blob/3_5_0-6/docs/release-notes/README-3.5.0)
- [Crossref customization](crossref-url-override.md)
- [Submodule fork deployment requirements](submodule-fork-deployment-fix.md)
