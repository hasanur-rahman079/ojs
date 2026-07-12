# EMS API Plugin — Feasibility Assessment & Implementation Plan

## Verdict: ✅ Fully Feasible

OJS 3.5.0 has **first-class, documented, tested support** for plugins to register custom REST API controllers without modifying a single line of core code. All core OJS services are accessible through the `Repo` facade and Eloquent ORM.

---

## 1. Evidence from Codebase

### 1.1 Plugin API Controller Registration (the critical mechanism)

**`lib/pkp/classes/core/APIRouter.php` line 109:**
```php
Hook::run('APIHandler::endpoints::plugin', [$this]);
```

The APIRouter fires this hook before checking filesystem routes. Plugins call:
```php
$apiRouter->registerPluginApiControllers([$myController]);
```

The `registerPluginApiControllers()` method (line 155) validates controllers are `PKPBaseController` instances and stores them by handler path. When a request matches, the plugin controller handles it instead of falling through to filesystem routes.

**Proof**: Unit test at `lib/pkp/tests/classes/core/APIRouterTest.php` (line 462, `testPluginEndpointsHookServesSiteWideApi()`) — an end-to-end test wiring a mock plugin, registering an API controller, dispatching a GET request, and asserting the JSON response.

**Note**: No existing bundled plugin uses this hook yet — it's a newer OJS 3.4/3.5 feature ready for adoption.

### 1.2 PKPBaseController — the modern API controller base

Controllers extend `PKPBaseController` (`lib/pkp/classes/core/PKPBaseController.php`) which extends Laravel's `Illuminate\Routing\Controller`. Three required methods:

| Method | Purpose | Example |
|--------|---------|---------|
| `getHandlerPath(): string` | URL segment after `/api/v1/` | `'ems-api'` |
| `getRouteGroupMiddleware(): array` | Middleware for all routes | `['has.user', 'has.context']` |
| `getGroupRoutes(): void` | Define routes with Laravel `Route` facade | `Route::get('manuscripts', ...)` |

Routes use full Laravel routing DSL:
```php
Route::middleware([self::roleAuthorizer([Role::ROLE_ID_MANAGER])])->group(function () {
    Route::get('manuscripts', $this->getMany(...))->name('ems.manuscripts.getMany');
    Route::get('manuscripts/{id}', $this->get(...))->name('ems.manuscripts.get')->whereNumber('id');
    Route::post('manuscripts', $this->create(...))->name('ems.manuscripts.create');
    Route::put('manuscripts/{id}', $this->update(...))->name('ems.manuscripts.update')->whereNumber('id');
});
```

### 1.3 Service Layer — `Repo` Facade

All core entities are accessible through `Repo::` (no raw SQL needed):

| Facet | Repository | Key Methods |
|-------|-----------|-------------|
| Submissions | `Repo::submission()` | `get()`, `getCollector()`, `add()`, `edit()`, `delete()`, `submit()` |
| Publications | `Repo::publication()` | `get()`, `add()`, `edit()`, `version()`, `publish()` |
| Review Assignments | `Repo::reviewAssignment()` | `get()`, `getCollector()`, `add()`, `edit()`, `delete()` |
| Decisions | `Repo::decision()` | `add()` (18 decision types: Accept, Decline, RequestRevisions, etc.) |
| Users | `Repo::user()` | `get()`, `getByEmail()`, `getByApiKey()`, `getCollector()` |
| User Groups | `Repo::userGroup()` | Role/group management |
| Sections | `Repo::section()` | Journal sections |
| Notifications | `Repo::notification()` | `getCollector()`, `add()`, `delete()` |
| Submission Files | `Repo::submissionFile()` | File management |
| Stage Assignments | `Repo::stageAssignment()` | Workflow stage participant tracking |
| Email Templates | `Repo::emailTemplate()` | Template CRUD |
| Event Logs | `Repo::eventLog()` | Activity logging |
| Email Logs | `Repo::emailLogEntry()` | Email history |

### 1.4 Authentication

- **JWT-based**: `Authorization: Bearer <token>` header
- **Middleware**: `DecodeApiTokenWithValidation` at `lib/pkp/classes/middleware/DecodeApiTokenWithValidation.php`
- **Role middleware**: `has.roles:{role_id|role_id}` (any match grants access)
- **Fallback**: Session-based auth for same-origin requests

### 1.5 Email System

35+ pre-built mailables in `lib/pkp/classes/mail/mailables/`. Send via `Illuminate\Support\Facades\Mail::send($mailable)`. Custom mailables can be registered via `Mailer::Mailables` hook.

### 1.6 Hook System

Key hooks for the EMS plugin:

| Hook | Fires in | Purpose |
|------|----------|---------|
| `APIHandler::endpoints::plugin` | `APIRouter::route()` | Register plugin API controllers |
| `APIHandler::endpoints::{entity}` | `APIHandler::__construct()` | Extend existing API endpoints |
| `Submission::add` | `Repository::add()` | After submission created |
| `Submission::edit` | `Repository::edit()` | Before submission update |
| `Decision::add` | `Decision\Repository::add()` | After editorial decision |
| `Mailer::Mailables` | Mail repository | Add custom mailables |

---

## 2. URL Structure

The plugin's API routes will live at:

- **Context-level**: `/{journalPath}/api/v1/{handlerPath}/{action}`
  - Example: `https://my.ems.pub/plantscience/api/v1/ems-api/manuscripts`
- **Site-wide**: `/index/api/v1/{handlerPath}/{action}`
  - Example: `https://my.ems.pub/index/api/v1/ems-api/admin/settings`

The envisioned clean URLs (`/api/manuscripts`, `/api/dashboard`) are NOT directly achievable through the plugin mechanism. The `/api/v1/` prefix is hardcoded in `APIRouter`. **Workarounds**:

1. **Next.js API client abstraction** (recommended): The frontend uses a configurable API base URL (`https://my.ems.pub/plantscience/api/v1/ems-api`) — clean from the developer's perspective.
2. **Nginx rewrite** (optional later): Map `/api/manuscripts` → `/index.php/api/v1/ems-api/manuscripts`.

### URL mapping:

| EMS Business Endpoint | Actual OJS URL |
|----------------------|----------------|
| `/api/manuscripts` | `/index.php/{journal}/api/v1/ems-api/manuscripts` |
| `/api/manuscripts/42` | `/index.php/{journal}/api/v1/ems-api/manuscripts/42` |
| `/api/dashboard` | `/index.php/{journal}/api/v1/ems-api/dashboard` |
| `/api/reviewers` | `/index.php/{journal}/api/v1/ems-api/reviewers` |
| `/api/workflow/42/review` | `/index.php/{journal}/api/v1/ems-api/workflow/submissions/42/review` |

The Next.js BFF abstracts all of this. The frontend developer writes `api.get('/manuscripts')` — not OJS URLs.

---

## 3. Recommended Architecture

### 3.1 Plugin Structure

```
plugins/generic/ems-api/
├── index.php                            # Entry point
├── EmsApiPlugin.php                     # Plugin class (extends GenericPlugin)
├── version.xml                          # Version metadata
│
├── controllers/                         # Extend PKPBaseController
│   ├── EmsManuscriptController.php      # GET/POST/PUT/DELETE manuscripts
│   ├── EmsReviewerController.php        # Reviewer search, assignment, stats
│   ├── EmsDashboardController.php       # Dashboard aggregation
│   ├── EmsWorkflowController.php        # Workflow state, stage transitions
│   ├── EmsDecisionController.php        # Editorial decisions
│   ├── EmsNotificationController.php    # Notification CRUD
│   ├── EmsSettingsController.php        # Plugin & journal settings
│   ├── EmsReportController.php          # Submission/review reports
│   ├── EmsAnalyticsController.php       # Acceptance rates, turnaround times
│   └── EmsFileController.php            # File upload/download
│
├── services/                            # Business logic layer
│   ├── ManuscriptService.php            # Orchestrates submission operations
│   ├── ReviewerService.php              # Review assignment logic + stats
│   ├── DashboardService.php             # Dashboard data aggregation
│   ├── WorkflowService.php              # Workflow state machine
│   ├── NotificationService.php          # Notification aggregation
│   ├── ReportService.php                # Report generation
│   └── AnalyticsService.php             # Analytics calculations
│
├── middleware/                           # Custom middleware
│   └── EmsApiAuth.php                   # Custom JWT validation (Phase 2+)
│
├── responses/                           # Response transformers
│   ├── ManuscriptResource.php           # Submission → EMS manuscript shape
│   ├── ReviewerResource.php             # User → EMS reviewer shape
│   └── DashboardResource.php            # Dashboard data shape
│
├── validators/                          # Request validation
│   ├── ManuscriptValidator.php
│   └── ReviewerValidator.php
│
└── helpers/
    └── EmsHelper.php
```

### 3.2 Plugin Registration (EmsApiPlugin.php)

```php
class EmsApiPlugin extends GenericPlugin
{
    public function register($category, $path, $mainContextId = null)
    {
        $success = parent::register($category, $path, $mainContextId);
        if (!$success || !$this->getEnabled()) {
            return $success;
        }

        Hook::add('APIHandler::endpoints::plugin', function (string $hookName, APIRouter $apiRouter) {
            $apiRouter->registerPluginApiControllers([
                new controllers\EmsManuscriptController(),
                new controllers\EmsReviewerController(),
                new controllers\EmsDashboardController(),
                new controllers\EmsWorkflowController(),
                new controllers\EmsDecisionController(),
                new controllers\EmsNotificationController(),
                new controllers\EmsSettingsController(),
                new controllers\EmsReportController(),
                new controllers\EmsAnalyticsController(),
                new controllers\EmsFileController(),
            ]);
            return Hook::CONTINUE;
        });

        return $success;
    }
}
```

### 3.3 Architecture Pattern — Data Flow

```
Next.js Frontend
      │  HTTP request (JWT auth)
      ▼
EMS Plugin Controller (PKPBaseController)
      │  validates input, checks roles
      ▼
EMS Service Layer
      │  business logic, transforms data
      ▼
OJS Repo Facade (Repo::submission(), etc.)
      │  data access, hooks, events
      ▼
Eloquent ORM → MySQL
```

Key principle: **The frontend never sees OJS internal data shapes.** Every controller method transforms OJS entities into EMS-specific response shapes. The frontend receives `manuscript.title`, not `submission.currentPublication.title`.

### 3.4 Multi-Journal Strategy

- **Context-level controllers** (`isSiteWide() = false`): Manuscript, reviewer, workflow, notification, file endpoints — scoped to one journal via URL path
- **Site-wide controllers** (`isSiteWide() = true`): Cross-journal admin, analytics, settings
- The `has.context` middleware auto-resolves the journal from the URL

---

## 4. API Design

### 4.1 Endpoints

```
GET    /api/v1/ems-api/dashboard              # Aggregated stats for current user
GET    /api/v1/ems-api/dashboard/queues        # Pending tasks by stage

GET    /api/v1/ems-api/manuscripts             # List with filters, pagination
POST   /api/v1/ems-api/manuscripts             # Create new submission
GET    /api/v1/ems-api/manuscripts/{id}        # Single manuscript detail
PUT    /api/v1/ems-api/manuscripts/{id}        # Update manuscript
DELETE /api/v1/ems-api/manuscripts/{id}        # Delete manuscript

GET    /api/v1/ems-api/manuscripts/{id}/publications        # Publication versions
GET    /api/v1/ems-api/manuscripts/{id}/files                # Submission files
GET    /api/v1/ems-api/manuscripts/{id}/contributors         # Authors/contributors
GET    /api/v1/ems-api/manuscripts/{id}/reviewers            # Assigned reviewers

GET    /api/v1/ems-api/reviewers               # Reviewer search & directory
GET    /api/v1/ems-api/reviewers/{id}           # Reviewer profile with stats
POST   /api/v1/ems-api/reviewers               # Assign reviewer to manuscript

GET    /api/v1/ems-api/workflow/submissions/{id}           # Full workflow state
GET    /api/v1/ems-api/workflow/submissions/{id}/stages    # Stage progression
POST   /api/v1/ems-api/workflow/submissions/{id}/decisions # Record decision
POST   /api/v1/ems-api/workflow/submissions/{id}/stage     # Move to next stage

GET    /api/v1/ems-api/notifications            # User notifications
PUT    /api/v1/ems-api/notifications/{id}/read   # Mark as read

GET    /api/v1/ems-api/reports/reviewers        # Reviewer performance
GET    /api/v1/ems-api/reports/submissions      # Submission report
GET    /api/v1/ems-api/analytics/editorial      # Editorial stats & trends

GET    /api/v1/ems-api/settings                 # Plugin settings
PUT    /api/v1/ems-api/settings                 # Update settings
```

### 4.2 Response Format

Consistent JSON envelope:
```json
{
    "data": { ... },
    "meta": {
        "page": 1,
        "perPage": 30,
        "total": 150
    }
}
```

### 4.3 Entity Transformation Example

OJS internal → EMS API response:
```json
// Before (OJS raw): Repo::submission()->get(42)
{
    "submission_id": 42,
    "context_id": 3,
    "current_publication_id": 10,
    "status": 1,
    "date_submitted": "2024-06-15"
}

// After (EMS API): ManuscriptResource
{
    "id": 42,
    "journalId": 3,
    "title": "Effects of Climate Change on Crop Yields",
    "status": "under_review",
    "submittedAt": "2024-06-15T10:30:00Z",
    "authors": [...],
    "currentStage": "external_review",
    "reviewRound": 1
}
```

---

## 5. Authentication Strategy

### Phase 1: OJS Built-in API Keys (simplest)

- Admin creates API keys for users in OJS
- Next.js sends `Authorization: Bearer <jwt-wrapped-api-key>` 
- `DecodeApiTokenWithValidation` middleware handles validation
- `has.roles` middleware handles authorization
- **Zero custom auth code needed**

### Phase 2: Custom JWT (better UX)

- Add `POST /api/v1/ems-api/auth/login` endpoint
- Validate credentials against OJS's `Validation::checkCredentials()`
- Return short-lived JWT (1h) + refresh token
- Custom `EmsApiAuth` middleware validates the JWT format
- JWT contains user ID, roles, context IDs — avoids DB lookups per request

### Phase 3: OAuth2/OIDC (SaaS multi-tenant)

- Integrate with external identity provider
- Map external identity to OJS user account
- Validate external JWT in custom middleware

---

## 6. Implementation Phases

### Phase 1: Foundation (Week 1) — Prove the concept
- Plugin skeleton: `index.php`, `EmsApiPlugin.php`, `version.xml`
- One controller: `EmsDashboardController` with `GET dashboard` health-check endpoint
- Register via `APIHandler::endpoints::plugin` hook
- Enable plugin via OJS admin
- **Verify**: `curl -H "Authorization: Bearer <token>" http://localhost/index.php/journal/api/v1/ems-api/dashboard`

### Phase 2: Core Data (Weeks 2-3)
- `EmsManuscriptController` — full CRUD for manuscripts
- `EmsReviewerController` — reviewer search & assignment
- `ManuscriptService`, `ReviewerService` — business logic layer
- `ManuscriptResource`, `ReviewerResource` — response transformers
- Input validators

### Phase 3: Workflow (Weeks 4-5)
- `EmsWorkflowController` — stage progression, state queries
- `EmsDecisionController` — editorial decisions
- `EmsNotificationController` — notification aggregation
- `EmsFileController` — file upload/download
- Workflow state machine in `WorkflowService`

### Phase 4: Dashboard & Analytics (Week 6)
- Full `EmsDashboardController` — pending tasks, queues, stats
- `EmsAnalyticsController` — editorial stats via `PKPStatsEditorialService`
- `EmsReportController` — submission & reviewer reports

### Phase 5: Auth & Settings (Week 7)
- `EmsSettingsController` — plugin & journal settings
- Custom JWT auth (Phase 2 auth)
- Site-wide admin controller for multi-journal

### Phase 6: Polish (Week 8)
- Comprehensive error handling
- API documentation (OpenAPI spec)
- Unit tests
- Nginx rewrite rules (optional clean URLs)

---

## 7. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| OJS upgrade changes Repo API | Medium | High | Service layer isolates OJS internals; only service classes need updating |
| `APIHandler::endpoints::plugin` hook removed | Low | High | Hook is tested in OJS core test suite; monitor release notes |
| JWT token format incompatibility | Low | Medium | Phase 1 uses OJS native auth; custom JWT is optional Phase 2 |
| Performance under load | Medium | Medium | Caching layer; eager loading; BFF limits request volume |
| Plugin route conflicts | Low | Low | `registerPluginApiControllers()` rejects duplicate handler paths |
| Context resolution failures | Low | High | Always handle null context in controllers; use `has.context` middleware |

---

## 8. What You CAN'T Do (without modifying core)

1. **Remove `/api/v1/` prefix** — OJS controls URL structure
2. **Replace authentication entirely** — OJS's auth middleware always runs (but you can layer custom auth on top)
3. **Override OJS admin UI** — the plugin adds API routes, not UI replacements
4. **Bypass OJS authorization model** — role checks flow through OJS's user/role system (this is actually good — consistency)

---

## 9. Key Reference Files

| File | What to Learn |
|------|--------------|
| `lib/pkp/classes/core/PKPBaseController.php` | Base class your controllers MUST extend |
| `lib/pkp/classes/core/APIRouter.php` | `registerPluginApiControllers()` + hook mechanism |
| `lib/pkp/tests/classes/core/APIRouterTest.php` | Working example of plugin API registration |
| `lib/pkp/api/v1/submissions/PKPSubmissionController.php` | Reference controller — routes, middleware, auth |
| `lib/pkp/api/v1/contexts/PKPContextController.php` | Simpler reference controller |
| `lib/pkp/classes/middleware/DecodeApiTokenWithValidation.php` | JWT auth pattern |
| `lib/pkp/classes/middleware/HasRoles.php` | Role-based access pattern |
| `plugins/generic/emspubcore/EmsPubCorePlugin.php` | Plugin with DAOs, hooks, custom tables |
| `lib/pkp/classes/facades/Repo.php` | PKP-level Repo facade |
| `classes/facades/Repo.php` | OJS-level Repo facade (more repos) |
| `lib/pkp/classes/services/PKPStatsEditorialService.php` | Editorial stats service |

---

## 10. Verdict Summary

| Question | Answer |
|----------|--------|
| Can a plugin register custom API routes? | ✅ Yes — `APIHandler::endpoints::plugin` hook |
| Can it use Laravel routing? | ✅ Yes — `PKPBaseController` extends `Illuminate\Routing\Controller` |
| Can it access all OJS services? | ✅ Yes — `Repo` facade covers all entities |
| Can it authenticate users? | ✅ Yes — JWT middleware, `has.user`, `has.roles` |
| Can it send emails? | ✅ Yes — `Mail::send()` with 35+ built-in mailables |
| Can it have its own DB tables? | ✅ Yes — Laravel `Schema` facade |
| Can it support multiple journals? | ✅ Yes — context-level + site-wide controllers |
| Does it need core modification? | ❌ No — zero core files touched |
| Are clean URLs (`/api/manuscripts`) possible? | ⚠️ Only via nginx rewrite or Next.js proxy |
