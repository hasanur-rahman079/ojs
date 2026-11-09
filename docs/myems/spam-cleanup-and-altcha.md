# Spam account cleanup and ALTCHA deployment

## Development cleanup on 9 November 2026

The imported development database contained 1,717 users. The reviewed bot
pattern matched 1,667 accounts: all were registered in IJAR (journal ID 1),
and 617 were also registered in Toxicant Research (journal ID 2).

The candidate accounts had all of these characteristics:

- Username, given name, family name, and affiliation each matched ten lowercase
  Latin letters, such as the repeated random strings in the reported profiles.
- Disabled, email never validated, and no recorded login.
- Only reader, author, or reviewer registrations in these two journals; no
  staff/admin role or registration in another journal.
- No matching author email, submissions through stage assignments, uploaded or
  temporary files, reviews, editorial decisions, payments, subscriptions,
  notifications, notes, or other checked activity references.
- Any invitation addressed to the user was an automatic `registrationAccess`
  invitation with no inviter. Editorial invitations were excluded. Registration
  sessions were allowed because they do not establish an authenticated login.

The other 50 accounts were retained, including five disabled accounts with
normal-looking academic profiles. Being disabled or unvalidated alone is
not sufficient evidence of spam.

The operation used OJS's `Repo::user()->mergeUsers()` into a disabled archive
account, `removed-spam-20261109`. The archive account has no journal roles and
an unused `example.invalid` email address. Source accounts, profile settings,
registration invitations, and sessions are removed through OJS and its database
relationships. No S3 files are deleted or changed.

A one-account merge was tested inside a transaction and rolled back before
the batch. The batch rechecks the exact audited ID set and protects the
retained users and journal-data counts before committing.

The batch completed successfully: 1,667 bot accounts were removed, all 50
original retained accounts were unchanged, and one disabled archive account
was added (51 users site-wide). IJAR now has 10 registered users; Toxicant
Research has 47. These counts overlap because accounts can belong to both
journals.

Verification confirmed that all removed accounts' profile settings,
memberships, sessions, and invitations were gone. Counts remained unchanged
for the three journals, 31 submissions, 31 publications, 98 authors, 148 file
records, 214 submission-file records, 18 review assignments, 59 stage
assignments, payments, subscriptions, and email/event logs. Both journal
pages, the site homepage, and login returned HTTP 200 after cleanup.

Private audit files and the pre-cleanup PostgreSQL dump are stored outside
the repository and web root:

```text
/home/unix/.local/share/neond/ojs-backups/spam-cleanup-20261109/
  before-cleanup.dump
  candidates.csv
  candidates.json
  candidate-ids.json
  candidate-query.sql
  retained-users.json
  baseline-counts.json
  cleanup-result.json
```

The audit files contain account data. Do not commit them or upload them to a
public document. The database dump uses PostgreSQL's custom format and requires
a compatible PostgreSQL client to restore. A restore should first be tested
in a separate database or neond branch.

## Cleaning production safely

Production is a separate operation. Do not replace its database with the
cleaned development dump or reuse development user IDs without a fresh audit.

### Dokploy deployment and database upgrade

This repository's entrypoint configures OJS and starts Apache. It does **not**
automatically run `tools/upgrade.php`. Deploy the new image and run the database
upgrade explicitly while public requests and background writers are paused.

Before the deployment:

- Pause automatic deployment until the maintenance window is ready. Publish
  the three customized submodule commits to their forks before publishing the
  OJS root commit, so the Docker build can fetch all pinned commits.
- Save a fresh production database backup, the current configuration, file
  storage backups, and the prior working image/deployment reference. Preserve
  the existing Dokploy Compose project and named volumes; do not run `down -v`.
- Read `app_key` from the **currently running production** `config.inc.php`
  into a private location, then set that same value as
  `OJSCONFIG_GENERAL_APP_KEY` in Dokploy's Environment tab. Do not generate a
  new value and do not use the development key. Preserve the existing security
  salt and API key secret too. The Compose configuration passes the app key
  through to the entrypoint on future deployments.
- Block public application traffic at the proxy/edge for every journal hostname,
  and direct port `8081` if it is reachable. Pause cron, queues, and external
  workers. Editing `installed` alone is not a complete public maintenance gate:
  it can expose the installer page. Keep the container terminal reachable.

Deploy the new OJS image in Dokploy. Open its application container terminal
and run these commands **inside that container**, not on your WSL checkout:

```bash
cd /var/www/html
```

Before running the upgrade, privately confirm that `[database]` points to the
intended production database, not `127.0.0.1:50007`. The file contains secrets;
do not paste it into chat or deployment logs. Confirm that `app_key` matches
the preserved production key. Then enter maintenance state:

```bash
sed -i 's/^installed[[:space:]]*=.*/installed = Off/' config.inc.php
php tools/upgrade.php upgrade
```

Run the PHP command as the application's `www-data` user so newly created
cache files retain the correct ownership. If the terminal is a root shell,
replace the PHP command above with:

```bash
su -s /bin/sh www-data -c 'php tools/upgrade.php upgrade'
```

Proceed only when the command succeeds and prints:

```text
Successfully upgraded to version 3.5.0.6
```

If it fails, retain maintenance mode and the error log. Do not run the fresh
installer, repeatedly rerun a partially failed migration, or roll back only
the image against a migrated database. Diagnose first; a recovery may require
restoring the matched database/configuration backup and previous image.

After success, restore the installed state:

```bash
sed -i 's/^installed[[:space:]]*=.*/installed = On/' config.inc.php
```

An OJS container restart/recreation runs the entrypoint again and sets
`installed = On`, so do not recreate the container in the middle of a failed
upgrade. The external maintenance gate remains necessary throughout.

Still within the maintenance window, perform the account audit and cleanup
below. Then test the journal pages, staff login, workflow, file access and
ALTCHA. Re-enable workers and public traffic only after those checks.

The new `.dockerignore` excludes `.env*`, local `config.inc.php`, private
`files`, and database dumps from the image build context. Runtime settings
must come from Dokploy and the entrypoint, not a copied development config.

Local preparation checks passed: a dummy-file Docker build excluded those
private paths while retaining the template, entrypoint, submodule metadata,
and audit SQL. Compose also resolved the preserved app key and CAPTCHA
settings from a Dokploy-style `.env` fixture. A full production-image build
and live Dokploy deployment have not been performed.

### Production account cleanup

1. Deploy and upgrade the OJS security release as above. Confirm
   that the application is connected to the intended production database.
2. Temporarily close self-registration in both journals while auditing and
   cleaning. Record the original registration settings so they can be restored.
3. Take a fresh production database backup and preserve its configuration and
   file storage. Verify that the dump can be read with `pg_restore --list`.
   Use a PostgreSQL client compatible with the production server. Keep backups
   and account reports outside the web root with restricted permissions.
4. Confirm journal IDs with `SELECT journal_id, path FROM journals;`. Run
   [the read-only candidate query](spam-user-candidates.sql) against production,
   adjusting journal IDs if necessary. Review names, affiliations, registration
   state, roles, and the relationship exclusions. Inspect any uncertain account
   separately; keep it if there is doubt.
5. Freeze the reviewed production IDs in a private manifest. Repeat the activity
   checks just before removal; omit anyone who has since validated, logged in,
   received a staff role, or acquired editorial activity. Account identity and
   roles are shared across the entire OJS site, not isolated to one journal.
6. Through OJS administration, create a neutral archive user such as
   `removed-spam-20261109` with a strong random password, a non-deliverable
   `example.invalid` email, and no staff roles. Disable the account. Do not merge
   spam into an administrator or a real author.
7. Use the supported OJS merge tool inside the production application container,
   from its application root, with explicit **production-reviewed** IDs:

   ```bash
   php tools/mergeUsers.php removed-spam-20261109 id=123 id=456
   ```

   The first argument is the account to **keep**. Subsequent arguments identify
   source accounts that will be removed. The IDs above are examples, not the
   development cleanup manifest. Start with one reviewed account, verify the
   result, then continue in manageable batches. The CLI does not provide a
   dry-run switch and a multi-user invocation is not automatically wrapped in
   one transaction. Keep a record of completed batches.
8. Merging transfers source role registrations to the archive user. Remove
   those journal memberships using OJS's user/role management and keep the
   archive disabled. Do not use a bare `DELETE FROM users` cleanup query.
9. Confirm that legitimate accounts, journal membership, submissions, authors,
   file records, reviews, decisions, and payments are intact. Test staff login
   and file access. Verify that registration invitations and sessions for removed
   users are gone. Clear OJS's application data cache through administration if
   old profiles remain visible.
10. Configure and test ALTCHA, then restore self-registration as intended.

The read-only query is deliberately specific to the observed bot pattern; it
does not identify every possible spam account. Schema differences in an older
production release require reviewing the query before use. If the live data
differs from this audit, stop and revise the manifest rather than broadening
deletion to all unvalidated users.

## Configure ALTCHA for deployment

Use the ALTCHA integration already included in OJS 3.5. Keep Google reCAPTCHA
off. OJS checks ALTCHA responses server-side for registration, login, and
password recovery when the corresponding switches are enabled.

Generate a strong random HMAC secret once in a trusted terminal, for example
with `openssl rand -hex 32`. Save it in Dokploy's Environment tab as
`OJSCONFIG_CAPTCHA_ALTCHA_HMACKEY` and preserve it across deployments. This
is a separate secret from the existing OJS `app_key`; do not reuse that key
or keep the template's `Example key`. Never commit either secret.

Set these production deployment variables in Dokploy:

```dotenv
OJSCONFIG_CAPTCHA_RECAPTCHA=Off
OJSCONFIG_CAPTCHA_ALTCHA=On
OJSCONFIG_CAPTCHA_ALTCHA_HMACKEY=YOUR_RANDOM_HMAC_SECRET
OJSCONFIG_CAPTCHA_ALTCHA_ON_REGISTER=On
OJSCONFIG_CAPTCHA_ALTCHA_ON_LOGIN=On
OJSCONFIG_CAPTCHA_ALTCHA_ON_LOST_PASSWORD=On
OJSCONFIG_EMAIL_REQUIRE_VALIDATION=On
```

`docker-compose.yml` passes these settings into the application container.
The existing entrypoint maps `OJSCONFIG_CAPTCHA_*` to `[captcha]` in
`config.inc.php` and logs setting names without their values. No Google
site/secret keys are required for ALTCHA.

For a manually managed configuration, the equivalent is:

```ini
[captcha]
recaptcha = Off
altcha = On
altcha_hmackey = "YOUR_RANDOM_HMAC_SECRET"
altcha_on_register = On
altcha_on_login = On
altcha_on_lost_password = On
```

Keep `[email] require_validation = On` in production. Email validation alone
did not prevent the bot profile clutter observed in this incident.

After deployment, test each journal's registration, login and password-recovery
forms. The ALTCHA widget should load and a valid solution should succeed;
missing, invalid and tampered responses must be rejected server-side. Verify
that legitimate staff can log in before reopening traffic. Use a controlled
test account for registration/password recovery rather than emailing existing
users. Do not enable ALTCHA with a placeholder or missing HMAC secret.

The local development configuration has not been changed: its CAPTCHA and
email-validation settings remain off for local testing with logged email.
The `On` settings above are for production. ALTCHA raises the computational
cost of automated registrations; monitor new signups after enabling it,
because it does not guarantee that every bot or human-assisted spam signup
will be blocked.

Preparation checks passed: Compose resolves all ALTCHA switches, the HMAC
secret, reCAPTCHA `Off`, email verification, and the existing app key from a
Dokploy-style `.env` fixture. An OJS validator self-check accepted a valid
solution and rejected missing and forged responses using an in-memory test
secret. A live browser challenge and production deployment remain untested.

## References

- [PKP's merge-user tool](https://github.com/pkp/pkp-lib/blob/stable-3_5_0/classes/cliTool/MergeUsersTool.php)
- [OJS CAPTCHA configuration](https://github.com/pkp/ojs/blob/3_5_0-6/config.TEMPLATE.inc.php)
- [ALTCHA](https://github.com/altcha-org/altcha)
