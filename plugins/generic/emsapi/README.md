# EMS API Plugin for OJS 3.5+

A custom REST API plugin that turns OJS (Open Journal Systems) into a headless editorial workflow engine. Provides business-oriented API endpoints for a Next.js frontend — build a modern Editorial Management System (like ScholarOne) powered by OJS under the hood.

**Status**: Phase 1 Complete — Foundation + Core CRUD

---

## Architecture

```
┌──────────────────────────────────────┐
│         Next.js Frontend             │
│    (Custom Editorial Management)      │
└──────────────┬───────────────────────┘
               │ HTTPS / REST / JSON
               ▼
┌──────────────────────────────────────┐
│         EMS API Plugin                │
│    plugins/generic/emsapi/            │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │ Controllers (PKPBaseController) │ │
│  │   /api/v1/ems-api/dashboard     │ │
│  │   /api/v1/ems-api/manuscripts   │ │
│  └─────────────┬───────────────────┘ │
│  ┌─────────────┴───────────────────┐ │
│  │ Services (Business Logic)       │ │
│  │   ManuscriptService             │ │
│  └─────────────┬───────────────────┘ │
│  ┌─────────────┴───────────────────┐ │
│  │ OJS Repo Facade                 │ │
│  │   Repo::submission()            │ │
│  │   Repo::publication()           │ │
│  │   Repo::reviewAssignment()      │ │
│  │   Repo::user() etc.             │ │
│  └─────────────────────────────────┘ │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│         OJS Core                      │
│   (Workflow Engine — never modified)  │
└──────────────────────────────────────┘
```

## Guiding Principles

1. **Never modify OJS core** — everything via plugins, hooks, and service extensions
2. **OJS is the workflow engine, not the UI** — the EMS API is the Backend-for-Frontend
3. **Business-oriented endpoints** — the frontend never sees OJS internal data models
4. **Site-wide plugin** — enable once in admin, works for all journals automatically

---

## Installation

```bash
# Clone into your OJS plugins directory
cd plugins/generic/
git clone git@github.com:hasanur-rahman079/myemsapi-ojs.git emsapi

# Enable in OJS admin:
# Administration → Site Settings → Plugins → EMS API Plugin → Enable
```

**Requirements**: OJS 3.5.0+, PHP 8.2+

---

## API Endpoints

### Base URL

```
https://your-ojs.org/index.php/{journalPath}/api/v1/ems-api
```

### Authentication

All endpoints require authentication. Use either:
- **API Key**: `Authorization: Bearer <jwt-wrapped-api-key>` (generate in OJS user profile)
- **Session Cookie**: For same-origin requests from the OJS web app

### Dashboard

| Method | Path | Description | Status |
|--------|------|-------------|--------|
| `GET` | `/dashboard` | Submission stats for current user | ✅ Done |
| `GET` | `/dashboard/queues` | Pending tasks by workflow stage | ✅ Done |

**Response**:
```json
{
  "data": {
    "submissions": {
      "active": 5,
      "published": 12,
      "declined": 3,
      "total": 20
    },
    "recent": [
      {
        "id": 42,
        "title": "Research Paper Title",
        "status": 1,
        "dateSubmitted": "2026-07-01 10:30:00",
        "stageId": 3
      }
    ]
  }
}
```

### Manuscripts

| Method | Path | Description | Status |
|--------|------|-------------|--------|
| `GET` | `/manuscripts` | List with filters & pagination | ✅ Done |
| `POST` | `/manuscripts` | Create new submission | ✅ Done |
| `GET` | `/manuscripts/{id}` | Single manuscript detail | ✅ Done |
| `PUT` | `/manuscripts/{id}` | Update manuscript | ✅ Done |
| `DELETE` | `/manuscripts/{id}` | Delete manuscript | ✅ Done |

**Query Parameters** (`GET /manuscripts`):

| Param | Type | Description |
|-------|------|-------------|
| `status` | int | Filter by submission status |
| `userId` | int | Filter by assigned user |
| `sectionId` | int | Filter by journal section |
| `searchPhrase` | string | Search by title/abstract |
| `page` | int | Page number (default 1) |
| `perPage` | int | Items per page (default 30, max 100) |
| `orderBy` | string | Sort field |
| `orderDir` | string | Sort direction (ASC/DESC) |

**Single Manuscript Response** (`GET /manuscripts/{id}`):
```json
{
  "data": {
    "id": 2,
    "status": 3,
    "stageId": 5,
    "dateSubmitted": "2026-07-08 05:01:06",
    "dateLastActivity": "2026-07-12 13:03:52",
    "locale": "en",
    "title": "Paper Title",
    "abstract": "<p>Abstract text...</p>",
    "authors": [
      {
        "id": 3,
        "firstName": "Md Ataur",
        "lastName": "Rahman",
        "email": "author@example.com",
        "affiliation": "University of Michigan, Ann Arbor, USA",
        "orcid": null,
        "primaryContact": true
      }
    ],
    "keywords": [{"name": "keyword1"}, {"name": "keyword2"}],
    "sectionId": 2,
    "publicationId": 2,
    "version": 1,
    "datePublished": "2026-07-12",
    "references": "1. Author A. Title. Journal. 2020...\n2. Author B...",
    "permissions": {
      "copyrightHolder": "JABET",
      "copyrightYear": 2026,
      "licenseUrl": "https://creativecommons.org/licenses/by/4.0/"
    },
    "issue": {
      "id": 1,
      "title": "Vol 1, Iss 1",
      "volume": 1,
      "number": "1",
      "year": 2026,
      "published": true,
      "datePublished": "2026-06-23 00:00:00"
    },
    "reviewers": [
      {
        "id": 1,
        "reviewerId": 2,
        "reviewerName": "Dr. Reviewer",
        "round": 1,
        "stageId": 3,
        "reviewMethod": 2,
        "status": "completed",
        "dateAssigned": "2026-07-08 05:09:06",
        "dateDue": "2026-08-05 00:00:00",
        "dateCompleted": "2026-07-08 05:19:20",
        "recommendation": 2
      }
    ],
    "files": [
      {
        "id": 4,
        "filename": "manuscript.pdf",
        "fileStage": 4,
        "genreId": 13,
        "mimetype": "application/pdf",
        "filesize": 2048576,
        "createdAt": "2026-07-08 05:06:52",
        "downloadUrl": "/index.php/jabet/$$$call$$$/api/file/file-api/download-file?fileId=4&submissionFileId=4&submissionId=2&stageId=4"
      }
    ]
  }
}
```

---

## Plugin Structure

```
plugins/generic/emsapi/
├── index.php                              # Plugin entry point
├── EmsApiPlugin.php                       # Main plugin class
├── version.xml                            # Version metadata (site-wide, lazy-load)
├── README.md                              # This file
│
├── controllers/
│   ├── EmsApiController.php               # Main combined controller (all routes)
│   ├── EmsDashboardController.php         # Dashboard-specific controller (legacy)
│   └── EmsManuscriptController.php        # Manuscript-specific controller (legacy)
│
├── services/
│   └── ManuscriptService.php              # Business logic + entity transformation
│
├── middleware/                             # Custom middleware (future)
├── responses/                             # Response transformers (future)
├── validators/                            # Request validation (future)
├── helpers/                               # Utility helpers (future)
└── locale/                                # Translations (future)
```

**Integration point**: `api/v1/ems-api/index.php` — OJS API router entry point

---

## How It Works

### Plugin Registration

```php
// EmsApiPlugin::register()
Hook::add('APIHandler::endpoints::plugin', function ($hookName, APIRouter $apiRouter) {
    $apiRouter->registerPluginApiControllers([new EmsApiController()]);
});
```

The `APIHandler::endpoints::plugin` hook (OJS 3.5+ native feature) lets plugins register API controllers. The plugin also provides a filesystem entry point at `api/v1/ems-api/index.php` as a fallback (same pattern all built-in OJS endpoints use).

### Data Flow

```
HTTP Request → APIRouter → api/v1/ems-api/index.php
    → APIHandler → EmsApiController → ManuscriptService
    → Repo::submission() / Repo::publication() / Repo::reviewAssignment()
    → Eloquent ORM → PostgreSQL/MySQL
    → Transform to EMS shape → JSON Response
```

### Entity Transformation

All OJS internal entities are transformed to EMS business shapes before reaching the frontend:

| OJS Internal | EMS API Response |
|-------------|-----------------|
| `Submission` → `getData('status')` | `manuscript.status` |
| `Publication` → `getLocalizedTitle()` | `manuscript.title` |
| `Author` → `getLocalizedAffiliationNames()` | `author.affiliation` |
| `publication.primaryContactId == author.id` | `author.primaryContact` |
| `CitationDAO::getRawCitationsByPublicationId()` | `manuscript.references` |
| `publication.copyrightHolder` | `permissions.copyrightHolder` |
| `Repo::issue()->get(issueId)` | `issue.{title, volume, number, year}` |

---

## Roadmap

### ✅ Phase 1: Foundation (Completed)
- [x] Plugin skeleton with `version.xml`, `EmsApiPlugin.php`
- [x] Dashboard endpoint (`GET /dashboard`, `GET /dashboard/queues`)
- [x] Manuscript CRUD (`GET/POST/PUT/DELETE /manuscripts`)
- [x] Manuscript detail with authors, keywords, references
- [x] Permissions & disclosure (copyright, license)
- [x] Issue information (volume, number, year)
- [x] Reviewer assignments with status
- [x] File listing with download URLs
- [x] Site-wide plugin (enable once, all journals)
- [x] API token authentication via OJS middleware

### 🚧 Phase 2: Reviewer Endpoints (Planned)
- [ ] `GET /reviewers` — reviewer directory with search & filters
- [ ] `GET /reviewers/{id}` — reviewer profile with stats
- [ ] `POST /manuscripts/{id}/reviewers` — assign reviewer
- [ ] `PUT /manuscripts/{id}/reviewers/{assignmentId}` — update assignment
- [ ] `DELETE /manuscripts/{id}/reviewers/{assignmentId}` — unassign reviewer

### 🚧 Phase 3: Workflow + Decisions (Planned)
- [ ] `GET /workflow/submissions/{id}` — full workflow state
- [ ] `GET /workflow/submissions/{id}/stages` — stage progression
- [ ] `POST /workflow/submissions/{id}/decisions` — record editorial decision
- [ ] `POST /workflow/submissions/{id}/stage` — move to next stage
- [ ] Decision history per manuscript

### 🚧 Phase 4: Files + Communication (Planned)
- [ ] `POST /manuscripts/{id}/files` — upload file
- [ ] `DELETE /manuscripts/{id}/files/{fileId}` — remove file
- [ ] File revision management
- [ ] Discussion/query endpoints (editorial discussions)

### 🚧 Phase 5: Notifications + Dashboard Enrichment (Planned)
- [ ] `GET /notifications` — user notifications
- [ ] `PUT /notifications/{id}/read` — mark as read
- [ ] Rich dashboard with charts and trends
- [ ] Activity feed

### 🚧 Phase 6: Analytics + Reports (Planned)
- [ ] `GET /analytics/editorial` — editorial stats
- [ ] `GET /analytics/submissions` — submission trends
- [ ] `GET /reports/reviewers` — reviewer performance
- [ ] `GET /reports/submissions` — submission report
- [ ] Acceptance rates, turnaround times

### 🚧 Phase 7: Multi-Journal SaaS (Planned)
- [ ] Site-wide admin controller for cross-journal management
- [ ] Journal CRUD via API
- [ ] User management across journals
- [ ] Tenant isolation hardening
- [ ] Rate limiting

### 🚧 Phase 8: Auth + Security (Planned)
- [ ] `POST /auth/login` — custom JWT login endpoint
- [ ] `POST /auth/refresh` — token refresh
- [ ] API key management
- [ ] Role-based access audit

### 🚧 Phase 9: Polish (Planned)
- [ ] OpenAPI/Swagger specification
- [ ] Comprehensive error responses
- [ ] Request validation
- [ ] Integration tests
- [ ] Response caching for dashboard/analytics

---

## Technical Notes

### Why `getData()` instead of getters?

OJS 3.5 uses the DataObject pattern for most entities. `Submission` properties like status, stage, and dates are accessed via `getData('fieldName')` rather than dedicated getters. Only a few commonly-used fields have explicit methods (`getId()`, `getCurrentPublication()`).

### Why `api/v1/ems-api/index.php`?

This is the standard OJS API entry point pattern. All 33 built-in OJS API endpoints (`submissions`, `contexts`, `users`, etc.) work this way. The `APIRouter` resolves `/api/v1/{entity}/` to `api/v1/{entity}/index.php`. Creating this file ensures the API works regardless of plugin database state.

### Compatibility

- **OJS**: 3.5.0+ (uses `PKPBaseController`, `APIHandler::endpoints::plugin` hook)
- **Database**: PostgreSQL or MySQL (uses OJS Eloquent ORM, no raw SQL)
- **PHP**: 8.2+

---

## License

GNU GPL v3 — same as OJS. Distributed as part of the EmsPub platform.
