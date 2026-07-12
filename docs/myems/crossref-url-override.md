# Crossref DOI Plugin — Custom Landing Page & Full Text URL Override

**Date:** 2026-07-13
**Branch:** `stable-3_5_0`

## What This Does

Adds editable **Landing Page URL** and **Full Text URL** fields to each article DOI in the DOI management page (`/dois`). When these URLs are set, the Crossref deposit XML uses them instead of OJS's default URLs.

## URL Resolution Priority

When generating Crossref deposit XML, URLs resolve in this order:

1. **Per-DOI override** — direct URL stored on the DOI object (editable in DOI management UI)
2. **Journal-wide template** — URL template from plugin settings (fallback, no UI currently)
3. **OJS default** — unchanged behavior via `Dispatcher::url()`

## Files Changed

### Core files (will need re-applying after upstream merge)

**`lib/pkp/locale/en/manager.po`**
- Lines added after `manager.dois.title`: four new locale keys
  - `manager.dois.landingPageUrl` → "Landing Page URL"
  - `manager.dois.landingPageUrlPlaceholder` → "Custom landing page URL (optional)"
  - `manager.dois.fullTextUrl` → "Full Text URL"
  - `manager.dois.fullTextUrlPlaceholder` → "Custom full text URL for similarity check (optional)"

**`lib/ui-library/src/components/ListPanel/doi/DoiListPanel.vue`**
- `mapDoiObject()` method — added `landingPageUrl` and `fullTextUrl` passthrough from DOI object
- Find: `registrationAgency: doiObject === null ? null : doiObject.registrationAgency,`
- Two new lines added after the above line

**`lib/ui-library/src/components/ListPanel/doi/DoiListItem.vue`**
- `doiListColumns` in `data()` — unchanged (2 columns: Type, DOI)
- Template: added `<template v-for>` block after the main `<TableRow v-for>`, containing two `<TableRow>` elements (Landing Page URL + Full Text URL inputs) wrapped in `<template v-for="row in currentVersionDoiObjects">` with `v-if="row.type === 'publication'"`
- `updateMutableDois()` — copies `landingPageUrl` and `fullTextUrl` from item into mutableDois
- `saveDois()` — change detection expanded to include URL fields
- `editDoi()` — PUT data includes `landingPageUrl` and `fullTextUrl`
- `addNewDoi()` — POST data includes `landingPageUrl` and `fullTextUrl`

### Plugin files (in submodule, git will merge normally)

**`plugins/generic/crossref/CrossrefPlugin.php`**
- `addToSchema()` — added `landingPageUrl` and `fullTextUrl` properties to DOI schema

**`plugins/generic/crossref/filter/ArticleCrossrefXmlFilter.php`**
- `resolveUrl()` — added `$doiId` parameter, checks per-DOI value first, then journal template, then OJS default
- `createJournalArticleNode()` — passes `$publicationDoiId` to resolveUrl
- `appendAsCrawledCollectionNodes()` — passes `$galleyDoiId` to resolveUrl
- `appendTextMiningCollectionNodes()` — passes `$galleyDoiId` to resolveUrl
- `createComponentListNode()` — passes `$componentDoiId` to resolveUrl

**`plugins/generic/crossref/classes/CrossrefSettings.php`**
- Journal-wide URL template fields were added then removed (no net change from original)

**`plugins/generic/crossref/locale/en/locale.po`**
- Journal-wide URL locale strings were added then removed (no net change from original)

## How to Re-apply After Upstream Merge

After merging upstream OJS changes, run `npm run build:backend` to recompile the Vue components into `js/build.js`.

If conflicts occur in:
- `manager.po` — just ensure the 4 locale keys are present after merge
- `DoiListItem.vue` — look for the `<template v-for>` block with URL rows
- `DoiListPanel.vue` — look for `landingPageUrl`/`fullTextUrl` in `mapDoiObject()`
