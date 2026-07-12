This is the OJS3.5 from pkp. This is the git repo https://github.com/hasanur-rahman079/ojs/tree/stable-3_5_0

I am using this as a managed hosted platform for multiple journal at my own hosting using dokploy. 

## Things to remember

- Never touch the core code as i want to use future updates. Always customize via plugins.
  **Exception:** Some core modifications already exist — each is documented in `docs/myems/` with file paths, line details, and re-apply instructions for after upstream merges. Always check `docs/myems/` before resolving merge conflicts or rebuilding. After any core file change, run `npm run build:backend`.

- These are our custom plugins for the EMS.Pub platform — maintain UI consistency across all of them using the native Vue component library:
  - `plugins/generic/emspubcore` — Core platform infrastructure (plans, billing, journal lifecycle)
  - `plugins/generic/emsapi` — REST API for the Next.js Editorial Management System frontend
  - `plugins/generic/s3ojs` — S3-compatible storage for submission files
  - `plugins/paymethod/emspubstripe` — Stripe payment gateway integration
- When designing UI for custom plugins, always use OJS's native Vue component library to maintain visual consistency and professional look. The components live at `lib/ui-library/src/components/` — use `PkpButton`, `PkpTable`, `ListPanel`, `FieldText`, `Modal`, `Badge`, `Spinner`, `Search`, `Pagination`, etc. for pages and forms. Compose plugin pages from these instead of hand-rolling HTML/CSS. This also ensures free accessibility, RTL support, and version-compatible styling.

## For git push

ask before git add and commits and push. 