# Site databases and URL routing

The running Rails database is the authoritative Site Setup catalog and source of
admin navigation. The default Site Setup's `database` value is currently a label
for that catalog; it does not rename the existing database or change its connection.
New non-default setups must use unique database names on the same PostgreSQL server.
The default site continues using its original connection. Other sites use their
provisioned databases when their Site URL matches the incoming request.

## Creating a website database

1. Set `USER_PASSWORD` in the server/worker environment and restart Rails. A missing
   or blank value blocks deployment of a site needing initial user creation.
2. Give the PostgreSQL application role CREATEDB permission and permission to load
   the SQL schema, extensions, tables, and native temporal triggers. These
   permissions are checked on deployment; do not put database credentials in a
   Site Setup record.
3. Open New Site Setup. Its editable fields are copied from the live default setup
   in memory; identity, history, and the default flag are not copied. Change Site
   Name or Configuration Name (for example `jumpstart-website`), then tab or
   click out of the field. Configuration Name also sets the displayed Site Name
   to `Jumpstart Website`. The form suggests database
   `jumpstart-website`, owner `Jumpstart Website`, and appends `/jumpstart-website`
   to the original Site URL. Repeated edits replace the suffix rather than stacking
   it. Other fields remain editable. Use a valid Site Domain and the desired Guest
   User Name, then save the draft. Opening/saving the form creates no database.
4. Review and Deploy Changes. Database provisioning follows the content commit.

Each new database gets the repository's SQL schema (including native bitemporal
functions/history), but no pages, uploads, blog posts, or existing user accounts.
It receives current, non-deleted menu/footer rows whose links start with `/admin`.
Their IDs, order, settings, and hierarchy among copied rows are retained. Parent
references to uncopied public rows and references to source pages are cleared.
All current Site Setup versions and their exact native history are replicated.

Two enabled accounts are created:

- Guest: `guest@<site_domain>`, the setup's Guest User Name (or `guest` if absent),
  Regular access, no roles. Its random password is not displayed or shared.
- Administrator: `<normalized-site-name>@example.com` (for example
  `jumpstart-website@example.com`), with the Owner Name (for example
  `Jumpstart Website`), Admin access, and its password hashed from `USER_PASSWORD`
  using Devise. The plaintext password is not stored in
  the catalog, logs, status messages, or provisioning requests.

User initialization is performed only once. Retrying does not reset passwords or
replace customized users/navigation. Changing Site Name later does not rename
existing accounts or an already-managed database. Original form values are kept
only in browser memory, not in another persisted record. Change the bootstrap administrator's password
through the normal account workflow after making the new site accessible.

## Catalog synchronization

Whenever a deployment changes ANY Site Setup, the complete Site Setup catalog and
its native temporal history are synchronized to every managed site database,
including databases belonging to disabled or deleted setups. Website content and
users in those databases are not synchronized. Site Setup settings are
source-authoritative; editing a replica directly is unsupported in this phase.

This synchronization includes SMTP/CAPTCHA settings, so all managed databases and
backups must have the same trusted administrative access as the source catalog.
Synchronization is a replication operation, not a fabricated new editing event.

## Failures and retries

PostgreSQL cannot atomically CREATE DATABASE and commit content across separate
databases. A durable synchronization request is saved with the deployment before
provisioning begins. Missing USER_PASSWORD, invalid names, and existing unmanaged
databases are rejected before content is published. Later connection/initialization
failures leave a visible pending/failed status under Deploy Changes. The UI says
content was deployed but synchronization is pending, rather than claiming rollback.

Use **Retry Database Sync** to resume. Requests are serialized with publishing;
retries replicate the latest authoritative catalog. Other databases may already
have synchronized when one target fails. A site whose initialization has not
completed returns a temporary-unavailable response; it never serves the default
database as a fallback.

Databases are stamped with an ownership token in the coordinator registry and on
the target. Unrelated existing databases are never adopted or overwritten. An
interrupted schema load is rolled back; an empty, owned database can be initialized
again. A completed database that disappears must be restored from backup; it is
not silently replaced with an empty one. No operation automatically drops a site
database. Changing a provisioned database name requires a separate migration plan.

## URL matching and isolation

Site URL must be an absolute HTTP(S) URL without a query, fragment, credentials,
encoded path separators, or dot segments. Hostnames are normalized to lowercase;
a trailing slash does not change a mount. Two active setups cannot use the same
hostname and path. The URL and normalized hostname/path have database indexes.
Scheme and port do not distinguish sites. Match the hostname seen by Rails; the
router does not select a database using a client-supplied X-Forwarded-Host header.

For example:

| Site URL | Database |
| --- | --- |
| `https://paul-carrick.com` | Original application connection |
| `https://paul-carrick.com/jumpstart-server` | That setup's Database field, such as `jump-start` |

The second site also owns `/jumpstart-server/admin`, `/jumpstart-server/api`, and
all other paths below that prefix. A longer matching prefix wins. Matching respects
path boundaries: `/jumpstart-server-other` does not match `/jumpstart-server`.
Choose a distinct prefix that does not shadow an existing page, application route,
or asset directory on the parent site.

Unknown hosts and disabled sites return 404. An uninitialized, unreachable, or
outdated site database returns 503; it never falls back to another site's content.
The default setup's Database label does not rename or replace its existing connection.
Production aliases for the default site can be listed in `DEFAULT_SITE_HOSTS`
(comma-separated hostnames). Development also accepts localhost/127.0.0.1/::1. For these local hosts, the
host of the live default setup is replaced at runtime by the local request origin,
keeping each setup's path. For example, stored URLs `https://paul-carrick.com` and
`https://paul-carrick.com/jumpstart-server` work at `http://localhost:3100` and
`http://localhost:3100/jumpstart-server` without editing either setup. Scheme and
port come from the request; stored URLs remain unchanged. Setups on unrelated
production hosts are not combined into this local origin. Conflicting local paths
return 503. This substitution is disabled in production.

Admin links, forms, API calls, uploads, and internal content links retain the site's
prefix. Each site has separate login and remember-me cookies, signed upload URLs,
and background-job database context. The default site's existing cookie name is
preserved. Site Setup administration stays in the original catalog; tenant admins
cannot edit the global catalog or deploy its pending changes.

Route lists are cached in each application process for five seconds. Publishing
invalidates the local cache; other processes see changes within that interval.
Database pools are reused per process and checked against the catalog's migration
versions before first use. `SITE_DATABASE_POOL_SIZE` defaults to 5 and
`SITE_DATABASE_POOL_LIMIT` to 64 per process. Idle, unused pools may be evicted;
when all slots are busy the request fails closed. Budget PostgreSQL connections
for the number of workers and active sites. No schema migrations run during requests.

## Deployment and later schema changes

Use a maintenance window when changing schemas across databases. Back up the
catalog and every managed site database first, and rehearse against copies.

1. Stop web/worker traffic and install the release and dependencies.
2. Migrate the original application database:
   `RAILS_ENV=production bundle exec rails db:migrate`.
3. Migrate every initialized managed database:
   `RAILS_ENV=production bundle exec rails site_databases:migrate`.
4. Build production assets with your normal deployment command, then restart all
   application and worker processes. Keep `USER_PASSWORD` configured for new sites.
5. Verify the default site and each configured prefix, login, admin editing, uploads,
   and a preview/deployment before reopening traffic.

The managed migration task verifies ownership before opening each target, applies
pending migrations, and reports failures. Details are written to restricted files
at `log/site-database-migration-<id>.log`. It does not replace the repository's
canonical SQL schema with a tenant schema. A failed target must be repaired and
migrated before serving it; do not bypass the version check. Uninitialized owned
databases are initialized through Retry Database Sync instead.

Provisioning and routing tests create uniquely named disposable PostgreSQL databases
and never clone live user data. A populated migration rehearsal is available with
`RAILS_ENV=test bundle exec rails runner script/verify_temporal_migration.rb`.
