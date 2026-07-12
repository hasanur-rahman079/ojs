# EMS API Plugin

Instead of using the built-in OJS API, create one central plugin: `plugins/generic/ems-api` so that we can use that plugin to create a modern Editorial Management System with custom Frontned using NextJs. It'll Uses OJS as the editorial workflow engine, Has a completely custom UI, Is API-first, can support multiple journals, Is modular and scalable, Can eventually become SaaS. 

Think of it like this:
```
               ScholarOne UI
                      +
           OJS Workflow Engine
                      =
                my.ems.pub

```

## High-Level Architecture

```
                        Users
                          │
                          ▼
                  Next.js Frontend
         ┌────────────────────────────────┐
         │ Authors                        │
         │ Reviewers                      │
         │ Editors                        │
         │ Publishers                     │
         │ Admin                          │
         └────────────────────────────────┘
                          │
                 HTTPS / REST / JSON
                          │
                          ▼
                  EMS API Plugin
         ┌────────────────────────────────┐
         │ Authentication                 │
         │ Authorization                  │
         │ Business Logic                 │
         │ API Controllers                │
         └────────────────────────────────┘
                          │
                  OJS Core Services
                          │
         ┌────────────────────────────────┐
         │ Submission Workflow            │
         │ Review Workflow                │
         │ Files                          │
         │ Email                          │
         │ Users                          │
         │ Journals                       │
         └────────────────────────────────┘
                          │
                          ▼
                    MySQL Database

```

OJS will be responsible for all of the features. The backend plugin extends OJS without modifying the core.


## Structure:

```
ems-api/

controllers/

services/

repositories/

middleware/

auth/

routes/

helpers/

responses/

validators/

events/

```

This becomes the Backend for Frontend (BFF).

## API Design

Instead of exposing OJS internals:

❌ Avoid:
```
/api/v1/users

/api/v1/publications

/api/v1/submissions

```

Expose business-oriented endpoints:
```
/api/dashboard

/api/manuscripts

/api/reviewers

/api/workflow

/api/reports

/api/analytics

/api/notifications

/api/settings

```

The frontend should never need to know OJS's internal data model.

## Guiding Principles

1. Never modify OJS core unless absolutely necessary. Prefer plugins, hooks, and service extensions to simplify upgrades.
2. Treat OJS as the workflow engine, not the user interface.
3. Treat the EMS API as the application's backend (a Backend-for-Frontend layer), exposing stable, business-oriented endpoints.
4. Design APIs around user workflows, not OJS's internal tables or objects.
5. Build for maintainability first. A clean architecture will pay off far more than short-term shortcuts as the platform grows into a commercial product.